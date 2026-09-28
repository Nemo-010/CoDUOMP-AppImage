<div align="center">

# CoDUOMP-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/Nemo-010/CoDUOMP-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/Nemo-010/CoDUOMP-AppImage/releases/latest)
[![CI Build Status](https://github.com/Nemo-010/CoDUOMP-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/Nemo-010/CoDUOMP-AppImage/releases/latest)
[![Latest Stable Release](https://img.shields.io/github/v/release/Nemo-010/CoDUOMP-AppImage)](https://github.com/Nemo-010/CoDUOMP-AppImage/releases/latest)

<p align="center">
  <img src="./opencoduo.png" width="128" />
</p>

| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/Nemo-010/CoDUOMP-AppImage/releases/latest) | [Click here](https://github.com/opencoduo/coduomp) |

</div>

---

Unofficial AppImage of [Open CoD:UO](https://github.com/opencoduo/coduomp), an open-source client for **Call of Duty: United Offensive** multiplayer.

The icon is upstream's own `assets/coduomp-icon-master.png`, resized to 512x512.

AppImage made using [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks.

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed, you will be prompted for permission to check for updates and if agreed you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

## Retail game data is required

This AppImage contains the client engine and its modules only. **Call of Duty: United Offensive must already be installed**, because the engine reads your existing game data in place and does not copy it.

On first launch the launcher looks for a retail root containing both `main/pak0.pk3` and `uo/pakuo00.pk3`:

1. the `CODUOMP_DATA_PATH` environment variable, if set;
2. a previously saved path;
3. Steam app **2640**, across all configured Steam libraries.

If nothing is found, set the path explicitly:

```sh
CODUOMP_DATA_PATH="$HOME/.steam/steam/steamapps/common/Call of Duty United Offensive" \
  ./CoDUOMP-x86_64.AppImage
```

You can also write it once into `~/.config/opencoduo/data-path`.

Configuration, logs, downloads and screenshots live in `~/.local/share/opencoduo` (or `$XDG_DATA_HOME/opencoduo`), never inside the AppImage.

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
