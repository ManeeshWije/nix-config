{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    dfRoot,
    ...
  }: {
    packages.neovim = let
      userNvim = lib.cleanSource (dfRoot + /nvim);
    in
      inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        runtimePkgs = with pkgs; [
          cargo
          rustc
          go
          nodejs
        ];

        package = pkgs.unstable.neovim-unwrapped;

        settings.config_directory = "${lib.cleanSource (dfRoot + /nvim)}";

        envDefault.MSS_NEOVIM_USER_DIR = "${userNvim}";
      };
  };
}
