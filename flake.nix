{
  description = "Home Manager configuration of César";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-cesar.url = "github:CesarGallego/nixpkgs/";
    # nixpkgs.url = "github:CesarGallego/nixpkgs/";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-cesar, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsC = nixpkgs-cesar.legacyPackages.${system};
    in {
      homeConfigurations.cesar = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
           ./home.nix 
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        # extraSpecialArgs = { homePkgs = [ pkgsC.jtdx ]; };
        extraSpecialArgs = { homePkgs = [ ]; };
      };
    };
}
