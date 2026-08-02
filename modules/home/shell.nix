_: {
  flake.homeModules.shell = {
    pkgs,
    dfRoot,
    inputs,
    ...
  }: {
    # Have home manager manage itself
    programs.home-manager.enable = true;

    home.packages = with pkgs;
      [
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
        tree-sitter
        yazi
        lazygit
        lazydocker
        starship
        imagemagick

        nixd
        alejandra
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        wl-clipboard
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
