{ pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-font-patcher
    #    noto-fonts
    #    dejavu-fonts
  ];
}
