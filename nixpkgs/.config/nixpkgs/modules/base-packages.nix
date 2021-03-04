{ config, pkgs, unstablePkgs, ... }:
{
   environment.systemPackages = with pkgs; [
     unstablePkgs._1password
     ag
     age
     aria2
     bat
     bind
     unstablePkgs.bottom
     unstablePkgs.bundix
     colordiff
     gitAndTools.delta
     fd
     fish
     fzf
     gnumake
     unstablePkgs.gnupg
     htop
     unstablePkgs.httpie
     iterm2-integration
     osc52-pbcopy
     jq
     lego
     lsof
     neovim
     nginx
     nmap
     unstablePkgs.onefetch
     overmind
     pfetch
     pigz
     procs
     ripgrep
     rsync
     speedtest-cli
     sshpass
     stow
     tmate
     tig
     tmux
     tmux-cssh
     tree
     unzip
     xsv
     unstablePkgs.youtube-dl
     yank
     unstablePkgs.yubikey-manager
     zstd
   ];
}
