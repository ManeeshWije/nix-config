{
  inputs,
  lib,
  withSystem,
  dfRoot,
  ...
}: let
  inherit (inputs.self) nixosModules homeModules;

  # hostname -> system. Each host's modules are named after the hostname:
  # nixosModules.<host> and homeModules.<host>. pkgs (with overlays) comes
  # from the per-system pkgs defined in overlays.nix, via withSystem.
  hosts = {
    endurance = "x86_64-linux";
  };

  mkNixos = name: system:
    withSystem system ({pkgs, ...}:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs dfRoot;};

        modules = [
          {nixpkgs.pkgs = pkgs;}
          nixosModules.${name}
          inputs.home-manager.nixosModules.home-manager
            {
       		home-manager = {
 			useGlobalPkgs = true;
 			useUserPackages = true;
                        extraSpecialArgs = { inherit inputs dfRoot; };
 			users.maneesh = homeModules.${name};
		};
	    }
        ];
      });

  mkHome = name: system:
    withSystem system ({pkgs, ...}:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit inputs dfRoot;};

        modules = [homeModules.${name}];
      });
in {
  flake.nixosConfigurations = lib.mapAttrs mkNixos hosts;

  flake.homeConfigurations =
    lib.mapAttrs'
    (name: system: lib.nameValuePair "maneesh@${name}" (mkHome name system))
    hosts;
}
