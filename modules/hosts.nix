{
  inputs,
  lib,
  dfRoot,
  hostOverlays,
  ...
}: let
  inherit (inputs.self) nixosModules homeModules;

  hosts = {
    endurance = {
      system = "x86_64-linux";
      nixpkgs = inputs.nixpkgs;
      homeManager = inputs.home-manager;
    };

    work-macbook = {
      system = "aarch64-darwin";
      nixpkgs = inputs.nixpkgs;
      homeManager = inputs.home-manager;
    };

    tars = {
      system = "aarch64-linux";
      nixpkgs = inputs.nixpkgs-unstable;
      homeManager = inputs.home-manager-unstable;
    };

    gargantua = {
      system = "aarch64-linux";
      nixpkgs = inputs.nixpkgs-unstable;
      homeManager = inputs.home-manager-unstable;
    };
  };

  mkPkgs = nixpkgs: system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;

      overlays = hostOverlays;
    };

  mkNixos = name: host: let
    pkgs = mkPkgs host.nixpkgs host.system;
  in
    host.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs dfRoot;
      };

      modules = [
        {nixpkgs.pkgs = pkgs;}

        nixosModules.${name}

        host.homeManager.nixosModules.home-manager

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = {
              inherit inputs dfRoot;
            };

            users.maneesh = homeModules.${name};
          };
        }
      ];
    };

  mkHome = name: host: let
    pkgs = mkPkgs host.nixpkgs host.system;
  in
    host.homeManager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit inputs dfRoot;
      };

      modules = [
        homeModules.${name}
      ];
    };
in {
  flake.nixosConfigurations =
    lib.mapAttrs mkNixos hosts;

  flake.homeConfigurations =
    lib.mapAttrs'
    (name: host:
      lib.nameValuePair
      "maneesh@${name}"
      (mkHome name host))
    hosts;
}
