{inputs, ...}: let
  crocuda_lib = inputs.crocuda.crocuda_lib;
in {
  crocuda.batteries.dhcp_stable_duid-uuid = {
    nixos = {config, ...}: {
      systemd.tmpfiles.rules = let
        user = "dhcpcd";
        group = "wheel"; # wheel | users
        content = "${crocuda_lib.network.str_to_duid-uuid config.networking.hostName}";
      in [
        "f+ '/var/lib/dhcpcd/duid' 664 ${user} ${group} - ${content}"
      ];
    };
  };
}
