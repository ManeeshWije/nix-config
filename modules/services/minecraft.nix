{inputs, ...}: {
  flake.nixosModules.minecraft = {pkgs, ...}: let
    inherit (pkgs) fetchurl;

    mods = {
      lithium = fetchurl {
        url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/f7vZ0VWU/lithium-fabric-0.25.3%2Bmc26.2.jar";
        sha512 = "148b638f3c6229fbaf487120a2344a0af5e411a5aa6533d5db9d75da0a8c0d8304f63eb4cca13f4d03b2c9b4c23d559dd74c1d832422ef8a3087bd005e62a8bd";
      };

      moonrise = fetchurl {
        url = "https://cdn.modrinth.com/data/KOHu7RCS/versions/W0HImEBl/Moonrise-Fabric-1.1.0%2B87549dd.jar";
        sha512 = "89f73b2ecc9cd3d7e08ee199cefb0eb3588eabbe4ec0ccb55de3c580cc1d562de441ae6371b3435e27dd6098819235c74bdcf8ac3a5dbd45ee829c09eb745f01";
      };

      repurposed-structures = fetchurl {
        url = "https://cdn.modrinth.com/data/muf0XoRe/versions/CrmgMIJp/repurposed_structures-7.7.6%2B26.2-fabric.jar";
        sha512 = "0c0c6dd1ed38497f32cbd47202e7f85a06984df510673a8f7edb35a41c367c910595d14b0837fb84f229e346dc9733a98b6b8015e77f100923178fc3d349b6c0";
      };

      essential-commands = fetchurl {
        url = "https://cdn.modrinth.com/data/6VdDUivB/versions/QvCRhAmG/essential_commands-0.41.0-mc26.2.jar";
        sha512 = "e70b62784e5dd0e41477cd0d9184a6da11c62f9f53899dd5309742a43ccf6c0abd4faddbc942799e94edb37daf88d09a0af66f99202c8e199ee465f98732c919";
      };

      fabric-api = fetchurl {
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/NqwNSxwA/fabric-api-0.158.0%2B26.2.jar";
        sha512 = "4c2c1ebe74ffd54875a01ff371b53ba3d8674ac98d561f7dae02a96d3d37fbdbc5f5abc6e820f73b6154d6f873ddd05a442b0998ed2d456863dc0ad972e040a6";
      };

      midnightlib = fetchurl {
        url = "https://cdn.modrinth.com/data/codAaoxh/versions/3uBvRFE9/midnightlib-fabric-1.9.3%2B26.2.jar";
        sha512 = "46a0959737bb54431f0ae0a7dfa2467f26211d27ea2cd1ef7a7750c9a97425f481db46bab6cc861cd3b77accb7dfef3653dc5c683d7dfc07fa7f76824351ce22";
      };

      mob-ignore-me = fetchurl {
        url = "https://cdn.modrinth.com/data/RPqFuDWl/versions/BtD5YEpa/mobignoreme-1.2.jar";
        sha512 = "46bd394ed8b6d8a98438a5b2d090c1d32a269e20ab679bdbb48c0e6976519a287d679de46ee739589b9a29d8936d260b4bed8d2362eac1aee9e36a799408029a";
      };

      fabric-permissions-api = fetchurl {
        url = "https://cdn.modrinth.com/data/lzVo0Dll/versions/b1EqjxFs/fabric-permissions-api-0.7.0.jar";
        sha512 = "fd1961a4496cdc6cf22fbac0627a331407e97d3131f222641c1e370824adb3179e530e33e9e03adff1843e5556750edbb7abe0be7a241c7f0e3ca3ddc8b78ab7";
      };

      natures-compass = fetchurl {
        url = "https://cdn.modrinth.com/data/fPetb5Kh/versions/1X6iEfOy/NaturesCompass-26.2-2.5.1-fabric.jar";
        sha512 = "3e596e8cf29f28d2fb827fd8cd1272c7914334f55779f1dcc19df2651dba28a593e2b5178852a55e5114b02e93c276a3b09282d9c174e5e7191ea2c4fc5370f7";
      };

      dynamic-lights = fetchurl {
        url = "https://cdn.modrinth.com/data/7YjclEGc/versions/XAsq3xsq/dynamiclights-v1.9.3-mc1.17-26.2.9-mod.jar";
        sha512 = "89bb5d380c5778dbca6d093a7dc82a280ab9c8142c801ccd04bbd6975ff6acf6110cef97b1641869f7bc6d963772f5689f00c90cea740d5420afed756f3caf2b";
      };

      veinminer = fetchurl {
        url = "https://cdn.modrinth.com/data/OhduvhIc/versions/InpIvPQ1/veinminer-fabric-2.12.1.jar";
        sha512 = "ddb20ee9f053e288c5912dea9abfe2a4447797ea77e67f80388fed73935b97ab5116603747ce699f8bff965e0965d1099446df1ff90ee3d8527a7fc017585977";
      };

      fabric-language-kotlin = fetchurl {
        url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/bdhiINYC/fabric-language-kotlin-1.13.13%2Bkotlin.2.4.10.jar";
        sha512 = "9a63c35a550b0362b7b25ff045d93709c7b0dae08c89076cba422813fdfb9e5f5dd021ed3afac9f82e74e95b88c249e8f68b240717151540ca3e88cc27fb9c77";
      };
    };
  in {
    imports = [
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;

      dataDir = "/var/lib/minecraft";

      servers.main = {
        enable = true;
        autoStart = true;

        package = pkgs.fabricServers.fabric-26_2.override {
          jre_headless = pkgs.openjdk25_headless;
        };

        jvmOpts = "-Xms2G -Xmx5G -XX:+UseG1GC";

        serverProperties = {
          server-port = 25565;

          gamemode = "survival";
          difficulty = "normal";
          max-players = 2;

          online-mode = true;
          white-list = true;

          view-distance = 16;
          simulation-distance = 16;

          enable-rcon = false;
          enable-query = false;
          level-seed = "-8612793767594611505";

          motd = "Fabric 26.2";
        };

        whitelist = {
          tty_ = "935d3f32-916a-4aee-80e9-89a6f659b194";
          abbybabyyy = "1ac68aa7-6631-4bfc-b802-25e7254f79d2";
          angelbbyabby = "6cb136a5-818a-43d2-a96b-0632d4ee66e0";
        };

        operators = {
          tty_ = {
            uuid = "935d3f32-916a-4aee-80e9-89a6f659b194";
            level = 3;
          };
          abbybabyyy = {
            uuid = "1ac68aa7-6631-4bfc-b802-25e7254f79d2";
            level = 3;
          };
          angelbbyabby = {
            uuid = "6cb136a5-818a-43d2-a96b-0632d4ee66e0";
            level = 3;
          };
        };

        symlinks.mods =
          pkgs.linkFarmFromDrvs
          "mods"
          (builtins.attrValues mods);
      };
    };

    users.users.maneesh.extraGroups = [
      "minecraft"
    ];
  };
}
