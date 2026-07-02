# crocuda.nixos - Den trivial server config modules.

A set of **nixos modules** which provide trivial base configuration
for servers.

For **paranoids** and **hypochondriacs**.

## Configuration directory architecture.

All tools configuration files are in their original format (non-nixified) in
`dotfiles` subdirectories.

Nix serve as:

- glue to imports dotfiles.
- make systemd units when needed.

## Installation and Usage (Flake)

Add the repo url to your flake inputs.

```nix
# flake.nix
inputs = {
  crocuda = {
      url = "github:crocuda/crocuda.nixos";
  };
};
```

Add the module to your system configuration.

```nix
# flake.nix
nixosConfigurations = {
  # CrocudaVM config
  my_machine = pkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [
        # Import the module and the related configuration
        inputs.crocuda.nixosModules.default
        ./crocuda.nix
    ];
  };
};
```

See `option.nix` for available options.

```nix
# crocuda.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {

  crocuda = {
    users = ["anon"]; # Will create user if not created.

    keyboard.layout = "colemak-dh";

    # Terminal stuffs
    shell = {
       fish.enable = true;
    };
    editor = {
      vim.enable = true;
      nvchad.enable = true;
      nvchad-ide.enable = true;
    };

    finance = {
      monero.enable = false;
      darkfi.enable = false;
    };
  };
}
```

## Generate disk images for virshle hypervisor.

## Try inside a VM.

Test inside a vm by building the flake inside template

```sh
nixos-rebuild build-vm \
      --flake './templates/tests#default' \
      --override-input crocuda ./ \
      --show-trace \
      --offline
```
