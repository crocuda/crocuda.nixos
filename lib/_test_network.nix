{
  lib,
  crocuda_lib,
  ...
}: let
  slib = crocuda_lib.network;
  secret = "vm-nixos";
  hash = "70cc2860c2371bf7872597545f76774c";
in
  with slib; {
    testStrToHash = {
      expr = _str_to_hash secret;
      expected = hash;
    };
    testHashToMac = {
      expr = str_to_mac secret;
      expected = "72:cc:28:60:c2:37";
    };
    testHashToIpv6 = {
      expr = str_to_ipv6 secret;
      expected = "70cc:2860:c237:1bf7:8725:9754:5f76:774c";
    };
    testHashToDuidUuid = {
      expr = str_to_duid-uuid secret;
      expected = "00:04:70:cc:28:60:c2:37:1b:f7:87:25:97:54:5f:76:77:4c";
    };
  }
