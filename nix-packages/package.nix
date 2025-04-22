{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  libXrandr,
  libXcursor,
  libGL,
  systemdLibs
}:
let
  luajit = {
    src = fetchFromGitHub {
      owner = "vittorioromeo";
      repo = "LuaJIT";
      rev = "4dc5ffbf60b16e54274c470fcc022165685c96fe";
      hash = "sha256-oNJbMGpcivoJbm8YvMcBnuLrKhvV0C0ZUOapcoJExLc=";
    };
  };
  SFML = {
    src = fetchFromGitHub {
      owner = "vittorioromeo";
      repo = "SFML";
      rev = "dacceddbd1adee49c7bfd120266e200800550394";
      hash = "sha256-6MIn+C29waqRZPQs0DDSCIN20GBW8ZXToNXcNNMr1H8=";
    };
  };
  zlib = {
    src = fetchFromGitHub {
      owner = "madler";
      repo = "zlib";
      rev = "cacf7f1d4e3d44d871b605da3b647f07d718623f";
      hash = "sha256-j5b6aki1ztrzfCqu8y729sPar8GpyQWIrajdzpJC+ww=";
    };
  };
  imgui = {
    src = fetchFromGitHub {
      owner = "ocornut";
      repo = "imgui";
      rev = "04316bd223f98e4c40bd82dc5f2a35c4891e4e5f";
      hash = "sha256-CalF5RlZxSmZviosc86i+pJkOVFJKIYmM/lQqIPEZyc=";
    };
  };
  imgui-sfml = {
    src = fetchFromGitHub {
      owner = "vittorioromeo";
      repo = "imgui-sfml";
      rev = "f35f353376281c0a891a4d614a241914ddfcbe29";
      hash = "sha256-NgAEcQsjed6nHRh/uNj2u9gxI7HQDW6G9TUUPpdgP/w=";
    };
  };
  libsodium-cmake = {
    src = fetchFromGitHub {
      owner = "vittorioromeo";
      repo = "libsodium-cmake";
      rev = "fd76500b60fcaa341b6fad24cda88c3504df770d";
      hash = "sha256-CwIcJ9siCNU64iQOmKAQjmCoUaxty00vbbnlmkO4MSA=";
    };
  };
  boostpfr = {
    src = fetchFromGitHub {
      owner = "boostorg";
      repo = "pfr";
      rev = "b0bf18798c7037ca8a91a1cd2ad2e5798d8f6d46";
      hash = "sha256-vKk4cAkbAEqCOjOukWQC8NoYixgA3bgXgzqWprc2hM0=";
    };
  };
in stdenv.mkDerivation rec {
  pname = "open-hexagon";
  version = "unstable-2023-04-21";
  src = ../.;
  cmakelist = builtins.readFile ../CMakeLists.txt;

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libXrandr libXcursor libGL systemdLibs ];

  # desktopItems = [
  #   (makeDesktopItem {
  #     name = "open-hexagon";
  #     exec = "open-hexagon";
  #     icon = "open-hexagon";
  #     desktopName = "Open Hexagon";
  #     comment = meta.description;
  #     type = "Application";
  #     categories = [ "Game" "ArcadeGame" ];
  #     startupWMClass = "SSVOpenHexagon";
  #   })
  # ];

  postUnpack = let

    split-cmakelist = (cpm_pkg: input_cmakelist: builtins.split "(CPMAddPackage\\([^)]*NAME ${cpm_pkg}[^)]*\\))" input_cmakelist);
    update-cmakelist = (cpm_pkg: input_cmakelist: lib.strings.concatStrings [
      (lib.lists.last (lib.lists.take 1 (split-cmakelist cpm_pkg input_cmakelist)))
      "add_subdirectory(${cpm_pkg})"
      (lib.lists.last (split-cmakelist cpm_pkg input_cmakelist))
    ]);
    cpm_pkgs = [ "luajit" "SFML" "zlib" "imgui" "imgui-sfml" "libsodium-cmake" "boostpfr" ];
    newcmakelist = builtins.foldl' (acc: elem: (update-cmakelist elem acc)) cmakelist cpm_pkgs;
  in
    ''
      (
        cd "$sourceRoot"
        cp -R --no-preserve=mode,ownership ${luajit.src} luajit
        cp -R --no-preserve=mode,ownership ${SFML.src} SFML
        cp -R --no-preserve=mode,ownership ${zlib.src} zlib
        cp -R --no-preserve=mode,ownership ${imgui.src} imgui
        cp -R --no-preserve=mode,ownership ${imgui-sfml.src} imgui-sfml
        cp -R --no-preserve=mode,ownership ${libsodium-cmake.src} libsodium-cmake
        cp -R --no-preserve=mode,ownership ${boostpfr.src} boostpfr
        echo '${newcmakelist}' > CMakeLists.txt
        cat CMakeLists.txt
        patchShebangs .
      )
    '';
}
