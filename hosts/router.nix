{ config, lib, pkgs, ... }:
{
  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  
  networking.hostName = "router";
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    tables.nat = {
      family = "ip";
      content = ''
        chain prerouting {
            type nat hook prerouting priority filter; policy accept;
        }
                    
        chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname { "eth0" } masquerade
        }
      '';
    };
  };
  networking.interfaces.eth1 = {
    ipv4.addresses = [{
      address = "192.168.1.1";
      prefixLength = 24;
    }];
  };

  services.openssh = {
    enable = true;
    hostKeys = [{
      path = "/etc/ssh/router-id_ed25519";
      type = "ed25519";
    }];
  };
  system.activationScripts.hostkeyInit = {
    text = ''
      echo [hostkeyInit] gathering hostkey
      cp ${../secrets/bootstrap/router-id_ed25519} /etc/ssh/router-id_ed25519
      echo [hostkeyInit] settings permissions
      chown 400 /etc/ssh/router-id_ed25519
      echo [hostkeyInit] done
    '';
    deps = ["etc"];
  };


  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "eth1";
      domain = "local";
      expand-hosts = true;
      dhcp-range = [
        "192.168.1.2,192.168.1.254"
      ];
      server = [
        "1.1.1.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };
}