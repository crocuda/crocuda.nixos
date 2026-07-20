{lib, ...}: let
  # Transform an ipv4 into a PTR record
  ipv4_to_ptr = ipv4:
    lib.concatStrings (lib.lists.reverseList (lib.strings.splitString "." ipv4)) + ".in-addr.arpa";

  # Transform an ipv6 into a PTR record
  ipv6_to_ptr = ipv6: let
    parsed = (lib.network.ipv6.fromString ipv6).address;
    numeric = lib.strings.join (
      lib.lists.remove ":" (
        lib.strings.splitString ":" parsed
      )
    );
    reversed = lib.strings.join "." (
      lib.lists.reverseList (
        lib.strings.splitString "" numeric
      )
    );
  in
    reversed + ".ipv6.arpa";
in {
  inherit ipv4_to_ptr;
  inherit ipv6_to_ptr;
}
