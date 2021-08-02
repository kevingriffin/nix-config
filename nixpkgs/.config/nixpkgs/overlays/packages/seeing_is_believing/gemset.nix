{
  ast = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  childprocess = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ic028k8xgm2dds9mqnvwwx3ibaz32j8455zxr9f4bcnviyahya5";
      type = "gem";
    };
    version = "3.0.0";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10ay35dm0lkcqprsiya6q2kwvyid884102ryipr4vrk790yfp8kd";
      type = "gem";
    };
    version = "1.11.3";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f7gmm60yla325wlnd3qkxs59qm2y0aan8ljpg6k18rwzrrfil6z";
      type = "gem";
    };
    version = "2.7.2.0";
  };
  seeing_is_believing = {
    dependencies = ["childprocess" "ffi" "parser"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10nb9bzkidw7rri4c3szzfqqbrdirzqhpv324qky42p80yfz53ga";
      type = "gem";
    };
    version = "4.0.1";
  };
}
