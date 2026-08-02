_: {
  flake.homeModules.yaziConfig = {
    dfRoot,
    ...
  }: {
    xdg.configFile."yazi" = {
      source = dfRoot + /yazi;
      recursive = true;
    };
  };
}
