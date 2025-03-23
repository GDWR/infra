{ config, lib, pkgs, ... }:
{
  age.secrets.apitoken = {
    file = ../secrets/apitoken.age;
    owner = "cfssl";
  };
  users.users.gdwr = {
    isNormalUser  = true;
    password = "gdwr";
    extraGroups  = [ "wheel" ];
  };
  systemd.services."kube-autojoin" = {
    before = [ "kubernetes.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      set -e
      exec 1>&2

      install -m 0600 ${config.age.secrets.apitoken.path} ${config.services.kubernetes.secretsPath}/apitoken.secret

      echo "Restarting certmgr..." >&1
      systemctl restart certmgr

      echo "Waiting for certs to appear..." >&1

      while [ ! -f ${config.services.kubernetes.pki.certs.kubelet.cert} ]; do sleep 1; done
      echo "Restarting kubelet..." >&1
      systemctl restart kubelet

      while [ ! -f ${config.services.kubernetes.pki.certs.kubeProxyClient.cert} ]; do sleep 1; done
      echo "Restarting kube-proxy..." >&1
      systemctl restart kube-proxy

      while [ ! -f ${config.services.kubernetes.pki.certs.flannelClient.cert} ]; do sleep 1; done
      echo "Restarting flannel..." >&1
      systemctl restart flannel

      echo "Node joined successfully"
    '';
    serviceConfig = {
      RestartSec = "10s";
      Restart = "on-failure";
    };
  };

  networking.hostName = "node";
  networking.firewall.enable = false;
  
  networking.dhcpcd.persistent = true;
  networking.dhcpcd.allowInterfaces = ["eth1"];

  services.openssh = {
    enable = true;
    hostKeys = [{
      path = "/etc/ssh/node-id_ed25519";
      type = "ed25519";
    }];
  };
  system.activationScripts.hostkeyInit = {
    text = ''
      echo [hostkeyInit] gathering hostkey
      cp ${../secrets/bootstrap/node-id_ed25519} /etc/ssh/node-id_ed25519
      echo [hostkeyInit] settings permissions
      chown 400 /etc/ssh/node-id_ed25519
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