# NixConfig

**Declarative NixOS + Home Manager configuration - 3 machines, one repo**

## Overview

Complete NixOS environment managed by Flakes - from bootloader to dotfiles.

## Machines

```
Gaming  → Desktop (NVIDIA PRIME)
TUF     → Laptop (NVIDIA Optimus, AMD+RTX)
Edu     → Laptop (AMD, TLP power management)
```

## Stack

**NixOS** + Home Manager  
**WM:** bspwm + sxhkd + polybar  
**Terminal:** Alacritty + Fish  
**Editor:** Neovim (custom config)  
**Secrets:** sops-nix + age encryption  
**Kernel:** CachyOS (gaming), vanilla (education)  

## Key Features

- Flake-based reproducible builds
- Colemak/QWERTY switchable keyboard layouts
- Gaming setup (Steam, Lutris, Wine, MangoHUD)
- NVIDIA Optimus auto-configured PRIME
- Podman containerization with Docker compat

## Structure

```
├── flake.nix           → System-level flake
├── home/flake.nix      → Home Manager flake
├── vortex.nix          → Shared system config
├── pkgs.nix            → Package lists
├── {TUF,Gaming,Edu}/   → Per-machine configs
│   ├── configuration.nix
│   ├── hardware-configuration.nix
│   └── secrets.yaml (encrypted)
└── home/
    ├── home.nix        → Shell, Git, aliases
    ├── neovim.nix      → Editor config
    ├── x11.nix         → bspwm + sxhkd
    └── misc/           → Dotfiles, scripts
```

## Usage

```bash
# Rebuild system (as root)
nixos-rebuild switch --flake .#TUF

# Rebuild home (as user)
home-manager switch --flake ./home#vortex

# Update flake inputs
nix flake update
```

## Why Nix?

- Reproducible - identical system across machines
- Rollback-ready - every build is a separate generation
- Declarative - code as infrastructure
- Experimental - test without risk
