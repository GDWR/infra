{ config, lib, pkgs, ... }:
{
  networking.hostName = "node";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };

  system.stateVersion = "24.11";
}