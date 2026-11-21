# caelestia-shell-mangowm (WIP)

**Work in progress.** Raw port of [Caelestia shell](https://github.com/caelestia-dots/shell) to MangoWM/MangoWC, replacing the previous custom Quickshell in `stylish-dots-nextgen`.

## Status

- Caelestia QML base imported and adapted with MangoWM compatibility shims.
- Drawers/launcher/dashboard/OSD/bar partially work on live MangoWM session.
- Many components still need MangoWM data/parity fixes (workspaces, active window, tray, notifications, settings binds, Matugen, lockscreen, background).
- `Background {}` is currently disabled in `quickshell/shell.qml` due MangoWM crash - needs isolation/fix.

## Attribution / License

- Original Caelestia shell: https://github.com/caelestia-dots/shell
- Caelestia/Quickshell components are licensed under **GPL-3.0** (see `LICENSE` and `quickshell/CAELESTIA-LICENSE`).
- This fork/adaptation: stylishlasher/stylish-dots-nextgen contributors, MangoWM integration changes.

## Live install (dev)

```bash
ln -sfn "$PWD/quickshell" ~/.config/quickshell/stylish
mkdir -p ~/.local/bin
cp -a scripts/stylish-shell ~/.local/bin/
stylish-shell restart
```

## Notes

This is a raw checkpoint before system reinstall. Expect rough edges and incomplete MangoWM parity.
