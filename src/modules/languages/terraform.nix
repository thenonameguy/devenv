{ pkgs, config, lib, pre-commit-hooks, ... }:

let
  cfg = config.languages.terraform;
in
{
  options.languages.terraform = {
    enable = lib.mkEnableOption "tools for Terraform development";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.terraform;
      defaultText = lib.literalExpression "pkgs.terraform";
      description = "The Terraform package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = with pkgs; [
      cfg.package
      terraform-ls
      tfsec
    ];

    pre-commit.tools.terraform-fmt = lib.mkForce
      pkgs.callPackage "${pre-commit-hooks}/terraform-fmt"
      { terraform = cfg.package; };
  };
}
