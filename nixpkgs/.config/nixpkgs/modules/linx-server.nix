{ config, lib, pkgs, ... }:
let
  kevin-cfg = config.kevin;

  configFile = pkgs.writeText "linx.ini" ''
    bind = 0.0.0.0:6730

    sitename = "files"
    siteurl = "https://files.kevin.jp"

    filespath = /var/www/linx/files/
    metapath = /var/www/linx/meta/

    authfile = /etc/nixos/linx-server-authfile

    cleanup-every-minutes = 5

    realip = true

    basicauth = true
  '';
in
with lib; {
  options = {
    kevin.linx-server = {
      enable = mkOption {
        default = false;
        type = with types; bool;
      };
    };
  };

  config = mkIf kevin-cfg.linx-server.enable {
    environment.systemPackages = with pkgs; [
      linx-server
    ];

    systemd.services.linx-server = {
      enable = true;
      description = "Linx file hosting server";

      serviceConfig = {
        Type = "simple";
        User = "linx";
        WorkingDirectory = "/var/www/linx";
        ExecStart = "${pkgs.linx-server}/bin/linx-server -config ${configFile}";
        Restart = "on-failure";
      };

      after = [ "network.target" ];
      wantedBy = [ "network.target" ];
    };

    users.groups = { linx = {}; };
    users.users.linx = {
      extraGroups = [ "linx" ];
      isSystemUser = true;
    };

    services.nginx.virtualHosts."files.kevin.jp" =
      {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass   = "http://localhost:6730";
        };
        extraConfig = ''
          client_max_body_size 4096M;
        '';
      };
  };
}
