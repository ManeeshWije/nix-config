_: {
  flake.homeModules.neovim = {
    pkgs,
    dfRoot,
    ...
  }: {
    home.packages = [
      pkgs.neovim  
    ];
    xdg.configFile."nvim" = {
		source = dfRoot + /nvim;
recursive = true;
	};
  };
}
