{ lib
, mkDerivation
, fetchFromGitHub
, gnuradio
, cmake
, pkg-config
, swig
, python
, log4cpp
, mpir
, thrift
, boost
, gmp
, icu
, spdlog
}:

let
  version = {
    "3.7" = "1.1.0";
    "3.8" = "3.8.0";
    "3.9" = null;
    "3.10" = "3.10";
  }.${gnuradio.versionAttr.major};
  src = fetchFromGitHub {
    owner = "bastibl";
    repo = "gr-rds";
    rev = "v${version}";
    sha256 = {
      "3.7" = "0jkzchvw0ivcxsjhi1h0mf7k13araxf5m4wi5v9xdgqxvipjzqfy";
      "3.8" = "+yKLJu2bo7I2jkAiOdjvdhZwxFz9NFgTmzcLthH9Y5o=";
      "3.9" = null;
      "3.10" = "sha256-86hPAUjdApCMCNPlt79ShNIuZrtc73O0MxTjgTuYo+U=";
    }.${gnuradio.versionAttr.major};
  };
in mkDerivation {
  pname = "gr-rds";
  inherit version src;
  disabledForGRafter = "3.11";

  buildInputs = [
    (if (lib.versionAtLeast gnuradio.versionAttr.major "3.10") then
      spdlog
     else
      log4cpp
    )
    mpir
    boost
    gmp
    icu
  ] ++ lib.optionals (gnuradio.hasFeature "gr-ctrlport") [
    thrift
    python.pkgs.thrift
  ] ++ lib.optionals (lib.versionAtLeast gnuradio.versionAttr.major "3.9") [
    python.pkgs.numpy
  ];

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

  meta = with lib; {
    description = "Gnuradio block for radio data system";
    homepage = "https://github.com/bastibl/gr-rds";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mog ];
  };
}
