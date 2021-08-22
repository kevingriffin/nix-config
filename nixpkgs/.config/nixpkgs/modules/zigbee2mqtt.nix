{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.zigbee2mqtt;
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
