# Desktop Windows Install

When a new desktop arrives in the lab, install Windows 11 with a Ventoy USB. Download the guide, which walks through everything from BIOS settings to initial setup with real installation screenshots.

| Document | Download |
|------|----------|
| Installing Windows 11 with a Ventoy USB | <a href="/docs/ventoy-windows11-install-guide.pdf" download="Ventoy Windows 설치 가이드.pdf">Download PDF (Korean)</a> |

## What You Need

1. **Ventoy USB** — Install Ventoy on a USB drive with Ventoy2Disk (existing data on the USB will be erased).
2. **Windows ISO** — Copy the ISO file to the Ventoy partition. No separate burning step is needed.
3. **Backup** — Back up data on the target disk, and check the license type and installation permissions.

## Installation Flow

| Step | Details |
|------|------|
| BIOS settings | Press `Del` right after power-on (Gigabyte boards) → **turn off Secure Boot** in the Boot tab → Save & Exit |
| Ventoy boot | Select the Windows ISO from the list → **Boot in normal mode** (use wimboot mode if that fails) |
| Windows install | Choose install options, product key, and edition → create partitions on the internal disk and install to the **largest primary partition** |
| Initial setup | To proceed without internet, press `Shift + F10` on the network screen → enter `oobe\bypassnro` → after restart, select **I don't have internet** |
| Privacy settings | Choose location, Find my device, diagnostic data, etc. as needed |

::: warning Choose the right disk
Disk numbers on the partition screen differ by PC. Check the size and name so you **don't select the Ventoy USB disk**.
:::

## After Installation

- Remove the Ventoy USB
- Install LAN and GPU drivers, run Windows Update
- Check activation status after connecting to the internet
- If needed, turn Secure Boot back on in the BIOS and confirm it boots
