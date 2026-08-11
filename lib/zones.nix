## Tests:
# nix-unit --flake ".#tests" \
#       --override-input crocuda ../crocuda.nixos
#
{lib, ...}: let
  # Transform an ipv4 into a PTR record
  ipv4_to_ptr = ipv4: let
    numeric = lib.strings.splitString "." ipv4;
    reversed = lib.strings.join "." (
      lib.lists.reverseList numeric
    );
  in
    reversed + ".in-addr.arpa";

  # Expand 0.
  _parse_and_expand_ipv6 = ipv6: let
    _parts = lib.strings.splitString ":" (
      (lib.network.ipv6.fromString ipv6).address
    );
    expanded = lib.strings.join ":" (
      lib.lists.forEach _parts
      (
        x:
          if builtins.stringLength x < 4
          then
            ## add zero
            lib.concatStrings (
              lib.replicate (4 - (builtins.stringLength x)) "0"
            )
            + x
          else x
      )
    );
  in
    expanded;

  # Transform an ipv6 into a PTR record
  ipv6_to_ptr = ipv6: let
    parsed = _parse_and_expand_ipv6 ipv6;
    numeric = lib.concatStrings (
      lib.lists.remove ":" (
        lib.strings.splitString ":" parsed
      )
    );
    reversed = lib.strings.join "." (
      lib.lists.reverseList (
        lib.strings.stringToCharacters numeric
      )
    );
  in
    reversed + ".ip6.arpa";
in {
  inherit ipv4_to_ptr;

  inherit _parse_and_expand_ipv6;
  inherit ipv6_to_ptr;
}
