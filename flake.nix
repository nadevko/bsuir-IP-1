{
  description = "BSUIR: Fundamentals of Information Security , term 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    mkflake.url = "github:jonascarpay/mkflake";

    bsuir-tex.url = "github:nadevko/bsuir-TeX-1/v0.1";
    bsuir-tex.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      mkflake,
      bsuir-tex,
      treefmt-nix,
      ...
    }:
    mkflake.lib.mkflake {
      perSystem =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          treefmt =
            (treefmt-nix.lib.evalModule pkgs {
              programs.nixfmt.enable = true;
              programs.nixfmt.strict = true;
              programs.latexindent.enable = true;
            }).config.build;
        in
        with pkgs;
        {
          devShells.default = mkShell {
            packages = [
              (texliveFull.withPackages (
                ps: with ps; [
                  bsuir-tex.packages.${system}.default
                  makecell
                  breqn
                  pgfplots
                ]
              ))
              tex-fmt
              inkscape-with-extensions
              python3
              python3Packages.pygments
            ];
          };
          formatter = treefmt.wrapper;
        };
    };
}
