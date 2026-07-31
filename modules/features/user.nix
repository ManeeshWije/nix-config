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

    programs.zsh.enable = true;
  };
}
