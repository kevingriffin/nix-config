{ config, pkgs, unstablePkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ruby_3_0
    seeing_is_believing
    rubocop
  ];

}
