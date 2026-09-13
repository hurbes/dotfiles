const { MarkdownView, Plugin } = require("obsidian");

const MIN = 0.5;
const MAX = 3;

function clamp(scale) {
  return Math.max(MIN, Math.min(MAX, scale));
}

function naturalSize(svg) {
  const vb = svg.viewBox && svg.viewBox.baseVal;
  if (vb && vb.width > 0 && vb.height > 0) {
    return { width: vb.width, height: vb.height };
  }
  const width = parseFloat(svg.getAttribute("width") || "");
  const height = parseFloat(svg.getAttribute("height") || "");
  if (width > 0 && height > 0) {
    return { width, height };
  }
  return null;
}

function applyScale(block, scale) {
  const svg = block.querySelector("svg");
  if (!svg) {
    return;
  }
  const natural = naturalSize(svg);
  if (!natural) {
    return;
  }
  const next = clamp(scale);
  if (next === 1) {
    svg.style.width = "";
    svg.style.height = "";
    svg.style.maxWidth = "";
    delete block.dataset.mzScale;
    block.classList.remove("mermaid-zoom-scaled");
    return;
  }
  svg.style.maxWidth = "none";
  svg.style.width = `${Math.round(natural.width * next)}px`;
  svg.style.height = `${Math.round(natural.height * next)}px`;
  block.dataset.mzScale = String(next);
  block.classList.add("mermaid-zoom-scaled");
}

function readScale(block) {
  const parsed = parseFloat(block.dataset.mzScale || "");
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 1;
}

module.exports = class MermaidZoomPersist extends Plugin {
  async onload() {
    this.store = Object.assign({ scales: {} }, await this.loadData());
    this.seen = new WeakSet();
    this.dirty = false;
    this.scanTimer = 0;

    this.observer = new MutationObserver(() => this.queueScan());
    this.observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ["data-mz-scale"],
    });

    this.registerEvent(
      this.app.workspace.on("layout-change", () => this.queueScan()),
    );
    this.registerEvent(
      this.app.workspace.on("file-open", () => this.queueScan()),
    );
    this.registerInterval(window.setInterval(() => void this.flush(), 400));
    this.app.workspace.onLayoutReady(() => this.queueScan());
  }

  onunload() {
    this.observer.disconnect();
    if (this.scanTimer) {
      window.clearTimeout(this.scanTimer);
    }
    void this.flush();
  }

  queueScan() {
    if (this.scanTimer) {
      window.clearTimeout(this.scanTimer);
    }
    this.scanTimer = window.setTimeout(() => this.scan(), 80);
  }

  scan() {
    this.app.workspace.iterateAllLeaves((leaf) => {
      const view = leaf.view;
      if (!(view instanceof MarkdownView) || !view.file) {
        return;
      }
      const blocks = Array.from(view.containerEl.querySelectorAll(".mermaid"));
      for (let i = 0; i < blocks.length; i += 1) {
        const block = blocks[i];
        if (!block.querySelector("svg")) {
          continue;
        }
        const key = `${view.file.path}:${i}`;
        const live = readScale(block);
        const saved = this.store.scales[key];

        if (!this.seen.has(block)) {
          this.seen.add(block);
          if (typeof saved === "number" && saved !== 1) {
            applyScale(block, saved);
          }
          continue;
        }

        if (live === 1) {
          if (key in this.store.scales) {
            delete this.store.scales[key];
            this.dirty = true;
          }
          continue;
        }

        if (this.store.scales[key] !== live) {
          this.store.scales[key] = live;
          this.dirty = true;
        }
      }
    });
  }

  async flush() {
    if (!this.dirty) {
      return;
    }
    this.dirty = false;
    await this.saveData(this.store);
  }
};
