{...}: {
  crocuda.privacy.tor = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        # Tor
        torsocks
        tor-browser
      ];
      ## Tor background service
      services.tor = {
        enable = true;
      };
    };
  };
}
