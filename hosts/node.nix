{ config, lib, pkgs, ... }:
{
  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };

  networking.hostName = "node";
  networking.firewall.enable = false;
  
  networking.dhcpcd.persistent = true;
  networking.dhcpcd.allowInterfaces = ["eth1"];
}