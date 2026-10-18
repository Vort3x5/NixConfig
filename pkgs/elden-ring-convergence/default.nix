{
  lib,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  writeShellApplication,
  symlinkJoin,
  runCommand,
  python3,
  me3, # nixpkgs me3 (has steam-run baked into Proton/SLR launch)
  gamemode,
  coreutils,
  findutils,
  gnugrep,
  gawk,
  unzip,
  gnutar,
  gzip,
  rofi,
  procps,
}:

let
  me3Version = me3.version or "0.13.0";

  # Official release Windows PE binaries (MSVC). nixpkgs builds the same
  # crates with mingw and links libmcfgthread-2.dll; Wine under Proton fails
  # to resolve that DLL from /nix/store even when collocated.
  me3Win64Src = fetchurl {
    url = "https://github.com/garyttierney/me3/releases/download/v${me3Version}/me3-linux-amd64.tar.gz";
    hash = "sha256-8xV53uv3W0cCBZaUtmS92JF8R3OrDCZnFcqPkuHpP8E=";
  };

  # On NixOS, stock me3 sets LD_PRELOAD=.../gameoverlayrenderer.so on the
  # steam-run child. That preload needs libGL and kills steam-run's bash before
  # FHS starts → zombie child and a hung me3 waiting on the monitor pipe.
  # Neutralize the filename (same length) so the missing object is ignored.
  me3-fixed = runCommand "me3-${me3Version}-no-overlay" {
    nativeBuildInputs = [
      python3
      makeWrapper
      gnutar
      gzip
    ];
    inherit me3Win64Src;
  } ''
    mkdir -p $out/bin $out/share/me3/win64

    if [[ -e "${me3}/bin/.me3-wrapped" ]]; then
      src="${me3}/bin/.me3-wrapped"
    else
      src=$(realpath "${me3}/bin/me3")
    fi

    python3 - "$src" "$out/bin/.me3-wrapped" <<'PY'
    import sys
    from pathlib import Path
    src, dst = map(Path, sys.argv[1:3])
    data = src.read_bytes()
    needle = b"gameoverlayrenderer.so"
    repl = b"xxxxxxxxxxxxxxxxxxxxxx"  # same length
    if needle not in data:
        raise SystemExit(f"overlay string not found in {src}")
    count = data.count(needle)
    dst.write_bytes(data.replace(needle, repl))
    dst.chmod(0o755)
    print(f"patched {count} overlay ref(s)")
    PY

    tar -xzf "$me3Win64Src" -C "$TMPDIR"
    hostDll=$(find "$TMPDIR" -type f -name 'me3_mod_host.dll' | head -n1)
    test -n "$hostDll"
    cp -L "$(dirname "$hostDll")/me3-launcher.exe" "$out/share/me3/win64/"
    cp -L "$hostDll" "$out/share/me3/win64/"
    if [[ -e "$(dirname "$hostDll")/me3.exe" ]]; then
      cp -L "$(dirname "$hostDll")/me3.exe" "$out/share/me3/win64/"
    fi
    chmod -R u+w "$out/share/me3/win64"
    test -f "$out/share/me3/win64/me3-launcher.exe"
    test -f "$out/share/me3/win64/me3_mod_host.dll"

    # WINEPATH mirrors nixpkgs packaging; helps Proton resolve host DLLs.
    makeWrapper "$out/bin/.me3-wrapped" "$out/bin/me3" \
      --set WINEPATH "$out/share/me3/win64" \
      --add-flags "--windows-binaries-dir" \
      --add-flags "$out/share/me3/win64"
  '';

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
      me3-fixed
      coreutils
      gnugrep
      procps
    ];
    text = ''
      set -euo pipefail
      # Always start from $HOME — steam-run/bwrap cannot chdir into odd paths
      # like /etc/nixos, and gamemoderun's LD_PRELOAD must not wrap steam-run.
      cd "$HOME"
      unset LD_PRELOAD || true

      ${resolveModDir}
      ${findProfile}

      ensure_steam() {
        if ! command -v steam >/dev/null 2>&1; then
          echo "steam not found on PATH" >&2
          exit 1
        fi
        if ! pgrep -x steam >/dev/null 2>&1; then
          echo "Starting Steam in the background..."
          steam -silent >/dev/null 2>&1 &
        fi
        for _ in $(seq 1 90); do
          if pgrep -f 'steamwebhelper' >/dev/null 2>&1; then
            sleep 3
            return 0
          fi
          sleep 1
        done
        echo "Steam did not become ready in time. Open Steam manually and retry." >&2
        exit 1
      }
      ensure_steam

      echo "Launching The Convergence via me3 ${me3Version}"
      echo "  profile: $PROFILE"
      echo "  mod dir: $MOD_DIR"
      exec me3 launch -g eldenring -p "$PROFILE" "''${ME3_ARGS[@]}"
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
  elden-ring-convergence-setup   # looks in ~/Downloads

Target: $MOD_DIR
Download: https://www.nexusmods.com/eldenring/mods/3419?tab=files
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
          echo "No Convergence zip found in ~/Downloads." >&2
          exit 1
        fi
        SRC="''${hits[0]}"
        echo "Using: $SRC"
      fi

      SRC="''${SRC/#\~/$HOME}"
      [[ -e "$SRC" ]] || { echo "Path not found: $SRC" >&2; exit 1; }

      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT

      if [[ -d "$SRC" ]]; then
        stage="$SRC"
      else
        case "$SRC" in
          *.zip|*.ZIP) unzip -q "$SRC" -d "$tmp" ;;
          *) echo "Need .zip or directory: $SRC" >&2; exit 1 ;;
        esac
        stage="$(find "$tmp" -type f -name 'convergence.me3' -printf '%h\n' | head -n1 || true)"
        if [[ -n "$stage" && "$(basename "$stage")" == "me3" ]]; then
          stage="$(dirname "$stage")"
        fi
        if [[ -z "$stage" || ! -d "$stage" ]]; then
          stage="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)"
        fi
        [[ -n "$stage" && -d "$stage" ]] || { echo "Could not find ConvergenceER root." >&2; exit 1; }
      fi

      mkdir -p "$(dirname "$MOD_DIR")"
      if [[ -e "$MOD_DIR" ]]; then
        backup="''${MOD_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "Existing install → $backup"
        mv "$MOD_DIR" "$backup"
      fi

      echo "Installing into $MOD_DIR"
      cp -a "$stage" "$MOD_DIR"
      echo "Done. Play: elden-ring-convergence   |   Vanilla: elden-ring"
    '';
  };

  desktopVanilla = makeDesktopItem {
    name = "elden-ring";
    desktopName = "ELDEN RING";
    comment = "Vanilla Elden Ring via Steam";
    exec = "elden-ring";
    icon = "steam_icon_${steamAppId}";
    categories = [ "Game" ];
  };

  desktopConvergence = makeDesktopItem {
    name = "elden-ring-convergence";
    desktopName = "ELDEN RING — The Convergence";
    comment = "The Convergence 3.0 overhaul (me3)";
    exec = "elden-ring-convergence";
    icon = "steam_icon_${steamAppId}";
    categories = [ "Game" ];
  };

  desktopPick = makeDesktopItem {
    name = "elden-ring-pick";
    desktopName = "ELDEN RING — Choose version";
    comment = "Pick vanilla or Convergence";
    exec = "elden-ring-pick";
    icon = "steam_icon_${steamAppId}";
    categories = [ "Game" ];
  };
in
symlinkJoin {
  name = "elden-ring-convergence";
  paths = [
    me3-fixed
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
    description = "Launch wrappers for vanilla Elden Ring and The Convergence 3.x";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
