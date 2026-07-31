_: {
  flake.homeModules.shell = {
    pkgs,
    dfRoot,
    inputs,
    ...
  }: {
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
    home.stateVersion = "25.11";

    # Have home manager manage itself
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      zsh
      vim
      gitFull
      unstable.delta
      unstable.gh
      gcc
      ripgrep
      fd
      fzf
      btop
      gnupg
      jq
      wl-clipboard
      tree-sitter
      yazi
      starship

      nixd
      alejandra
    ];

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      initContent = builtins.readFile (dfRoot + /.zshrc);
    };
  };
}
