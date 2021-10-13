-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./test.dhall
let lib = ./lib.dhall

in  λ(extIp : Text) →
    λ(cfgs : List lib.AppConfig) →
      { etc =
        { `acme-client.conf` = ./templates/acme-client.conf.dhall cfgs
        , `doas.conf` = ./templates/doas.conf.dhall cfgs
        , `httpd.conf` = ./templates/httpd.conf.dhall cfgs
        , `pf.conf` = ./templates/pf.conf as Text
        , `rc.d` = ./templates/daemons.dhall cfgs
        , `relayd.conf` = ./templates/relayd.conf.dhall extIp cfgs
        }
      , home = ./templates/appHomeDirs.dhall cfgs
      , usr.local
        =
        { lib.gary.`libdeploy.sh` = ./templates/libdeploy.sh as Text
        , bin =
          { gary-deploy = ./templates/deploy.sh as Text
          , gary-start-app = ./templates/start_app.sh as Text
          }
        }
      }
