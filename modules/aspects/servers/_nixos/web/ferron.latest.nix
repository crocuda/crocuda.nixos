{
  pkgs ? import <nixpkgs> {},
  lib,
  ...
}:
with lib;
with pkgs;
  rustPlatform.buildRustPackage rec {
    pname = "ferron";
    version = "2.0.1";

    src = fetchFromGitHub {
      owner = "ferronweb";
      repo = "ferron";
      tag = version;
      # sha256 = lib.fakeSha256;
      sha256 = "sha256-i0tMPc5qWBfdADwqITAKXpN7AAHTOPXNHWGUuYLD0vA=";
      # sha256 = "sha256-t43xXUzXoj0Fxrt/BZaBP1fua2W8HPd1x9bsTV0uUD4=";
    };

    # cargoHash = "";
    cargoHash = "sha256-M2oaKhiwxAYJRvKTdTdzWLcndxmba+sW8rBKoTNOFpc=";
    # cargoHash = "sha256-IYK//lxxmcgMpAAeN8WAbOW4Wi9iS1oZdLCT/iFNw7A=";

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      zstd
    ];

    env = {
      ZSTD_SYS_USE_PKG_CONFIG = true;
    };

    nativeInstallCheckInputs = [
      versionCheckHook
    ];
    versionCheckProgramArg = "--version";

    doCheck = false;
    doInstallCheck = false;

    passthru = {
      updateScript = nix-update-script {};
    };

    meta = {
      description = "Fast, memory-safe web server written in Rust";
      homepage = "https://github.com/ferronweb/ferron";
      changelog = "https://github.com/ferronweb/ferron/releases/tag/${finalAttrs.version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [
        _0x4A6F
        GaetanLepage
      ];
      mainProgram = "ferron";
    };
  }
