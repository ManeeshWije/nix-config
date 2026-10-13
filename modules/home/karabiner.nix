{...}: {
  flake.homeModules.karabiner = {...}: {
    xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
      profiles = [
        {
          name = "Default profile";
          selected = true;

          complex_modifications.rules = [
            # this is for non corne keyboards aka built in
            {
              description = "Caps Lock to Cmd outside terminals, Ctrl inside";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {key_code = "left_command";}
                  ];
                  conditions = [
                    {
                      type = "frontmost_application_unless";
                      bundle_identifiers = [
                        "^com\\.mitchellh\\.ghostty$"
                        "^com\\.raphaelamorim\\.rio$"
                      ];
                    }
                  ];
                }
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {key_code = "left_control";}
                  ];
                  conditions = [
                    {
                      type = "frontmost_application_if";
                      bundle_identifiers = [
                        "^com\\.mitchellh\\.ghostty$"
                        "^com\\.raphaelamorim\\.rio$"
                      ];
                    }
                  ];
                }
              ];
            }

            # this is for corne keyboard as its mapping doesnt have a caps lock so the above wont work
            {
              description = "Left Ctrl to Cmd outside terminals";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "left_control";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {key_code = "left_command";}
                  ];
                  conditions = [
                    {
                      type = "frontmost_application_unless";
                      bundle_identifiers = [
                        "^com\\.mitchellh\\.ghostty$"
                        "^com\\.raphaelamorim\\.rio$"
                      ];
                    }
                  ];
                }
              ];
            }
          ];

          virtual_hid_keyboard = {
            country_code = 0;
            keyboard_type_v2 = "ansi";
          };
        }
      ];
    };
  };
}
