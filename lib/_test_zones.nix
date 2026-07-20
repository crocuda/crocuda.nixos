{
  lib,
  crocuda_lib,
  ...
}: let
  slib = crocuda_lib.zones;
in
  with slib; {
    testIpv6ToPtr = {
      expr = "2002:7f00:1::";
      expected = "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.0.0.0.f.7.2.0.0.2.ip6.arpa";
    };
    testIpv4ToPtr = {
      expr = ipv4_to_ptr "127.0.0.1";
      expected = "1.0.0.127.in-addr.arpa";
    };
  }
