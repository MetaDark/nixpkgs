{ lib, stdenv, fetchFromGitHub, fetchpatch }:

let
  version = "2.9.4";
in stdenv.mkDerivation {
  pname = "http-parser";
  inherit version;

  src = fetchFromGitHub {
    owner = "nodejs";
    repo = "http-parser";
    rev = "v${version}";
    sha256 = "1vda4dp75pjf5fcph73sy0ifm3xrssrmf927qd1x8g3q46z0cv6c";
  };

  NIX_CFLAGS_COMPILE = "-Wno-error";
  patches = [
    ./build-shared.patch
    # Fix arvm7l: Assertion `sizeof(http_parser) == 4 + 4 + 8 + 2 + 2 + 4 + sizeof(void *)' failed
    # This patch is in master, remove it in the next release
    (fetchpatch {
      url = "https://github.com/nodejs/http-parser/commit/4f15b7d510dc7c6361a26a7c6d2f7c3a17f8d878.patch";
      sha256 = "0km10c8qyccyg3zrk1axgamm7v3bj4b7bnkq9rgmvp9hx8jlr5md";
    })
  ];
  makeFlags = [ "DESTDIR=" "PREFIX=$(out)" ];
  buildFlags = [ "library" ];
  doCheck = true;
  checkTarget = "test";

  meta = with lib; {
    description = "An HTTP message parser written in C";
    homepage = "https://github.com/nodejs/http-parser";
    maintainers = with maintainers; [ matthewbauer ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
