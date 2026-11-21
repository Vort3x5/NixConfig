# NixConfig

**Declarative NixOS + Home Manager configuration - 3 machines, one repo**

## Overview

Complete NixOS environment managed by Flakes - from bootloader to dotfiles.

## Machines

```
Gaming  → Desktop (NVIDIA PRIME reverse sync)
TUF     → Laptop (NVIDIA Optimus sync)
Edu     → Laptop (AMD, TLP, no Steam/VBox gaming stack)
```

## Stack

**NixOS** + Home Manager  
**WM:** bspwm + sxhkd + polybar  
**Terminal:** Alacritty + Fish  
**Editor:** Neovim (custom config)  
**Secrets:** sops-nix + age encryption  
**Kernel:** vanilla (nixpkgs)

## Key Features

- Single flake for system + home
- Shared modules under `vortex/` (common / gaming / devtools / sops)
- Gaming setup (Steam, Lutris, Wine, MangoHUD) only on TUF + Gaming
- NVIDIA baseline in `nvidia.nix`; hosts only set PRIME
- Podman/Docker/VirtualBox only on TUF + Gaming

## Structure

```
├── flake.nix              → System + Home Manager
├── nvidia.nix             → Shared NVIDIA baseline
├── vortex/
│   ├── common.nix         → Shared base (desktop, user, locales, …)
│   ├── gaming.nix         → Steam / Lutris / Wine / gamemode
│   ├── devtools.nix       → Docker, Podman, VirtualBox
│   ├── sops.nix           → Shared age / ssh secret wiring
│   ├── pkgs-common.nix
│   └── pkgs-gaming.nix
├── {TUF,Gaming,Edu}/      → Per-machine configs
│   ├── configuration.nix
│   ├── hardware-configuration.nix
│   └── secrets.yaml (encrypted)
└── home/
    ├── home.nix           → Shell, Git, aliases
    ├── neovim.nix         → Editor config
    ├── x11.nix            → bspwm + polybar
    └── misc/              → Dotfiles, scripts
```

## Usage

```bash
# Rebuild system (as root)
nixos-rebuild switch --flake .#TUF

# Rebuild home (as user; `vortex` reads ~/.config/layout → needs impure)
home-manager switch --impure --flake .#vortex

# Explicit keyboard layout variants (pure)
home-manager switch --flake .#vortex-colemak
home-manager switch --flake .#vortex-qwerty

# Update flake inputs
nix flake update
```

## Why Nix?

- Reproducible - identical system across machines
- Rollback-ready - every build is a separate generation
- Declarative - code as infrastructure
- Experimental - test without risk
