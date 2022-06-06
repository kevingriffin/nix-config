{ config, pkgs, unstablePkgs, ... }:

with pkgs;
{
  environment.systemPackages = with pkgs; [
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint_d
  ];
}
