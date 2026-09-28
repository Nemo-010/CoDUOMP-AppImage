#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel       \
	curl             \
	libdecor         \
	minizip          \
	nasm             \
	openal           \
	patchelf         \
	sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa --prefer-nano libdecor-mini

echo "Building libjpeg6-turbo..."
echo "---------------------------------------------------------------"
# the client links against libjpeg.so.62 (LIBJPEG_6.2), which no Arch package
# provides; Arch's libjpeg-turbo is soname 8
make-aur-package libjpeg6-turbo

echo "Downloading Open CoD:UO..."
echo "---------------------------------------------------------------"
RELEASE_JSON=$(curl -Ls https://api.github.com/repos/opencoduo/coduomp/releases/latest)
ASSET=$(printf '%s\n' "$RELEASE_JSON" | jq -r '
	.assets[]
	| select(.name | test("^opencoduo-linux-x86_64-.*\\.tar\\.gz$"))
	| "\(.browser_download_url) \((.digest // "") | sub("^sha256:"; ""))"')
TARBALL_URL=$(printf '%s\n' "$ASSET" | cut -d' ' -f1)
TARBALL_SHA=$(printf '%s\n' "$ASSET" | cut -d' ' -f2)
TARBALL=${TARBALL_URL##*/}
if [ -z "$TARBALL_URL" ]; then
	echo "Could not find the linux-x86_64 release asset!" >&2
	exit 1
fi

if [ ! -f "$TARBALL" ]; then
	curl --retry-connrefused --retry 30 -Lo "$TARBALL" "$TARBALL_URL"
fi
if [ -n "$TARBALL_SHA" ]; then
	echo "$TARBALL_SHA  $TARBALL" | sha256sum -c -
fi

rm -rf pkg
mkdir -p pkg
tar -xzf "$TARBALL" -C pkg --strip-components=1
chmod +x pkg/CoDUOMP pkg/uo/*.so
