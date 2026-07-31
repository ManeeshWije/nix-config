_: {
  flake.homeModules.yazi = {
    dfRoot,
    ...
  }: {
    xdg.configFile."yazi" = {
      source = dfRoot + /yazi;
      recursive = true;
    };
  };
}
