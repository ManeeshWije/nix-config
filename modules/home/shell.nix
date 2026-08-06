_: {
  flake.homeModules.shell = {
    pkgs,
    dfRoot,
    inputs,
    ...
  }: {
    # Have home manager manage itself
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      zsh
      tmux
      tmux-sessionizer
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
      poppler
      resvg
      ffmpeg
      lazygit
      lazydocker
      starship
      imagemagick
      zip
      unzip
      unstable.codex

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
      initContent = ''
        ${builtins.readFile (dfRoot + /.zshrc)}
          if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
            export GITHUB_PACKAGE_TOKEN="$(gh auth token)"
          fi
      '';
    };
  };
}
