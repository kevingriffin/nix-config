{ pkgs, ... }:
let
  inherit (import ../router-constants.nix) localv4Address v6Address;
in
{
  services.dnsmasq = {
    enable = true;

    settings = {
      server = [
        "8.8.8.8"
        "8.8.4.4"
        "2001:4860:4860::8888"
        "2001:4860:4860::8844"
      ];

      bind-interfaces = true;

      listen-address = [
        v6Address
        localv4Address
        "127.0.0.1"
        "::1"
      ];

      conf-file = "${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf";

      dnssec = true;

      domain = "kevin.jp";

      dhcp-authoritative = true;

      dhcp-range = [
        "192.168.11.50,192.168.11.200,255.255.255.0,192.168.11.255,12h"
        "::,static"
      ];

      dhcp-host = [
        "74:4D:28:FA:46:85,192.168.11.2" # switch
        "F0:2F:74:FA:14:63,192.168.11.80" # umaru
        "64:4B:F0:19:F4:9D,192.168.11.92" # tsukihi
        "90:48:9A:85:70:1A,192.168.11.94" # tvb928217d081b
        "00:0E:C6:E5:58:F4,192.168.11.98"
        "00:22:CF:F6:C4:C9,192.168.11.96"
        "38:56:10:00:88:89,192.168.11.70" # sesame wifi       
      ];

      dhcp-option = [
        "option:router,${localv4Address}"
        "option:ntp-server,${localv4Address}"
        "option6:ntp-server,${v6Address}"
        "option6:dns-server,${v6Address}"
        "option6:domain-search,kevin.jp"
      ];

      no-resolv = true;
      cache-size = 10000;
      quiet-dhcp = true;
    };
  };

  # dnsmasq is configured to bind to the slaac'd address, which
  # might take a small delay to come up. If it persistently fails,
  # we should fail loudly though.
  #
  # These rules encode:
  #   - wait 5 seconds beteween restarts
  #   - if restarted more than 10 times in 5 minutes, fail hard.
  #
  # This is sane, because 10 immediate restarts take 10*5 = 50
  # seconds < 300 seconds.
  systemd.services.dnsmasq = {
    unitConfig = {
      StartLimitIntervalSec = "300"; # 5 minutes
      StartLimitBurst = 10;
    };
    serviceConfig = {
      RestartSec = "5s";
    };
  };


  services.prometheus.exporters.dnsmasq = {
    enable = true;
    leasesPath = "/var/lib/dnsmasq/dnsmasq.leases";
  };
}
