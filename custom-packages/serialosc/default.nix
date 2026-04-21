{ lib
, stdenv
, fetchFromGitHub
, python3
, wafHook
, pkg-config
, git
, makeWrapper
, libmonome
, liblo
, libuv
, avahi-compat
, udev
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "serialosc";
  version = "1.4.7";

  src = fetchFromGitHub {
    owner = "monome";
    repo = "serialosc";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-zglwhRXKJCvVwGIj+72ZUUxzhHaFHVggMrJunDcY2UE=";
  };

  # `git` is a nativeBuildInput because the upstream wscript calls
  # `git rev-parse` unconditionally and only catches CalledProcessError
  # (not FileNotFoundError). With git present, the call fails cleanly
  # with CalledProcessError (we're not inside a git repo) and the
  # version string is built without a commit suffix.
  nativeBuildInputs = [ python3 wafHook pkg-config git makeWrapper ];

  buildInputs = [
    libmonome
    liblo
    libuv
    avahi-compat
    udev
  ];

  # serialosc calls `dlopen("libdns_sd.so")` at runtime (with a bare
  # filename) for its zeroconf/Bonjour code. Nix's dynamic linker
  # search path doesn't include avahi-compat by default, so the dlopen
  # fails with a non-fatal but noisy warning. Wrap the daemon so that
  # LD_LIBRARY_PATH covers avahi-compat's lib dir, making the dlopen
  # succeed and enabling LAN-visible device advertisement.
  postInstall = ''
    wrapProgram $out/bin/serialoscd \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ avahi-compat ]}
  '';

  meta = {
    description = "Multi-device, Bonjour-capable OSC server for monome devices";
    homepage = "https://github.com/monome/serialosc";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "serialoscd";
    maintainers = [ ];
  };
})
