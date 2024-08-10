{ pkgs }: {
  publishVersion = import ./publish-version { inherit pkgs; };
}
