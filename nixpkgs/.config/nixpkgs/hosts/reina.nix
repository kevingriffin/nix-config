{ config, pkgs, ... }:

{
  imports = [
    ../modules/base-packages.nix
    ../modules/ruby-development.nix
  ];


  environment.systemPackages = with pkgs; [
    gitAndTools.hub
    gitFull
    id3v2
    python3Packages.eyeD3
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."reina.kevin.jp" = {
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
      sslCertificate = "/etc/nginx/lego/certificates/reina.kevin.jp.crt";
      sslCertificateKey = "/etc/nginx/lego/certificates/reina.kevin.jp.key";
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;

  nix.maxJobs = 4;
  nix.buildCores = 3;
}
