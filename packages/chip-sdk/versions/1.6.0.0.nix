{ fetchFromGitHub }:
{

  version = "1.6.0.0";

  src = fetchFromGitHub {
    owner = "project-chip";
    repo = "connectedhomeip";
    rev = "v1.6.0.0";
    hash = "sha256-ZdieqVuDOCFRPfd8BCZ4YCOy6hdi0Qn++/2aOnig5vI=";
  };

  openthreadSrc = fetchFromGitHub {
    owner = "openthread";
    repo = "openthread";
    rev = "1b805618025e406f85227187e3f2bc0b73fa17bd";
    hash = "sha256-idghNQhsVI5OXiasQtWWx9TpyEDMXF2qHxSVw82nLTE=";
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
      rev = "c9687b52fa704606d19952255c78142fdb2a131a";
      hash = "sha256-xh99ka7gIHTTiOhSdZ6r3A38TtNLCACUPZ3x5RFJC+s=";
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
      rev = "8e75a40acfea6b05ee643099e41f3b2e11ee464d";
      hash = "sha256-On2gfxjcSSrn+a42L/+6RvdBUm0Uz2yMnYiV6177ME4=";
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
      rev = "2e0504d31e6878208036a4dd91f44841dabb1ee7";
      hash = "sha256-C6zC51e8prIR9Rqf+hnYctAuZhgg5vCKD9xAMpquw4w=";
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
      rev = "3455302847cf1e4671f1d8f5fa953fd46a7b1404";
      hash = "sha256-rf8d2UNTVEZhuiyChK2XnUbfGDvsfXnKADhaSp8qBwQ=";
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
