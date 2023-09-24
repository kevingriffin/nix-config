self: super: {
  iknow-devops = super.callPackage ./packages/iknow-devops.nix {};
  phraseapp_updater = super.callPackage ./packages/phraseapp_updater {};
  osc52-pbcopy = super.callPackage ./packages/osc52-pbcopy.nix {};
  iterm2-integration = super.callPackage ./packages/iterm2-integration.nix {};
}
