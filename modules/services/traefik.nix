{...}: {
  flake.nixosModules.traefik = {config, ...}: {
    sops.defaultSopsFile = ../../secrets/traefik.yaml;

    sops.secrets.cf-dns-api-token = {
      key = "cf_dns_api_token";
      owner = "traefik";
    };

    sops.secrets.cf-email = {
      key = "cf_email";
      owner = "traefik";
    };

    services.traefik = {
      enable = true;

      environmentFiles = [
        "/run/traefik/cloudflare.env"
      ];

      staticConfigOptions = {
        entryPoints = {
          web = {
            address = ":80";

            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };

          websecure.address = ":443";
        };

        certificatesResolvers.cloudflare.acme = {
          email = "${config.sops.secrets.cf-email}";
          storage = "/var/lib/traefik/acme.json";

          dnsChallenge = {
            provider = "cloudflare";

            # Important because Pi-hole overrides wijeproject.com locally.
            resolvers = [
              "1.1.1.1:53"
              "1.0.0.1:53"
            ];
          };
        };
      };
    };

    systemd.services.traefik = {
      preStart = ''
        install -d -m 0700 -o traefik -g traefik /run/traefik

        printf 'CF_DNS_API_TOKEN=%s\n' \
          "$(cat ${config.sops.secrets.cf-dns-api-token.path})" \
          > /run/traefik/cloudflare.env

        chown traefik:traefik /run/traefik/cloudflare.env
        chmod 600 /run/traefik/cloudflare.env
      '';
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
