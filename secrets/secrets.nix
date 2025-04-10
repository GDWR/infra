let
  # https://github.com/gdwr.keys
  gdwr = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClusjRerKzTGFpocV5iB8JJewUMWCA1gksw7FTP4RwfqXN5jEWObo4sMWVNi8UiQLB6OsE9/SIAAWusEZBudwySWBAolyZFQNNkWt8oAvcD8QRz1LmMP/2FZr+ckkbCJuhNz4kMmAs9O5til+xjEq7W7YWOrv3LuBQKzyf++/516FNiudvKumn3yOH6UilQibXoLrLrtSUm8/joxqtsxciOJASY+tG/SM0L7pGLFn6aiLDQzOKINV1PpktS52JOs+zKzluuJUYzlgqlrnd4MIAuG8vY8FF0DxaCOhi27i6d19oIJWELx82cHgXyx2XgvdEKbrkBMF5tWsgryr8G4cE/TVo5rIQEfnmpV1/nw9bwgm4QZb6LVPRIVFp1uNjOrKbqC0UIX01NLAQa6fTdJ6T+BhaQ06cp9Lxdaagk2DTr2QKzhLoi18QsrLvBvczaZP3Wnz6dG04G3yW6DwDnfH0N0bqV0w5Z9m/OeTbCIdr+wd/IokczGfNHBqzeeQzeNM=";
  deployers = [ gdwr ];

  master = builtins.readFile ./bootstrap/master-id_ed25519.pub;
  node = builtins.readFile ./bootstrap/node-id_ed25519.pub;
  router = builtins.readFile ./bootstrap/router-id_ed25519.pub;
  hosts = [ master node router ];
in
{
  "apitoken.age".publicKeys = deployers ++ [ master node ];
}