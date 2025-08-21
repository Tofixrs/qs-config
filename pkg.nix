{
  stdenvNoCC,
  filter,
}:
stdenvNoCC.mkDerivation {
  pname = "qs-config";
  version = "0.1";
  phases = ["installPhase"];
  src = filter {
    root = ./.;
    include = ["modules" "scripts" "services" "utils" "widgets" "shell.qml" "utils.js"];
  };
  installPhase = ''
    mkdir -p $out
    cp $src/* $out -r
  '';
}
