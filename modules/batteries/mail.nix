{...}: {
  crocuda.batteries.mail = {mails, ...}: {
    nixos = {config, ...}: {
      config.crocuda.servers.mails = {
        enable = true;
        accounts = mails;
      };
    };
  };
}
