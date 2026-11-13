{ fetchFromGitHub }:
{

  version = "1.5.0.1";

  src = fetchFromGitHub {
    owner = "project-chip";
    repo = "connectedhomeip";
    rev = "v1.5.0.1";
    hash = "sha256-L2HqSqBzB/a1SWbOSVWTQplTyMhJFhmKgA2aS0SPxRo=";
  };

  openthreadSrc = fetchFromGitHub {
    owner = "openthread";
    repo = "openthread";
    rev = "687cc3664875e1ef2e30c1df4cfc9c14754782a5";
    hash = "sha256-5lPSjoP0u0A6R619jwAQrbKCYUH+B0RclnbL8yQThho=";
  };

  fetchedSubmoduleSources = [
    {
      path = "third_party/nlassert/repo";
      url = "https://github.com/nestlabs/nlassert.git";
      rev = "c5892c5ae43830f939ed660ff8ac5f1b91d336d3";
      hash = "sha256-CT15ld/VuyBHz3du+npBnmBDHuFM11fFjusDgvTAS3k=";
    }
    {
      path = "third_party/nlio/repo";
      url = "https://github.com/nestlabs/nlio.git";
      rev = "0e725502c2b17bb0a0c22ddd4bcaee9090c8fb5c";
      hash = "sha256-LGvIhFB5iLYPDrj4J2hYBZ7Erxxq7mi7dg/8VrKDo1E=";
    }
    {
      path = "third_party/pigweed/repo";
      url = "https://github.com/google/pigweed.git";
      rev = "abf16415ace60cd29691fc55c14a654975800c88";
      hash = "sha256-AcKQqYefjat3BjoK+AMf7LaMLiZnBPiSKbuRswbhWk0=";
    }
    {
      path = "third_party/perfetto/repo";
      url = "https://github.com/google/perfetto.git";
      rev = "b9aca8fb0a7d4130e6ad0b33ca3d14abbc276185";
      hash = "sha256-RcW7m0ejdJt4D77d0bvNsbwb1kU3fvF9fx7wVKyelFA=";
    }
    {
      path = "third_party/lwip/repo";
      url = "https://github.com/lwip-tcpip/lwip.git";
      rev = "4599f551dead9eac233b91c0b9ee5879f5d0620a";
      hash = "sha256-mg+zatxp3F1lEpuZt//63NGcyjbxi5/Xs6gR5KAU2Fw=";
    }
    {
      path = "third_party/libwebsockets/repo";
      url = "https://github.com/warmcat/libwebsockets";
      rev = "edc6a44ea2f779a7291b8b155a2152cfd05ba863";
      hash = "sha256-fFaM5J/PDiqtJ1Q9s+ZzIw9XY4x1psgjQYs4QMa6DcE=";
    }
    {
      path = "third_party/editline/repo";
      url = "https://github.com/troglobit/editline.git";
      rev = "f735e4d1d566cac3caa4a5e248179d07f0babefd";
      hash = "sha256-MUXxSmhpQd8CZdGGC6Ln9eci85E+GBhlNk28VHUvjaU=";
    }
    {
      path = "third_party/nanopb/repo";
      url = "https://github.com/nanopb/nanopb.git";
      rev = "671672b4d7994a9b07a307ae654885c7202ae886";
      hash = "sha256-o0xbxAFj86EvnldHk7ao8ltBBzxm4TgkChvNVME6n78=";
    }
    {
      path = "third_party/jsoncpp/repo";
      url = "https://github.com/open-source-parsers/jsoncpp.git";
      rev = "ca98c98457b1163cca1f7d8db62827c115fec6d1";
      hash = "sha256-RX9ZV6zEn3RDN/n6FE4iJJ+MR1LB5vKbsQ/XmpqYbB0=";
    }
  ];
}
