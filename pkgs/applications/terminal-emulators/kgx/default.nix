{ lib, stdenv
, fetchgit
, gettext
, gnome3
, gtk3
, libhandy
, pcre2
, vte
, appstream-glib
, desktop-file-utils
, git
, meson
, ninja
, pkg-config
, python3
, sassc
, wrapGAppsHook
}:

stdenv.mkDerivation {
  pname = "kgx";
  version = "unstable-2021-03-12";

  src = fetchgit {
    url = "https://gitlab.gnome.org/ZanderBrown/kgx";
    rev = "6fc5a263b98e8676edac3ecf44927f7a6dbb0741";
    sha256 = "0m4sf1lwylkinrsc1gr7iw51flrfs1sqn7lp1l7lzm10x98np3y4";
  };

  patches = [
    # Missing gio-unix dependency
    ./nautilus-dependency.patch
  ];

  buildInputs = [
    gettext
    gnome3.libgtop
    gnome3.nautilus
    gtk3
    libhandy
    pcre2
    vte
  ];

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    git
    meson
    ninja
    pkg-config
    python3
    sassc
    wrapGAppsHook
  ];

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py
  '';

  preFixup = ''
    substituteInPlace $out/share/applications/org.gnome.zbrown.KingsCross.desktop \
      --replace "Exec=kgx" "Exec=$out/bin/kgx"
  '';

  meta = with lib; {
    description = "Simple user-friendly terminal emulator for the GNOME desktop";
    homepage = "https://gitlab.gnome.org/ZanderBrown/kgx";
    license = licenses.gpl3;
    maintainers = with maintainers; [ zhaofengli ];
    platforms = platforms.linux;
  };
}
