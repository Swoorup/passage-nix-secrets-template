let
  lib = import <nixpkgs/lib>;
  vaultUtil = import ./lib/vaultUtil.nix { inherit lib; };
  vaults = import ./vaults.nix;

  currentDir = builtins.toString ./.;
  vaultDirs = map (vault: "${currentDir}/${vault}") vaults;

  getVaultSecrets =
    vaultDir:
    let
      secretFiles = vaultUtil.getVaultSecretFiles vaultDir;
      recipients = vaultUtil.getAgeRecipients vaultDir;
    in
    lib.genAttrs secretFiles (file: {
      publicKeys = recipients;
    });

  allSecrets = lib.pipe vaultDirs [
    (map getVaultSecrets)
    lib.mergeAttrsList
  ];

in
allSecrets
