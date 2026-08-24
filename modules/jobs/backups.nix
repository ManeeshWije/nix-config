{...}: let
  mkBackup = {
    name,
    source,
    bucket,
    prefix,
    region,
    schedule,
  }: {
    config,
    lib,
    pkgs,
    ...
  }: {
    sops.secrets.aws-backup-access-key = {
      sopsFile = ../secrets/aws-backup.yaml;
      key = "aws_access_key_id";
    };

    sops.secrets.aws-backup-secret-key = {
      sopsFile = ../secrets/aws-backup.yaml;
      key = "aws_secret_access_key";
    };

    sops.templates."${name}-rclone.env" = {
      mode = "0400";

      content = ''
        RCLONE_CONFIG_AWS_TYPE=s3
        RCLONE_CONFIG_AWS_PROVIDER=AWS
        RCLONE_CONFIG_AWS_ACCESS_KEY_ID=${config.sops.placeholder.aws-backup-access-key}
        RCLONE_CONFIG_AWS_SECRET_ACCESS_KEY=${config.sops.placeholder.aws-backup-secret-key}
        RCLONE_CONFIG_AWS_REGION=${region}
      '';
    };

    systemd.services.${name} = {
      description = "Backup ${source} to S3";

      wants = [
        "network-online.target"
      ];

      after = [
        "network-online.target"
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";

        EnvironmentFile =
          config.sops.templates."${name}-rclone.env".path;

        Nice = 10;
        IOSchedulingClass = "idle";
      };

      script = ''
        ${pkgs.rclone}/bin/rclone copy \
          ${lib.escapeShellArg source} \
          ${lib.escapeShellArg "aws:${bucket}/${prefix}"} \
          --fast-list \
          --transfers 4 \
          --checkers 8 \
          --create-empty-src-dirs \
          --stats 30s
      '';
    };

    systemd.timers.${name} = {
      wantedBy = [
        "timers.target"
      ];

      timerConfig = {
        OnCalendar = schedule;

        # If the Pi was off at the scheduled time,
        # run the backup after it comes back.
        Persistent = true;

        # Don't make both Pis hammer S3 at precisely the same time.
        RandomizedDelaySec = "30m";

        Unit = "${name}.service";
      };
    };
  };
in {
  flake.nixosModules.backup-tars = mkBackup {
    name = "backup-tars";
    source = "/var/lib";

    bucket = "wijeproject-backups";
    prefix = "tars/var-lib";
    region = "us-east-2";

    schedule = "*-*-* 03:00:00";
  };

  flake.nixosModules.backup-gargantua = mkBackup {
    name = "backup-gargantua";
    source = "/storage";

    bucket = "wijeproject-backups";
    prefix = "gargantua/storage";
    region = "us-east-2";

    schedule = "*-*-* 04:00:00";
  };
}
