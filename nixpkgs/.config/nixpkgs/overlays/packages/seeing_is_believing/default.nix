{ lib, bundlerEnv, ruby_3_0 }:

bundlerEnv rec {
  pname = "seeing_is_believing";

  ruby = ruby_3_0;

  gemdir = ./.;

  meta = with lib; {
    description = "Records the results of every line of code in your file (intended to be like xmpfilter), inspired by Bret Victor's JavaScript example in his talk 'Inventing on Principle'";
    homepage = https://github.com/JoshCheek/seeing_is_believing;
    license = licenses.wtfpl;
    platforms = platforms.unix;
  };
}

