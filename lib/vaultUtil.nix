{ lib }:
let
  getConfig = vaultDir: {
    VAULT_NAME = baseNameOf (builtins.toString vaultDir);
    PASSAGE_DIR = "${vaultDir}/store";
    PASSAGE_IDENTITIES_FILE = "${vaultDir}/identities";
    PASSAGE_RECIPIENTS_FILE = "${vaultDir}/.age-recipients";
  };

  # Read and process the recipients file using pipe
  getAgeRecipients =
    vaultDir:
    with builtins;
    (
      let
        ageRecipientsFile = (getConfig vaultDir).PASSAGE_RECIPIENTS_FILE;
      in
      if pathExists ageRecipientsFile then
        lib.pipe ageRecipientsFile [
          readFile
          (lib.splitString "\n")
          (map lib.trim)
          (filter (line: line != "" && !(match "^#.*" line != null)))
        ]
      else
        [ ]
    );

  # Get lists of all .age files in the vault
  # Paths are separated by dot 
  # ie vault/foo/bar.age -> foo.bar.age
  getVaultSecretFiles =
    vaultDir:
    with builtins;
    let
      vaultConfig = getConfig vaultDir;
      vaultName = vaultConfig.VAULT_NAME;
      passageDir = vaultConfig.PASSAGE_DIR;
      allFiles = if pathExists passageDir then lib.filesystem.listFilesRecursive passageDir else [ ];
      ageFiles = filter (file: lib.hasSuffix ".age" file) allFiles;
      relativePaths = map (file: lib.removePrefix "${passageDir}/" file) ageFiles;
      paths = map (file: "${vaultName}/store/${file}") relativePaths;
    in
    paths;

in
{
  inherit getConfig getAgeRecipients getVaultSecretFiles;
}
