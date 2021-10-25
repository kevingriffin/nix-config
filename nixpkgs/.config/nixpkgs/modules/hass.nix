{ config, pkgs, unstablePkgs, ... }:
{
  imports = [
    (builtins.fetchGit {
      url = "https://github.com/thefloweringash/hass_ir_adapter";
      ref = "master";
      rev = "3ad4405119cc10b055dd9d5945c4f291e0f714ae";
    } + "/nix/module.nix")
  ];

  security.acme.email       = "me@kevin.jp";
  security.acme.acceptTerms = true;

  services.nginx = {
    enable                   = true;
    recommendedProxySettings = true;
    virtualHosts."hass.kevin.jp" = {
      forceSSL   = true;
      enableACME = true;
      locations."/" = {
        proxyPass       = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };
    virtualHosts."mqtt.kevin.jp" = {
      forceSSL   = true;
      enableACME = true;
      locations."/" = {
        proxyPass       = "http://127.0.0.1:1883";
        proxyWebsockets = true;
      };
    };
  };

  services.mosquitto = let
    secrets = import ../secrets.nix;
  in
  {
    enable         = true;
    host           = "0.0.0.0";
    allowAnonymous = true;
    checkPasswords = true;
    ssl = {
      enable = false;
    };

    aclExtraConf = ''
      topic read $SYS/#
      topic read homie/#
      topic read ir/#
      topic read sht/#
      topic read homeassistant/#
    '';

    users.hass = {
      acl = [
        "topic readwrite homeassistant/#"
        "topic readwrite zigbee2mqtt/#"
        "topic read homie/#"
        "topic read sht/#"
        "topic readwrite tasmota/#"
      ];
      hashedPassword = secrets.mosquitto-hass-ir-hashed-password;
    };

    users.zigbee = {
      acl = [
        "topic readwrite homeassistant/#"
        "topic readwrite zigbee2mqtt/#"
        "topic read homie/#"
        "topic read sht/#"
      ];
      hashedPassword = secrets.mosquitto-hass-ir-hashed-password;
    };

    users.hass_ir_adapter = {
      acl = [
        "topic readwrite homeassistant/#"
        "topic readwrite ir/#"
        "topic read sht/#"
        "topic read homie/#"
        "topic readwrite tasmota/#"
      ];
      hashedPassword = secrets.mosquitto-hass-ir-hashed-password;
    };

    users.tasmota = {
      acl = [
        "topic readwrite homeassistant/#"
        "pattern readwrite tasmota/%c/#"
      ];
      hashedPassword = secrets.mosquitto-hass-ir-hashed-password;
    };
  };

  services.home-assistant = let
    withoutTests = pkg: pkg.overrideAttrs (attrs: {
      doCheck        = false;
      doInstallCheck = false;
    });

    pysesame2  = pythonPackages: pythonPackages.callPackage ./packages/pysesame2_python.nix { };

    hassPkg = withoutTests (unstablePkgs.home-assistant.override {
     extraComponents = [
       "automation" "config" "conversation" "discovery" "frontend"
       "group" "history" "homeassistant" "homekit"
       "logbook" "map" "mqtt" "notify" "prometheus" "sun" "tasmota"
       "tts" "homekit_controller" "braviatv" "ffmpeg" "sesame" "dhcp"
       "default_config" "zha"
     ];

     extraPackages = ps: with ps; [ pkgs.ffmpeg (pysesame2 ps) ];
    });

    secrets = import ../secrets.nix;
  in
  {
    enable              = true;
    package             = hassPkg;
    autoExtraComponents = false;

    config = {
      homeassistant = {
        name        = "Home";
        latitude    = 35.653063;
        longitude   = 139.669092;
        elevation   = 33;
        unit_system = "metric";
        time_zone   = "Asia/Tokyo";

        customize = {
          ${"media_player.sony_bravia_tv"} = {
            device_class = "tv";
            friendly_name = "Bravia";
            source_list = [
              "HDMI1/MHL"
              "HDMI2"
              "HDMI3"
              "HDMI4"
            ];
          };
        };
      };


      default_config = {};

      http = {
        base_url            = "https://hass.kevin.jp";
        use_x_forwarded_for = true;
        trusted_proxies     = "127.0.0.1";
      };

      discovery = {};

      # disable due to split network mDNS
      zeroconf = {
        default_interface = false;
      };

      mqtt = {
        broker    = "127.0.0.1";
        username  = "hass";
        password  = secrets.mosquitto-password;
        discovery = true;
      };

      homekit = {
        name = "Hass-Bridge";

        filter = {
          include_entities = [
            "climate.bedroom"
            "climate.living_room"
            "climate.family_room"
            "climate.spare_room"
            "climate.study"
            "light.bedroom"
            "light.study"
            "light.living_room"
            "light.dining_room"
            "light.family_room"
            "lock.front_top"
            "media_player.sony_bravia_tv"
            "input_boolean.switch_1_button_4"
            "input_boolean.switch_1_button_3"
            "input_boolean.switch_1_button_2"
            "input_boolean.switch_1_button_1"
          ];
        };
      };

      lock = [
        {
          platform = "sesame";
          api_key  = secrets.sesame-token;
        }
      ];

      group = {};

      automation = [
        {
          id = "switch_1_button_4";
          alias = "switch_1_button_4";
          trigger = {
            platform = "mqtt";
            topic = "zigbee2mqtt/0xbc33acfffe28bd75";
          };

          condition = {
            condition = "template";
            value_template = "{{ trigger.payload_json['action'] == '4_single' }}";
          };

          action = {
            service = "input_boolean.toggle";
            target = {
              entity_id = "input_boolean.switch_1_button_4";
            };
          };
        }
        {
          id = "switch_1_button_3";
          alias = "switch_1_button_3";
          trigger = {
            platform = "mqtt";
            topic = "zigbee2mqtt/0xbc33acfffe28bd75";
          };

          condition = {
            condition = "template";
            value_template = "{{ trigger.payload_json['action'] == '3_single' }}";
          };

          action = {
            service = "input_boolean.toggle";
            target = {
              entity_id = "input_boolean.switch_1_button_3";
            };
          };
        }
        {
          id = "switch_1_button_2";
          alias = "switch_1_button_2";
          trigger = {
            platform = "mqtt";
            topic = "zigbee2mqtt/0xbc33acfffe28bd75";
          };

          condition = {
            condition = "template";
            value_template = "{{ trigger.payload_json['action'] == '2_single' }}";
          };

          action = {
            service = "input_boolean.toggle";
            target = {
              entity_id = "input_boolean.switch_1_button_2";
            };
          };
        }
        {
          id = "switch_1_button_1";
          alias = "switch_1_button_1";
          trigger = {
            platform = "mqtt";
            topic = "zigbee2mqtt/0xbc33acfffe28bd75";
          };

          condition = {
            condition = "template";
            value_template = "{{ trigger.payload_json['action'] == '1_single' }}";
          };

          action = {
            service = "input_boolean.toggle";
            target = {
              entity_id = "input_boolean.switch_1_button_1";
            };
          };
        }
      ];

      input_boolean = {
        switch_1_button_4 = {
          name = "Switch 1 Button 4";
        };
        switch_1_button_3 = {
          name = "Switch 1 Button 3";
        };
        switch_1_button_2 = {
          name = "Switch 1 Button 2";
        };
        switch_1_button_1 = {
          name = "Switch 1 Button 1";
        };
      };

      script     = {};

      light = [
        {
          platform      = "mqtt";
          name          = "Family Room";
          payload_on    = "0,+9055-4530+570-1690C-580+545eF-585FdCgFdCgFgFdCdC-560CdC-1695CdCeFg+540gFhChCdCeFeFeFhChCeFeFhCh+565eFgFdCgFeFgFgFgFgFgFgFhCgFg+550eFhCe+695-410ChCgFdCdChCiCdCh+575";
          payload_off   = "0,+9045-4530+580-1680+605-520C-550CgE-1655CgCd+610fIfCdCdCg+575dCdCdCgJgJgJgJ-555G-1710GcGjGcGcGc+545cGcMcGcGcMcGeFlGcGcMeFeFcGcMeFeFcMeFiFcMcMeF-1715+570-1695O-1690OqO-560M-1720+565qO-585+515";
          command_topic = "tasmota/ir1/cmnd/irsend";
        }
        {
          platform      = "mqtt";
          name          = "Dining Room";
          payload_on    = "0,+3420-1710+390-425C-1320CeCd+365-1345CdCdF-450+360gFhFhCdFhFgFhFgFhFhFhIhIhFhIhFhCeFgFhIgFhFgCeFhF";
          payload_off   = "0,+3390-1735+390-425+365-1345EfCdEfCdE-450EgEfEgCdEgEgC-1320CdEf+360gCdE-455IgEgCdEgCdEfChEgChCdEfChCdC";
          command_topic = "tasmota/ir6/cmnd/irsend";
        }
        {
          platform      = "mqtt";
          name          = "Bedroom";
          payload_on    = "0,+9025-4525+545-590C-1720CdC-610+520fG-585CdC-1715CiChCiCeCfGiCiCdCiCdCiCiCiCeChCiCd+540iCfGfGdJhCi+570-565J-42035+8990-2240K";
          payload_off   = "0,+9025-4520+550-585+545-1715CdCdEdE-610+520dEfCfEdEfEfCgHfCfCdCdEfCfCfEfCfCgHfCfCgHdEdEdEgHfEgH-42035+8970-2260C";
          command_topic = "tasmota/ir3/cmnd/irsend";
        }
      ];
    };
  };

  services.hass_ir_adapter = let
    secrets = import ../secrets.nix;
  in
  {
    enable = true;
    config = ''
      mqtt:
        broker: tcp://127.0.0.1:1883
        username: hass_ir_adapter
        password: ${secrets.mosquitto-password}
      emitters:
        - id: tasmota_ir1
          type: tasmota
          topic: tasmota/ir1/cmnd
        - id: tasmota_ir2
          type: tasmota
          topic: tasmota/ir2/cmnd
        - id: tasmota_ir3
          type: tasmota
          topic: tasmota/ir3/cmnd
        - id: tasmota_ir4
          type: tasmota
          topic: tasmota/ir4/cmnd
        - id: tasmota_ir5
          type: tasmota
          topic: tasmota/ir5/cmnd
      aircons:
        - id: living_room_ac
          name: "Living Room"
          emitter: tasmota_ir5
          type: tasmota_hvac
          temperature_topic: tasmota/ir5/tele/SENSOR
          temperature_template: |-
            {{ value_json['SHT3X-0x45'].Temperature }}
          vendor: MITSUBISHI_AC
        - id: study_ac
          name: "Study"
          emitter: tasmota_ir4
          type: tasmota_hvac
          temperature_topic: tasmota/ir4/tele/SENSOR
          temperature_template: |-
            {{ value_json['SHT3X-0x45'].Temperature }}
          vendor: MITSUBISHI_AC
        - id: bedroom_ac
          name: "Bedroom"
          emitter: tasmota_ir3
          type: tasmota_hvac
          temperature_topic: tasmota/ir3/tele/SENSOR
          temperature_template: |-
            {{ value_json['SHT3X-0x45'].Temperature }}
          vendor: MITSUBISHI_AC
        - id: family_room_ac
          name: "Family Room"
          emitter: tasmota_ir1
          type: tasmota_hvac
          temperature_topic: tasmota/ir1/tele/SENSOR
          temperature_template: |-
            {{ value_json['SHT3X-0x45'].Temperature }}
          vendor: MITSUBISHI_AC
        - id: spare_room_ac
          name: "Spare Room"
          emitter: tasmota_ir2
          type: tasmota_hvac
          temperature_topic: tasmota/ir2/tele/SENSOR
          temperature_template: |-
            {{ value_json['SHT3X-0x45'].Temperature }}
          vendor: MITSUBISHI_AC
      lights:
        - id: living_room_lights
          name: "Living Room"
          type: daiko
          emitter: tasmota_ir5
          channel: 1
        - id: study_lights
          name: "Study"
          type: daiko
          emitter: tasmota_ir4
          channel: 1
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80 443           # nginx
    1883             # mqtt
    8123 21063 21064 # home-assistant
  ];

  networking.firewall.allowedUDPPorts = [
    5353 # home-assistant
  ];
}
