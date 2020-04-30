{ 
  pkgs ? import <nixpkgs> {}
}:

let c_autoconf = pkgs.fetchurl {
  url = "https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz";
  sha256 = "0s999kyxc3fwb5dsj1dzddfdlhv58z8js6m5lkb15p0y76dxcjwm";
}; in
let c_automake = pkgs.fetchurl {
  url = "https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.gz";
  sha256 = "1a6yr727zpmsclpgijal43nnqck9rac5qqfmypqk5nwp7x99g2k0";
}; in
let c_binutils_dev = pkgs.fetchgit {
  url = "https://github.com/espressif/binutils-gdb.git";
  rev = "esp-2020r1-binutils";
  sha256 = "10jpx86pa28fad07g51693yzpvzv1q0a6vymj9qdlbkg3cpcpiwj";
  leaveDotGit = true;
}; in
let c_expat = pkgs.fetchurl {
  url = "http://downloads.sourceforge.net/project/expat/expat/2.2.5/expat-2.2.5.tar.bz2";
  sha256 = "1xpd78sp7m34jqrw5x13bz7kgz0n6aj15wn4zj4gfx3ypbpk5p6r";
}; in
let c_gmp = pkgs.fetchurl {
  url = "https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz";
  sha256 = "04hrwahdxyqdik559604r7wrj9ffklwvipgfxgj4ys4skbl6bdc7";
}; in
let c_mprf = pkgs.fetchurl {
  url = "https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.1.tar.xz";
  sha256 = "0vp1lrc08gcmwdaqck6bpzllkrykvp06vz5gnqpyw0v3h9h4m1v7";
}; in
let c_isl = pkgs.fetchurl {
  url = "http://isl.gforge.inria.fr/isl-0.19.tar.xz";
  sha256 = "19dqyvngwj51fw2nfshr3r2hrbwkpsfrlvd4kx8gqv9a1sh1lv3d";
}; in
let c_mpc = pkgs.fetchurl {
  url = "http://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz";
  sha256 = "0biwnhjm3rx3hc0rfpvyniky4lpzsvdcwhmcn7f0h4iw2hwcb1b9";
}; in
let c_ncurses = pkgs.fetchurl {
  url = "http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz";
  sha256 = "05qdmbmrrn88ii9f66rkcmcyzp1kb1ymkx7g040lfkd1nkp7w1da";
}; in
let c_gcc_new = pkgs.fetchgit {
  url = "https://github.com/espressif/gcc.git";
  rev = "esp-2020r1";
  sha256 = "0w8khjpxdi9axmk1sq7aa6mlsfi9ammh4r49yr8br78mhb96q0v3";
  leaveDotGit = true;
}; in
let c_newlib = pkgs.fetchurl {
  url = "https://sourceware.org/pub/newlib/newlib-3.0.0.20180226.tar.gz";
  sha256 = "0ranikv74bqv71a4rlaci97djsvlzk9idsbgy35yqirh9j3hrd6h";
}; in
let c_newlib_dev = pkgs.fetchgit {
  url = "https://github.com/espressif/newlib-esp32.git";
  rev = "esp-2020r1";
  sha256 = "0rbxmbry92623xafc7zij2hwy54azh9xvbzblyfrcr9j24bbf127";
  leaveDotGit = true;
}; in
let c_gdb = pkgs.fetchurl {
  url = "ftp://ftp.ntua.gr/pub/gnu/gdb/gdb-8.1.tar.gz";
  sha256 = "03lix8z2aphiw2ygnz7cc5cb5w5qp61a4w2kg004n3h5v8i26jp5";
}; in
let c_gdb_dev = pkgs.fetchgit {
  url = "https://github.com/espressif/binutils-gdb.git";
  rev = "fa0bbca1813321e7725a6b1eaf26f21f2f97c851";
  sha256 = "0wrgpcsdrkyir4hsnvnwb96qdhrry20sp70jaz6a2swpbicwf15k";
  leaveDotGit = true;
}; in
let crosstool = pkgs.stdenv.mkDerivation {
  name = "crosstool-ng";

  src = pkgs.fetchgit {
    url = "https://github.com/espressif/crosstool-NG";
    rev = "esp-2020r1";
    leaveDotGit = true;
    sha256 = "062ckzni873inkhgwf3ijraqmwr0bk0vd4bhkq1ddlqh8gqa7n4q";
  };

  nativeBuildInputs = with pkgs; [ autoconf gperf bison flex help2man libtool
                             automake ncurses python file texinfo wget gcc7
                             git which coreutils unzip hostname perl ];

  patches = [ ./crosstool-devel-fetch.diff ];

  postPatch = ''
    substitute ./bootstrap ./bootstrap --replace "/usr/bin/env" ${pkgs.coreutils}/bin/env
  '';

  configurePhase = ''
    ./bootstrap
    ./configure --enable-local
    make
  '';

  dontStrip = true;
  dontPatchElf = true;

  buildPhase = ''
    # Pop `format` from hardening
    export NIX_HARDENING_ENABLE="fortify stackprotector pic strictoverflow relro bindnow" 
    # It will complain if it is set
    unset LD_LIBRARY_PATH
    mkdir -p .tarballs
    export CT_FORBID_DOWNLOAD=y
    unset CC CXX
    ln -s ${c_expat} .tarballs/expat-2.2.5.tar.bz2
    ln -s ${c_gmp} .tarballs/gmp-6.1.2.tar.xz
    ln -s ${c_mprf} .tarballs/mpfr-4.0.1.tar.xz
    ln -s ${c_isl} .tarballs/isl-0.19.tar.xz
    ln -s ${c_mpc} .tarballs/mpc-1.1.0.tar.gz
    ln -s ${c_ncurses} .tarballs/ncurses-6.1.tar.gz
    ln -s ${c_autoconf} .tarballs/autoconf-2.69.tar.gz
    ln -s ${c_automake} .tarballs/automake-1.16.1.tar.gz
    ./ct-ng xtensa-esp32-elf 
    echo CT_BINUTILS_DEVEL_URL=file://${c_binutils_dev} >> .config
    echo CT_BINUTILS_DEVEL_BRANCH= >> .config
    echo CT_BINUTILS_DEVEL_REVISION="esp-2020r1-binutils" >> .config
    echo CT_NEWLIB_DEVEL_URL=file://${c_newlib_dev} >> .config
    echo CT_NEWLIB_DEVEL_REVISION="esp-2020r1" >> .config
    echo CT_NEWLIB_DEVEL_BRANCH= >> .config
    echo CT_GCC_DEVEL_URL=file://${c_gcc_new} >> .config
    echo CT_GCC_DEVEL_BRANCH= >> .config
    echo CT_GCC_DEVEL_REVISION="esp-2020r1" >> .config
    echo CT_GDB_DEVEL_URL=file://${c_gdb_dev} >> .config
    echo CT_GDB_DEVEL_BRANCH= >> .config
    echo CT_GDB_DEVEL_REVISION="esp-2020r1-gdb" >> .config
    echo CT_LOCAL_TARBALLS_DIR=$(pwd)/.tarballs >> .config
    ./ct-ng build || { cat build.log; exit 1; }
  '';

  installPhase = ''
    mkdir -p $out
    cp -r builds/xtensa-esp32-elf/* $out/
  '';

}; in
let packageOverrides = self: super: {
  # esp-idf currently depends on pyparsing <2.4.0
  # Some 2.5.x might fix the issue, for now we're stuck with this:
  # https://github.com/espressif/esp-idf/issues/4813
  pyparsing = super.pyparsing.overridePythonAttrs(old: rec {
    version = "2.3.1";

    src = super.fetchPypi {
      pname = "pyparsing";
      inherit version;
      sha256 = "66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a";
    };
  });
}; in
let python = pkgs.python27.override { inherit packageOverrides; self = python; }; in
let pythonPackages = pkgs.callPackage <nixpkgs/pkgs/top-level/python-packages.nix> {
  inherit python;
  overrides = packageOverrides;
}; in
let idf = pkgs.stdenv.mkDerivation {
  name = "idf";
  src = pkgs.fetchgit {
      url = "https://github.com/espressif/esp-idf";
      rev = "v4.0";
      sha256 = "016cn5c7x4rmrf0s86d4gih9s72afn77jw3rlxw7m1gg80k79hxa";
      fetchSubmodules = true;
      leaveDotGit = true;
    };

  propagatedBuildInputs = (with pkgs; [ ncurses flex bison gperf pkgconfig git python27 cmake ])
                       ++ (with pythonPackages; [ pyserial future cryptography click setuptools pyparsing pyelftools pygdbmi ]);

  dontUseCmakeConfigure = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    cp -r .git $out/
  '';

 }; in
{
  inherit idf crosstool pythonPackages pkgs;
}
