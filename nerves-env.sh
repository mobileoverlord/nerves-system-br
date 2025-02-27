#!/bin/bash

# Source this script to setup your environment to cross-compile
# and build Erlang apps for this Nerves build.

# "readlink -f" implementation for BSD
# This code was extracted from the Elixir shell scripts
readlink_f () {
    cd "$(dirname "$1")" > /dev/null
    filename="$(basename "$1")"
    if [ -h "$filename" ]; then
        readlink_f "$(readlink "$filename")"
    else
        echo "`pwd -P`/$filename"
    fi
}

# If the script is called with the -get-nerves-root flag it just returns the
# Nerves system directory. This is so that other shells can execute the script
# without needing to implement the equivalent of $BASH_SOURCE for every shell.
for arg in $*
do
    if [ $arg = "-get-nerves-root" ];
    then
        echo $(dirname $(readlink_f "${BASH_SOURCE[0]}"))
        exit 0
    fi
done

if [ "$BASH_SOURCE" = "" ]; then
    GET_NR_COMMAND="$0 $@ -get-nerves-root"
    SCRIPT_DIR=$(bash -c "$GET_NR_COMMAND")
else
    SCRIPT_DIR=$(dirname $(readlink_f "${BASH_SOURCE[0]}"))
fi

# Detect if this script has been run directly rather than sourced, since
# that won't work.
if [[ "$SHELL" = "/bin/bash" ]]; then
    if [ "$0" != "bash" -a "$0" != "-bash" -a "$0" != "/bin/bash" ]; then
        echo ERROR: This scripted should be sourced from bash:
        echo
        echo source $BASH_SOURCE
        echo
        exit 1
    fi
#elif [[ "$SHELL" = "/bin/zsh" ]]; then
# TODO: Figure out how to detect this error from other shells.
fi

# Determine the location of the NERVES_SYSTEM directory. This script is
# either being sourced from the directory or from the base of nerves-system-br.
# If it's the latter, then point the helper script at the appropriate place.
if [ -e "$SCRIPT_DIR/.config" ]; then
    NERVES_SYSTEM=$SCRIPT_DIR
elif [ -e "$SCRIPT_DIR/buildroot/output" ]; then
    NERVES_SYSTEM=$SCRIPT_DIR/buildroot/output
else
    echo "ERROR: Can't find Nerves system directory. Has Nerves been built?"
    echo " If sourcing from the nerves-system-br directory, then the build products"
    echo " aren't in the default location. The new way is to source nerves-env.sh"
    echo " from nerves-system-br's output directory."
    return 1
fi

source $SCRIPT_DIR/scripts/nerves-env-helper.sh $NERVES_SYSTEM
if [ $? != 0 ]; then
    echo "Shell environment NOT updated for Nerves!"
    return 1
else
    # Found it. Print out some useful information so that the user can
    # easily figure out whether the wrong nerves installation was used.
    NERVES_DEFCONFIG=$(grep BR2_DEFCONFIG= $NERVES_SYSTEM/.config | sed -e 's/BR2_DEFCONFIG=".*\/\(.*\)"/\1/')
    NERVES_VERSION=$(grep NERVES_VERSION:= $NERVES_SYSTEM/nerves.mk | sed -e 's/NERVES_VERSION\:=\(.*\)/\1/')
    NERVES_ELIXIR_VERSION_FILE=$(dirname $(readlink_f $(which iex)))/../VERSION

    echo "Shell environment updated for Nerves"
    echo
    echo "Nerves version: $NERVES_VERSION"
    echo "Nerves configuration: $NERVES_DEFCONFIG"
    echo "Cross-compiler prefix: $(basename $CROSSCOMPILE)"
    echo "Erlang/OTP release on target: $NERVES_TARGET_ERL_VER"
    if [ -e $NERVES_ELIXIR_VERSION_FILE ]; then
        echo "Elixir version: $(cat $NERVES_ELIXIR_VERSION_FILE)"
    fi
fi
