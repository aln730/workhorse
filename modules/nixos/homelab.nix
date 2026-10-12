# Shared options for every homelab service module.
{ lib, ... }:
{
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
      example = "example.com";
      description = "Base domain; services live at <name>.<domain>.";
    };
    dataRoot = lib.mkOption {
      type = lib.types.str;
      default = "/srv";
      description = "Where service data lives (point this at your big disk).";
    };
  };
}
