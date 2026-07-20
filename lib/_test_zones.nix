{
  lib,
  crocuda_lib,
  ...
}: let
  slib = crocuda_lib.zones;
in
  with slib; {
    testIpv4ToPtr = {
      expr = ipv4_to_ptr "127.0.0.1";
      expected = "1.0.0.127.in-addr.arpa";
    };
    testExpandIpv6 = {
      expr = _parse_and_expand_ipv6 "2002:7f00:1::";
      expected = "2002:7f00:0001:0000:0000:0000:0000:0000";
    };
    testIpv6ToPtr = {
      expr = ipv6_to_ptr "2002:7f00:1::";
      expected = "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.0.0.0.f.7.2.0.0.2.ip6.arpa";
    };
  }
