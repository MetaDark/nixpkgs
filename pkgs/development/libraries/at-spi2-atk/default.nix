{ lib, stdenv
, fetchurl

, meson
, ninja
, pkg-config

, at-spi2-core
, atk
, dbus
, glib
, libxml2

, gnome3 # To pass updateScript
}:

stdenv.mkDerivation rec {
  pname = "at-spi2-atk";
  version = "2.38.0";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "z6AIpa+CKzauYofxgYLEDJHdaZxV+qOGBYge0XXKRk8=";
  };

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [ at-spi2-core atk dbus glib libxml2 ];

  doCheck = false; # fails with "No test data file provided"

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  # In file included from /build/aom/av1/common/arm/av1_txfm_neon.c:12:
  # /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-gcc-10.2.0/lib/gcc/armv7l-unknown-linux-gnueabihf/10.2.0/include/arm_neon.h:10373:1: error: inlining failed in call to 'always_inline' 'vld1q_s32': target specific option mismatch
  # 10373 | vld1q_s32 (const int32_t * __a)
  requiredSystemFeatures = lib.optional (stdenv.hostPlatform.system == "armv7l-linux")
    [ "gccarch-armv7-a" ];

  meta = with lib; {
    description = "D-Bus bridge for Assistive Technology Service Provider Interface (AT-SPI) and Accessibility Toolkit (ATK)";
    homepage = "https://gitlab.gnome.org/GNOME/at-spi2-atk";
    license = licenses.lgpl21Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.unix;
  };
}
