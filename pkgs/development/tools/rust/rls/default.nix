{ stdenv, fetchFromGitHub, rustPlatform
, openssl, pkgconfig, cmake, zlib }:

rustPlatform.buildRustPackage rec {
  name = "rls-${version}";
  # with rust 1.x you can only build rls version 1.x.y
  version = "1.35.0";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rls";
    rev = version;
    sha256 = "1l3fvlgfzri8954nbwqxqghjy5wa8p1aiml12r1lqs92dh0g192f";
  };

  cargoSha256 = "0v96ndys6bv5dfjg01chrqrqjc57qqfjw40n6vppi9bpw0f6wkf5";

  # a nightly compiler is required unless we use this cheat code.
  RUSTC_BOOTSTRAP = 1;

  # clippy is hard to build with stable rust so we disable clippy lints
  cargoBuildFlags = [ "--no-default-features" ];

  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ openssl zlib ];

  doCheck = true;
  # the default checkPhase has no way to pass --no-default-features
  checkPhase = ''
    runHook preCheck

    # client tests are flaky
    rm tests/client.rs

    echo "Running cargo test"
    cargo test --no-default-features
    runHook postCheck
  '';

  meta = with stdenv.lib; {
    description = "Rust Language Server - provides information about Rust programs to IDEs and other tools";
    homepage = https://github.com/rust-lang/rls/;
    license = licenses.mit;
    maintainers = with maintainers; [ symphorien ];
    platforms = platforms.all;
  };
}
