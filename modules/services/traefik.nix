{...}: {
  flake.nixosModules.traefik = {config, ...}: {
    sops.secrets.cf-dns-api-token = {
      sopsFile = ../secrets/traefik.yaml;
      key = "cf_dns_api_token";
      owner = "traefik";
    };

    sops.secrets.cf-email = {
      sopsFile = ../secrets/traefik.yaml;
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
          # LAN HTTP
          web = {
            address = ":80";

            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };

          # LAN HTTPS
          websecure.address = ":443";

          # WAN HTTP after router NAT 80 -> 9080
          web-ext = {
            address = ":9080";

            # Deliberately redirect to public/default HTTPS :443.
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };

          # WAN HTTPS after router NAT 443 -> 9443
          websecure-ext.address = ":9443";
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

    networking.firewall.allowedTCPPorts = [80 443 9080 9443];
  };
}
