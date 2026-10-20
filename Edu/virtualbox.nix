# Fragment do /etc/nixos/Edu/ — VirtualBox dla PSIR.
# Nie edytuj recznie: uzyj scripts/enable-vbox-on-edu.sh
{ ... }:
{
	users.users.vortex.extraGroups = [ "vboxusers" ];

	virtualisation.virtualbox.host = {
		enable = true;
		# Extension Pack nie jest wymagany do lab1 (OVA + bridged/host-only).
		enableExtensionPack = false;
	};
}
