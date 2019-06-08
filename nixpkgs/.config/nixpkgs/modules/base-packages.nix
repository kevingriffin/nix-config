{ config, pkgs, ... }:

let
  unstablePkgs = import<nixpkgs-unstable> {};
in
{
   environment.systemPackages = with pkgs; [
     _1password
     ag
     bind
     unstablePkgs.certbot
     colordiff
     direnv
     fzf
     gitAndTools.diff-so-fancy
     gitAndTools.hub
     gitFull
     gnumake
     gnupg
     htop
     httpie
     irssi
     jq
     lsof
     neovim
     nmap
     ripgrep
     rsync
     sshpass
     stow
     tcpdump
     tig
     tmux
     tree
     unzip
     wget
     weechat
     wireshark
     unstablePkgs.youtube-dl
     yubikey-manager
   ];
}