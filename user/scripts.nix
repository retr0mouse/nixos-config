{pkgs, ...}: let
  mkScript = name: pkgs.writeShellScriptBin name (builtins.readFile ../scripts/${name}.sh);
in {
  home.packages = [
    (mkScript "powerprofile")
    (mkScript "igpu_usage")
    (mkScript "dgpu_usage")
    (mkScript "bluetooth_status")
    (mkScript "clipboard_menu")
  ];
}
