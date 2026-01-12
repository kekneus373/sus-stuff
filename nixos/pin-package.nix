let
  legacy = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/<revision>.tar.gz"; # take revision ID from Hydra at Input tab, Revision column
  }) {};

in {
  environment.systemPackages = with legacy; [
    legacy.setserial
  ];
}
