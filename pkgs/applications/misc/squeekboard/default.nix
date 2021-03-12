{ lib
, stdenv
, pkgs
, fetchFromGitLab
, cmake
, meson
, ninja
, pkg-config
, gnome3
, glib
, gtk3
, wayland
, wayland-protocols
, rustc
, cargo
, libxml2
, libxkbcommon
, rustPlatform
, makeWrapper
, substituteAll
, fetchpatch
, feedbackd
}:

rustPlatform.buildRustPackage rec {
  pname = "squeekboard";
  version = "1.12.0";

  src = fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1iQqu2pnEsSVqPYTpeC8r/BDHDTlQGYiU5xwiLlzQXQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustc
    cargo
    glib  # for glib-compile-resources
    wayland
    makeWrapper
  ];

  buildInputs = [
    gtk3  # for gio-2.0
    gnome3.gnome-desktop
    wayland
    wayland-protocols
    libxml2
    libxkbcommon
    feedbackd
  ];

  cargoSha256 = "0ficb6ld91m7mxwg979n5h924ml6apx0ggvhazl12jnpbnfwq0jw";

  cargoUpdateHook = ''
    cat Cargo.toml.in Cargo.deps > Cargo.toml
  '';

  preBuild = ''
    cat Cargo.toml.base ../Cargo.deps > ../Cargo.toml
  '';

  # Don't use buildRustPackage phases, only use it for rust deps setup
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;

  meta = with lib; {
    description = "Squeekboard is a virtual keyboard supporting Wayland";
    homepage = "https://source.puri.sm/Librem5/squeekboard";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ masipcat ];
    platforms = platforms.linux;
  };
}
