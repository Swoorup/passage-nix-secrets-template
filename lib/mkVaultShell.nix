{
  pkgs,
  config,
  lib,
  ...
}:

let
  # The vault directory is the directory that contains the `store`, `identities`, `.age-recipients`
  vaultDir = config.env.DEVENV_ROOT;
  repoDir = "${vaultDir}/..";
  vaultUtil = import ./vaultUtil.nix { inherit lib; };
  vaultConfig = vaultUtil.getConfig vaultDir;
in
{
  env = {
    PASSAGE_DIR = vaultConfig.PASSAGE_DIR;
    PASSAGE_IDENTITIES_FILE = vaultConfig.PASSAGE_IDENTITIES_FILE;
    PASSAGE_RECIPIENTS_FILE = vaultConfig.PASSAGE_RECIPIENTS_FILE;
  };

  packages = with pkgs; [
    age-plugin-yubikey
    age-plugin-fido2-hmac
    age-plugin-ledger
    age
    passage
  ];

  scripts = {
    repl.exec = "nix repl --extra-experimental-features 'flakes repl-flake' nixpkgs";
    root-repl.exec = ''
      nix repl --expr "builtins.getFlake \"${repoDir}\""
    '';

    qr.exec = ''
      ${pkgs.qrencode}/bin/qrencode -t ansiutf8 <<< "$@"
    '';

    dump-secrets-list.exec = ''
      nix-instantiate --json --eval --strict -E "import ${repoDir}/secrets.nix" | 
      ${pkgs.jq}/bin/jq -r '
        "Secret Path\n" +
        "---------\n" +
        (to_entries | map(" " + .key) | join("\n"))
      '
    '';

  };

  enterShell =
    let
      vaultName = vaultConfig.VAULT_NAME;
      padding = lib.concatStrings (lib.replicate (28 - builtins.stringLength vaultName) " ");
    in
    ''
      echo ""
      echo "╔════════════════════════════════════════════════════════════════╗"
      echo "║                                                                ║"
      echo "║   Welcome to the '${vaultName}' Retro Terminal!${padding}║"
      echo "║                                                                ║"
      echo "║   ▀▄▀▄▀▄ RADICAL SECRETS MANAGEMENT SYSTEM ▄▀▄▀▄▀              ║"
      echo "║                                                                ║"
      echo "║   Load up your floppy disks and fire up that CRT monitor,      ║"
      echo "║   'cause we're about to hack the mainframe like it's 1985!     ║"
      echo "║                                                                ║"
      echo "║   Remember: Be excellent to each other, and party on, dudes!   ║"
      echo "║                                                                ║"
      echo "╚════════════════════════════════════════════════════════════════╝"
      echo ""
    '';

  processes.rekey.exec = ''
    ${pkgs.watchexec}/bin/watchexec -w ${vaultConfig.PASSAGE_IDENTITIES_FILE} -- passage reencrypt
  '';
}
