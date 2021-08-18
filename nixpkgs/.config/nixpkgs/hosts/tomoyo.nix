{ config, pkgs, unstablePkgs, ... }:

{
  imports = [
    ../modules/preboot-ssh.nix
    ../modules/vpn.nix
    ../modules/prometheus.nix
    ../modules/matrix-synapse.nix
    ../modules/borg-backup
    ../modules/znc.nix
    ../modules/linx-server.nix
    ../modules/miniflux.nix
    (import ../modules/base-packages.nix { inherit config pkgs; })
   ];

  boot.loader.grub.enable  = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device  = "/dev/vda";

  boot.initrd.luks.devices = {
    rootdev = {
    device  = "/dev/vda2";
    preLVM  = true;
    };
  };

  nix.buildCores = 2;

  console.font       = "Lat2-Terminus16";
  console.keyMap     = "us";

  environment.systemPackages = with pkgs; [
     _1password
     socat
     iknow-devops
     phraseapp_updater
     gitAndTools.diff-so-fancy
     unstablePkgs.gitAndTools.hub
     gitFull
     git-lfs
  ];

  time.timeZone = "Asia/Tokyo";

  networking.hostName = "tomoyo";
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  kevin.linx-server.enable = true;

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

  services.prometheus.exporters.node = {
    enable       = true;
    openFirewall = false;
  };

  services.grafana = {
    enable                = true;
    port                  = 4000;
    addr                  = "[::]";
    domain                = "grafana.kevin.jp";
    rootUrl               = "https://grafana.kevin.jp";
    auth.anonymous.enable = false;
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

    virtualHosts."tomoyo.kevin.jp" = {
      enableACME = true;
      forceSSL   = true;

      locations."/" = {
        proxyPass = "http://localhost:3000";
      };

      locations."/prometheus" = {
        proxyPass   = "http://localhost:9090";
        extraConfig = ''
          auth_basic           "Prometheus";
          auth_basic_user_file /etc/nixos/.htpasswd;
          '';
      };

      locations."/grafana" = {
        proxyPass   = "http://localhost:4000";
        extraConfig = ''
          rewrite  ^/grafana/(.*)  /$1 break;
          '';
      };
    };

    virtualHosts."grafana.kevin.jp" = {
      enableACME = true;
      forceSSL   = true;

      locations."/" = {
        proxyPass   = "http://localhost:4000";
      #   extraConfig = ''
      #     rewrite  ^/grafana/(.*)  /$1 break;
      #     '';
      };
    };

    virtualHosts."prometheus.kevin.jp" = {
      enableACME = true;
      forceSSL   = true;


      locations."/" = {
        proxyPass   = "http://localhost:9090";
        extraConfig = ''
          auth_basic           "Prometheus";
          auth_basic_user_file /etc/nixos/.htpasswd;
          '';
      };
    };

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

  kevin.preboot-ssh = {
    enable       = true;
    identityFile = "/home/kevin/identities/ssh.json";
  };

  kevin.iknow-vpn = {
    enable     = true;
    ips        = [ "192.168.1.165/32" "2001:19f0:7001:3571:c0fe:0:f00:5/128" ];
    allowedIPs = [ "0.0.0.0/0" "::/0" ];
  };

  kevin.vpn-host = {
    enable         = true;
    prefix         = "2001:19f0:7001:4b5d:1000";
    prefixLength   = 68;
    v4Base         = "192.168.2";
    port           = 52337;
    upstreamIfname = "ens3";
    neighborProxy  = true;

    peers = (builtins.fromJSON (builtins.readFile "/home/kevin/identities/wireguard-hosts.json"));
  };

  users.users.git = {
    isNormalUser = true;
    home         = "/home/git";
    description  = "git";
  };

  system.stateVersion = "19.03";
}
