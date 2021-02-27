{ lib, stdenv, fetchurl, meson, ninja
, gtk-doc ? null, file, docbook_xsl
, buildDevDoc ? gtk-doc != null
}: let
  inherit (lib) optional optionals;
in stdenv.mkDerivation rec {
  pname = "orc";
  version = "0.4.32";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/orc/${pname}-${version}.tar.xz";
    sha256 = "1w0qmyj3v9sb2g7ff39pp38b9850y9hyy0bag26ifrby5f7ksvm6";
  };

  outputs = [ "out" "dev" ]
     ++ optional buildDevDoc "devdoc"
  ;
  outputBin = "dev"; # compilation tools

  mesonFlags =
    optional (!buildDevDoc) [ "-Dgtk_doc=disabled" ]
  ;

  nativeBuildInputs = [ meson ninja ]
    ++ optionals buildDevDoc [ gtk-doc file docbook_xsl ]
  ;

  doCheck = !stdenv.isAarch32; # exec_opcodes_sys fails

  # 2/13 test-schro       FAIL           0.40s (killed by signal 11 SIGSEGV)
  # 3/13 exec_opcodes_sys FAIL           0.36s (killed by signal 11 SIGSEGV)
  # 4/13 exec_parse       FAIL           0.33s (killed by signal 11 SIGSEGV)
  # 5/13 perf_opcodes_sys FAIL           0.44s (killed by signal 11 SIGSEGV)
  # 6/13 perf_parse       FAIL           0.49s (killed by signal 11 SIGSEGV)
  # 11/13 orc_test        FAIL           0.75s (killed by signal 11 SIGSEGV)
  requiredSystemFeatures = lib.optional (stdenv.hostPlatform.system == "armv7l-linux")
    [ "gccarch-armv7-a" ];

  meta = with lib; {
    description = "The Oil Runtime Compiler";
    homepage = "https://gstreamer.freedesktop.org/projects/orc.html";
    # The source code implementing the Marsenne Twister algorithm is licensed
    # under the 3-clause BSD license. The rest is 2-clause BSD license.
    license = with licenses; [ bsd3 bsd2 ];
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
