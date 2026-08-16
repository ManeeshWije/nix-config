_: {
  flake.nixosModules.user = {
    pkgs,
    config,
    ...
  }: {
    users.users.maneesh = {
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "Maneesh Wijewardhana";
      extraGroups = ["networkmanager" "wheel" "docker"];
    };

	users.users.maneesh.openssh.authorizedKeys.keys = [
	  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJb33lZq6xLBJM3NXyH2WddcipCG1TVAY8YvgPfXMkdH m.mwije1@proton.me"
	];

    programs.zsh.enable = true;
  };
}
