{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, python3
, wrapGAppsHook
, libinput
, gnome3
, glib
, gtk3
, wayland
, dbus
, cmake
, libdrm
, libxkbcommon
, wlroots
}:

let
  # See upstream report and fix in Alpine
  # - https://source.puri.sm/Librem5/phosh/-/issues/422
  # - https://gitlab.alpinelinux.org/alpine/aports/-/merge_requests/14522
  phocWlroots = wlroots.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./0001-Revert-layer-shell-error-on-0-dimension-without-anch.patch
    ];
  });
in stdenv.mkDerivation rec {
  pname = "phoc";
  version = "0.6.0";

  src = fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-khIBWTmXntPML+YckHvGMhSXhjocXHL0hg4WqOrQvR4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    libdrm.dev
    libxkbcommon
    libinput
    glib
    gtk3
    gnome3.gnome-desktop
    # For keybindings settings schemas
    gnome3.mutter
    wayland
    phocWlroots
  ];

  mesonFlags = ["-Dembed-wlroots=disabled"];

  postPatch = ''
    chmod +x build-aux/post_install.py
    patchShebangs build-aux/post_install.py
  '';

  meta = with lib; {
    description = "Wayland compositor for mobile phones like the Librem 5";
    homepage = "https://source.puri.sm/Librem5/phoc";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ masipcat ];
    platforms = platforms.linux;
  };
}
