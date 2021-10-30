{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
  # nixpkgs currently doesn't package
  # a new enough version for TS004F
  package = pkgs.callPackage ./packages/zigbee2mqtt {};
in
{
  services.zigbee2mqtt = {
    enable = true;
    package = package;
    settings = {
      homeassistant = true;
      permit_join   = false;
      serial        = {
        port = "/dev/ttyACM0";
      };
      mqtt = {
        user = "zigbee";
        password = secrets.mosquitto-password;
      };
    };
  };
}
