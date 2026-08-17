{...}: {
  flake.nixosModules.pihole = {
    services.pihole-ftl = {
      enable = true;

      settings = {
        dns.upstreams = [
          "9.9.9.9"
          "1.1.1.1"
        ];
      };

      lists = [
        {
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          type = "block";
          enabled = true;
          description = "HaGeZi Pro";
        }
      ];
    };

    services.pihole-web = {
      enable = true;
      ports = ["443s"];
    };

    networking.firewall = {
      allowedTCPPorts = [53 443];
      allowedUDPPorts = [53];
    };
  };
}
