{ config, pkgs, lib, ... }:

let
  iknowPkgs = import <iknow>;
in
{
  environment.systemPackages = with iknowPkgs; [
    branchctl
  ];
}
