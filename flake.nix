# flake.nix
{
  description = "zxcv's homelab server configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };
    in
    {
      overlays.default = import ./overlays { inherit inputs; };

      nixosConfigurations.workhorse = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.default ]; }
          ./hosts/workhorse.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.zxcv = import ./home/server.nix;
          }
        ];
      };

      homeConfigurations."zxcv@workhorse" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home/server.nix ];
      };

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            name = "workhorse-nixos-shell";
            packages = with pkgs; [
              nixfmt
              nil
              statix
              sops
              age
              wireguard-tools
            ];
          };
        }
      );
    };
}
