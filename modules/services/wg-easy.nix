{...}: {
  flake.nixosModules.wg-easy = {config, ...}: {
    sops.secrets."wg-easy-init-username" = {
      sopsFile = ../secrets/wireguard.yaml;
      key = "init_username";
    };

    sops.secrets."wg-easy-init-password" = {
      sopsFile = ../secrets/wireguard.yaml;
      key = "init_password";
    };

    sops.templates."wg-easy.env" = {
      mode = "0400";
      content = ''
        INIT_USERNAME=${config.sops.placeholder."wg-easy-init-username"}
        INIT_PASSWORD=${config.sops.placeholder."wg-easy-init-password"}
      '';
    };

    # Load modules on the host instead of granting the container SYS_MODULE.
    boot.kernelModules = ["wireguard" "iptable_nat" "iptable_filter"];
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    virtualisation.oci-containers = {
      backend = "docker";

      containers.wg-easy = {
        serviceName = "wg-easy";
        image = "ghcr.io/wg-easy/wg-easy:15";
        pull = "missing";

        environment = {
          TZ = "America/Toronto";
          HOST = "0.0.0.0";
          PORT = "51821";
          INSECURE = "false";
          DISABLE_IPV6 = "true";

          # INIT_* settings apply only when initializing a new database.
          INIT_ENABLED = "true";
          INIT_HOST = "wg.wijeproject.com";
          INIT_PORT = "51820";
          INIT_DNS = "192.168.88.251";
          INIT_IPV4_CIDR = "10.8.0.0/24";
          # Both CIDRs are required together, even with IPv6 disabled.
          INIT_IPV6_CIDR = "fdcc:ad94:bacf:61a4::/64";

          # Split tunnel: reach the home LAN and VPN peers through WireGuard.
          INIT_ALLOWED_IPS = "192.168.88.0/24,10.8.0.0/24";
        };

        environmentFiles = [
          config.sops.templates."wg-easy.env".path
        ];

        volumes = [
          "wg-easy-data:/etc/wireguard"
        ];

        ports = [
          "51820:51820/udp"
          "127.0.0.1:51821:51821/tcp"
        ];

        # Keep WireGuard routes and NAT in Docker's network namespace.
        # Docker then masquerades LAN-bound traffic through Tars.
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--sysctl=net.ipv4.ip_forward=1"
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--security-opt=no-new-privileges:true"
        ];
      };
    };

    systemd.services.wg-easy = {
      requires = ["systemd-modules-load.service"];
      after = ["systemd-modules-load.service"];
    };

    networking.firewall.allowedUDPPorts = [51820];

    # Pi-hole's wildcard sends LAN/VPN clients to Tars's LAN HTTPS entry point.
    # Public DNS for wg.wijeproject.com must point directly to the WAN IP
    # (DNS-only in Cloudflare), with router UDP 51820 forwarded to Tars.
    services.traefik.dynamicConfigOptions.http = {
      routers.wg-easy = {
        rule = "Host(`wg.wijeproject.com`)";
        entryPoints = [
          "websecure"
          "websecure-ext"
        ];
        service = "wg-easy";
        tls.certResolver = "cloudflare";
        middlewares = ["wg-easy-headers"];
      };

      services.wg-easy.loadBalancer.servers = [
        {url = "http://127.0.0.1:51821";}
      ];

      middlewares.wg-easy-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
