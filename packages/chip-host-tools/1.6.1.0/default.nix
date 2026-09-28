{
  callPackage,
  fetchFromGitHub,
  zapCliBin,
}:
callPackage ../base.nix {
  inherit zapCliBin;

  version = "1.6.1.0";

  src = fetchFromGitHub {
    owner = "project-chip";
    repo = "connectedhomeip";
    rev = "v1.6.1.0";
    hash = "sha256-R7NjfWTAHTVWLTkhs089AAU5WQse4XqtDt+NTDO56bU=";
  };

  openthreadSrc = fetchFromGitHub {
    owner = "openthread";
    repo = "openthread";
    rev = "8bb5b30b2bd7c3e17101cfe9837d4ddf486502c3";
    hash = "sha256-Cf9gSLwygE13jkXvY+IE4QHE7rOoRpse+5Xkfa7az4U=";
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
      rev = "8bc35d07baf8000f8db57674a23c5e06f7516d79";
      hash = "sha256-MgS6iinARHSJhzsLJ7pDxeANo16sRHiUz0UoO+4cTm4=";
    }
    {
      path = "third_party/perfetto/repo";
      url = "https://github.com/google/perfetto.git";
      rev = "c1bbc165292877349b219a12498c1e768015a9e8";
      hash = "sha256-JuE3JBKAKxbxEgAA3u6w6jVtSCkzXT7yOIFeRAZIWbw=";
    }
    {
      path = "third_party/lwip/repo";
      url = "https://github.com/lwip-tcpip/lwip.git";
      rev = "3d896ba0a37ff3ce73270ca5e230707fe47f60e3";
      hash = "sha256-UDz+ptI/ssKb2HwmM3aE1XWtYcaGF/JmnVqnpa9CI38=";
    }
    {
      path = "third_party/libwebsockets/repo";
      url = "https://github.com/warmcat/libwebsockets";
      rev = "98fcfb5a3e24db7d7bfde2855e64d69a19382433";
      hash = "sha256-VY5caFHEJY06Vb4abDKmfcL12lRkmk0auxb/4ZZwqqc=";
    }
    {
      path = "third_party/editline/repo";
      url = "https://github.com/troglobit/editline.git";
      rev = "79c39d2756d02db6887b4669c45cce0eae05f9c8";
      hash = "sha256-elREUDoHseXQzq0vXw6scz+FbyIgrt8BOrL1Qk5wOfE=";
    }
    {
      path = "third_party/nanopb/repo";
      url = "https://github.com/nanopb/nanopb.git";
      rev = "98bf4db69897b53434f3d0ba72e0a3ab1a902824";
      hash = "sha256-zXhUEajCZ24VA/S0pSFewz096s8rmhKARSWbSC5TdAg=";
    }
    {
      path = "third_party/jsoncpp/repo";
      url = "https://github.com/open-source-parsers/jsoncpp.git";
      rev = "8519b8381f3c741ad1421f88237b1deda0b11412";
      hash = "sha256-5cH9G4/TVCM5HX6QSk3P4m5+cwuK4x8hP9FohBcmjik=";
    }
    {
      path = "third_party/ot-commissioner/repo";
      url = "https://github.com/openthread/ot-commissioner.git";
      rev = "8922c6a5e8f5206cfb0c8f1b0b89b76abb6c5e10";
      hash = "sha256-zawgvGSywZezS1ZIVUrIwP6zEMsC8lWLGJsDhXxvWhs=";
      fetchSubmodules = true;
    }
    {
      path = "third_party/uriparser/repo";
      url = "https://github.com/uriparser/uriparser.git";
      rev = "04d8b8df5e0c6bf6c06e472540c015943a613bd2";
      hash = "sha256-k4hRy4kfsaxUNIITPNxzqVgl+AwiR1NpKcE9DtAbwxc=";
    }
  ];
}
