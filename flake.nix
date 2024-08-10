{
  description = "Collection of tools for development";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        version = pkgs.lib.strings.fileContents "${self}/version";
        fullVersion = ''${version}-${self.dirtyShortRev or self.shortRev or "dirty"}'';

        publishVersion = pkgs.writers.writePython3Bin "publish-version" {} ./ver.py;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            publishVersion
          ];
        };
      }
    );
}
