{ config, lib, pkgs, ... }:
{
  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };

  networking.hostName = "router";
  networking.firewall.enable = false;
  networking.interfaces.eth1 = {
    ipv4.addresses = [{
      address = "10.1.1.1";
      prefixLength = 24;
    }];
  };

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "eth1";
      dhcp-range = [
        "10.1.1.2,10.1.1.254"
      ];
    };
  };
}