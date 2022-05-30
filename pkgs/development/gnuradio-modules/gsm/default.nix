{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, cppunit
, swig
, boost
, log4cpp
, python
, libosmocore
, osmosdr
, spdlog
, gnuradio
, gmp
}:

mkDerivation {
  pname = "gr-gsm";
  version = "unstable-maint3.10-2022-03-08";
  src = fetchFromGitHub {
    owner = "bkerler";          # fork of ptrkrysik
    repo = "gr-gsm";
    rev = "cd59fb949124c9660d8182de131fecf249389bd6";
    sha256 = "sha256-SYnKcoPvCvb1nOJ1UzKfvq+I8v4YPXpKve5ivCbJ1A4=";
  };
  disabledForGRafter = "3.12";

  nativeBuildInputs = [
    cmake
    pkg-config
    (if (lib.versionAtLeast gnuradio.versionAttr.major "3.9") then
      python.pkgs.pybind11
    else
      swig
    )
    python
  ];

  buildInputs = [
    cppunit
    (if (lib.versionAtLeast gnuradio.versionAttr.major "3.10") then
      spdlog
     else
      log4cpp
    )
    boost
    libosmocore
    osmosdr
    gmp
  ];

  propagatedBuildInputs = lib.optionals (lib.versionAtLeast gnuradio.versionAttr.major "3.9") [
    python.pkgs.numpy
    # libsndfile

    # needed for grgsm_livemon:
    python.pkgs.Mako
    python.pkgs.pyyaml
    python.pkgs.matplotlib
  ];

  cmakeFlags = [
    "-DENABLE_GRC=ON"
    "-DENABLE_GRCC=ON"
  ];

  # grcc tries to write a cache file and there seems to be no easy way
  # to prevent it; also maybe fix importing own modules by grcc
  preBuild = ''
    export HOME="''${TMP:-/tmp}"
    export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"
    env|sort
  '';

  meta = with lib; {
    description = "Gnuradio block for gsm";
    homepage = "https://github.com/ptrkrysik/gr-gsm";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mog ];
  };
}
