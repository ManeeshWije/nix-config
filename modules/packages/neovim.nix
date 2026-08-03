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
        cargo
        rustc
        rustfmt
        go
        nodejs
        python3
        black
        marksman
      ];

      package = pkgs.unstable.neovim-unwrapped;

      settings.config_directory = "${lib.cleanSource (dfRoot + /nvim)}";
    };
  };
}
