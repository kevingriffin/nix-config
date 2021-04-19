let
  branchCtlRepo = fetchGit { url = "git@github.com:iknow/branchctl"; ref = "master"; };
in
self: super: {
  babelfish = super.callPackage ./packages/babelfish.nix {};
  seeing_is_believing = super.callPackage ./packages/seeing_is_believing/default.nix {};
  iknow-devops = super.callPackage ./packages/iknow-devops.nix {};
  iknow-devops-legacy = super.callPackage ./packages/iknow-devops-legacy.nix {};
  phraseapp_updater = super.callPackage ./packages/phraseapp_updater {};
  csshx = super.callPackage ./packages/csshx.nix {};
  cfn-lint = self.python2.pkgs.callPackage ./packages/cfn-lint.nix {};
  cfn_flip = self.python2.pkgs.callPackage ./packages/cfn_flip.nix {};
  hex = super.callPackage ./packages/hex.nix {};
  kube-ps1 = super.callPackage ./packages/kube-ps1.nix {};
  ndppd = super.callPackage ./packages/ndppd {};
  linx-server = super.callPackage ./packages/linx-server.nix {};
  go-rice = super.callPackage ./packages/go-rice.nix {};
  nomino = super.callPackage ./packages/nomino.nix {};
  osc52-pbcopy = super.callPackage ./packages/osc52-pbcopy.nix {};
  iterm2-integration = super.callPackage ./packages/iterm2-integration.nix {};

  branchctl = self.callPackage "${branchCtlRepo}/nix/branchctl.nix" {};

  branchctlPlugins = {
    branchctl-secret-gpg = self.callPackage "${branchCtlRepo}/plugins/branchctl-secret-gpg" {};
  };

  # Workarounds for packages that misbehave on macOS
  gixy = super.gixy.overrideAttrs(attrs: {
    doCheck        = false;
    doInstallCheck = false;
    meta.platforms = super.lib.platforms.unix;
  });
  python38 = super.python38.override {
    packageOverrides = pythonSelf: pythonSuper: {
      apsw = pythonSelf.callPackage ./packages/apsw_python.nix {};
    };
  };
}
