# Dotfiles

Mac configs I actually use. Ghostty for the terminal, AeroSpace for tiling, Oh My Zsh, and an Obsidian theme sampled from Ghostty's default dark palette so the two don't look like they came from different decades.

## Screenshots

Ghostty, then Obsidian. Same palette, same font, same tab shape.

<p align="center">
  <img src="screenshots/ghostty-terminal.jpg" alt="Ghostty terminal" width="900">
</p>
<p align="center"><em>Ghostty. MonoLisa, block cursor, title still says Mac OS X Terminal.</em></p>

<p align="center">
  <img src="screenshots/obsidian-window.jpg" alt="Obsidian with the Ghostty theme" width="900">
</p>
<p align="center"><em>Obsidian. Ribbon gone, tabs like Ghostty, wallpaper only as a tint.</em></p>

## What's here

- `ghostty/config` is the terminal. MonoLisa, no ligatures, block cursor, a little blur.
- `aerospace.toml` is letter workspaces and i3-style keys. Alt-enter opens Ghostty. New windows get shoved onto a workspace instead of spawning on top of whatever I was doing.
- `zsh/` is Oh My Zsh with robbyrussell, a big history, and fzf-tab so Tab is a fuzzy finder instead of a menu.
- `obsidian/` is the Ghostty theme, a chrome snippet that hides the ribbon, and the plugin settings that make the window feel closer to the terminal.
- `borders/bordersrc` is JankyBorders. AeroSpace starts it so the focused window has a ring.
- `vorssaint/Vorssaint Settings.plist` is a Vorssaint settings backup. Shortcuts, menu bar meters, screenshot keys, that kind of thing. Not clipboard history, not Scratchpad notes.

MonoLisa is a paid font. Both Ghostty and Obsidian name it. If you don't have it, change the font lines.

## Install

Clone the repo, then run the script. It symlinks the files into place and copies Obsidian bits only if you point it at a vault.

```bash
git clone https://github.com/hurbes/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
./install.sh --vault ~/Documents/YourVault
```

Existing files get a `.bak` suffix. The script does not touch your notes.

Apps and CLI tools from Homebrew:

```bash
brew bundle
```

Oh My Zsh is separate. Install that first, then rerun `./install.sh` so it can clone fzf-tab, zsh-autosuggestions, and zsh-syntax-highlighting. You also want `fzf`, `zoxide`, and `eza` on PATH, which the Brewfile covers.

In Obsidian, install Hider, Lacewing, Style Settings, and Mermaid Zoom from the community list. `mermaid-zoom-persist` is a small local plugin in this repo, so the copy step is enough.

Vorssaint is imported from inside the app, not by the script. Open Settings, Advanced, Import settings, and pick `vorssaint/Vorssaint Settings.plist`. It restarts the app. Clipboard history and Scratchpad stay on the old Mac.

## Workspaces

I skip H, J, K, and L because those keys move focus.

| Key | What I put there |
| --- | --- |
| B | browsers |
| D | Docker |
| G | Ghostty |
| I | Imark |
| N | Obsidian |
| W | WhatsApp |

The rest are free. Alt plus the letter jumps to it. Alt-shift plus the letter takes the current window with you.

## A couple of opinions

I kept the Ghostty title "Mac OS X Terminal" because I think it's funny. The padding and cell height are fussy on purpose. Default Ghostty feels a bit tight on a Retina screen.

Obsidian translucency is easy to overdo. The theme uses a high alpha so you get a tint of the wallpaper, not the wallpaper showing through your notes. The snippet keeps blur off the editor scroller. Blur on that layer made scrolling flicker.

LiveSync is not in this repo. That's a private sync setup and it does not belong on GitHub.
