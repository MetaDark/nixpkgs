{ stdenv, callPackage, buildFHSUserEnv
, SDL2, cairo, curl, expat, gdk_pixbuf, glew110, glib, glibc
, gtk2, libGL, libSM, libX11, libXxf86vm, libpng12, pango, zlib
, xdg_utils
}:

let
  unwrapped = callPackage ./unwrapped.nix {};
in buildFHSUserEnv {
  name = unwrapped.pname;
  inherit (unwrapped) meta;

  targetPkgs = pkgs: with pkgs; [
    # Libraries, found with:
    # > patchelf --print-needed $out/share/games/runescape-launcher/runescape
    # > patchelf --print-needed ~/Jagex/launcher/rs2client
    SDL2
    cairo
    curl
    expat
    gdk_pixbuf
    glew110
    glib
    glibc
    gtk2
    libGL
    libSM
    libX11
    libXxf86vm
    libpng12
    pango
    stdenv.cc.cc.lib
    zlib

    # Binaries, found with:
    # > strings $out/share/games/runescape-launcher/runescape | grep /bin
    # > strings ~/Jagex/launcher/rs2client | grep /bin
    xdg_utils
  ];

  extraInstallCommands = ''
    mkdir -p "$out"
    ln -s ${unwrapped}/share "$out"
  '';

  runScript = "${unwrapped}/bin/${unwrapped.pname}";
}
