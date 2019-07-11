{ stdenv, fetchFromGitHub, rustPlatform
, openssl, pkgconfig, cmake, zlib }:

rustPlatform.buildRustPackage rec {
  name = "rls-${version}";
  # with rust 1.x you can only build rls version 1.x.y
  version = "1.36.0";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rls";
    rev = version;
    sha256 = "1mclv0admxv48pndyqghxc4nf1amhbd700cgrzjshf9jrnffxmrn";
  };

  cargoSha256 = "1yli9540510xmzqnzfi3p6rh23bjqsviflqw95a0fawf2rnj8sin";

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
