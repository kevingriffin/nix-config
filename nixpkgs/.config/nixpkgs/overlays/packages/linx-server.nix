{ pkgs, lib, stdenv, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "linx-server";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "andreimarcu";
    repo = "linx-server";
    rev = "9a5fc11dffe5d2ac6cb6e7edfa97bccd417285ed";
    sha256 = "00rv13iq8dnws14zghf9p0ja6jj7j66iq9srzmlsjn9pdbr2rkl7";
  };

   modSha256 = "052l2xf2i67jrka0kvcga6swi7qnjjrma9y35i8whaivwnrhbar2";

  nativeBuildInputs = with pkgs; [
    go-rice
  ];

  postBuild = ''
    rice append --exec $GOPATH/bin/linx-server
  '';

  dontStrip = true;

  meta = with lib; {
    description = "Self-hosted file/code/media sharing website";
    homepage = "https://github.com/andreimarcu/${pname}";
    license = licenses.gpl3;
    maintainers = [ maintainers.hazel ];
  };
}
