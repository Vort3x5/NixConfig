{ pkgs }:
{
	list = with pkgs; [
		steam discord obs-studio prismlauncher

		mangohud gamemode gamescope wine
		(lutris.override {
			extraLibraries = pkgs: [
				pkgs.gamemode
				pkgs.libnghttp2
				pkgs.openssl
				pkgs.icu
			];
		})
	];
}
