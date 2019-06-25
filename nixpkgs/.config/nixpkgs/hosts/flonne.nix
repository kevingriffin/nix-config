# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
#     ../modules/internet-of-shit.nix
#     ../modules/home-assistant.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "flonne"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:
  # Behaves terribly on a disk-constrained system
  services.udisks2.enable = false;

  networking.firewall.allowedTCPPorts = [ 22 17569 ];
  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };


  # networking.dhcpcd.denyInterfaces = [ "ens224" ];
  networking.dhcpcd.extraConfig = ''
    interface ens224
      noipv4
      ipv6ra_noautoconf
  '';

  services.ndppd = {
    enable = true;
    configFile = pkgs.writeText "ndppd.conf" ''
      proxy ens224 {
        target_hwaddr 00:0C:29:CF:64:31
        timeout 1000
        rule 2404:7a80:3440:4a00::/64 {
          # iface ens192
          static
        }
      }
    '';
  };

  systemd.services.ndppd.serviceConfig.Restart = "always";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
