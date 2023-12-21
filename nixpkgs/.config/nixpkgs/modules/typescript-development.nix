{ config, pkgs, unstablePkgs, ... }:

with pkgs;
{
  environment.systemPackages = with pkgs; [
    dprint
    nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
  ];
}
