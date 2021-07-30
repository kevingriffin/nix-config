# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstablePkgs = import<nixpkgs-unstable> {
    config.allowUnfree = true;
    overlays = [ (import ./overlays/packages.nix) ];
  };
in
{
  imports = [
    ./hardware-configuration.nix
    (import ./modules/base-packages.nix { inherit config pkgs unstablePkgs; })
    (import ./local.nix { inherit config pkgs lib unstablePkgs; })
  ];

  nix.useSandbox = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import ./overlays/packages.nix)
  ];

  boot.cleanTmpDir = true;

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    borgbackup
    traceroute
    sshfs
    pinentry
  ];

  # Use neovim as default editor
  environment.variables.EDITOR = "nvim";

  programs.ssh.startAgent = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    pinentryFlavor = "curses";
  };

  programs.mtr.enable     = true;

  programs.mosh.enable    = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        source (fzf-share)/key-bindings.fish
    '';
  };

  # Set up fzf to go through hidden files
  # and use a fast rg backend
  environment.variables.FZF_DEFAULT_COMMAND = "rg --files --hidden -g='!.git'";
  environment.variables.FZF_DEFAULT_OPTS    = "--ansi --preview-window=right:60% --height 90%";
  environment.variables.FZF_CTRL_T_OPTS     = "--preview 'bat --color=always --style=numbers {}'";
  environment.variables.FZF_CTRL_T_COMMAND  = "rg --files --hidden -g='!.git'";

  # cd into directories with fd
  environment.variables.FZF_ALT_C_COMMAND = "fd -t d .";

  services.openssh = {
    enable                          = true;
    passwordAuthentication          = false;
    challengeResponseAuthentication = false;
    permitRootLogin                 = "no";
  };

  networking.firewall = {
    allowPing       = true;
    rejectPackets   = true;
    allowedTCPPorts = [ 3000 ] ;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kevin = {
    uid          = 1000;
    isNormalUser = true;
    home         = "/home/kevin";
    description  = "Kevin Griffin";
    extraGroups  = [ "wheel" "dialout" ];
  };

  users.defaultUserShell = "/run/current-system/sw/bin/fish";
}
