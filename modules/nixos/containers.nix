# Podman backend for the services that have no NixOS module.
{ ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.oci-containers.backend = "podman";
}
