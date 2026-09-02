_: {
  flake.homeModules.shell = {
    pkgs,
    dfRoot,
    ...
  }: {
    # Have Home Manager manage itself
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
      rclone
      fzf
      btop
      gnupg
      jq
      mpv
      tree-sitter
      yazi
      poppler
      resvg
      ffmpeg
      starship
      imagemagick
      sops
      zip
      unzip
      unstable.codex

      nixd
      alejandra
    ];

    home.file.".gitconfig".source = dfRoot + /git/.gitconfig;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        ${builtins.readFile (dfRoot + /zsh/.zshrc)}

        if command -v gh >/dev/null 2>&1 \
          && gh auth status >/dev/null 2>&1; then
          export GITHUB_PACKAGE_TOKEN="$(gh auth token)"
        fi
      '';
    };
  };
}
