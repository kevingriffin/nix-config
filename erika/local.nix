{ config, pkgs, ... }:

{
  imports = [
    ../modules/eikaiwa-servers.nix
    ../modules/ruby-development.nix
    ../modules/swift.nix
   ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs"];
  boot.loader.grub.device = "nodev";


  boot.initrd.luks.devices = [
    {
      name = "root1";
      device = "/dev/disk/by-uuid/8537440e-66a3-4696-a9cc-69493e8e97f9";
      allowDiscards = true;
    }
    {
      name = "root2";
      device = "/dev/disk/by-uuid/02be44d4-9def-47e7-95cb-413bd54130d0";
      allowDiscards = true;
    }
  ];


  boot.kernelParams = [ "nomodeset" ];

  hardware.cpu.intel.updateMicrocode = true;

  environment.systemPackages = with pkgs; [
     eikaiwa-packages
     seeing_is_believing
     yubikey-manager
     opensc
  ];

  system.activationScripts.userActivationScripts =
          ''
            mkdir -p /usr/lib
            cp ${pkgs.opensc}/lib/opensc-pkcs11.so /usr/lib
          '';

  environment.variables.OPENSC="/usr/lib/opensc-pkcs11.so";

  networking.hostName = "erika";
  networking.hostId = "a5621c46";
  services.pcscd.enable = true;

  system.autoUpgrade = {
    enable = true;
  };


  nix.buildCores = 8;
}
