# NovaStudio Installer

A modular Bash installer for Fedora that configures a purpose-built creative workstation. Choose from Gaming, Audio Production, Media Production, or a full creator suite — only the tools you need get installed.

---

## Requirements

- **OS:** Fedora 42 or later (tested up to Fedora 43)
- **Privileges:** Must be run with `sudo`
- **Internet:** Active connection required for package downloads

---

## Quick Start

```bash
sudo bash install.sh
```

You will be prompted to choose an installation profile (see below).

---

## Profiles

| # | Profile | What gets installed |
|---|---------|---------------------|
| 1 | **Gaming** | Steam, Lutris, Heroic, Wine, MangoHud, GameMode, GameScope, ProtonUp-Qt, Discord, controller support |
| 2 | **Audio Production** | PipeWire (low-latency), JACK2, ALSA tools, LV2/LADSPA plugin framework, Focusrite Scarlett/Clarett driver config |
| 3 | **Media Production** | FFmpeg, OBS Studio, Blender, Kdenlive, VLC, GStreamer codecs |
| 4 | **Full Creator Studio** | Everything from all three profiles above |

> If you enter an unrecognised option the installer defaults to **Full Creator Studio**.

---

## Project Structure

```
.
├── install.sh              # Entry point
└── lib/
│   └── common.sh           # Shared helpers (logging, install_pkg, banner)
└── modules/
    ├── hardware.sh         # CPU/GPU/audio hardware detection
    ├── profile.sh          # Profile selection prompt
    ├── gpu.sh              # GPU driver installation (NVIDIA / AMD / Intel)
    ├── audio.sh            # PipeWire, JACK, Focusrite, audio groups
    ├── gaming.sh           # Gaming tools and launchers
    ├── wine.sh             # Wine + Winetricks
    ├── media.sh            # Media creation tools
    └── optimisations.sh    # RPM Fusion repos, system update, GameMode polkit rule
```

---

## What the Installer Does

### On every run
- Enables **RPM Fusion** (free + nonfree) repositories
- Runs a full **system update** via `dnf upgrade`
- Detects CPU, GPU vendor, and connected USB audio devices

### GPU drivers (`gpu.sh`)
- **NVIDIA** — installs `akmod-nvidia` and CUDA drivers via RPM Fusion
- **AMD** — installs Mesa Vulkan and DRI drivers
- **Intel** — installs `intel-media-driver` and Mesa Vulkan drivers

### Audio profile (`audio.sh`)
- Removes PulseAudio if present and replaces it with the full **PipeWire** stack
- Writes a low-latency PipeWire config (`/etc/pipewire/pipewire.conf.d/99-novastudio-rt.conf`) targeting 32-sample quanta at 48 kHz
- Writes a WirePlumber ALSA tuning config with suspend timeout disabled
- Installs **Focusrite Scarlett/Clarett** kernel module options and udev rules (driver is built into Linux 5.14+)
- Adds the current user to the `audio`, `jackuser`, and `realtime` groups
- Enables PipeWire and WirePlumber as global user services

### Gaming profile (`gaming.sh`)
- Installs native packages via `dnf` (Steam, Lutris, MangoHud, GameMode, GameScope, Wine)
- Installs Flatpak apps from Flathub (Heroic Games Launcher, ProtonUp-Qt, Discord)
- Configures the `xpad` kernel module to load at boot for Xbox controller support

### Optimisations (`optimisations.sh`)
- Writes a **polkit rule** granting the `gamemode` group permission to call `cpugovctl` for CPU governor switching without a password prompt

---

## Logs

The installer logs all activity to:

```
/var/log/novastudio-installer.log
```

---

## Post-Install Notes

- **NVIDIA users:** The `akmod-nvidia` module will build on first boot. Allow a few minutes before the display driver is active.
- **Audio users:** Log out and back in after installation so group membership (`audio`, `realtime`) takes effect. PipeWire services will start automatically on next login.
- **Focusrite users:** No third-party driver is needed on Linux 5.14+. The installer sets kernel module options and udev rules for full Scarlett Gen 2/3/4 and Clarett USB/+ feature access.
- **Gaming users:** After installation, run ProtonUp-Qt to install the latest GE-Proton build for best compatibility.

---

## Troubleshooting

**"Run installer using sudo"** — The script must be executed with `sudo bash install.sh`, not as a regular user.

**A package failed to install** — Non-fatal failures are logged with `[SKIP]` or `ERROR:` markers in the log file. The installer continues past individual package failures rather than aborting entirely.

**GameMode service won't start** — `gamemoded.service` is a user service. If it fails during install (common when running under sudo), enable it manually after logging in: `systemctl --user enable --now gamemoded.service`

**PipeWire not starting** — Ensure you've logged out and back in. Check `systemctl --user status pipewire` and review `/var/log/novastudio-installer.log` for errors.
