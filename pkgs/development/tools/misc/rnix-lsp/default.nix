{ lib, rustPlatform, fetchFromGitHub, nodejs }:

rustPlatform.buildRustPackage rec {
  pname = "rnix-lsp";
  version = "master";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = pname;
    rev = version;
    sha256 = "01s1sywlv133xzakrp2mki1w14rkicsf0h0wbrn2nf2fna3vk5ln";
  };

  cargoSha256 = "0j9swbh9iig9mimsy8kskzxqpwppp7jikd4cz2lz16jg7irvjq0w";

  patches = [
    ./fix-error-serialization.patch
    ./stable-rust.patch
  ];

  meta = with lib; {
    description = "WIP Language Server for Nix";
    license = licenses.mit;
    maintainers = [ maintainers.metadark ];
    platforms = platforms.all;
  };
}
