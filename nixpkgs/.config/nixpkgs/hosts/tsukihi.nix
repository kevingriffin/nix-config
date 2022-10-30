{ config, pkgs, ... }:

{

  imports = [
    ../modules/base-packages.nix
    ../modules/ruby-development.nix
    ../modules/typescript-development.nix
    ../modules/iknow-development.nix
  ];

  nix.extraOptions = "extra-platforms = x86_64-darwin aarch64-darwin";

  # Use the login keychain with aws-vault
  environment.variables.AWS_VAULT_KEYCHAIN_NAME = "login";

  environment.systemPackages = with pkgs; [
     iknow-devops
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 6;
  nix.settings.cores    = 8;

}
