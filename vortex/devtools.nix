{ pkgs, ... }:
{
	users.users.vortex.extraGroups = [
		"docker"
		"kvm"
		"vboxusers"
	];

	virtualisation.virtualbox.host = {
		enable = true;
		enableExtensionPack = true;
	};
	virtualisation.docker.enable = true;
	virtualisation.podman = {
		enable = true;
		# dockerCompat = true;
	};

	environment.systemPackages = with pkgs; [
		distrobox
		podman
		docker
		docker-compose
	];
}
