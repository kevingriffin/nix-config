{ lib, buildEnv, yarn, overmind, ruby_2_5, bundler, nodejs-10_x ? null }:

let
  pkgsNewEnough = (lib.versionAtLeast yarn.version "1.10.0") && (nodejs-10_x != null);

  webpkgs = if pkgsNewEnough
    then { inherit yarn nodejs-10_x bundler; }
    else builtins.trace "Using <nixpkgs-unstable> channel for web packages"
         (import <nixpkgs-unstable> {});
in

let
  nodejs  = webpkgs.nodejs-10_x;
  yarn    = webpkgs.yarn.override { inherit nodejs; };
  bundler = webpkgs.bundler;
in

buildEnv {
  name = "eikaiwa-packages";
  paths = [
    nodejs
    yarn
    overmind
    ruby_2_5
    bundler
  ];
}
