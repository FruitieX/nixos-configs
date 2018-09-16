# This file contains configs that are common for all of my hosts

{ config, pkgs, lib, ... }:

let
  hostname = import ./hostname.nix;
in {
  nixpkgs.config = {
    # Allow non-free licenses
    allowUnfree = true;

    # Unstable package set
    packageOverrides = {
      unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {
        config = config.nixpkgs.config;
      };
    };
  };

  # System packages
  environment.systemPackages =
    (import ./pkgs-global.nix pkgs) ++
    (import ./pkgs-system.nix pkgs);

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Power management
  powerManagement.cpuFreqGovernor = "ondemand";
  powerManagement.powertop.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.rasse = {
    isNormalUser = true;
    extraGroups = [ "wheel" "adbusers" "vboxusers" "audio" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse" ];
  };

  # Audio
  hardware.pulseaudio = {
    enable = true;

    # Enable tcp streaming support
    tcp.enable = true;
  };
  #users.extraUsers.rasse.extraGroups = ["audio"];

  # Networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 1234 3000 ];

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    passwordAuthentication = lib.mkDefault false;
  };

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = lib.mkDefault [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
            labels.alias = hostname;
          }
        ];
      }
    ];
    exporters.node = {
      enable = true;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };
  };
  services.grafana = {
    enable = true;
    port = 4000;
  };

  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  # TODO: find out why this doesn't work.
  # Currently we load zprezto from .zshrc with awkward hacks
  #programs.zsh.interactiveShellInit = with builtins; ''
  #  export ZDOTDIR=${pkgs.zsh-prezto}/
  #  source "$ZDOTDIR/init.zsh"
  #'';

  #environment.shellAliases = {
  #  la="ls -A";
  #};
  environment.variables = {
    ZPREZTO = [ "${pkgs.zsh-prezto}" ];
    NIXOS_CONFIG = [ "/etc/nixos" ];

    # enable smooth scrolling in firefox
    MOZ_USE_XINPUT2 = [ "1" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

  # TODO: make this clear out ancient kernels so /boot doesn't fill up
  # OR: resize /boot partition on satsuma so this is no longer an issue
  # system.autoUpgrade.enable = true;

  # Symlink dotfiles
  system.activationScripts.dotfiles = ''
    # Symlink all the files in $1 to $2, $1 needs to be an absolute path
    linkdir() {
      for f in $(find $1 -maxdepth 1 -type f -printf '%P\n'); do
        ln -s -f -v $1/$f $2/$f;
        chown -h rasse:users $2/$f
      done
    }

    # Recursively symlink all the files in $1 to $2
    reclink () {
      linkdir $1 $2
      for d in $(find $1 -type d -printf '%P\n'); do
        mkdir -p -v $2/$d;
        chown rasse:users $2/$d
        linkdir $1/$d $2/$d;
      done
    };

    reclink /etc/nixos/home /home

    unset -f linkdir
    unset -f reclink
  '';
}
