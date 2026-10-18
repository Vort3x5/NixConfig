{ pkgs, lib, ... }:
let
	gamingPackages = import ./pkgs-gaming.nix { inherit pkgs; };
in
{
	programs.steam = {
		enable = true;
		gamescopeSession.enable = true;
	};

	programs.gamemode.enable = true;

	# Gaming-oriented kernel cmdline. mkDefault keeps host/NVIDIA modules able to
	# take precedence (same merge behaviour as the old shared vortex.nix).
	boot.kernelParams = lib.mkDefault [
		"mitigations=off"
		"preempt=full"
		"split_lock_detect=off"
		"usbcore.quirks=041e:4055:bc"
	];

	environment.systemPackages = gamingPackages.list;
}
