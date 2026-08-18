{...}: {
  flake.nixosModules.traefik = {config, ...}: {
    sops.secrets.cf-dns-api-token = {
      sopsFile = ../../secrets/traefik.yaml;
      key = "cf_dns_api_token";
      owner = "traefik";
    };

    sops.secrets.cf-email = {
      sopsFile = ../../secrets/traefik.yaml;
      key = "cf_email";
      owner = "traefik";
    };

    systemd.services.traefik.environment = {
      CF_DNS_API_TOKEN_FILE =
        config.sops.secrets.cf-dns-api-token.path;
      TRAEFIK_CERTIFICATESRESOLVERS_CLOUDFLARE_ACME_EMAIL_FILE =
        config.sops.secrets.cf-email.path;
    };

    services.traefik = {
      enable = true;

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
          storage = "/var/lib/traefik/acme.json";

          dnsChallenge = {
            provider = "cloudflare";
            resolvers = [
              "1.1.1.1:53"
              "1.0.0.1:53"
            ];
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
