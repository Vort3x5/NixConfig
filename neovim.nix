{ config, pkgs, ...}:
{
	programs.nvf = {
		enable = true;

		settings = {
			configRC = {
				basic = true;
			};
		};
	}
}
