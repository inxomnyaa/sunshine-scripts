# sunshine-scripts

Helpers for streaming a GNOME (Wayland) desktop with [Sunshine](https://github.com/LizardByte/Sunshine) (Flatpak) to [Moonlight](https://moonlight-stream.org/):

- **`sunshine-res`**: switches the monitor to fit the connecting device while a stream runs, then restores it.
- **`sunshine-add`**: adds an installed app or a Steam game to Sunshine, with a generated cover image.
- **`covers/cover.sh`**: renders 600×800 Moonlight covers in one consistent style.

Built for Sunshine as a **Flatpak** on **GNOME**. Every command reaches the host through `flatpak-spawn --host`.

## Requirements

- Sunshine Flatpak (`dev.lizardbyte.app.Sunshine`)
- [`displayconfig-mutter`](https://github.com/eaglesemanation/displayconfig-mutter) on the host (`sunshine-res`)
- ImageMagick 7 (`magick`) and fontconfig (covers)
- [`gum`](https://github.com/charmbracelet/gum) and Python 3 (`sunshine-add`)

## Install

```sh
./install.sh
```

The script copies `bin/*` to `~/.local/bin` and `covers/*` to `~/.local/share/sunshine-covers`. It never overwrites files that already exist.

## sunshine-res

```sh
sunshine-res apply [W H FPS]   # fit the monitor to the client (defaults to SUNSHINE_CLIENT_* env)
sunshine-res fixed WxH [SCALE] # fixed mode, e.g. 1280x720 100
sunshine-res restore           # back to your normal settings
```

- **`apply`** picks the monitor mode closest to the client's aspect ratio. It then sets the UI scale so the desktop is about 720 logical pixels tall, which keeps text readable on a phone.
- **`fixed`** uses the highest refresh rate available for that mode.

The monitor connector is detected automatically.

**Set your normal monitor settings** at the top of the script, or through environment variables:

| Variable | Default | Meaning |
|---|---|---|
| `SUNSHINE_RES_NATIVE_MODE` | `3440x1440` | resolution to restore |
| `SUNSHINE_RES_NATIVE_HZ` | `165` | refresh rate to restore |
| `SUNSHINE_RES_NATIVE_SCALE` | `125` | UI scale (%) to restore |
| `SUNSHINE_RES_TARGET_HEIGHT` | `720` | logical height `apply` aims for |

**Why it waits after each switch:** mutter applies display modes asynchronously, and a refresh-rate change makes the monitor re-sync. If Sunshine starts capturing in the middle of a switch, the XDG portal stream never starts. Moonlight then shows *"no video received"*, Sunshine hangs, and GNOME asks for screen-share permission again. So `sunshine-res` waits until mutter reports the new mode, then gives the monitor 3 seconds to settle.

Add it to an app's `prep-cmd` in Sunshine's `apps.json` (see [`examples/apps.json`](examples/apps.json)):

```json
"prep-cmd": [{
  "do": "sh -c \"flatpak-spawn --host /home/YOU/.local/bin/sunshine-res apply ${SUNSHINE_CLIENT_WIDTH} ${SUNSHINE_CLIENT_HEIGHT} ${SUNSHINE_CLIENT_FPS}\"",
  "undo": "flatpak-spawn --host /home/YOU/.local/bin/sunshine-res restore"
}]
```

`flatpak-spawn --host` doesn't forward Sunshine's environment variables. That's why the client size is passed as arguments.

## sunshine-add

```sh
sunshine-add                         # interactive: "Installed app" or "Steam game"
sunshine-add steam <appid>           # add a Steam game with defaults
sunshine-add desktop <file.desktop>  # add a .desktop app with defaults
```

1. You choose an app from your `.desktop` entries (user, Flatpak and system) or a game from your Steam library. Both lists are searchable.
2. You set the name and decide whether the stream should fit the monitor to the client.
3. For installed apps, you decide whether the stream ends when the app closes.
4. It creates the cover from one of three sources:
   - **Generated**: the app icon on a gradient tinted with the icon's colour.
   - **Steam box art**: taken from Steam's local library cache.
   - **[SteamGridDB](https://www.steamgriddb.com/)**: the first time, it asks for a free API key and saves it to `~/.config/steamgriddb/api_key`.
5. It writes the entry to Sunshine's `apps.json`. An app with the same name is updated, and a backup is kept as `apps.json.before-add`.
6. It offers to restart Sunshine through its systemd user service.

### Moonlight app order

Moonlight sorts apps alphabetically and has no setting for that. To pin apps to the top, start their names with spaces: `"  Desktop"` sorts before `" Something"`, which sorts before `"Anything"`.

## covers

`cover.sh` provides `cover` (icon + label on a tinted gradient) and `steamcover` (portrait art cropped to 600×800). `sunshine-add` records each generated cover in `make-covers.sh`, so you can re-render all of them later.

## Notes

- **Share-screen dialog keeps coming back:** Sunshine's Flatpak captures the screen through the XDG portal. Each GNOME restore token works only once, so a crash or a force-kill (`flatpak kill`) costs you the saved permission. Set `encoder = nvenc` (or the one encoder that works on your GPU) in `sunshine.conf`, so the startup checks open fewer portal sessions, and stop Sunshine with SIGTERM rather than SIGKILL.
- **Moonlight over Tailscale:**
  - Add the PC in Moonlight by its Tailscale IP.
  - Make sure Moonlight isn't excluded in the Tailscale Android app's split tunneling.
  - Allow `41641/udp` in the PC firewall, so Tailscale can hold a direct connection instead of falling back to a relay.

## License

MIT
