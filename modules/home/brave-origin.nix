_: {
  flake.homeModules.brave-origin = {pkgs, ...}: {
    home.packages = with pkgs; [
	brave-origin
    ];
  };
}
