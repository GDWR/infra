{ config, lib, pkgs, ... }:
{
  age.secrets.apitoken = {
    file = ../secrets/apitoken.age;
    owner = "cfssl";
  };
  systemd.services."cfssl-autoinit" = {
    before = [ "cfssl.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p ${config.services.cfssl.dataDir}
      ${pkgs.coreutils}/bin/ln -s ${config.age.secrets.apitoken.path} ${config.services.cfssl.dataDir}/apitoken.secret
    '';
    serviceConfig = {
      RestartSec = "10s";
      Restart = "on-failure";
    };
  };

  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };

  networking.hostName = "master";
  networking.firewall.enable = false;

  networking.dhcpcd.persistent = true;
  networking.dhcpcd.allowInterfaces = ["eth1"];

  services.openssh = {
    enable = true;
    hostKeys = [{
      path = "/etc/ssh/master-id_ed25519";
      type = "ed25519";
    }];
  };
  system.activationScripts.hostkeyInit = {
    text = ''
      echo [hostkeyInit] gathering hostkey
      cp ${../secrets/bootstrap/master-id_ed25519} /etc/ssh/master-id_ed25519
      echo [hostkeyInit] settings permissions
      chown 400 /etc/ssh/master-id_ed25519
      echo [hostkeyInit] done
    '';
    deps = ["etc"];
  };

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