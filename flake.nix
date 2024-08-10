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

        tools = import ./tools { inherit pkgs; };
      in
      {
        packages = tools;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            tools.publishVersion
          ];
        };
      }
    );
}
