{ stdenv, fetchFromGitHub, ninja, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "sumneko-lua-language-server";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "sumneko";
    repo = "lua-language-server";
    rev = "${version}";
    sha256 = "0d93ikxs0c5fm9k57xbzgphm90dnfqq3nz2bc3bqxi7gzyldb9z6";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    ninja
    makeWrapper
  ];

  patches = [
    ./sumneko_home_expansion.patch
  ];

  preBuildPhase = ''
    cd 3rd/luamake
  '';
  
  ninjaFlags = "-f ninja/linux.ninja";

  postBuildPhase = ''
    cd ../..
    ./3rd/luamake/luamake rebuild
  '';

  installPhase = ''
    mkdir -p $out/bin $out/extras
    cp -r ./{locale,meta,script,*.lua} $out/extras/
    cp ./bin/Linux/{bee.so,lpeglabel.so} $out/extras
    cp ./bin/Linux/lua-language-server $out/extras/.lua-language-server-unwrapped
    makeWrapper $out/extras/.lua-language-server-unwrapped \
      $out/bin/lua-language-server \
      --add-flags "-E $out/extras/main.lua \
      --logpath='~/.cache/sumneko_lua/log' \
      --metapath='~/.cache/sumneko_lua/meta'"
  '';

  meta = with stdenv.lib; {
    description = "Lua Language Server coded by Lua ";
    homepage = "https://github.com/sumneko/lua-language-server";
    license = licenses.mit;
    maintainers = with maintainers; [ mjlbach ];
    platforms = platforms.linux;
  };
}
