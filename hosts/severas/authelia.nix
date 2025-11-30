{ hidden, ... }:

let
  name = "klevas";
  full_name = "authelia-${name}";
  secret_path = "/var/keys/${full_name}";
  local_address = "127.0.0.1:9091";
in
{
  users.groups.smtp-users.members = [ full_name ];

  services.nginx.virtualHosts.${hidden.domains.authelia} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${local_address}";
        # TODO check which options aren't needed
        extraConfig = ''
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Forwarded-URI $request_uri;
          proxy_set_header X-Forwarded-Ssl on;

          client_body_buffer_size 128k;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
          proxy_redirect  http://  $scheme://;
          proxy_http_version 1.1;
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 64 256k;

          real_ip_header X-Forwarded-For;
          real_ip_recursive on;

          send_timeout 5m;
          proxy_read_timeout 360;
          proxy_send_timeout 360;
          proxy_connect_timeout 360;
        '';
      };
    };
  };

  services.postgresql = {
    ensureDatabases = [ full_name ];
    ensureUsers = [{ name = full_name; ensureDBOwnership = true; }];
  };

  services.authelia.instances.${name} = {
    enable = true;
    settings = {
      theme = "auto";

      server = {
        address = "tcp://${local_address}";
        endpoints.authz.auth-request.implementation = "AuthRequest"; # For nginx auth
      };

      log = {
        level = "info";
        format = "text";
      };

      default_2fa_method = "totp";

      storage.postgres = {
        address = "unix:///run/postgresql";
        database = full_name;
        username = full_name;
      };

      session.cookies = [
        {
          domain = hidden.domains.base;
          authelia_url = "https://${hidden.domains.authelia}";
          inactivity = "1 day";
          expiration = "3 days";
          remember_me = "1 month";
        }
      ];

      notifier.smtp = {
        address = "submissions://${hidden.smtp.server}:${toString hidden.smtp.port}";
        username = hidden.smtp.username;
        sender = "Authelia <auth@${hidden.smtp.host}>";
      };

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "*.${hidden.domains.base}";
            policy = "one_factor";
          }
        ];
      };

      authentication_backend.file = {
        path = "${secret_path}/users.yml";
        watch = true;
      };

      identity_providers.oidc = {
        clients = [
          {
            client_name = "Immich";
            client_id = "B8.76BaK5izIn-m-H.5seiS5N6ICoTI2-N-JlqyPzT.TSMP6jrGXzl4MieZFBImsQQOC7sxL";
            client_secret = hidden.auth.immich.client_secret;
            redirect_uris = [
              "https://${hidden.immich_domain}/auth/login"
              "https://${hidden.immich_domain}/user-settings"
              "app.immich:///oauth-callback"
            ];
            authorization_policy = "one_factor";
            scopes = [
              "openid"
              "profile"
              "email"
            ];
            token_endpoint_auth_method = "client_secret_post";
          }
          {
            client_name = "Jellyfin";
            client_id = "x7qT09jXPYS8.YdytKg08s3Np2rS3_-sjt7zzpIwfWunaLPpKmxftgNZHQBbGxa2dTZllr~d";
            client_secret = hidden.auth.jellyfin.client_secret;
            redirect_uris = [
              "https://${hidden.domains.jellyfin}/sso/OID/redirect/authelia"
            ];
            require_pkce = true;
            pkce_challenge_method = "S256";
            authorization_policy = "one_factor";
            scopes = [
              "openid"
              "profile"
              "groups"
            ];
            token_endpoint_auth_method = "client_secret_post";
          }
        ];
      };
    };

    secrets = {
      jwtSecretFile = "${secret_path}/jwt_secret";
      oidcIssuerPrivateKeyFile = "${secret_path}/oidc_private.pem";
      storageEncryptionKeyFile = "${secret_path}/storage_encryption";
    };

    environmentVariables.AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = hidden.smtp.password_file;
  };
}
