$ cat configuration.nix                                                                            [16:16:04]
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  user = import ./user.nix;
  hostId = import ./hostid.nix;

  #dwl-custom = pkgs.callPackage "./timaios-dwl.nix" {};
in {
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" user.username ];
    cores = 16;
    max-jobs = 16;
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
  #system.copySystemConfiguration = true;

  nix.gc = {
	  automatic = true;
	  dates = "weekly";
	  options = "--delete-older-than 30d";
  };

  nix.optimise = {
	  automatic = true;
	  dates = [ "weekly" ];
  };

# Bootloader
  boot.loader.timeout = 1;
  boot.loader.efi = {
	  canTouchEfiVariables = true;
	  efiSysMountPoint = "/boot";
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";

  boot.loader.grub = {
	  enable = true;
	  device = "nodev";
	  zfsSupport = true;
	  efiSupport = true;
	  mirroredBoots = [
	  { devices = [ "nodev" ]; path = "/boot"; }
	  ];
  };

  networking.hostName = user.hostname; # Define your hostname.
#networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
	  networking.hostId = hostId.hostId;
#networking.wireless.userControlled.enable = true;

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enable networking
  networking.networkmanager.enable = true;

# Set your time zone.
  time.timeZone = user.timezone;

# Select internationalisation properties.
  i18n.defaultLocale = user.lang;
  i18n.extraLocaleSettings = {
	  LC_ADDRESS = user.locale;
	  LC_IDENTIFICATION = user.locale;
	  LC_MEASUREMENT = user.locale;
	  LC_MONETARY = user.locale;
	  LC_NAME = user.locale;
	  LC_NUMERIC = user.locale;
	  LC_PAPER = user.locale;
	  LC_TELEPHONE = user.locale;
	  LC_TIME = user.locale;
  };

# Enable the GNOME Desktop Environment.
#services.xserver.displayManager.gdm.enable = true;
#services.xserver.desktopManager.gnome.enable = true;

# Configure console keymap
  console.keyMap = user.keymap;

# Enable CUPS to print documents.
  services.printing.enable = true;

# Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
	  enable = true;
	  alsa.enable = true;
	  alsa.support32Bit = true;
	  pulse.enable = true;
# If you want to use JACK applications, uncomment this
#jack.enable = true;

# use the example session manager (no others are packaged yet so this is enabled by default,
# no need to redefine it in your config for now)
#media-session.enable = true; # No longer works
  };
  services.pipewire.wireplumber.enable = true;

  # Enable screen sharing
  xdg.portal = {
    enable = true;
    # Use "wlr" for Sway/Hyprland, "gtk" for GNOME/KDE
    wlr.enable = true;
    config = {
      common = {
        default = [ "wlr" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
  };


# Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

# Enable support for drawing tablets
  hardware.opentabletdriver.enable = true;
  hardware.uinput.enable = true;
  boot.kernelModules = [ "wacom" "uinput" ];
  boot.extraModprobeConfig = ''
	  options wacom quirks=0x01
	  '';
  services.udev.packages = [ pkgs.libwacom ];

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${user.username}" = {
	  shell = pkgs.zsh;
	  isNormalUser = true;
	  extraGroups = [ "networkmanager" "wheel" "network" "podman" "input" "video" ];
	  packages = with pkgs; [
	  ];

          # Critical for rootless: defines the range of IDs the container can use
	  subUidRanges = [{ startUid = 100000; count = 65536; }];
	  subGidRanges = [{ startGid = 100000; count = 65536; }];
  };


# Install firefox.
  programs.firefox.enable = true;

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

# List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
	  python312Packages.nix-prefetch-github
		  wpa_supplicant_gui

		  vim
		  gh
		  jujutsu
		  killall

		  gnome-themes-extra
		  gtk3
		  gtk4

		  twm # Timaios window manager, from flake overlay

		  wmenu
		  kanshi
		  pavucontrol
		  swaybg
		  swaylock

		  grim
		  slurp
		  wl-clipboard
		  mako # notification system developed by swaywm maintainer
		  batsignal # Battery notification daemon
		  fastfetch
		  gcc
		  seahorse
		  unzip
		  gnutar
		  htop

# Useful container development tools
		  dive # look into docker image layers
		  podman-tui # status of containers in the terminal
#docker-compose # start group of containers for dev
		  podman-compose # start group of containers for dev

#mothership
#thalassa
#inputs.dev-infra.packages.${pkgs.system}.default

		  keepassxc
		  signal-desktop

#krita
		  blender

		  libwacom
		  libinput 
		  xf86_input_wacom


		  usbutils  # For lsusb, usb-devices
		  pciutils  # Bonus: lspci for GPUs
		  ];



# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

# Proper session
	  security.polkit.enable = true;
  services.dbus.enable = true;

# Power management and battery monitoring
  services.upower.enable = true;

  systemd.user.services.batsignal = {
	  description = "Battery monitor daemon";
	  wantedBy = [ "graphical-session.target" ];
	  partOf = [ "graphical-session.target" ];
	  serviceConfig = {
		  ExecStart = "${pkgs.batsignal}/bin/batsignal -w 20 -c 5 -d 2";
		  Restart = "always";
	  };
  };

  # Nvidia
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.cudaSupport = true;

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Or production
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Needed for swaylock to work
  security.pam.services.swaylock = {};

  # Fonts
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
  ];

  # Dark mode
  programs.dconf.enable = true;
  programs.dconf.profiles.user = {
    databases = [{
      lockAll = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
      };
    }];
  };
  
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style = "adwaita-dark";

  # Use vim as default editor 
  environment.variables.EDITOR = "vim";

  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # Greetd as display manager 
  services.greetd = {
    enable = true; settings = {
      default_session = {
        command = "${pkgs.twm}/bin/twm";
        user = user.username;
      };
    };
  };

  # Programs
  programs.git.enable = true;
  programs.git.config = {
    # Set the global username
    user.name = user.fullname;

    # Set the global email
    user.email = user.email;

    # Set the default branch name for new repositories (optional, default is typically 'master' or 'main')
    init.defaultBranch = "main";
  };
  programs.foot.enable = true;

  # Shell
  # Note: Requires the shell to be set to zsh in user conf
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -l -a";
      update = "/home/${user.username}/setup/install.sh && sudo nixos-rebuild switch";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "zoxide" "colored-man-pages" "sudo" "fancy-ctrl-z" ];
      theme = "dst";
    };
  };

  # Xwayland
  #programs.xwayland.enable = true;

  # Zoxide for moving around quickly and ergonomically
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
  environment.etc."cdi/nvidia-container-toolkit.json".source = "/run/cdi/nvidia-container-toolkit.json";

  virtualisation = {
    #docker = {
    #  enable = true;
    #  rootless = {
    #    enable = true;
    #    setSocketVariable = true;
    #  };
    #};
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
 
