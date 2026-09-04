{...}: {
  flake.nixosModules.qbittorrent = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    namespace = "qbittorrent";
    namespacePath = "/run/netns/${namespace}";

    wgInterface = "proton";

    hostVeth = "qbit-host";
    namespaceVeth = "qbit-ns";

    # Host <-> qBittorrent namespace only.
    hostVethAddress = "10.200.200.1/30";
    namespaceVethAddress = "10.200.200.2/30";

    #
    # qBittorrent 5.1.4
    #
    # IMPORTANT:
    #
    # This is the actual pre-packaged qBittorrent from nixos-25.11.
    # We are NOT overriding its src and therefore are NOT asking Tars to
    # compile qBittorrent against our unstable package set.
    #
    qbittorrentPackage =
      inputs.nixpkgs-qbittorrent.legacyPackages.${pkgs.stdenv.hostPlatform.system}.qbittorrent-nox;

    protonDns = pkgs.writeText "qbittorrent-resolv.conf" ''
      nameserver 10.2.0.1
      nameserver 2a07:b944::2:1
    '';

    protonPortForward = pkgs.writeShellApplication {
      name = "proton-qbittorrent-port-forward";

      runtimeInputs = with pkgs; [
        libnatpmp
        curl
        gnused
        jq
        coreutils
      ];

      text = ''
        api="http://127.0.0.1:8080"

        request_port() {
          protocol="$1"

          if ! output="$(
            natpmpc \
              -a 1 0 "$protocol" 60 \
              -g 10.2.0.1 \
              2>&1
          )"; then
            echo "natpmpc failed for $protocol:" >&2
            echo "$output" >&2
            return 1
          fi

          port="$(
            printf '%s\n' "$output" |
              sed -nE 's/.*Mapped public port ([0-9]+).*/\1/p'
          )"

          if [ -z "$port" ]; then
            echo "Could not parse Proton $protocol port:" >&2
            echo "$output" >&2
            return 1
          fi

          printf '%s\n' "$port"
        }

        echo "Waiting for qBittorrent Web API..."

        until curl \
          --fail \
          --silent \
          --show-error \
          --header "Referer: $api" \
          "$api/api/v2/app/version" \
          >/dev/null
        do
          sleep 1
        done

        current_port=""

        while true; do
          udp_port="$(request_port udp)"
          tcp_port="$(request_port tcp)"

          if [ "$udp_port" != "$tcp_port" ]; then
            echo \
              "Proton allocated different ports: UDP=$udp_port TCP=$tcp_port" \
              >&2
            exit 1
          fi

          port="$tcp_port"

          if [ "$port" != "$current_port" ]; then
            echo "Proton forwarded port is now $port"

            curl \
              --fail \
              --silent \
              --show-error \
              --header "Referer: $api" \
              --data-urlencode \
                "json={\"listen_port\":$port,\"upnp\":false}" \
              "$api/api/v2/app/setPreferences"

            actual_port="$(
              curl \
                --fail \
                --silent \
                --show-error \
                --header "Referer: $api" \
                "$api/api/v2/app/preferences" |
                jq -r '.listen_port'
            )"

            if [ "$actual_port" != "$port" ]; then
              echo \
                "qBittorrent port update failed: expected=$port actual=$actual_port" \
                >&2
              exit 1
            fi

            echo "qBittorrent listening port updated to $port"

            current_port="$port"
          fi

          # Proton's NAT-PMP lease is 60 seconds.
          # Renew before expiry.
          sleep 45
        done
      '';
    };
  in {
    #
    # Proton WireGuard secret
    #

    sops.secrets."proton-wireguard-private-key" = {
      sopsFile = ../secrets/proton.yaml;
      key = "wireguard_private_key";
      mode = "0400";
    };

    #
    # Network namespace + Proton WireGuard
    #

    systemd.services.qbittorrent-netns = {
      description = "qBittorrent ProtonVPN network namespace";

      wantedBy = [
        "multi-user.target"
      ];

      wants = [
        "network-online.target"
      ];

      after = [
        "network-online.target"
      ];

      before = [
        "qbittorrent.service"
        "proton-qbittorrent-port-forward.service"
      ];

      path = with pkgs; [
        iproute2
        wireguard-tools
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        #
        # Clean up leftovers from a failed previous start.
        #

        ip link del ${hostVeth} 2>/dev/null || true
        ip link del ${wgInterface} 2>/dev/null || true
        ip netns del ${namespace} 2>/dev/null || true

        #
        # Namespace
        #

        ip netns add ${namespace}

        ip -n ${namespace} link set lo up

        #
        # WireGuard
        #
        # Create it in the host namespace first, then move the interface
        # into the qBittorrent namespace.
        #

        ip link add ${wgInterface} type wireguard

        ip link set ${wgInterface} netns ${namespace}

        ip -n ${namespace} link set \
          ${wgInterface} \
          mtu 1420

        ip -n ${namespace} address add \
          10.2.0.2/32 \
          dev ${wgInterface}

        ip -n ${namespace} -6 address add \
          2a07:b944::2:2/128 \
          dev ${wgInterface}

        ip netns exec ${namespace} \
          wg set ${wgInterface} \
            private-key ${config.sops.secrets."proton-wireguard-private-key".path} \
            peer '6tGMeS0XSeK2kFkDgAbAdQyWi9xYT74lO5KPEWdkrC0=' \
            allowed-ips '0.0.0.0/0,::/0' \
            endpoint '169.150.196.68:51820' \
            persistent-keepalive 25

        ip -n ${namespace} link set \
          ${wgInterface} \
          up

        #
        # The only Internet default routes in this namespace.
        #

        ip -n ${namespace} route add \
          default \
          dev ${wgInterface}

        ip -n ${namespace} -6 route add \
          default \
          dev ${wgInterface}

        #
        # Host <-> namespace veth.
        #
        # No default route is provided through this interface.
        #

        ip link add ${hostVeth} \
          type veth \
          peer name ${namespaceVeth}

        ip address add \
          ${hostVethAddress} \
          dev ${hostVeth}

        ip link set ${hostVeth} up

        ip link set \
          ${namespaceVeth} \
          netns ${namespace}

        ip -n ${namespace} address add \
          ${namespaceVethAddress} \
          dev ${namespaceVeth}

        ip -n ${namespace} link set \
          ${namespaceVeth} \
          up

        echo "qBittorrent network namespace ready"
      '';

      preStop = ''
        ip link del ${hostVeth} 2>/dev/null || true
        ip netns del ${namespace} 2>/dev/null || true
      '';
    };

    #
    # qBittorrent
    #

    services.qbittorrent = {
      enable = true;

      #
      # Pre-built qBittorrent 5.1.4 from nixos-25.11.
      #

      package = qbittorrentPackage;

      webuiPort = 8080;

      # Proton sets this dynamically.
      torrentingPort = null;

      openFirewall = false;

      #
      # Keep this EMPTY.
      #
      # qBittorrent owns qBittorrent.conf so UI configuration persists.
      #

      serverConfig = {};

      extraArgs = [
        "--confirm-legal-notice"
      ];
    };

    systemd.services.qbittorrent = {
      bindsTo = [
        "qbittorrent-netns.service"
      ];

      after = [
        "qbittorrent-netns.service"
      ];

      #
      # Never download into an accidentally-unmounted local /storage.
      #

      unitConfig.RequiresMountsFor = [
        "/storage/Downloads"
      ];

      serviceConfig = {
        NetworkNamespacePath = namespacePath;

        #
        # DNS inside the VPN namespace goes through Proton.
        #

        BindReadOnlyPaths = [
          "${protonDns}:/etc/resolv.conf"
        ];

        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    #
    # Proton NAT-PMP lease + qBittorrent port synchronization
    #

    systemd.services.proton-qbittorrent-port-forward = {
      description = "ProtonVPN port forwarding for qBittorrent";

      wantedBy = [
        "multi-user.target"
      ];

      bindsTo = [
        "qbittorrent-netns.service"
        "qbittorrent.service"
      ];

      requires = [
        "qbittorrent.service"
      ];

      after = [
        "qbittorrent-netns.service"
        "qbittorrent.service"
      ];

      serviceConfig = {
        Type = "simple";

        User = "qbittorrent";
        Group = "qbittorrent";

        NetworkNamespacePath = namespacePath;

        ExecStart = lib.getExe protonPortForward;

        Restart = "always";
        RestartSec = "5s";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
      };
    };

    #
    # Traefik
    #

    services.traefik.dynamicConfigOptions.http = {
      routers.qbittorrent = {
        rule = "Host(`qb.wijeproject.com`)";

        # Internal only.
        entryPoints = [
          "websecure"
        ];

        service = "qbittorrent";

        tls.certResolver = "cloudflare";
      };

      services.qbittorrent.loadBalancer = {
        passHostHeader = false;

        servers = [
          {
            url = "http://10.200.200.2:8080";
          }
        ];
      };
    };

    #
    # Useful admin/debugging tools
    #

    environment.systemPackages = with pkgs; [
      iproute2
      wireguard-tools
      libnatpmp
      curl
      jq
    ];
  };
}
