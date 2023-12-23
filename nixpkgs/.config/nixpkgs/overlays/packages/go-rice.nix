{ lib, stdenv, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "go-rice";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "GeertJohan";
    repo = "go.rice";
    rev = "d954009f7238df62c766980934c8ea7f161d0e59";
    sha256 = "19lca5hcw9milgmjv6vlcg8vq4mz9a9sp5bpihxvyza0da6pklmf";
  };

  vendorHash = "0nnvqkzbp3qxkfr8fy69viaif002r0zs0z1k02a2bvx0r9jmsnjn";

  meta = with lib; {
    description = "A Go package that embeds static files into a binary";
    homepage = "https://github.com/GeertJohan/go.rice";
    license = licenses.bsd2;
    maintainers = [ maintainers.hazel ];
  };
}
