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


  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = ["node"];
    masterAddress = "master.local";
    easyCerts = true;

    # point kubelet and other services to kube-apiserver
    kubelet.kubeconfig.server = "https://master.local:6443"; 
    apiserverAddress = "https://master.local:6443";


    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}