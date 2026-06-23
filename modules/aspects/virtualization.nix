{crocuda, ...}: {
  crocuda.virtualization.utils = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # Build images based on flakes and local config
        nixos-generators
        rqlite
        disko
        cdrkit
      ];
    };
  };
  crocuda.virtualization.docker = {
    ## Add Users to container group.
    policies.to-users = {user, ...}: {
      nixos = {...}: {
        users.groups = {
          docker.members = user;
        };
      };
    };
    includes = [crocuda.virtualization.docker.policies.to-users];
    nixos = {pkgs, ...}: {
      # Enable docker usage
      virtualisation.docker.enable = true;
      # Enable podman usage
      virtualisation.podman.enable = true;

      ## Autostart containers on docker start.
      systemd.services.docker.postStart = ''
        #!${pkgs.bash}/bin/bash
        set +e # Do not exit if a command fails
        echo "Restarting containers..."
        ${pkgs.docker}/bin/docker restart $(${pkgs.docker}/bin/docker ps -a -q)
        exit 0
      '';
    };
  };
}
