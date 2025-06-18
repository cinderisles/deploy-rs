{
  lib,
  rustPlatform,
  stdenv,
  buildPackages,
  installShellFiles,
  darwin,
}:
rustPlatform.buildRustPackage {
  pname = "deploy-rs";
  version = "0.1.0";

  src = lib.sourceByRegex ./. [
    "Cargo\.lock"
    "Cargo\.toml"
    "src"
    "src/bin"
    ".*\.rs$"
  ];

  cargoLock.lockFile = ./Cargo.lock;

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      mkdir completions

      for shell in bash zsh fish; do
        ${emulator} $out/bin/deploy --generate-completion $shell > completions/deploy.$shell
      done

      installShellCompletion completions/*
    ''
  );

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = {
    description = "A simple multi-profile Nix-flake deploy tool";
    homepage = "https://github.com/serokell/deploy-rs";
    license = lib.licenses.mpl20;
    mainProgram = "deploy";
  };
}
