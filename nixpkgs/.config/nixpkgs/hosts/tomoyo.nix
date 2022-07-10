{ config, pkgs, modulesPath, unstablePkgs, ... }:

{
  imports = [
    ../modules/borg-backup
    ../modules/miniflux.nix
    "${modulesPath}/virtualisation/amazon-image.nix"
    (import ../modules/base-packages.nix { inherit config pkgs; })
  ];

  ec2.hvm = true;
  ec2.efi = true;

  nix.buildCores = 2;

  console.font       = "Lat2-Terminus16";
  console.keyMap     = "us";

  time.timeZone = "Asia/Tokyo";

  networking.hostName = "tomoyo";
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.borgBackup = let
    secrets = import ../secrets.nix;
  in
  {
    enable = true;
    paths = [ "/home/git" "/etc/nixos" "/var/www" ];
    excludedGlobs = [ ".*" ];
    remoteRepo = {
      host         = "hk-s020.rsync.net";
      user         = "20504";
      path         = "tomoyo/git-backups";
      borgPath     = "borg1";
      borgPassword = secrets.borg-password;
    };
  };

  services.postgresql.enable = true;

  services.unifi = {
    enable       = true;
    unifiPackage = unstablePkgs.unifiStable;
    openPorts    = true;
  };

  security.acme.email       = "me@kevin.jp";
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings  = true;

    virtualHosts."kevin.jp" = {
      enableACME = true;
      forceSSL   = true;

      root = "/var/www/kevin.jp";

      locations."/" = {
        index    =  "$lang/index.html";
        tryFiles =  "$lang/$uri $lang/$uri.html $uri $uri.html $uri/ =404";
      };

      extraConfig = ''
        charset UTF-8;

        location ~* \.(jpg|jpeg|png|gif|ico)$ {
          expires 30d;
        }
        location ~* \.(css|js)$ {
          expires 7d;
        }
        '';
    };

    virtualHosts."ffxiv.kevin.jp" = {
      enableACME = true;
      forceSSL   = true;

      root = "/var/www/ffxiv.kevin.jp";

      locations."/" = {
        index    =  "index.html";
      };

      extraConfig = ''
        charset UTF-8;

        location ~* \.(jpg|jpeg|png|gif|ico)$ {
          expires 30d;
        }
        location ~* \.(css|js)$ {
          expires 7d;
        }
        '';
    };

    # proxy_max_temp_file_size needed for http2
    # interface of unifi
    commonHttpConfig = ''
      map $http_accept_language $lang {
        default en;
        "~*^((|,)\s*(?!(ja|en))\w+(-\w+)?(;q=[\d\.]+)?)*(|,)\s*en\b" en;
        "~*^((|,)\s*(?!(ja|en))\w+(-\w+)?(;q=[\d\.]+)?)*(|,)\s*ja\b" ja;
      }
      proxy_max_temp_file_size 0;
    '';

    virtualHosts."unifi.kevin.jp" = {
      enableACME = true;
      forceSSL   = true;
      http2      = true;
      locations."/" = {
        proxyPass       = "https://localhost:8443";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
        '';
      };

      locations."/api" = {
        proxyPass       = "https://localhost:8443/api";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Origin  "";
          proxy_set_header Referer "";
        '';
      };
    };
  };

  users.users.git = {
    isNormalUser = true;
    home         = "/home/git";
    description  = "git";
  };

  system.stateVersion = "22.05";
}
