# Nix Secrets Management with Passage

This repository demonstrates an advanced secrets management system using Nix, integrating the [`passage`](https://github.com/FiloSottile/passage) tool and generating rules for [`agenix`](https://github.com/ryantm/agenix) via `secrets.nix`.

## Overview

This system uses `passage` for secret management and integrates with `agenix` for encryption and decryption of sensitive data. It's designed to work seamlessly with Nix-based systems and provides a flexible, secure way to manage secrets across multiple vaults.

## Getting Started

1. Ensure you have Nix installed on your system.
2. Clone this repository.
3. Enter the development shell:

   ```sh
   nix develop
   ```

## Vault Structure
Secrets are organized into vaults. Each vault is a directory containing:

* `store/:` Directory for storing encrypted secrets
* `identities/:` Directory for storing identity files
* `.age-recipients:` File listing public keys of recipients

## Managing Secrets
### Adding a New Secret
Use the passage command to add a new secret:

```shell
passage insert path/to/secret
```

### Viewing Secrets
To view a secret:

```shell
passage show path/to/secret
```

### Listing Secrets
To see a list of all secrets:

```shell
dump-secrets-list
```

## Replication and Reencryption
The system automatically watches for changes in the identities file and reencrypts secrets when necessary:

```shell
passage reencrypt
```

## Integration with Agenix

The secrets.nix file generates rules for agenix based on the vault structure. It automatically detects secret files and recipients across all vaults.

Development Shell Features
The development shell provides several useful commands:

* `repl`: Start a Nix REPL with Nixpkgs
* `root-repl`: Start a Nix REPL with the current flake
* `qr`: Generate QR codes
* `dump-secrets-list`: List all secrets paths

## Security Considerations

* Keep your identity files secure and backed up.
* Use strong, unique passwords for your secrets.
* Regularly audit your .age-recipients file to ensure only authorized keys have access.

## Contributing

Contributions are welcome! Please submit pull requests or open issues for any improvements or bug fixes.

Remember to keep your secrets secure and never commit unencrypted sensitive data to version control.

# How I manage keys

I first created an EdDSA public/private key pair to use for `agenix`, and then I `age` encrypted them to a set of three Yubikeys I use in my daily life. In this way, they're backed up and the key to read them is stored away in something secure I'm already using.

If I wanted, I could also probably [store the encrypted keys as paper](https://www.jabberwocky.com/software/paperkey/). But I prefer the Yubikey approach.
