{
  lib,
  self_lib,
  ...
}:
with self_lib; let
  secret = "vm-nixos";

  vms = {
    xxs = {
      size = 10;
    };
    xs = {
      size = 10;
    };
  };
in {
}
