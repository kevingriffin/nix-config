{ config, pkgs, lib, unstablePkgs, ... }:

{
  imports =
    [
     ../nix-mape/nixos-modules
     ../modules/router.nix
     ../modules/dns.nix
     ../modules/borg-backup
     ../modules/router-wireguard.nix
     (import ../modules/base-packages.nix { inherit config pkgs; })
     (import ../modules/zigbee2mqtt.nix { inherit config; pkgs = unstablePkgs; })
     (import ../modules/hass.nix { inherit config pkgs unstablePkgs; })
    ];


  boot.loader.grub.enable                = true;
  boot.loader.grub.version               = 2;
  boot.loader.grub.efiSupport            = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device                = "nodev"; # or "nodev" for efi only
  boot.loader.efi.canTouchEfiVariables   = false;

  networking.hostName = "pleinair";

  time.timeZone = "Asia/Tokyo";

  services.openssh.enable = true;

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
  };

  services.borgBackup = let
    secrets = import ../secrets.nix;
  in
  {
    enable = true;
    paths = [ "/var/lib/hass" ];
    excludedGlobs = [ "configuration.yaml" ];
    remoteRepo = {
      host         = "hk-s020.rsync.net";
      user         = "20504";
      path         = "pleinair";
      borgPath     = "borg1";
      borgPassword = secrets.borg-password;
    };
  };

  networking.mape.nftables =
  let
    inherit (import ../router-constants.nix) upstreamIf internalIf;
    renderPorts = ports: map toString ports;
    renderPortRanges = ranges: map ({ from, to }: "${toString from}-${toString to}") ranges;
    allow = proto: ports: ranges: lib.optionalString (ports != [] || ranges != []) ''
      ${proto} dport { ${lib.concatStringsSep "," (renderPorts ports ++ renderPortRanges ranges) } } \
        counter accept comment "networking.firewall allowed ports"
    '';
  in
    {
      tables.filter.chains.input.rules = ''
        icmp type echo-request accept
        tcp dport 22 accept
        udp dport mdns accept
      ''
      + allow "udp" config.networking.firewall.allowedUDPPorts config.networking.firewall.allowedUDPPortRanges
      + allow "tcp" config.networking.firewall.allowedTCPPorts config.networking.firewall.allowedTCPPortRanges;
    };

   users.users.kevin = {
     isNormalUser = true;
     extraGroups = [ "wheel" ];
   };

  system.stateVersion = "20.09";

}
