{ stdenv, lib, buildEnv
, kubectl, kops, kubectx, kustomize
, skopeo, k9s, awscli2
}:

buildEnv {
  name = "iknow-devops";
  pathsToLink = [ "/bin" ];
  paths = [
    awscli2
    k9s
    kubectl
    kops
    kubectx
    kustomize
    skopeo
  ];
}
