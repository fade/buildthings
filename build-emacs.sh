#!/usr/bin/env bash

# set -x

# Defaults for unspecified options.

num_jobs=$(cat /proc/cpuinfo | grep 'core id' | wc -l)
source_location=$HOME/SourceCode/emacs
source_tag=master

# do the options

while getopts g:p:s:t: flag
do
    case "${flag}" in
        g) puregtk=${OPTARG};;
        p) num_jobs=${OPTARG};;
        s) source_location=${OPTARG};;
        t) source_tag=${OPTARG};;
    esac
done

emacs_src=$source_location

echo "NUMBER OF PARALLEL JOBS: $num_jobs"
echo "IN SOURCE TREE: $source_location"
echo "For Source tag: $source_tag"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "using $emacs_src source directory"

# if the source directory exists, use it, otherwise clone it and use
# the new clone

# if ( $puregtk )
# then
#     echo "Cloning puregtk emacs source from https://github.com/fejfighter/emacs"
#     git clone -b pgtk-nativecomp https://github.com/fejfighter/emacs $emacs_src
#     # cd $emacs_src
#     echo [Done.]

if [[ -d $emacs_src ]]
then
    cd $emacs_src
else
    echo "Cloning emacs source from git://git.savannah.gnu.org/emacs.git"
    git clone git://git.savannah.gnu.org/emacs.git $emacs_src
    cd $emacs_src
    echo [Done.]
fi

sleep 5

./autogen.sh &&

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Cleaning old build artifacts... "

sleep 5

make distclean

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Stashing any remaining local files so checkout/fetch can work..."

sleep 5

git stash

echo "Refreshing sources from upstream..."

sleep 5

echo "Checking out $source_tag ..."
sleep 3
git checkout $source_tag &&
echo "[ Done. ]"

git fetch --all && git pull --all &&
# git checkout master && git fetch --all && git pull --all &&

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Configuring emacs source code for version $source_tag... "

sleep 3


## native comp
echo "Configuring with emacs Native Compilation for elisp..."
./configure --with-native-compilation --with-gnutls --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xml2

## no native comp
# ./configure --with-gnutls --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xml2

# if ( $puregtk )
# then
#     ./configure --with-dbus --with-giv --with-jpeg --with-png --with-rsvg --with-tiff --with-xft --with-xpm --with-gpm --with-xwidgets --with-modules --with-native-comp --with-pgtk
# else
#     ./configure --with-native-compilation --with-gnutls --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xml2
# fi

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Configured. Building with $num_jobs workers..."

sleep 5

make -j$num_jobs bootstrap

