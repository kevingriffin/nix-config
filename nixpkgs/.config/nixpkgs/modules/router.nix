{ config, lib, pkgs, ... }:
let
  inherit (import ../router-constants.nix) upstreamIf internalIf v4Address v6Address brAddress lowPort highPort local4Network;
  hosts = import ../hosts.nix;
in
{
  nixpkgs.overlays = [ (self: super: {
    dhcpcd = super.dhcpcd.overrideAttrs (attrs: {
      configureFlags = (attrs.configureFlags or []) ++ [ "--disable-auth" ];
      patches = (attrs.patches or []) ++ [ ./dhcpcd-no-default-options.patch ];
    });
  }) ];

  networking.firewall.rejectPackets = true;

  networking.mape.tunnel = {
    enable = true;
    upstreamInterface = upstreamIf;
    v4 = v4Address;
    v6 = v6Address;
    br = brAddress;
    ports = {
      low  = lowPort;
      high = highPort;
    };
  };

  networking.useDHCP = true;
  networking.dhcpcd.enable = true;
  networking.dhcpcd.extraConfig = ''
    nohook resolv.conf
    noipv6rs
    nodhcp
    noipv4
    duid ll
    interface ${upstreamIf}
      ipv6rs
      nooption dhcp6_vivco
      option dhcp6_rapid_commit
      ia_pd 1 ${internalIf}/0/64
  '';

  services.radvd.enable = true;
  services.radvd.config = ''
    interface ${internalIf} {
      AdvSendAdvert on;
      prefix ::/64 {};
    };
  '';

  systemd.network = {
    enable = true;

    networks.internal = {
      matchConfig.Name = internalIf;
      networkConfig.Address = local4Network;
      networkConfig.IPForward = "yes";
    };
  };

  networking.mape.nftables = {
    tables.filter.chains.input.rules = with hosts.v6; ''
      ip6 saddr { 240e:f7:4f01:c::/64, 240e:d9:d800:200::/64 } counter drop comment "china probes"
      iif ${internalIf} ct state new accept
      tcp dport 22 ip6 daddr ${pleinair} counter accept;
      tcp dport 9100 ip6 daddr ${pleinair} counter accept;
    '';

    tables.filter.chains.forward.rules = ''
      ip6 saddr { 240e:f7:4f01:c::/64, 240e:d9:d800:200::/64 } counter drop comment "china probes"

      iif ${internalIf} ct state new accept
      ct status dnat log prefix "allowing dnat connection: " accept

      # take all of rfc4890 here. It's quite likely that the standard
      # "ct state { established, related }" will handle everything
      # except "echo-request", so add with counters to see which ones
      # are actually hit.

      # rfc4890 4.3.1 - traffic that must not be dropped
      icmpv6 type { destination-unreachable, packet-too-big } counter accept
      icmpv6 type time-exceeded icmpv6 code 0 counter accept
      icmpv6 type parameter-problem icmpv6 code { 1, 2 } counter accept
      icmpv6 type { echo-request, echo-reply } counter accept

      # rfc4890 4.3.2 - traffic that normally should not be dropped
      icmpv6 type time-exceeded icmpv6 code 1 counter accept
      icmpv6 type parameter-problem icmpv6 code 0 counter accept
      icmpv6 type { 145, 146, 147, 148 } counter accept

      tcp dport 22             ip6 daddr @ssh-hosts counter accept;
      tcp dport 32400          ip6 daddr @plex-hosts counter accept;
      tcp dport 9100           ip6 daddr @prometheus-hosts counter accept;

      tcp dport { 80, 443 }    ip6 daddr @web-hosts counter accept;
      tcp dport { 3283, 5900 } ip6 daddr @ard-hosts counter accept;
    '';

    tables.filter.sets.ssh-hosts = {
      type = "ipv6_addr";
      elements = with hosts.v6; [
        umaru
        erika
        tsukihi
      ];
    };

    tables.filter.sets.web-hosts = {
      type = "ipv6_addr";
      elements = with hosts.v6; [
        erika
        umaru
        tsukihi
      ];
    };

    tables.filter.sets.ard-hosts = {
      type = "ipv6_addr";
      elements = with hosts.v6; [
        tsukihi
      ];
    };

    tables.filter.sets.prometheus-hosts = {
      type = "ipv6_addr";
      elements = with hosts.v6; [
        erika
        umaru
        tsukihi
      ];
    };

    tables.filter.sets.plex-hosts = {
      type = "ipv6_addr";
      elements = with hosts.v6; [
        umaru
      ];
    };

    tables.mangle.chains.forward = {
      baseChain = {
        type = "filter";
        hook = "forward";
        priority = "mangle";
      };
      rules = ''
        tcp flags & (syn | rst) == syn tcp option maxseg size set rt mtu counter
      '';
    };
  };

  networking.mape.portForwards = with hosts.v4; [
    { protocol = "tcp"; port = 30305; to = { host = umaru;  port = 32400; }; } # plex ipv4
    { protocol = "tcp"; port = 9826;  to = { host = umaru;  port = 9826;  }; } # qbittorrent
    { protocol = "tcp"; port = 8883;  to = { host = sesame; port = 50798; }; } # sesame wifi
    { protocol = "udp"; port = 9826;  to = { host = umaru;  port = 9826;  }; } # qbittorrent
    { protocol = "udp"; port = 123;   to = { host = sesame; port = 50798; }; } # sesame wifi
    { protocol = "udp"; port = 50798; to.host = ""; } # wireguard
  ];

  networking.mape.portRangeForwards = [
  ];
}
