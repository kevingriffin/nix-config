{ config, lib, pkgs, ... }:

let
  inherit (import ../router-constants.nix) upstreamIf;
  wireguardPrefix = "2404:7a80:32e1:6601";
  wireguard4Addr = ordinal: "192.168.2.${toString ordinal}";
  wireguard6Addr = ordinal: "${wireguardPrefix}::${toString ordinal}";
  wireguardPort = 50798;

  peers = (builtins.fromJSON (builtins.readFile "/home/kevin/identities/wireguard-hosts.json"));
in
{

  environment.systemPackages = [ pkgs.wireguard-tools ] ;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "${wireguardPrefix}::1/64" ];
      listenPort = wireguardPort;
      privateKeyFile = "/etc/nixos/wireguard-private-key";

      peers = lib.mapAttrsToList (n: { ordinal, publicKey, ... }: {
        inherit publicKey;
        allowedIPs = [
          "${wireguard4Addr ordinal}/32"
          "${wireguard6Addr ordinal}/128"
        ];
      }) peers;

      postSetup = ''
        ${pkgs.iproute}/bin/ip link set wg0 mtu ${toString (1420 - 20)}
      '';
    };
  };

  networking.mape.nftables = {
    tables.filter.sets.wireguard-v6-full-access = {
      type = "ipv6_addr";
      elements = lib.mapAttrsToList (_: cfg: wireguard6Addr cfg.ordinal) peers;
    };

    tables.filter.sets.wireguard-v4-full-access = {
      type = "ipv4_addr";
      elements = lib.mapAttrsToList (_: cfg: wireguard4Addr cfg.ordinal) peers;
    };

    tables.filter.chains.input.rules = ''
      udp dport ${toString wireguardPort} counter accept comment "wireguard"
    '';

    tables.filter.chains.forward.rules = ''
      ip6 saddr @wireguard-v6-full-access counter accept comment "wireguard clients full access"
      ip  saddr @wireguard-v4-full-access counter accept comment "wireguard clients full access"
    '';
  };

  services.prometheus.exporters.wireguard = {
    enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.wireguard.port
  ];
}
