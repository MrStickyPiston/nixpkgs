{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  openssl,
  cacert,
  clang,
  fetchFromGitHub,
  wild ? null,
}:

let
  hasWild =
    stdenv.hostPlatform.isLinux && (stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isAarch64);
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ncro";
  version = "v2.2.2";

  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "ncro";
    tag = finalAttrs.version;
    hash = "sha256-attdCg/FjUooYxVidEDR5wVeQ8aAPAj4b6HQVL17Tng=";
  };

  useNextest = true;

  nativeBuildInputs = [
    pkg-config
    cacert
  ]
  ++ (lib.optionals hasWild [
    wild
    clang
  ]);

  buildInputs = [
    openssl.dev
  ];
  env = {
    # reqwest (rustls) needs a CA bundle to construct a TLS client, even in
    # tests that never make network requests.
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    # Link nixpkgs c libs, no vendored copies.
    OPENSSL_NO_VENDOR = 1;
  }
  // lib.optionalAttrs hasWild {
    RUSTFLAGS = "-Clinker=${clang}/bin/clang -Clink-arg=--ld-path=wild";
  };

  cargoHash = "sha256-woqDFlQ8r/8KMVLW6K8ucrMPBNZklqmiaaAevQnzbPk=";

  meta = {
    description = "Lightweight HTTP proxy for optimizing Nix cache routes for fast access";
    homepage = "https://github.com/manic-systems/ncro";
    license = lib.licenses.eupl12;
    maintainers = [ ];
  };
})
