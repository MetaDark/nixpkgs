{ fetchurl, lib, stdenv }:

stdenv.mkDerivation rec {
  name = "gsl-2.6";

  src = fetchurl {
    url = "mirror://gnu/gsl/${name}.tar.gz";
    sha256 = "1a460zj9xmbgvcymkdhqh313c4l29mn9cffbi5vf33x3qygk70mp";
  };

  # do not let -march=skylake to enable FMA (https://lists.gnu.org/archive/html/bug-gsl/2011-11/msg00019.html)
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isx86_64 "-mno-fma";

  doCheck =
    # https://lists.gnu.org/archive/html/bug-gsl/2015-11/msg00012.html
    stdenv.hostPlatform.system != "i686-linux" &&

    # ../test-driver: line 95:   475 Segmentation fault      (core dumped) "$@" > $log_file 2>&1
    # FAIL: test
    stdenv.hostPlatform.system != "armv7l-linux" &&

    stdenv.hostPlatform.system != "aarch64-linux";

  meta = {
    description = "The GNU Scientific Library, a large numerical library";
    homepage = "https://www.gnu.org/software/gsl/";
    license = lib.licenses.gpl3Plus;

    longDescription = ''
      The GNU Scientific Library (GSL) is a numerical library for C
      and C++ programmers.  It is free software under the GNU General
      Public License.

      The library provides a wide range of mathematical routines such
      as random number generators, special functions and least-squares
      fitting.  There are over 1000 functions in total with an
      extensive test suite.
    '';
    platforms = lib.platforms.unix;
  };
}
