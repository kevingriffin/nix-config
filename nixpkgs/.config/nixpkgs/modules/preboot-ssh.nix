{ config, pkgs, lib, ... }:

with lib;

let
  kevin-cfg = config.kevin;

  prebootSshSubmodule = with lib.types; submodule {
    options = {
      enable = mkEnableOption "Pre-boot SSH";
      identityFile = mkOption { type = str; };
    };
  };

  identities = path: (map (x: x.key) (builtins.fromJSON (builtins.readFile path)));
in
{
  options = with lib.types; {
    kevin = {
      preboot-ssh = mkOption {
        type = prebootSshSubmodule;
        default = {};
      };
    };
  };

  config = lib.mkIf kevin-cfg.preboot-ssh.enable {
    boot.initrd = {
      availableKernelModules = [ "vmxnet3" "virtio_pci" "e1000" ];

      network.enable = true;

      network.ssh = {
        enable = true;
        port = 2022;
        authorizedKeys = (identities kevin-cfg.preboot-ssh.identityFile);
        hostKeys = [ /etc/nixos/ecdsa_host_key ];
      };
    };
  };
}
