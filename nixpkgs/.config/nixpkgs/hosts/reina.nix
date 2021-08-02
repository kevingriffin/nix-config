{ config, pkgs, ... }:

{
  imports = [
    ../modules/base-packages.nix
    ../modules/ruby-development.nix
  ];


  environment.systemPackages = with pkgs; [
    id3v2
    pythonPackages.eyeD3
    opensc
  ];

  system.activationScripts.extraActivation.text = with pkgs; ''
    if ! (cmp -s ${opensc}/lib/pkcs11/opensc-pkcs11.so /usr/local/lib/opensc-pkcs11.so) ; then
      rm /usr/local/lib/opensc-pkcs11.so
      cp ${opensc}/lib/pkcs11/opensc-pkcs11.so /usr/local/lib
    fi
  '';

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

  nix.maxJobs = 8;
  nix.buildCores = 8;
}
