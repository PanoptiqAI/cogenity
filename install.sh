#!/bin/sh
set -eu

repository=PanoptiqAI/cogenity
bun_version=1.3.14
install_dir=${COGENITY_INSTALL_DIR:-"$HOME/.local/bin"}
operating_system=$(uname -s)
architecture=$(uname -m)

case "$operating_system:$architecture" in
  Darwin:arm64)
    bun_asset=bun-darwin-aarch64.zip
    bun_digest=d8b96221828ad6f97ac7ac0ab7e95872341af763001e8803e8267652c2652620
    ;;
  Darwin:x86_64)
    bun_asset=bun-darwin-x64.zip
    bun_digest=4183df3374623e5bab315c547cfa0974533cd457d86b73b639f7a87974cd6633
    ;;
  Linux:aarch64 | Linux:arm64) bun_arch=aarch64 ;;
  Linux:x86_64 | Linux:amd64) bun_arch=x64-baseline ;;
  *)
    printf 'Unsupported platform: %s %s\n' "$operating_system" "$architecture" >&2
    exit 1
    ;;
esac

if [ "$operating_system" = Darwin ]; then
  macos_version=$(sw_vers -productVersion 2>/dev/null) || macos_version=
  macos_major=${macos_version%%.*}
  case "$macos_major" in
    '' | *[!0-9]*) macos_major=0 ;;
  esac
  if [ "$macos_major" -lt 13 ]; then
    printf 'macOS 13 or newer is required.\n' >&2
    exit 1
  fi
fi

if [ "$operating_system" = Linux ]; then
  libc_version=$(getconf GNU_LIBC_VERSION 2>/dev/null) || libc_version=
  case "$libc_version" in
    glibc\ *) bun_libc=glibc ;;
    *)
      ldd_version=$(ldd --version 2>&1) || true
      case "$ldd_version" in
        *musl*) bun_libc=musl ;;
        *) printf 'glibc or musl Linux is required.\n' >&2; exit 1 ;;
      esac
      ;;
  esac
  case "$bun_arch:$bun_libc" in
    aarch64:glibc)
      bun_asset=bun-linux-aarch64.zip
      bun_digest=a27ffb63a8310375836e0d6f668ae17fa8d8d18b88c37c821c65331973a19a3b
      ;;
    aarch64:musl)
      bun_asset=bun-linux-aarch64-musl.zip
      bun_digest=b98e0ad3625c5c00d1d5b5ff55605c7adddbfae151861e68ade57b2d3b8703bb
      ;;
    x64-baseline:glibc)
      bun_asset=bun-linux-x64-baseline.zip
      bun_digest=a063908ae08b7852ca10939bbdc6ceed3ddabce8fb9402dce83d65d73b36e6c7
      ;;
    x64-baseline:musl)
      bun_asset=bun-linux-x64-musl-baseline.zip
      bun_digest=56a7d6806cf155536c0178f0ea5fbd098e684fa509ebdb4fc0a7e19fb65382dc
      ;;
  esac
fi

command -v unzip >/dev/null 2>&1 || {
  printf 'unzip is required to install Cogenity.\n' >&2
  exit 1
}

temporary_dir=
staged_runtime=
staged_wrapper=
cleanup() {
  [ -z "$temporary_dir" ] || rm -rf "$temporary_dir"
  [ -z "$staged_runtime" ] || rm -rf "$staged_runtime"
  [ -z "$staged_wrapper" ] || rm -f "$staged_wrapper"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

temporary_dir=$(mktemp -d)
cogenity_url="https://github.com/$repository/releases/download/v0.11.1"
bun_url="https://github.com/oven-sh/bun/releases/download/bun-v$bun_version"
curl --proto '=https' --tlsv1.2 --fail --show-error --location \
  --output "$temporary_dir/cogenity.js" "$cogenity_url/cogenity.js"
curl --proto '=https' --tlsv1.2 --fail --show-error --location \
  --output "$temporary_dir/SHA256SUMS" "$cogenity_url/SHA256SUMS"
curl --proto '=https' --tlsv1.2 --fail --show-error --location \
  --output "$temporary_dir/bun.zip" "$bun_url/$bun_asset"

cogenity_digest=$(awk '$2 == "cogenity.js" { print $1 }' "$temporary_dir/SHA256SUMS")
case "$cogenity_digest" in
  ????????????????????????????????????????????????????????????????) ;;
  *) printf 'Release checksum is missing or invalid for cogenity.js.\n' >&2; exit 1 ;;
esac
[ "$(sha256_file "$temporary_dir/cogenity.js")" = "$cogenity_digest" ] || {
  printf 'Checksum verification failed for cogenity.js.\n' >&2
  exit 1
}
[ "$(sha256_file "$temporary_dir/bun.zip")" = "$bun_digest" ] || {
  printf 'Checksum verification failed for %s.\n' "$bun_asset" >&2
  exit 1
}

unzip -q "$temporary_dir/bun.zip" -d "$temporary_dir/bun"
bun_directory=${bun_asset%.zip}
bun_executable="$temporary_dir/bun/$bun_directory/bun"
[ -f "$bun_executable" ] && [ -x "$bun_executable" ] || {
  printf 'The Bun archive did not contain the expected executable.\n' >&2
  exit 1
}
[ "$("$bun_executable" --version)" = "$bun_version" ] || {
  printf 'The Bun archive did not contain version %s.\n' "$bun_version" >&2
  exit 1
}

mkdir -p "$install_dir/.cogenity"
runtime_name="release-$cogenity_digest"
runtime_dir="$install_dir/.cogenity/$runtime_name"
old_runtime_dir=
runtime_is_current=false
if [ -x "$runtime_dir/bun" ] && [ -f "$runtime_dir/cogenity.js" ]; then
  if [ "$(sha256_file "$runtime_dir/bun")" = "$(sha256_file "$bun_executable")" ] &&
    [ "$(sha256_file "$runtime_dir/cogenity.js")" = "$cogenity_digest" ]; then
    runtime_is_current=true
  fi
fi
if [ "$runtime_is_current" = false ]; then
  staged_runtime=$(mktemp -d "$install_dir/.cogenity/.release.XXXXXX")
  cp "$temporary_dir/cogenity.js" "$staged_runtime/cogenity.js"
  cp "$bun_executable" "$staged_runtime/bun"
  chmod 755 "$staged_runtime/bun"
  if [ -e "$runtime_dir" ]; then
    old_runtime_dir=$runtime_dir
    runtime_name=${staged_runtime##*/}
  else
    mv "$staged_runtime" "$runtime_dir"
    staged_runtime=
  fi
fi

staged_wrapper=$(mktemp "$install_dir/.cogenity-wrapper.XXXXXX")
{
  printf '%s\n' '#!/bin/sh' 'set -eu'
  printf '%s\n' 'install_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)'
  printf 'exec "$install_dir/.cogenity/%s/bun" "$install_dir/.cogenity/%s/cogenity.js" "$@"\n' "$runtime_name" "$runtime_name"
} > "$staged_wrapper"
chmod 755 "$staged_wrapper"
trap '' HUP INT TERM
mv -f "$staged_wrapper" "$install_dir/cogenity"
staged_wrapper=
staged_runtime=
trap 'exit 1' HUP INT TERM
[ -z "$old_runtime_dir" ] || rm -rf "$old_runtime_dir"

printf 'Installed Cogenity at %s/cogenity\n' "$install_dir"
case ":$PATH:" in
  *:"$install_dir":*) ;;
  *) printf 'Add %s to PATH before running cogenity.\n' "$install_dir" ;;
esac
