{...}: {
  flake.homeModules.karabiner = {...}: {
    xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
      profiles = [
        {
          name = "Default profile";
          selected = true;

          complex_modifications.rules = [
            {
              description = "Caps to cmd unless in terminal, then ctrl";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_gui";
                      repeat = true;
                    }
                  ];
                  conditions = [
                    {
                      type = "frontmost_application_unless";
                      bundle_identifiers = [
                        "com.mitchellh.ghostty"
                        "com.raphaelamorim.rio"
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
                    {
                      key_code = "left_control";
                      repeat = true;
                    }
                  ];
                  conditions = [
                    {
                      type = "frontmost_application_if";
                      bundle_identifiers = [
                        "com.mitchellh.ghostty"
                        "com.raphaelamorim.rio"
                      ];
                    }
                  ];
                }
              ];
            }
          ];

          devices = [
            {
              identifiers = {
                is_keyboard = true;
                product_id = 833;
                vendor_id = 1452;
              };
              simple_modifications = [
                {
                  from.key_code = "caps_lock";
                  to = [{key_code = "left_control";}];
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
