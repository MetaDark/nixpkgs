{ lib, stdenv, fetchFromGitHub, pkg-config, glib, freetype, cairo, libintl
, meson, ninja
, gobject-introspection
, icu, graphite2, harfbuzz # The icu variant uses and propagates the non-icu one.
, ApplicationServices, CoreText
, withCoreText ? false
, withIcu ? false # recommended by upstream as default, but most don't needed and it's big
, withGraphite2 ? true # it is small and major distros do include it
, python3
, gtk-doc, docbook-xsl-nons, docbook_xml_dtd_43
}:

let
  version = "2.7.4";
  inherit (lib) optional optionals optionalString;
  mesonFeatureFlag = opt: b:
    "-D${opt}=${if b then "enabled" else "disabled"}";
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
in

stdenv.mkDerivation {
  name = "harfbuzz${optionalString withIcu "-icu"}-${version}";

  src = fetchFromGitHub {
    owner  = "harfbuzz";
    repo   = "harfbuzz";
    rev    = version;
    sha256 = "sha256-uMkniDNBQ2mxDmeM7K/YQtZ3Avh9RVXYe7XsUErGas8=";
  };

  postPatch = ''
    patchShebangs src/*.py
    patchShebangs test
  '' + lib.optionalString stdenv.isDarwin ''
    # ApplicationServices.framework headers have cast-align warnings.
    substituteInPlace src/hb.hh \
      --replace '#pragma GCC diagnostic error   "-Wcast-align"' ""
  '';

  outputs = [ "out" "dev" "devdoc" ];
  outputBin = "dev";

  mesonFlags = [
    (mesonFeatureFlag "graphite" withGraphite2)
    (mesonFeatureFlag "icu" withIcu)
    (mesonFeatureFlag "coretext" withCoreText)
    (mesonFeatureFlag "introspection" (!isCross))
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    libintl
    pkg-config
    python3
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    glib # glib-mkenums
  ] ++ lib.optional (!isCross) gobject-introspection;

  buildInputs = [ glib freetype cairo ] # recommended by upstream
    ++ lib.optional (!isCross) gobject-introspection
    ++ lib.optionals withCoreText [ ApplicationServices CoreText ];

  propagatedBuildInputs = []
    ++ optional withGraphite2 graphite2
    ++ optionals withIcu [ icu harfbuzz ];

  doCheck = !stdenv.isAarch32; # 66/348 harfbuzz:fuzzing+slow / shape_fuzzer TIMEOUT 60.14s

  # Slightly hacky; some pkgs expect them in a single directory.
  postFixup = optionalString withIcu ''
    rm "$out"/lib/libharfbuzz.* "$dev/lib/pkgconfig/harfbuzz.pc"
    ln -s {'${harfbuzz.out}',"$out"}/lib/libharfbuzz.la
    ln -s {'${harfbuzz.dev}',"$dev"}/lib/pkgconfig/harfbuzz.pc
    ${optionalString stdenv.isDarwin ''
      ln -s {'${harfbuzz.out}',"$out"}/lib/libharfbuzz.dylib
      ln -s {'${harfbuzz.out}',"$out"}/lib/libharfbuzz.0.dylib
    ''}
  '';

  # FAILED: tests/GIMarshallingTests-1.0.gir
  requiredSystemFeatures = lib.optional (stdenv.hostPlatform.system == "armv7l-linux")
    [ "gccarch-armv7-a" ];

  meta = with lib; {
    description = "An OpenType text shaping engine";
    homepage = "https://harfbuzz.github.io/";
    maintainers = [ maintainers.eelco ];
    license = licenses.mit;
    platforms = with platforms; linux ++ darwin;
  };
}
