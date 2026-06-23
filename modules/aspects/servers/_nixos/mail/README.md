# Maddy configuration

So you have come up with a crocuda module configuration
that looks like this.

```nix
# crocuda.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  crocuda = {
    users = ["anon"];
    servers = {
      mail.maddy = {
        enable = true;
        domains = [
          "test.com"
          "example.com"
        ];
        accounts = [
          "alice@test.com"
          "bob@example.com"
        ];
      };
    };
  };
}
```

## Add mandatory credentials

Mail adress boxes are created but cannot be accessed as is.
You need to add credentials (need root priviledges).

```sh
sudo maddy creds password alice@test.com
```

## Create an autoconfigure file

TODO()
