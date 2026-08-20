{...}: {
  flake.nixosModules.pihole = {
    services.pihole-ftl = {
      enable = true;

      settings = {
        dns = {
          upstreams = [
            "9.9.9.9"
            "1.1.1.1"
          ];
        };

        misc.dnsmasq_lines = [
          "address=/home.wijeproject.com/192.168.88.251"
        ];
      };

      lists = [
        {
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          type = "block";
          enabled = true;
          description = "HaGeZi Pro";
        }
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black's HOSTS";
        }
      ];
    };

    services.pihole-web = {
      enable = true;

      hostName = "pihole.wijeproject.com";

      # Only Traefik needs to talk to this.
      ports = [
        "127.0.0.1:8081"
      ];
    };

    services.traefik.dynamicConfigOptions.http = {
      routers.pihole = {
        rule = "Host(`pihole.home.wijeproject.com`)";
        entryPoints = ["websecure"];

        tls = {
          certResolver = "cloudflare";
        };

        service = "pihole";
      };

      services.pihole.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8081";
        }
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
}
