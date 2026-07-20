{crocuda, ...}: {
  crocuda.batteries.mails = mails: {
    includes = [
      crocuda.mails
    ];
    nixos = {config, ...}: {
      config.crocuda.mails = {
        enable = true;
        accounts = mails;
      };
    };
  };
}
