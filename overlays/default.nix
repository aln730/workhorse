{ inputs }:
final: prev: {
  # Newer packages on demand: pkgs.unstable.<name>
  unstable = import inputs.nixos-unstable {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
}
