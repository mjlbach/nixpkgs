{ stdenv
, fetchFromGitHub
, rustPlatform
, asciidoc
, docbook_xsl
, libxslt
, installShellFiles
, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "py-spy";
  version = "v0.3.3";

  src = fetchFromGitHub {
    owner = "BenFred";
    repo = pname;
    rev = version;
    sha256 = "1iga3320mgi7m853la55xip514a3chqsdi1a1rwv25lr9b1p7vd3";
  };

  cargoSha256 = "17ldqr3asrdcsh4l29m3b5r37r5d0b3npq1lrgjmxb6vlx6a36qh";

  meta = with stdenv.lib; {
    description = "Sampling profiler for Python programs";
    homepage = "https://github.com/benfred/py-spy";
    license = licenses.MIT;
    maintainers = [ mjlbach ];
    platforms = platforms.all;
  };
}
