{ config, pkgs, unstablePkgs, ... }:

{
  imports = [
    ../modules/preboot-ssh.nix
    ../modules/vpn.nix
    (import ../modules/ruby-development.nix { inherit config pkgs unstablePkgs; })
    (import ../modules/weechat.nix          { inherit config; pkgs = unstablePkgs; })
    (import ../modules/base-packages.nix { inherit config; pkgs = unstablePkgs; })
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device              = "nodev";

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.enableUnstable = true;

  boot.initrd.luks.devices = {
    root1 = {
      device = "/dev/disk/by-uuid/8537440e-66a3-4696-a9cc-69493e8e97f9";
      allowDiscards = true;
    };
    root3 = {
      device = "/dev/disk/by-uuid/fa6207ba-af6f-4c9d-b3c6-db9062ce4608";
      allowDiscards = true;
    };
  };

  boot.kernelParams = [ "nomodeset" ];
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
  };

  hardware.cpu.intel.updateMicrocode = true;

  console.packages   = with pkgs; [ source-code-pro ];
  console.font       = "source-code-pro";
  console.keyMap     = "jp106";

  fonts.fonts = with pkgs; [
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
  ];

  programs.fish = {
    useBabelfish = true;
  };

  time.timeZone = "Asia/Tokyo";

  security.acme.email       = "me@kevin.jp";
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = with pkgs; [
    gitAndTools.diff-so-fancy
    unstablePkgs.gitAndTools.hub
    gitFull
    git-lfs
    seeing_is_believing
    yubikey-manager
    opensc
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."erika.kevin.jp" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
      locations."/socket.io" = {
        proxyPass = "http://localhost:3002";
        proxyWebsockets = true;
      };
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
  };

  # Set up opensc each activation with
  # newly built version
  system.activationScripts.userActivationScripts =
          ''
            mkdir -p /usr/lib
            if ! (cmp -s ${pkgs.opensc}/lib/opensc-pkcs11.so /usr/lib/opensc-pkcs11.so) ; then
              cp ${pkgs.opensc}/lib/opensc-pkcs11.so /usr/lib
            fi
          '';

  environment.variables.OPENSC="/usr/lib/opensc-pkcs11.so";

  kevin.preboot-ssh = {
    enable = false;
    identityFile = "/home/kevin/identities/ssh.json";
  };

  kevin.iknow-vpn = {
    enable = false;
    ips    = [ "192.168.1.169/32" "2001:19f0:7001:3571:c0fe:0:f00:9/128" ];
    allowedIPs  = [ "0.0.0.0/0" "::/0" ];
  };

  kevin.tomoyo-vpn = {
    enable     = false;
    ips    = [ "192.168.2.5/32" "2001:19f0:7001:4b5d:1000::5/128"];
    allowedIPs  = [ "0.0.0.0/0" "::/0" ];
  };


  networking.hostName = "erika";
  networking.hostId = "a5621c46";

  services.pcscd.enable = true;

  system.autoUpgrade = {
    enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "Monday 03:15";
    options = "--delete-older-than 7d";
  };

  nix.buildCores = 8;

  system.stateVersion = "19.03";
}
