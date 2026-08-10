{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    dfRoot,
    ...
  }: {
    packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
      inherit pkgs;
      runtimePkgs = with pkgs; [
        lua-language-server
        typescript-go
        oxlint
        unstable.oxfmt
        vscode-langservers-extracted
        rust-analyzer
        rustfmt
        docker-language-server
        bash-language-server
        nixd
        pyright
        stylua
        tailwindcss-language-server
        yaml-language-server
      ];

      package = pkgs.unstable.neovim-unwrapped;

      settings.config_directory = "${lib.cleanSource (dfRoot + /nvim-native)}";
    };
  };
}
