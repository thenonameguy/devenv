{ pkgs, config, lib, ... }:
let
  cfg = config.languages.texlive;

  base = cfg.base;
  packages = lib.genAttrs cfg.packages (name: base.${name} or (throw "No such texlive package ${name}"));
  package = base.combine packages;
  tex = base.combine {
    inherit (base) latexindent chktex scheme-basic;
  };
in
{
  options.languages.texlive = {
    enable = lib.mkEnableOption "TeX Live";
    base = lib.mkOption {
      default = pkgs.texlive;
      defaultText = lib.literalExpression "pkgs.texlive";
      description = "TeX Live package set to use";
    };
    packages = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.string;
      default = [ "collection-basic" ];
      description = "Packages available to TeX Live";
    };
  };
  config = lib.mkIf cfg.enable {
    packages = [ package ];
    pre-commit.tools.latexindent = lib.mkForce tex;
    pre-commit.tools.chktex = lib.mkForce tex;
  };
}
