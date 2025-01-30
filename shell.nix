# vim: tabstop=2 shiftwidth=2 expandtab autoindent smartindent colorcolumn=80
{ pkgs ? import <nixpkgs> {} }:

let

zephyr-sdk = pkgs.stdenvNoCC.mkDerivation rec {
  pname = "zephyr-sdk";
  version = "0.17.0";

  src = pkgs.fetchurl {
    url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-sdk-${version}_linux-x86_64.tar.xz";
    sha256 = "sha256-51NrSHn2ic/U75wZOQadpsTPDjAwopQBddY1TnuLaeE=";
  };

  buildInputs = with pkgs; [
    autoPatchelfHook ncurses libtinfo python310 libxcrypt-legacy
  ];

  installPhase = ''
    mkdir $out && cp -Rf * $out/
  '';
};

in
pkgs.mkShell rec {
  packages = with pkgs; [
    zephyr-sdk cmake ninja
    (python3.withPackages(p: with p; [ west pyelftools ]))
  ];

  shellHook = ''
    set -o vi

    # Set environment variables required for Zephyr SDK
    export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
    export ZEPHYR_SDK_INSTALL_DIR=${zephyr-sdk}

    echo "Zephyr SDK environment setup complete!"

    [ -d $PWD/.venv ] || python3 -m venv $PWD/.venv
    source $PWD/.venv/bin/activate

    [ -f $PWD/zephyr/scripts/requirements.txt ] && \
      pip install -r $PWD/zephyr/scripts/requirements.txt
  '';
}

