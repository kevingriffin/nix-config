{ config, pkgs, ... }:

{

  imports = [
    ../modules/base-packages.nix
    ../modules/ruby-development.nix
  ];

  nix.extraOptions = "extra-platforms = x86_64-darwin aarch64-darwin";

  environment.systemPackages = with pkgs; [
     branchctl
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
    virtualHosts."rinoa.kevin.jp" = {
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
      locations."/socket.io" = {
        proxyPass = "http://localhost:3002";
        proxyWebsockets = true;
      };
      sslCertificate = "/etc/nginx/lego/certificates/rinoa.kevin.jp.crt";
      sslCertificateKey = "/etc/nginx/lego/certificates/rinoa.kevin.jp.key";
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs    = 8;
  nix.buildCores = 8;

}
