# NixConfig

**Declarative NixOS + Home Manager configuration - 3 machines, one repo**

## Overview

Complete NixOS environment managed by Flakes - from bootloader to dotfiles.

## Machines

```
Gaming  → Desktop (NVIDIA PRIME, vanilla kernel)
TUF     → Laptop (NVIDIA Optimus, CachyOS BORE)
Edu     → Laptop (AMD, TLP, no Steam/VBox/CachyOS)
```

## Stack

**NixOS** + Home Manager  
**WM:** bspwm + sxhkd + polybar  
**Terminal:** Alacritty + Fish  
**Editor:** Neovim (custom config)  
**Secrets:** sops-nix + age encryption  
**Kernel:** CachyOS on TUF only; vanilla elsewhere  

## Key Features

- Flake-based reproducible builds
- Shared modules split under `vortex/` (common / gaming / devtools / kernel-cachyos)
- Gaming setup (Steam, Lutris, Wine, MangoHUD) only on TUF + Gaming
- NVIDIA Optimus auto-configured PRIME
- Podman/Docker/VirtualBox only on TUF + Gaming

## Structure

```
├── flake.nix              → System-level flake
├── home/flake.nix         → Home Manager flake
├── vortex/
│   ├── common.nix         → Shared base (desktop, user, locales, …)
│   ├── gaming.nix         → Steam / Lutris / Wine / gamemode
│   ├── devtools.nix       → Docker, Podman, VirtualBox
│   ├── kernel-cachyos.nix → CachyOS + Attic (TUF only)
│   ├── pkgs-common.nix
│   └── pkgs-gaming.nix
├── {TUF,Gaming,Edu}/      → Per-machine configs
│   ├── configuration.nix
│   ├── hardware-configuration.nix
│   └── secrets.yaml (encrypted)
└── home/
    ├── home.nix           → Shell, Git, aliases
    ├── neovim.nix         → Editor config
    ├── x11.nix            → bspwm + sxhkd
    └── misc/              → Dotfiles, scripts
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
