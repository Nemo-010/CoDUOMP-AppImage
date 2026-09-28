#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export OUTNAME=CoDUOMP-"$ARCH".AppImage
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=./opencoduo.png
export DESKTOP=./opencoduo.desktop
export MAIN_BIN=CoDUOMP
export APPDIR=${PWD}/AppDir
export DEPLOY_SDL=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PULSE=1
export ANYLINUX_LIB=1

# Deploy dependencies
quick-sharun \
	"$PWD/pkg/CoDUOMP"                  \
	"$PWD"/pkg/uo/uo_cgame_mp_x86_64.so \
	"$PWD"/pkg/uo/uo_ui_mp_x86_64.so    \
	"$PWD"/pkg/uo/uo_game_mp_x86_64.so

# fs_basepath points at APPDIR and Sys_LoadDll builds "<basepath>/<game>/<name>",
# so the modules have to sit at APPDIR/uo/ instead of under lib/
mkdir -p "$APPDIR"/uo
for m in uo_cgame_mp_x86_64.so uo_ui_mp_x86_64.so uo_game_mp_x86_64.so; do
	found=$(find "$APPDIR"/lib -name "$m" -print | head -n 1)
	if [ -z "$found" ]; then
		echo "ERROR: $m was not deployed!" >&2
		exit 1
	fi
	mv -f "$found" "$APPDIR"/uo/"$m"
done
find "$APPDIR"/lib -type d -empty -delete

# lib.path was written before the move, so it still lists the old location
"$APPDIR"/sharun -g

# quick-sharun generates AppRun itself; the paths the client needs are set
# from a hook, which AppRun sources from bin/
cp -f 90-coduomp-paths.hook "$APPDIR"/bin/90-coduomp-paths.hook

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
