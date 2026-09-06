{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  writeShellApplication,
  symlinkJoin,
  openssl,
  steam,
  gamemode,
  coreutils,
  findutils,
  gnugrep,
  gawk,
  unzip,
  rofi,
  procps,
}:

let
  me3Version = "0.13.0";

  # me3 creates IPC under /tmp; privateTmp would hide it from the Proton side.
  steam-run = (steam.override { privateTmp = false; }).run;

  # Official Linux portable build — avoids compiling me3 + mingw from nixpkgs-unstable.
  me3 = stdenv.mkDerivation rec {
    pname = "me3";
    version = me3Version;

    src = fetchurl {
      url = "https://github.com/garyttierney/me3/releases/download/v${version}/me3-linux-amd64.tar.gz";
      hash = "sha256-8xV53uv3W0cCBZaUtmS92JF8R3OrDCZnFcqPkuHpP8E=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];
    buildInputs = [
      openssl
      stdenv.cc.cc.lib
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share/me3 $out/share/applications $out/share/icons/hicolor/128x128/apps
      install -Dm755 bin/me3 $out/bin/.me3-wrapped
      cp -r bin/win64 $out/share/me3/
      install -Dm644 dist/me3.png $out/share/icons/hicolor/128x128/apps/me3.png
      install -Dm644 dist/me3-launch.desktop $out/share/applications/me3-launch.desktop
      # steam-run provides the FHS env Proton/me3 expect on NixOS.
      # Always start from $HOME so bubblewrap doesn't choke on exotic cwd paths.
      makeWrapper ${lib.getExe steam-run} $out/bin/me3 \
        --run 'cd "''${HOME:-/tmp}"' \
        --add-flags "$out/bin/.me3-wrapped" \
        --add-flags "--windows-binaries-dir" \
        --add-flags "$out/share/me3/win64"
      runHook postInstall
    '';

    meta = {
      description = "Mod Engine 3 — FROMSOFTWARE mod loader";
      homepage = "https://github.com/garyttierney/me3";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "me3";
    };
  };

  # Mod assets stay outside the Nix store (large Nexus download).
  # Override with ELDEN_RING_CONVERGENCE_DIR if you prefer another path.
  defaultModDir = "$HOME/Games/ConvergenceER";
  steamAppId = "1245620";

  resolveModDir = ''
    MOD_DIR="''${ELDEN_RING_CONVERGENCE_DIR:-${defaultModDir}}"
    MOD_DIR="''${MOD_DIR/#\~/$HOME}"
  '';

  findProfile = ''
    WANT_SEAMLESS=0
    ME3_ARGS=()
    for arg in "$@"; do
      case "$arg" in
        --seamless) WANT_SEAMLESS=1 ;;
        *) ME3_ARGS+=("$arg") ;;
      esac
    done
    if [[ "''${ELDEN_RING_CONVERGENCE_SEAMLESS:-0}" == "1" ]]; then
      WANT_SEAMLESS=1
    fi

    PROFILE=""
    if [[ "$WANT_SEAMLESS" == "1" ]]; then
      for candidate in \
        "$MOD_DIR/me3/convergence - seamless.me3" \
        "$MOD_DIR/me3/convergence-seamless.me3"
      do
        if [[ -f "$candidate" ]]; then
          PROFILE="$candidate"
          break
        fi
      done
      if [[ -z "$PROFILE" ]]; then
        echo "Seamless profile not found under $MOD_DIR/me3/" >&2
        echo "Install Seamless Co-op into the Convergence folder first." >&2
        exit 1
      fi
    else
      for candidate in \
        "$MOD_DIR/me3/convergence.me3" \
        "$MOD_DIR/convergence.me3"
      do
        if [[ -f "$candidate" ]]; then
          PROFILE="$candidate"
          break
        fi
      done
      if [[ -z "$PROFILE" ]]; then
        echo "Convergence profile not found." >&2
        echo "Expected: $MOD_DIR/me3/convergence.me3" >&2
        echo "Run: elden-ring-convergence-setup /path/to/ConvergenceER*.zip" >&2
        exit 1
      fi
    fi
  '';

  elden-ring = writeShellApplication {
    name = "elden-ring";
    runtimeInputs = [ gamemode ];
    text = ''
      set -euo pipefail
      echo "Launching vanilla Elden Ring (Steam ${steamAppId})..."
      if command -v steam >/dev/null 2>&1; then
        exec gamemoderun steam -applaunch ${steamAppId} "$@"
      fi
      exec xdg-open "steam://rungameid/${steamAppId}"
    '';
  };

  elden-ring-convergence = writeShellApplication {
    name = "elden-ring-convergence";
    runtimeInputs = [
      me3
      gamemode
      coreutils
      gnugrep
      procps
    ];
    text = ''
      set -euo pipefail
      ${resolveModDir}
      ${findProfile}

      # Steam must be running for Proton/app ownership checks.
      if command -v steam >/dev/null 2>&1; then
        if ! pgrep -x steam >/dev/null 2>&1; then
          echo "Starting Steam in the background..."
          steam -silent >/dev/null 2>&1 &
          sleep 3
        fi
      fi

      echo "Launching The Convergence via me3 ${me3Version}"
      echo "  profile: $PROFILE"
      echo "  mod dir: $MOD_DIR"
      # System me3 instead of the Windows me3.exe bundled with the mod.
      exec gamemoderun me3 launch -g eldenring -p "$PROFILE" "''${ME3_ARGS[@]}"
    '';
  };

  elden-ring-convergence-seamless = writeShellApplication {
    name = "elden-ring-convergence-seamless";
    runtimeInputs = [ elden-ring-convergence ];
    text = ''
      set -euo pipefail
      exec elden-ring-convergence --seamless "$@"
    '';
  };

  elden-ring-pick = writeShellApplication {
    name = "elden-ring-pick";
    runtimeInputs = [
      rofi
      elden-ring
      elden-ring-convergence
      elden-ring-convergence-seamless
    ];
    text = ''
      set -euo pipefail
      choice="$(printf '%s\n' \
        "Vanilla (Steam)" \
        "The Convergence 3.0" \
        "The Convergence + Seamless" \
        | rofi -dmenu -i -p "Elden Ring" -no-custom)"

      case "$choice" in
        "Vanilla (Steam)") exec elden-ring ;;
        "The Convergence 3.0") exec elden-ring-convergence ;;
        "The Convergence + Seamless") exec elden-ring-convergence-seamless ;;
        *) exit 1 ;;
      esac
    '';
  };

  elden-ring-convergence-setup = writeShellApplication {
    name = "elden-ring-convergence-setup";
    runtimeInputs = [
      coreutils
      findutils
      gnugrep
      gawk
      unzip
    ];
    text = ''
      set -euo pipefail
      ${resolveModDir}

      usage() {
        cat <<EOF
elden-ring-convergence-setup — install The Convergence 3.0.x for Nix/me3

Usage:
  elden-ring-convergence-setup <zip-or-extracted-dir>
  elden-ring-convergence-setup   # interactive: looks in ~/Downloads

Target directory: $MOD_DIR
  (override with ELDEN_RING_CONVERGENCE_DIR)

Download the manual package from:
  https://www.nexusmods.com/eldenring/mods/3419?tab=files
Prefer the full ConvergenceER archive (not only the tiny Linux launcher).

Notes:
  • Keep Elden Ring on 1.16.x until Convergence updates for 1.17+
    (your install is currently fine if Steam shows 1.16.x)
  • Steam game files stay untouched — vanilla via: elden-ring
  • Convergence via: elden-ring-convergence
EOF
      }

      if [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        usage
        exit 0
      fi

      SRC="''${1:-}"
      if [[ -z "$SRC" ]]; then
        mapfile -t hits < <(find "$HOME/Downloads" -maxdepth 2 -type f \
          \( -iname '*convergence*.zip' -o -iname '*ConvergenceER*.zip' \) \
          2>/dev/null | sort -r)
        if [[ ''${#hits[@]} -eq 0 ]]; then
          usage
          echo >&2
          echo "No Convergence zip found in ~/Downloads." >&2
          exit 1
        fi
        SRC="''${hits[0]}"
        echo "Using: $SRC"
      fi

      SRC="''${SRC/#\~/$HOME}"
      if [[ ! -e "$SRC" ]]; then
        echo "Path not found: $SRC" >&2
        exit 1
      fi

      tmp="$(mktemp -d)"
      cleanup() { rm -rf "$tmp"; }
      trap cleanup EXIT

      if [[ -d "$SRC" ]]; then
        stage="$SRC"
      else
        case "$SRC" in
          *.zip|*.ZIP)
            echo "Extracting $SRC ..."
            unzip -q "$SRC" -d "$tmp"
            ;;
          *)
            echo "Unsupported archive (need .zip or a directory): $SRC" >&2
            exit 1
            ;;
        esac
        stage="$(find "$tmp" -type f \( -name 'convergence.me3' -o -path '*/me3/convergence.me3' \) -printf '%h\n' | head -n1 || true)"
        if [[ -n "$stage" && "$(basename "$stage")" == "me3" ]]; then
          stage="$(dirname "$stage")"
        fi
        if [[ -z "$stage" || ! -d "$stage" ]]; then
          stage="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)"
        fi
        if [[ -z "$stage" || ! -d "$stage" ]]; then
          echo "Could not locate ConvergenceER root inside the archive." >&2
          exit 1
        fi
      fi

      if [[ ! -f "$stage/me3/convergence.me3" && ! -f "$stage/convergence.me3" ]]; then
        echo "Warning: no convergence.me3 under $stage" >&2
        echo "Continuing anyway — make sure this is a Convergence 3.x package." >&2
      fi

      mkdir -p "$(dirname "$MOD_DIR")"
      if [[ -e "$MOD_DIR" ]]; then
        backup="''${MOD_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "Existing install found — moving to $backup"
        mv "$MOD_DIR" "$backup"
      fi

      echo "Installing into $MOD_DIR"
      cp -a "$stage" "$MOD_DIR"

      echo
      echo "Done."
      if [[ -f "$MOD_DIR/me3/convergence.me3" ]]; then
        echo "Profile: $MOD_DIR/me3/convergence.me3"
      fi
      echo
      echo "Play Convergence:  elden-ring-convergence"
      echo "Play vanilla:      elden-ring"
      echo "Picker (rofi):     elden-ring-pick"
    '';
  };

  desktopVanilla = makeDesktopItem {
    name = "elden-ring";
    desktopName = "ELDEN RING";
    comment = "Vanilla Elden Ring via Steam";
    exec = "elden-ring";
    icon = "steam_icon_${steamAppId}";
    categories = [ "Game" ];
    terminal = false;
  };

  desktopConvergence = makeDesktopItem {
    name = "elden-ring-convergence";
    desktopName = "ELDEN RING — The Convergence";
    comment = "The Convergence 3.0 overhaul (me3)";
    exec = "elden-ring-convergence";
    icon = "steam_icon_${steamAppId}";
    categories = [ "Game" ];
    terminal = false;
  };

  desktopPick = makeDesktopItem {
    name = "elden-ring-pick";
    desktopName = "ELDEN RING — Choose version";
    comment = "Pick vanilla or Convergence";
    exec = "elden-ring-pick";
    icon = "steam_icon_${steamAppId}";
    categories = [ "Game" ];
    terminal = false;
  };
in
symlinkJoin {
  name = "elden-ring-convergence";
  paths = [
    me3
    elden-ring
    elden-ring-convergence
    elden-ring-convergence-seamless
    elden-ring-convergence-setup
    elden-ring-pick
    desktopVanilla
    desktopConvergence
    desktopPick
  ];
  meta = {
    description = "Launch wrappers for vanilla Elden Ring and The Convergence 3.x (me3)";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
