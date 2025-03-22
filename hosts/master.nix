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

  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = "master.local";
    apiserverAddress = "https://master.local:6443";
    easyCerts = true;
    apiserver = {
      securePort = 6443;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}