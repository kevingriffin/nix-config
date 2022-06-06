{ config, pkgs, unstablePkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ruby_3_1
    rubocop
    direnv
    lorri
  ];

  environment.variables.DIRENV_LOG_FORMAT = "";

}
