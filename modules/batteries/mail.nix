{crocuda, ...}: {
  crocuda.batteries.mails = mails: {
    imports = [
      crocuda.aspects.mail
    ];
    nixos = {config, ...}: {
      config.crocuda.mails = {
        enable = true;
        accounts = mails;
      };
    };
  };
}
