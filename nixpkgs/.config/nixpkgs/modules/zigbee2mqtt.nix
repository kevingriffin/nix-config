{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.zigbee2mqtt;
    config = {
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
  # Needed to use 20.09 nixOS module with sufficiently new package for my hub
  systemd.services.zigbee2mqtt.environment.ZIGBEE2MQTT_DATA = "/var/lib/zigbee2mqtt";
}
