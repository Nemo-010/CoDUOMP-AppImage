#!/bin/sh

# Open CoD:UO (OpenCoDuo) Anylinux AppImage launcher.
#
# The client finds its bundled cgame/UI modules through fs_basepath, which
# defaults to the current working directory, and the retail main/ and uo/
# game data through fs_cdpath. The AppImage is read-only, so both are set
# explicitly here.

set -e

MAIN_BIN=CoDUOMP

export PATH=$APPDIR/bin:$PATH
export ARG0 APPDIR PATH

if [ -f "$APPDIR"/AppRun.lib ]; then
	. "$APPDIR"/AppRun.lib
	for hook in $APPDIR/bin/*.hook; do
		[ -e "$hook" ] || continue
		. "$hook"
	done
fi

# Where the engine keeps configuration, logs, downloads and screenshots.
if [ -z "$CODUOMP_HOME" ]; then
	if [ -n "$XDG_DATA_HOME" ]; then
		CODUOMP_HOME=$XDG_DATA_HOME/opencoduo
	else
		CODUOMP_HOME=${HOME:-/tmp}/.local/share/opencoduo
	fi
fi
mkdir -p "$CODUOMP_HOME"

# Retail data root: must contain main/pak0.pk3 and uo/pakuo00.pk3.
# CODUOMP_DATA_PATH wins, then a saved selection, then Steam app 2640.
CODUOMP_CONFIG_DIR=${XDG_CONFIG_HOME:-${HOME:-/tmp}/.config}/opencoduo
CODUOMP_DATA_CONF=$CODUOMP_CONFIG_DIR/data-path

_find_steam_data() {
	_root=$1
	[ -d "$_root/steamapps" ] || return 1
	for _manifest in "$_root"/steamapps/appmanifest_2640.acf; do
		[ -f "$_manifest" ] || continue
		_installdir=$(sed -n 's/.*"installdir"[[:space:]]*"\([^"]*\)".*/\1/p' "$_manifest" | head -n 1)
		[ -n "$_installdir" ] || continue
		printf '%s\n' "$_root/steamapps/common/$_installdir"
		return 0
	done
	return 1
}

_find_library_folders() {
	[ -f "$1/steamapps/libraryfolders.vdf" ] || return 0
	sed -n 's/.*"path"[[:space:]]*"\([^"]*\)".*/\1/p' "$1/steamapps/libraryfolders.vdf"
}

_valid_data_root() {
	[ -d "$1/main" ] && [ -d "$1/uo" ] &&
		[ -f "$1/main/pak0.pk3" ] && [ -f "$1/uo/pakuo00.pk3" ]
}

if [ -z "$CODUOMP_DATA_PATH" ] && [ -f "$CODUOMP_DATA_CONF" ]; then
	CODUOMP_DATA_PATH=$(sed -n '1p' "$CODUOMP_DATA_CONF")
fi

if [ -z "$CODUOMP_DATA_PATH" ]; then
	_steam=$HOME/.steam/steam
	[ -d "$_steam" ] || _steam=$HOME/.local/share/Steam
	[ -d "$_steam" ] || _steam=$HOME/.var/app/com.valvesoftware.Steam/data/Steam
	for _root in "$_steam" $(_find_library_folders "$_steam"); do
		[ -n "$_root" ] || continue
		_candidate=$(_find_steam_data "$_root" 2>/dev/null) || continue
		if _valid_data_root "$_candidate"; then
			CODUOMP_DATA_PATH=$_candidate
			break
		fi
	done
fi

if ! _valid_data_root "$CODUOMP_DATA_PATH"; then
	err_msg "======================================================================"
	err_msg ""
	err_msg "Call of Duty: United Offensive game data was not found."
	err_msg ""
	err_msg "The AppImage contains the engine and its modules only. Point it at a"
	err_msg "retail installation that contains both main/pak0.pk3 and"
	err_msg "uo/pakuo00.pk3, either with the CODUOMP_DATA_PATH environment"
	err_msg "variable or by writing the path into:"
	err_msg ""
	err_msg "  $CODUOMP_DATA_CONF"
	err_msg ""
	err_msg "Example:"
	err_msg ""
	err_msg "  CODUOMP_DATA_PATH=\"\$HOME/.steam/steam/steamapps/common/Call of Duty United Offensive\" \\"
	err_msg "    $ARG0"
	err_msg ""
	err_msg "======================================================================"
	exit 1
fi

mkdir -p "$CODUOMP_CONFIG_DIR" 2>/dev/null || :
printf '%s\n' "$CODUOMP_DATA_PATH" > "$CODUOMP_DATA_CONF" 2>/dev/null || :

# fs_basepath only ever needs the bundled uo/ modules, so the AppImage root
# is correct for it. The retail paks arrive through fs_cdpath.
set -- "$APPDIR/bin/$MAIN_BIN" \
	+set fs_basepath "$APPDIR" \
	+set fs_cdpath "$CODUOMP_DATA_PATH" \
	+set fs_homepath "$CODUOMP_HOME" \
	"$@"

cd "$APPDIR"

if [ "$APPIMAGE_DEBUG" = 1 ]; then
	cat /etc/os-release >"$PWD"/"${APPIMAGE##*/}"-debug.log 2>/dev/null || :
	export LD_DEBUG=libs
	export LIBGL_DEBUG=verbose
	export EGL_LOG_LEVEL=debug
	export LC_ALL=C
	export CROSS_LIBC_DLOPEN_DEBUG=1
	export SHARUN_PRINTENV=1
	"$@" 2>>"$PWD"/"${APPIMAGE##*/}"-debug.log || :
	>&2 echo "Debug log at: '$PWD/${APPIMAGE##*/}-debug.log'"
else
	exec "$@"
fi
