#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel       \
	curl             \
	libdecor         \
	libjpeg-turbo    \
	minizip          \
	openal           \
	patchelf         \
	sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa --prefer-nano libdecor-mini

echo "Downloading Open CoD:UO release 7..."
echo "---------------------------------------------------------------"
TARBALL=opencoduo-linux-x86_64-e23642dc5.tar.gz
SHASUM=d8f3cc972e508d27035de5d6c45c401fe5014840c1bd7909e5ba9794aa3c135a
if [ ! -f "$TARBALL" ]; then
	curl --retry-connrefused --retry 30 -Lo "$TARBALL" \
		"https://github.com/opencoduo/coduomp/releases/download/7/$TARBALL"
fi
echo "$SHASUM  $TARBALL" | sha256sum -c -

mkdir -p pkg
tar -xzf "$TARBALL" -C pkg --strip-components=1 \
	opencoduo-linux-x86_64-e23642dc5/CoDUOMP \
	opencoduo-linux-x86_64-e23642dc5/uo
chmod +x pkg/CoDUOMP pkg/uo/*.so

echo '7' > ~/version
