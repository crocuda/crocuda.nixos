{...}: {
  crocuda.ssd = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.smartd = {
        enable = true;
        autodetect = true;
      };
      environment.systemPackages = with pkgs; [
        smartmontools
      ];
    };
  };
}
