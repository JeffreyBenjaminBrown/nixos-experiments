{ config, pkgs, nixpkgs, ... }:

{
  environment.systemPackages =
  with pkgs; [
    ### editors ###
    ###############
    (import ./emacs.nix { inherit pkgs; })
      # Fun fact: Does not rely on the `with pkgs` statement.
    mg

    ### storage, versioning, formatting ###
    #######################################
    parted
    ntfs3g # NTFS driver (e.g. for Windows hard drives)
    archiver
    zip
    unzip
    gzip
    gnupg # to encrypt, decrypt
    pinentry # needed by gnupg
    gitMinimal
    ark
    borgbackup
    encfs

    ### networking, trafficking ###
    ###############################
    networkmanager
    wget

    ### exploring filetree ###
    ##########################
    tree
    file # shows types of files

    ### programming languages, or close neighbors ###
    #################################################
    awscli
    python
    python3
    gcc

    ### photo|video ###
    ###################
    gnumake
    cmake

    ### misc ###
    ############
    killall
    xsel
    tmux

    ### big | sketchy | unfree ###
    ##############################
    vivaldi # A browser, fast like Opera, that can use Chrome extensions.

  ];
}
