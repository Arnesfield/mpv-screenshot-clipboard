# mpv-screenshot-clipboard

Take a screenshot and copy the image file to clipboard (uses `xclip` and `wl-copy`).

## Requirements

- Requires [mpv](https://mpv.io/).
- Requires `file` in `PATH` to get the image file mime type.
- Requires `xclip` (or `wl-copy` for Wayland) in `PATH` to copy image files to clipboard.

## Install

1. You can clone this repository under your `scripts` directory (e.g., `~/.config/mpv/scripts`).

   ```sh
   git clone git@github.com:Arnesfield/mpv-screenshot-clipboard.git screenshot-clipboard
   ```

2. (optional) Save [`screenshot-clipboard.conf`](screenshot-clipboard.conf) to `script-opts` directory.

   ```sh
   wget github.com/Arnesfield/mpv-screenshot-clipboard/raw/main/screenshot-clipboard.conf
   ```

3. Add the following keybindings to `input.conf` to replace the default screenshot keybindings:

   ```conf
   s script-message screenshot-clipboard
   S script-message screenshot-clipboard video
   ctrl+s script-message screenshot-clipboard window
   alt+s script-message screenshot-clipboard each-frame
   ```

## Config

List of configuration options ([`screenshot-clipboard.conf`](screenshot-clipboard.conf)).

### disable_osd_messages

Disables OSD messages by log level. Comma-separated values of: `info`, `error`

Example:

```conf
disable_osd_messages=info,error
```

## License

Licensed under the [MIT License](LICENSE).
