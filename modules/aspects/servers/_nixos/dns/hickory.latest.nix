{
  pkgs ? import <nixpkgs> {},
  lib,
  ...
}:
with lib;
with pkgs;
  rustPlatform.buildRustPackage rec {
    pname = "hickory-dns";
    # version = "0.26.0-alpha.1";
    version = "main";

    src = fetchFromGitHub {
      owner = "hickory-dns";
      repo = "hickory-dns";

      rev = "branch/main";
      hash = "sha256-wjLG60eY9AYPk7ha4e6HsH3W5rMloOITcJ8f8wFmj1g=";

      # tag = "v${version}";
      # hash = "sha256-tXBGnrD0KrIhRKBEeq+jLSgFWHFTRUU6AGiAGEALIwk=";
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    # Remove doc params causing failure
    preBuild = ''
      sed -i "s/doc![.*]//" /build/ferron-2.1.0-vendor/monoio-0.2.4/src/lib.rs
    '';

    useFetchCargoVendor = true;
    cargoHash = "sha256-jxGyn7qDJAI4LtO+j4CL5plzMcQ6v7DUsq1dAYFyMPY=";

    # cargoHash = "sha256-p3IDm+C8266Lh2To0Vho0SNL91VRktMljpI89J/A0u4=";
    # cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    buildInputs = [openssl];
    nativeBuildInputs = [pkg-config];
    allowBuiltinFetchGit = true;

    # tests expect internet connectivity to query real nameservers like 8.8.8.8
    doCheck = false;

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "Rust based DNS client, server, and resolver";
      homepage = "https://hickory-dns.org/";
      maintainers = with lib.maintainers; [colinsane];
      platforms = lib.platforms.linux;
      license = with lib.licenses; [
        asl20
        mit
      ];
      mainProgram = "hickory-dns";
    };
  }
