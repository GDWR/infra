{ config, lib, pkgs, ... }:
{
  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };

  networking.hostName = "master";
  networking.firewall.enable = false;

  networking.dhcpcd.persistent = true;
  networking.dhcpcd.allowInterfaces = ["eth1"];
  networking.dhcpcd.extraConfig = ''
    noarp
    noipv6

    interface eth1
    static routers=10.1.1.1
    static domain_name_servers=10.1.1.1 1.1.1.1 8.8.8.8 8.8.4.4
  '';
}