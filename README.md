# NovаStudio OS

```
  ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ███████╗████████╗██╗   ██╗██████╗ ██╗ ██████╗
  ████╗  ██║██╔═══██╗██║   ██║██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔═══██╗
  ██╔██╗ ██║██║   ██║██║   ██║███████║███████╗   ██║   ██║   ██║██║  ██║██║██║   ██║
  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║╚════██║   ██║   ██║   ██║██║  ██║██║██║   ██║
  ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║███████║   ██║   ╚██████╔╝██████╔╝██║╚██████╔╝
  ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝
```

**Version 2.1 | Architect Edition**

> A single-script Fedora transformer that turns a fresh Fedora install into a fully tuned
> media production, audio engineering, gaming, and Windows-app-compatible workstation.
> One script. One reboot. Everything works.

---

## Table of Contents

1. [What Is This?](#1-what-is-this)
2. [What Does It Install?](#2-what-does-it-install)
3. [Requirements](#3-requirements)
4. [Pre-Installation: Installing Fedora](#4-pre-installation-installing-fedora)
5. [Installing NovаStudio OS](#5-installing-novastudio-os)
6. [Post-Install Setup](#6-post-install-setup)
7. [Running Individual Modules](#7-running-individual-modules)
8. [Daily Use Reference](#8-daily-use-reference)
9. [Focusrite Setup Guide](#9-focusrite-setup-guide)
10. [Yabridge & Windows VST Guide](#10-yabridge--windows-vst-guide)
11. [Gaming Guide](#11-gaming-guide)
12. [Theme Customisation](#12-theme-customisation)
13. [Troubleshooting](#13-troubleshooting)
14. [FAQ](#14-faq)
15. [Uninstalling](#15-uninstalling)

---

## 1. What Is This?

NovаStudio OS is **not** a separate Linux distro. It is a comprehensive Bash script that
you run on top of a standard Fedora installation. It auto-detects your hardware and
configures everything you need for:

- 🎬 **Video & media production** — Kdenlive, OBS, Blender, DaVinci Resolve prep
- 🎵 **Audio production** — PipeWire, JACK, Ardour, Carla, VST/LV2 plugins
- 🎧 **Focusrite interfaces** — Scarlett, Clarett USB/Thunderbolt, full driver support
- 🪟 **Windows app compatibility** — Wine Staging, DXVK, VKD3D-Proton
- 🎛️ **Windows VST plugins** — yabridge bridges your Windows plugins into Linux DAWs
- 🎮 **Gaming** — Steam, Lutris, Proton-GE, GameMode, MangoHud, controllers
- 🖥️ **Low-latency performance** — realtime kernel, tuned scheduler, RT limits
- 🎨 **Customisable themes** — one-command theme switcher, Papirus icons

Everything is automated. You answer a few prompts, go make a cup of tea, and come back to
a fully configured production workstation.

---

## 2. What Does It Install?

### Core System
| Component | Details |
|---|---|
| Kernel | `kernel-rt` (realtime) or `kernel-lts` fallback |
| Audio server | PipeWire (replaces PulseAudio) + JACK2 |
| Package repos | RPM Fusion Free + Non-Free, Flathub |
| CPU governor | `performance` (desktop) / `schedutil` (laptop) |
| I/O scheduler | `none` (NVMe) / `mq-deadline` (SSD) / `bfq` (HDD) |

### GPU Drivers (auto-detected)
| GPU | Driver |
|---|---|
| NVIDIA | `akmod-nvidia` (stable, kernel-module auto-rebuilds) |
| AMD | `amdgpu` + Mesa + ROCm (optional) |
| Intel | `intel-media-driver` + Mesa + VA-API |

### Audio Production
| App | Purpose |
|---|---|
| Ardour | Professional DAW |
| Audacity | Audio editor / recorder |
| Carla | Plugin host (VST2/VST3/LV2/LADSPA/CLAP) |
| QJackCtl | JACK patchbay GUI |
| Calf Studio | LV2 plugin suite |
| a2jmidid | ALSA → JACK MIDI bridge |
| zita-njbridge | Networked JACK |

### Media Production
| App | Purpose |
|---|---|
| Kdenlive | Video editor (NLE) |
| OBS Studio | Recording & streaming |
| Blender | 3D / VFX / video editing |
| GIMP | Photo / image editor |
| Krita | Digital painting |
| Inkscape | Vector graphics |
| RawTherapee | RAW photo processing |
| FFmpeg | Universal media converter |

### Windows Compatibility
| Component | Purpose |
|---|---|
| Wine Staging | Windows app compatibility layer |
| DXVK | DirectX 9/10/11 → Vulkan translation |
| VKD3D-Proton | DirectX 12 → Vulkan translation |
| winetricks | Wine component installer |
| yabridge | Windows VST/VST3/CLAP → Linux bridge |
| yabridgectl | yabridge management tool |
| Bottles | GUI Wine prefix manager |

### Gaming
| Component | Purpose |
|---|---|
| Steam | Primary gaming platform |
| Proton | Windows game compatibility in Steam |
| ProtonPlus | Proton-GE version manager |
| Lutris | Universal game manager |
| Heroic | Epic / GOG / Amazon game launcher |
| GameMode | CPU/GPU boost during gaming |
| MangoHud | In-game performance overlay |
| vkBasalt | In-game post-processing (sharpening) |
| GameScope | Micro-compositor (resolution lock) |
| RetroArch | Multi-system emulator |
| Dolphin | GameCube / Wii emulator |
| RPCS3 | PlayStation 3 emulator |
| xemu | Original Xbox emulator |
| PPSSPP | PSP emulator |
| mGBA | Game Boy Advance emulator |
| xpadneo | Advanced Xbox wireless controller driver |
| Sunshine/Moonlight | Local game streaming |

---

## 3. Requirements

### Minimum Hardware
| Component | Minimum | Recommended |
|---|---|---|
| CPU | 4 cores / any x86_64 | 8+ cores |
| RAM | 8 GB | 16 GB+ |
| Storage | 50 GB free | 100 GB+ free (SSD/NVMe strongly recommended) |
| GPU | Any supported | NVIDIA RTX / AMD RX 6000+ |
| Internet | Required | Broadband (several GB of downloads) |

### Software Requirements
- **Fedora Linux 39, 40, or 41** (fresh install recommended)
- Internet connection
- `sudo` / root access

> ⚠️ **Do not run on an existing production system without reading the backup section.**
> The script backs up key config files but modifies the kernel, GRUB, and system settings.

---

## 4. Pre-Installation: Installing Fedora

If you already have Fedora installed, skip to [Section 5](#5-installing-novastudio-os).

### Step 1 — Download Fedora

Go to [https://fedoraproject.org/workstation/download](https://fedoraproject.org/workstation/download)
and download the latest **Fedora Workstation** ISO (Fedora 41 or newer recommended).

> 💡 **Which edition?** Choose **Fedora Workstation** (GNOME). The script supports KDE
> Plasma too, but GNOME is best tested. If you prefer KDE, download Fedora KDE Spin from
> [https://spins.fedoraproject.org](https://spins.fedoraproject.org).

### Step 2 — Create a Bootable USB

**On Windows:**
1. Download [Rufus](https://rufus.ie) or [Ventoy](https://ventoy.net)
2. Plug in a USB drive (8 GB minimum — all data will be erased)
3. Open Rufus → select your ISO → click Start
4. When asked about ISO mode, choose **DD Image mode**

**On Linux/macOS:**
```bash
# Find your USB device (look for /dev/sdX or /dev/diskN)
lsblk           # Linux
diskutil list   # macOS

# Write the ISO (replace /dev/sdX with your USB device — double-check this!)
sudo dd if=Fedora-Workstation-Live-x86_64-41-1.4.iso of=/dev/sdX bs=4M status=progress
sync
```

**Using GNOME Disks (GUI — Linux):**
1. Open **Disks** application
2. Select your USB drive
3. Click the ⋮ menu → **Restore Disk Image**
4. Select the Fedora ISO → Start Restoring

### Step 3 — Boot from USB

1. Plug the USB into your computer
2. Restart and enter your BIOS/UEFI (usually **F2**, **F12**, **Delete**, or **Esc** at boot)
3. In the boot menu, select your USB drive
4. Choose **Start Fedora Workstation Live**

### Step 4 — Install Fedora

1. Click **Install to Hard Drive**
2. Choose your language and keyboard layout
3. **Storage Configuration:**
   - For a new/dedicated machine: select your drive → **Automatic** partitioning
   - For dual-boot with Windows: select **Custom** and create partitions manually
     - EFI partition: 512 MB (if not already existing)
     - `/` (root): 50 GB minimum (100 GB+ recommended)
     - `/home`: remaining space
4. Set your timezone
5. Click **Begin Installation**
6. Set your **root password** and create your **user account** (make it an Administrator)
7. Wait for installation to complete (~10–20 minutes)
8. Click **Finish Installation** → **Restart Now**
9. Remove the USB when prompted

### Step 5 — First Boot

1. Complete the Fedora initial setup wizard
2. Sign in with the user account you created
3. Open a terminal (press the **Super/Windows key**, type `terminal`, press Enter)
4. Run a quick system update before anything else:

```bash
sudo dnf upgrade --refresh -y
sudo reboot
```

After the reboot, you're ready for NovаStudio OS.

---

## 5. Installing NovаStudio OS

### Step 1 — Get the Script

Open a terminal and download the script using one of these methods:

**Method A — Direct download (simplest):**
```bash
# Download the script to your home folder
curl -Lo ~/novastudio-setup.sh https://your-host/novastudio-setup.sh

# Or if you have the file on a USB drive, copy it:
cp /run/media/$USER/YOUR_USB/novastudio-setup.sh ~/novastudio-setup.sh
```

**Method B — If you received the file directly:**
```bash
# Move it to your home directory if needed
mv ~/Downloads/novastudio-setup.sh ~/novastudio-setup.sh
```

### Step 2 — Make It Executable

```bash
chmod +x ~/novastudio-setup.sh
```

### Step 3 — Verify the Script (Optional but Recommended)

Before running any script as root, it's good practice to read it first:

```bash
# Open in a text editor to review
less ~/novastudio-setup.sh

# Or check the line count — should be ~1950 lines
wc -l ~/novastudio-setup.sh
```

### Step 4 — Run the Script

```bash
sudo bash ~/novastudio-setup.sh
```

> ⚠️ The script **must be run with sudo**. It will immediately check for root access and
> refuse to continue without it.

### Step 5 — The Interactive Wizard

The script will display a welcome screen like this:

```
  ███████╗ NovаStudio OS ████████╗
  ══════════════════════════════════
  Version 2.1 | Architect Edition

  What will be installed:
    [1]  Hardware auto-detection & driver selection
    [2]  Low-latency / realtime kernel + system tuning
    [3]  GPU drivers (NVIDIA / AMD / Intel — auto-detected)
    ...
    [10] 🎮 Gaming: Steam, Lutris, GameMode, MangoHud, controllers

  Begin NovаStudio OS installation? [Y/n]:
```

**Answer the prompts:**

| Prompt | Recommended Answer |
|---|---|
| Begin installation? | `Y` (Enter) |
| Installation mode [F/c] | `F` (Full — recommended for first time) |
| Reboot now? | `Y` (Enter) |

For a custom install, type `C` at the mode prompt to pick individual modules.

### Step 6 — Wait for Completion

The installation takes **20–60 minutes** depending on your internet speed and hardware.
You will see a live progress display. The script is entirely non-destructive of your
personal files — it only modifies system configuration files (all backed up).

When it finishes you will see:

```
  ╔══════════════════════════════════════════════════════════════╗
  ║  🚀  NovаStudio OS Setup Complete!                           ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  ✅  No errors encountered — clean install!                  ║
  ...
```

### Step 7 — Reboot

The script will ask if you want to reboot. Say yes. **The reboot is required** — the new
kernel, udev rules, audio groups, and environment variables all need a fresh boot to take
effect.

```bash
# If you skipped the reboot prompt, do it manually:
sudo reboot
```

---

## 6. Post-Install Setup

After your first reboot into NovаStudio OS:

### Verify Audio is Working

```bash
# Check PipeWire is running
systemctl --user status pipewire pipewire-pulse wireplumber

# Should all show: Active: active (running)
```

Open the **Sound** settings panel and confirm your devices appear. If you have a
Focusrite connected, plug it in now — it should appear automatically.

### Verify Gaming Stack

```bash
# Check Vulkan is available
vulkaninfo --summary

# Check GameMode is running
gamemoded -t

# Launch Steam and let it update
steam
```

### Install Proton-GE (Strongly Recommended for Gaming)

1. Open **ProtonPlus** (search in your app launcher)
2. Click **Install** next to the latest **GE-Proton** version
3. In Steam → Settings → Compatibility → tick **Enable Steam Play for all other titles**
4. Select **GE-Proton** (latest) as your default

### Set Up yabridge for Windows VSTs

See the full guide in [Section 10](#10-yabridge--windows-vst-guide).

### First-Time JACK Configuration

1. Open **QJackCtl** from your app launcher
2. Click **Setup**
3. Set:
   - **Driver**: `alsa`
   - **Sample Rate**: `48000` (or `44100` for legacy projects)
   - **Frames/Period**: `64` (increase to `128` or `256` if you get xruns)
   - **Periods/Buffer**: `2`
4. Click **OK** → **Start**

---

## 7. Running Individual Modules

You can re-run any part of the setup independently. Useful if:
- You want to add gaming to an existing install
- Something failed the first time
- You added new hardware

```bash
# Full wizard (interactive)
sudo bash ~/novastudio-setup.sh

# Full unattended install (no prompts)
sudo bash ~/novastudio-setup.sh --full

# Only set up audio (PipeWire + JACK + Focusrite)
sudo bash ~/novastudio-setup.sh --audio-only

# Only set up gaming stack
sudo bash ~/novastudio-setup.sh --gaming-only

# Only install Wine + yabridge
sudo bash ~/novastudio-setup.sh --wine-only

# Only configure desktop themes
sudo bash ~/novastudio-setup.sh --themes-only

# Just run hardware detection and print a report
sudo bash ~/novastudio-setup.sh --detect

# Show help
sudo bash ~/novastudio-setup.sh --help
```

---

## 8. Daily Use Reference

### Quick Help

```bash
novastudio-info
```

Prints a colour-coded reference card with all important commands.

### Theme Switcher

```bash
novastudio-theme dark       # Dark theme (default)
novastudio-theme light      # Light theme
novastudio-theme nordic     # Nordic dark theme (install separately)
novastudio-theme catppuccin # Catppuccin Mocha theme (install separately)
novastudio-theme list       # Show all available themes
```

### Audio Commands

```bash
qjackctl          # Open JACK patchbay / control
carla             # Open Carla plugin host
ardour6           # Open Ardour DAW
yabridgectl sync  # Sync Windows VST plugins with yabridge
yabridgectl status # Check plugin status
```

### Gaming Commands

```bash
steam                          # Launch Steam
lutris                         # Launch Lutris
game-launch <executable>       # Launch any game with GameMode + MangoHud
gamemoderun %command%          # Prefix for Steam launch options
mangohud %command%             # Show overlay only (no GameMode)
gamescope -W 1920 -H 1080 -- %command%  # Force resolution
```

### System

```bash
btop              # Graphical system monitor
novastudio-info   # Quick reference card
sudo novastudio-setup.sh --detect   # Re-run hardware detection
```

---

## 9. Focusrite Setup Guide

### Supported Devices

NovаStudio OS supports all Focusrite USB and Thunderbolt devices using the upstream
`scarlett2` kernel driver, which is included in Linux 5.14+. This includes:

- Scarlett Solo, 2i2, 4i4, 8i6, 18i8, 18i20 (all generations)
- Scarlett 2nd Gen (USB)
- Scarlett 3rd Gen (USB)
- Scarlett 4th Gen (USB)
- Clarett USB, Clarett USB+
- Clarett Thunderbolt (requires Thunderbolt controller)
- Vocaster One, Vocaster Two

### Connecting Your Interface

1. Plug in your Focusrite via USB (or Thunderbolt)
2. It will be detected automatically — no manual driver install needed
3. Open **PipeWire** settings (via your system sound settings) and select it as your
   default input/output device

### Enabling Advanced Controls (Scarlett Gen 2/3/4)

The `scarlett2` driver exposes advanced mixer controls via ALSA:

```bash
# Open the full Focusrite mixer in terminal
alsamixer -c "Scarlett"

# Or use the graphical ALSA mixer
alsamixergui

# List all Focusrite ALSA controls
amixer -c "Scarlett" contents
```

### Configuring for Low Latency

For the lowest possible latency with your Focusrite:

1. Open **QJackCtl** → Setup
2. Select your Scarlett as the ALSA device (it will show as `hw:Scarlett`)
3. Set **Frames/Period** to `64` (3.2ms at 48kHz)
4. If you get xruns, increase to `128` (5.3ms) or `256` (10.7ms)

```bash
# Test latency
jack_delay -p system:playback_1 -c system:capture_1
```

### USB Power Management (Auto-configured)

The script disables USB autosuspend for Focusrite devices so they never drop out:

```bash
# Verify autosuspend is disabled for your device
cat /sys/bus/usb/devices/*/power/autosuspend | head
# Should show -1 for the Focusrite
```

### Thunderbolt (Clarett)

If you have a Clarett Thunderbolt device:

```bash
# Authorise Thunderbolt device
boltctl list
boltctl enroll <device-uuid>

# Or use the GUI
gnome-control-center thunderbolt
```

---

## 10. Yabridge & Windows VST Guide

Yabridge lets you use Windows VST2, VST3, and CLAP plugins inside Linux DAWs like
Ardour, Carla, Bitwig, REAPER, and others.

### How It Works

```
Your Linux DAW  ←→  yabridge  ←→  Wine  ←→  Windows VST plugin
```

Yabridge creates a bridge between your Linux DAW and Windows plugins running inside Wine.
From the DAW's perspective, the plugins appear as native Linux plugins.

### Step 1 — Install Your Windows Plugins

1. Download your VST plugin installer (.exe) from the manufacturer's website
2. Run it through Wine or Bottles:

```bash
# Using Wine directly
WINEPREFIX=~/.wine-novastudio wine "YourPlugin-Setup.exe"

# Or open Bottles, create a new bottle with the "Audio" preset,
# then install the .exe through the Bottles GUI
```

3. Install to one of these default paths (yabridge monitors these automatically):
   - `C:\Program Files\VstPlugins\`
   - `C:\Program Files\Common Files\VST3\`
   - `C:\Program Files (x86)\VstPlugins\`
   - `C:\Program Files (x86)\Steinberg\VSTPlugins\`

### Step 2 — Sync Yabridge

After installing plugins, tell yabridge to pick them up:

```bash
yabridgectl sync
```

You should see output like:
```
Syncing yabridge plugins in 4 directories...
Added: YourPlugin.dll -> ~/.vst/YourPlugin.so
Done, 1 new plugin(s), 0 updated, 0 skipped
```

### Step 3 — Check Plugin Status

```bash
yabridgectl status
```

This shows all detected plugins and their current state.

### Step 4 — Load in Your DAW

Start your DAW and scan for new plugins. The bridged plugins will appear as normal
VST/VST3 plugins in the standard plugin directories:

- VST2: `~/.vst/`
- VST3: `~/.vst3/`

### Adding Custom Plugin Directories

If you installed plugins to a non-standard path:

```bash
# Add a custom directory
yabridgectl add "/home/$USER/.wine-novastudio/drive_c/Program Files/MyPlugins"

# Then sync
yabridgectl sync
```

### Troubleshooting yabridge

```bash
# Check yabridge version
yabridgectl --version

# Verify Wine is found
yabridgectl status | grep wine

# Run a plugin in verbose mode for diagnostics
YABRIDGE_DEBUG_LEVEL=1 ardour6

# View yabridge logs
journalctl --user -f -u yabridge
```

---

## 11. Gaming Guide

### Steam Setup

Steam is installed and Proton is pre-configured for all titles. On first launch:

1. Open **Steam** from your app launcher
2. Log in to your Steam account
3. Steam will update automatically
4. Install **ProtonPlus** (already installed) and add Proton-GE:
   - Open **ProtonPlus** → Install latest **GE-Proton**

**Recommended Steam Launch Options** (right-click a game → Properties → Launch Options):

```
gamemoderun mangohud %command%
```

For DX12-heavy games (Cyberpunk 2077, etc.):

```
gamemoderun mangohud PROTON_ENABLE_NVAPI=1 VKD3D_FEATURE_LEVEL=12_1 %command%
```

### MangoHud Overlay

MangoHud shows an in-game performance overlay. Controls:

| Key | Action |
|---|---|
| `RShift + F12` | Toggle overlay on/off |
| `LShift + F2` | Start/stop logging |
| `F5` | Upload log |

To customise the overlay:

```bash
nano ~/.config/MangoHud/MangoHud.conf
```

### GameMode

GameMode automatically boosts CPU/GPU performance when you launch a game and returns
to normal when you exit. It's automatic when you prefix with `gamemoderun`.

```bash
# Check GameMode is working
gamemoded -t

# Launch any app with GameMode
gamemoderun ./game
game-launch ./game   # NovаStudio shortcut (same thing + MangoHud)
```

### Lutris — Non-Steam Games

Lutris handles games from GOG, Battle.net, itch.io, and anywhere else:

1. Open **Lutris**
2. Connect your accounts (GOG, etc.) via the left panel
3. Search for any game and click Install — Lutris handles runners automatically

**Recommended Lutris global runner settings:**
- Wine version: **wine-ge-latest** (install via the runner manager)
- Enable **DXVK**
- Enable **esync** and **fsync**

### Controller Setup

**Xbox Controllers:**
- Wired: plug in and play — detected automatically
- Wireless (via USB adapter): detected by xpadneo automatically
- Check with: `ls /dev/input/js*`

**PlayStation Controllers (DualSense / DS4):**
- Connect via USB or Bluetooth
- Will appear in Steam automatically
- For Bluetooth pairing: Settings → Bluetooth → pair normally

**Testing controllers:**
```bash
# List detected controllers
ls /dev/input/js*

# Test input
jstest /dev/input/js0

# GUI controller tester / mapper
antimicrox
```

### Emulation

| Emulator | System | Launch |
|---|---|---|
| RetroArch | Multi-system | Search app launcher |
| Dolphin | GameCube, Wii | Search app launcher |
| RPCS3 | PlayStation 3 | Search app launcher |
| xemu | Original Xbox | Search app launcher |
| PPSSPP | PSP | Search app launcher |
| mGBA | GBA / GB / GBC | Search app launcher |

> ⚠️ You must provide your own legally obtained game ROMs/ISOs and BIOS files.

### Game Streaming

**Sunshine** (installed) lets you stream games from this machine to any device running
Moonlight (TV, phone, laptop, Steam Deck, etc.):

```bash
# Start Sunshine
flatpak run dev.lizardbyte.app.Sunshine

# Open the web interface to configure
# Navigate to: https://localhost:47990
```

---

## 12. Theme Customisation

### Built-in Theme Switcher

```bash
novastudio-theme dark       # Adwaita Dark (default)
novastudio-theme light      # Adwaita Light
novastudio-theme list       # Show all installed themes
```

### Installing Additional Themes

**Nordic (popular dark blue theme):**
```bash
sudo dnf copr enable -y frostyx/nordic
sudo dnf install -y nordic-theme
novastudio-theme nordic
```

**Catppuccin Mocha:**
```bash
# Download from GitHub
curl -Lo /tmp/catppuccin.zip \
  https://github.com/catppuccin/gtk/releases/latest/download/catppuccin-mocha-standard-teal-dark.zip
sudo unzip /tmp/catppuccin.zip -d /usr/share/themes/
novastudio-theme catppuccin
```

**WhiteSur (macOS-style):**
```bash
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/whitesur
bash /tmp/whitesur/install.sh
```

### GNOME Extensions (Recommended)

Install via the Extension Manager app (already installed):

| Extension | Effect |
|---|---|
| Blur my Shell | Blurred panel/overview backgrounds |
| Dash to Dock | macOS-style dock |
| Just Perfection | Deep GNOME UI customisation |
| AppIndicator | System tray icons |
| Pop Shell | Tiling window manager |

Or install from the web: [https://extensions.gnome.org](https://extensions.gnome.org)

### Icon Themes

Papirus icons are pre-installed. To change:

```bash
# GNOME Tweaks → Appearance → Icons
gnome-tweaks

# Or via command line:
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
```

### Fonts

JetBrains Mono and Inter are pre-installed. Change in GNOME Tweaks → Fonts.

```bash
# Set interface font
gsettings set org.gnome.desktop.interface font-name 'Inter 11'

# Set monospace font (terminals, code editors)
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
```

---

## 13. Troubleshooting

### The script failed partway through

The script is designed to be re-run safely. Simply run it again:

```bash
sudo bash ~/novastudio-setup.sh
```

Any packages already installed will be skipped. Check the log for what went wrong:

```bash
less /var/log/novastudio-setup.log

# Jump to errors
grep -i "error\|ERR\|fail" /var/log/novastudio-setup.log
```

### No sound after reboot

```bash
# Restart PipeWire services
systemctl --user restart pipewire pipewire-pulse wireplumber

# Check they're running
systemctl --user status pipewire

# Check your user is in the audio group
groups $USER
# Should include: audio jackuser realtime

# If not, add yourself and log out/in:
sudo usermod -aG audio,jackuser,realtime $USER
```

### JACK won't start / xruns

```bash
# Try a higher buffer size in QJackCtl (128, 256, or 512 frames)
# Check for conflicting processes
pactl info | grep "Server Name"  # Should say PipeWire
fuser /dev/snd/*                 # Should show only pipewire

# Restart everything
systemctl --user stop wireplumber pipewire-pulse pipewire
systemctl --user start pipewire wireplumber pipewire-pulse
```

### Focusrite not detected

```bash
# Check it's visible to USB
lsusb | grep -i "1235\|focusrite\|scarlett"

# Check the kernel driver
dmesg | grep -i scarlett

# Check ALSA sees it
aplay -l | grep -i scarlett

# If missing, reload the USB audio module
sudo modprobe -r snd_usb_audio && sudo modprobe snd_usb_audio
```

### NVIDIA driver not working

```bash
# Check if module is loaded
lsmod | grep nvidia

# Wait for akmods to finish building (can take 5+ minutes after first boot)
sudo akmods --force

# Check akmod status
sudo systemctl status akmods

# Verify driver version
nvidia-smi
```

### Games crash immediately

```bash
# Check Vulkan is available
vulkaninfo --summary

# Ensure vm.max_map_count is set (required by many games)
sysctl vm.max_map_count
# Should be: vm.max_map_count = 2147483642

# If not:
sudo sysctl -w vm.max_map_count=2147483642

# Check DXVK is active (look for d3d11.dll in Wine prefix)
ls ~/.wine-novastudio/drive_c/windows/system32/d3d11.dll
```

### Steam games show "no supported app" for Proton

1. In Steam: Settings → Compatibility → Enable Steam Play for all other titles ✓
2. Select **GE-Proton** (installed via ProtonPlus) as the default
3. Restart Steam

### yabridge plugins not showing in DAW

```bash
# Re-sync
yabridgectl sync

# Check where plugins landed
ls ~/.vst/
ls ~/.vst3/

# Make sure your DAW scans these paths
# In Ardour: Edit → Preferences → Plugins → VST Search Path
# Add: /home/$USER/.vst and /home/$USER/.vst3
```

### Controller not detected

```bash
# Check kernel sees it
dmesg | tail -20  # plug in controller, then run this

# List input devices
ls /dev/input/

# Test with jstest
sudo jstest /dev/input/js0

# For Xbox wireless specifically, check xpadneo
dkms status | grep xpadneo
```

---

## 14. FAQ

**Q: Can I run this on an existing Fedora installation with personal files?**
A: Yes. The script only modifies system configuration files, not your home directory
(except adding things to `~/.bashrc` and `~/.config`). All system files that are changed
are backed up to `/var/novastudio/backups/`.

**Q: Does this work on Fedora KDE Spin?**
A: Yes. The script detects KDE and installs KDE-specific packages (`kvantum`,
`breeze-gtk`, etc.) instead of GNOME-specific ones.

**Q: Can I use this on a laptop?**
A: Yes, and it auto-detects laptops. On laptops, it uses `schedutil` instead of
`performance` governor to preserve battery life while still being responsive.

**Q: Will this break my Windows dual-boot?**
A: The script modifies GRUB configuration but does not remove or alter the Windows EFI
entry. GRUB will still show Windows as a boot option.

**Q: Why does the script need root?**
A: Installing system packages, modifying kernel parameters, writing udev rules, and
configuring system services all require root access. The script does not touch your
personal files as root.

**Q: How do I know the realtime kernel is active?**
```bash
uname -r
# Should show something like: 6.6.14-200.rt14.fc41.x86_64
# The "rt" in the name confirms the realtime kernel
```

**Q: Can I add more Windows VST paths?**
```bash
yabridgectl add "/path/to/your/vst/folder"
yabridgectl sync
```

**Q: How do I update NovаStudio OS?**
```bash
# Update all system packages
sudo dnf upgrade --refresh

# Update Flatpak apps
flatpak update

# Re-run the setup script to get any new configuration
sudo bash ~/novastudio-setup.sh --full
```

**Q: DaVinci Resolve isn't installed — why?**
A: DaVinci Resolve requires a manual download from Blackmagic Design's website
(they don't allow redistribution). The script installs all required dependencies.
After downloading from [blackmagicdesign.com](https://www.blackmagicdesign.com/products/davinciresolve):
```bash
sudo bash DaVinci_Resolve_*.run
```

**Q: Can I uninstall NovаStudio OS and go back to stock Fedora?**
A: See [Section 15](#15-uninstalling).

---

## 15. Uninstalling

NovаStudio OS makes system-level changes, so there is no single uninstall command.
However, all original config files were backed up. Here's how to revert the key changes:

### Restore Backed-up Config Files

```bash
# Find your backup directory
ls /var/novastudio/backups/

# Restore specific files (replace DATE with your actual timestamp)
sudo cp /var/novastudio/backups/DATE/grub.bak /etc/default/grub
sudo cp /var/novastudio/backups/DATE/sysctl.conf.bak /etc/sysctl.conf
sudo cp /var/novastudio/backups/DATE/limits.conf.bak /etc/security/limits.conf
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### Revert to Standard Kernel

```bash
# List installed kernels
rpm -q kernel kernel-rt

# Remove realtime kernel
sudo dnf remove kernel-rt kernel-rt-devel

# Set standard kernel as default
sudo grubby --set-default /boot/vmlinuz-$(uname -r | sed 's/\.rt.*//')
```

### Remove Installed Services

```bash
sudo systemctl disable cpu-performance disable-thp nvidia-persistent
sudo systemctl stop cpu-performance disable-thp
```

### Remove Custom System Files

```bash
sudo rm -f /etc/sysctl.d/99-novastudio.conf
sudo rm -f /etc/sysctl.d/99-novastudio-gaming.conf
sudo rm -f /etc/udev/rules.d/60-novastudio-io.rules
sudo rm -f /etc/udev/rules.d/60-focusrite.rules
sudo rm -f /etc/udev/rules.d/70-sony-controllers.rules
sudo rm -f /etc/modprobe.d/focusrite.conf
sudo rm -f /etc/pipewire/pipewire.conf.d/99-novastudio-rt.conf
sudo rm -f /etc/wireplumber/wireplumber.conf.d/99-novastudio-alsa.conf
sudo rm -f /etc/gamemode.ini
sudo rm -f /usr/local/bin/novastudio-theme
sudo rm -f /usr/local/bin/novastudio-info
sudo rm -f /usr/local/bin/game-launch
```

### Remove Installed Apps (Optional)

```bash
# Remove Flatpak apps
flatpak uninstall --all

# Remove RPM packages (selective — be careful)
sudo dnf remove wine wine-staging lutris steam gamemode mangohud
```

---

## Appendix: File Locations

| File | Purpose |
|---|---|
| `/var/log/novastudio-setup.log` | Full setup log |
| `/var/novastudio/backups/` | Config file backups |
| `~/.config/novastudio/` | NovаStudio user config |
| `~/.wine-novastudio/` | Windows compatibility Wine prefix |
| `~/.local/share/yabridge/` | yabridge installation |
| `~/.config/MangoHud/MangoHud.conf` | MangoHud overlay config |
| `~/.config/vkBasalt/vkBasalt.conf` | vkBasalt post-processing config |
| `/etc/gamemode.ini` | GameMode configuration |
| `/etc/pipewire/pipewire.conf.d/` | PipeWire custom config |
| `/etc/wireplumber/wireplumber.conf.d/` | WirePlumber custom config |
| `/etc/sysctl.d/99-novastudio.conf` | Kernel parameter tuning |
| `/etc/sysctl.d/99-novastudio-gaming.conf` | Gaming kernel parameters |
| `/etc/udev/rules.d/60-focusrite.rules` | Focusrite udev rules |
| `/usr/share/backgrounds/novastudio/` | NovаStudio wallpapers |

---

## Appendix: Key Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `RShift + F12` | Toggle MangoHud overlay (in-game) |
| `Home` | Toggle vkBasalt sharpening (in-game) |
| `LShift + F2` | Start/stop MangoHud performance logging |
| `Super` (Windows key) | GNOME Activities overview |

---

## Licence

MIT Licence. See script header for full details.

---

*NovаStudio OS — Built for creators who refuse to compromise.*
