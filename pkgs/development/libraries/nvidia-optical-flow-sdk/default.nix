{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation {
  name = "nvidia-video-sdk-6.0.1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "NVIDIAOpticalFlowSDK";
    name = "nvidia_video_sdk_6.0.1.zip";
    rev = "79c6cee80a2df9a196f20afd6b598a9810964c32";
    sha256 = "1y6igwv75v1ynqm7j6la3ky0f15mgnj1jyyak82yvhcsx1aax0a1";
  };

  # # We only need the header files. The library files are
  # # in the nvidia_x11 driver.
  installPhase = ''
    mkdir -p $out/include
    cp -R * $out/include
  '';

  meta = with stdenv.lib; {
    description = "Nvidia optical flow headers for computing the relative motion of pixels between images";
    homepage = https://developer.nvidia.com/opticalflow-sdk;
    license = licenses.unfree;
  };
}

