{ lib, stdenv, fetchurl
, fixedPoint ? false, withCustomModes ? true }:

let
  version = "1.3.1";
in
stdenv.mkDerivation {
  pname = "libopus";
  inherit version;

  src = fetchurl {
    url = "https://archive.mozilla.org/pub/opus/opus-${version}.tar.gz";
    sha256 = "17gz8kxs4i7icsc1gj713gadiapyklynlwqlf0ai98dj4lg8xdb5";
  };

  outputs = [ "out" "dev" ];

  configureFlags = lib.optional fixedPoint "--enable-fixed-point"
                ++ lib.optional withCustomModes "--enable-custom-modes";

  doCheck = !stdenv.isi686 && !stdenv.isAarch32; # test_unit_LPC_inv_pred_gain fails


  # ./test-driver: line 107:  8290 Aborted                 (core dumped) "$@" > $log_file 2>&1
  # FAIL: silk/tests/test_unit_LPC_inv_pred_gain
  requiredSystemFeatures = lib.optional (stdenv.hostPlatform.system == "armv7l-linux")
    [ "gccarch-armv7-a" ];

  meta = with lib; {
    description = "Open, royalty-free, highly versatile audio codec";
    license = lib.licenses.bsd3;
    homepage = "https://www.opus-codec.org/";
    platforms = platforms.unix;
  };
}
