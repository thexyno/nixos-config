{ ... }:

{
  environment.persistence."/persistent" = {
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  ragon.user.persistent = {
    extraFiles = [
      ".zsh_history"
    ];
    extraDirectories = [
      ".config/coc"
      ".config/pipewire/media-session.d"
      ".config/discordcanary"
      ".config/Bitwarden"
      ".config/TabNine"
      ".local/share/nvim"
      ".local/share/TabNine"
      ".mozilla/"
      ".ssh"
      "Downloads"
      "proj"
      "git"
    ];
  };
}
