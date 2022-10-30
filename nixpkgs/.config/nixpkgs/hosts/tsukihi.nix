{ config, pkgs, ... }:

{

  imports = [
    ../modules/base-packages.nix
    ../modules/ruby-development.nix
    ../modules/typescript-development.nix
  ];

  nix.extraOptions = "extra-platforms = x86_64-darwin aarch64-darwin";

  environment.systemPackages = with pkgs; [
     branchctl
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 6;
  nix.settings.cores    = 8;

}
