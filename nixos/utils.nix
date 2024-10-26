{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    mold
    gcc13
    jdk11
    dioxus-cli
    surrealdb
    surrealdb-migrations
    surrealist
    trunk
    alacritty
    steam-run
    fuse
    inotify-tools
    unzip
    inputs.Neve.packages.${pkgs.system}.default
    noto-fonts
    dejavu_fonts
    bun
    tree
  ];
}
