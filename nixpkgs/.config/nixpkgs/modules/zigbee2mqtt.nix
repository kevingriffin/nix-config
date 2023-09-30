{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = true;
      permit_join   = false;
      serial        = {
        port = "/dev/ttyACM0";
      };
      mqtt = {
        user = "zigbee";
        server = "mqtt://127.0.0.1:1883";
        password = secrets.mosquitto-password;
      };
    };
  };
}
