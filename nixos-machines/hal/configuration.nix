# /etc/nixos/configuration.nix

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Ajustes simples de memória
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  # ZRAM
  zramSwap = {
    enable = true;
    memoryPercent = 40;
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver.enable = true;

  # GNOME + GDM
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Teclado
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Som
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # OpenGL / gráficos
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  nixpkgs.config.allowUnfree = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # GameMode
  programs.gamemode.enable = true;

  # dconf
  programs.dconf.enable = true;

  # TRIM explícito
  services.fstrim.enable = true;

  # Limpeza e otimização automáticas do Nix
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Usuário
  users.users.hal = {
    isNormalUser = true;
    description = "hal";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # GNOME / Dock / Zoom / Tema
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          cursor-theme = "Adwaita";
          icon-theme = "Fluent-dark";
          enable-animations = false;
        };

        # Habilita escalonamento fracionário no GNOME
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };

        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
        };

        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "dash-to-dock@micxgx.gmail.com"
            "caffeine@patapon.info"
          ];
          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "steam.desktop"
            "bitwarden.desktop"
            "onlyoffice-desktopeditors.desktop"
            "org.gnome.Console.desktop"
          ];
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-position = "BOTTOM";
          extend-height = false;
          dock-fixed = false;
          autohide = true;
          autohide-in-fullscreen = true;
          intellihide = true;
          disable-overview-on-startup = true;
          require-pressure-to-show = false;
          pressure-threshold = lib.gvariant.mkDouble 0.0;
          show-trash = false;
          show-mounts = false;
          isolate-workspaces = false;
          click-action = "minimize";
          scroll-action = "cycle-windows";
          show-delay = lib.gvariant.mkDouble 0.0;
          hide-delay = lib.gvariant.mkDouble 0.0;
          animation-time = lib.gvariant.mkDouble 0.15;
          dash-max-icon-size = lib.gvariant.mkInt32 40;
          transparency-mode = "FIXED";
          background-opacity = lib.gvariant.mkDouble 0.75;
        };

        "org/gnome/desktop/wm/preferences" = {
          button-layout = ":minimize,maximize,close";
        };
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    nano
    micro
    htop
    pciutils
    usbutils
    mesa-demos

    firefox
    gnome-tweaks

    bitwarden-desktop
    onlyoffice-desktopeditors

    mangohud
    goverlay
    protonup-qt

    fluent-icon-theme

    gnomeExtensions.dash-to-dock
    gnomeExtensions.caffeine
  ];

  programs.firefox.enable = true;

  services.flatpak.enable = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
}
