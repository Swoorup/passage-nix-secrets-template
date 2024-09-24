{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Nix package manager settings
  # nix.settings = {
  #   substituters = [
  #     "https://devenv.cachix.org"
  #     "https://nix-community.cachix.org"
  #     "https://cache.nixos.org/"
  #   ];
  #   trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #     "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  #   ];
  # };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      systems,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib // builtins;
      forEachSystem = lib.genAttrs (import systems);
      vaults = import ./vaults.nix;
    in
    {
      packages = forEachSystem (
        system:
        let
          vaultPkgs = lib.pipe vaults [
            (map (
              vault:
              lib.nameValuePair "${vault}-devenv-up" (self.devShells.${system}.${vault}.config.procfileScript)
            ))
            lib.listToAttrs
          ];
        in
        vaultPkgs
        # { devenv-up = self.devShells.${system}.daily-vault.config.procfileScript; }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkVaultShell =
            vault:
            devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [ ./lib/mkVaultShell.nix ];
            };
        in
        lib.genAttrs vaults mkVaultShell
      );

      secrets = import ./secrets.nix;
    };
}
