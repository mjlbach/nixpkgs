{ lib
, callPackage
, stdenv
, buildJdk, runJdk
, buildJdkName
, cctools, libcxx, CoreFoundation, CoreServices, Foundation
, enableNixHacks ? false
}:

let
  common = callPackage ./common.nix;
in rec { 
  bazel = common {
    version = "2.0.0";
    sha256 = "1fvc7lakdczim1i99hrwhwx2w75afd3q9fgbhrx7i3pnav3a6kbj";
    javac11 = "v7.0";
    src_deps = ./src-deps.json;
    inherit  buildJdk runJdk  buildJdkName  cctools libcxx CoreFoundation CoreServices Foundation enableNixHacks;
  };
  bazel_1 = common {
    version = "1.2.1";
    sha256 = "1qfk14mgx1m454b4w4ldggljzqkqwpdwrlynq7rc8aq11yfs8p95";
    javac11 = "v6.1";
    src_deps = ./src-deps-bazel-1.json;
    inherit  buildJdk runJdk  buildJdkName  cctools libcxx CoreFoundation CoreServices Foundation enableNixHacks;
  };
}
