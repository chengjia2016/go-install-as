#!/bin/bash
set -e

TMP_DIR="/tmp"
SOURCE_DIR=`pwd`
IMPORT_AS=`basename $SOURCE_DIR`
DESTINATION_DIR="$GOROOT"

function usage()
{
    echo -e "'go install' a package under a specific import path"
    echo -e ""
    echo -e "./$0"
    echo -e "\t(--tmp-dir=$TMP_DIR)"
    echo -e "\t(--source-dir=$SOURCE_DIR)"
    echo -e "\t(--import-as=$IMPORT_AS)"
    echo -e "\t(--destination-dir=$DESTINATION_DIR)"
    echo -e "\t(-h)"
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --tmp-dir)
            TMP_DIR=$VALUE
            ;;
        --source-dir)
            SOURCE_DIR=$VALUE
            ;;
        --import-as)
            IMPORT_AS=$VALUE
            ;;
        --destination-dir)
            DESTINATION_DIR=$VALUE
            ;;
    esac
    shift
done

if [ ! -d $TMP_DIR ]; then
    echo "--tmp-dir must exist"
    exit 1
fi

if [ ! -d $SOURCE_DIR ]; then
    echo "--source-dir must exist"
    exit 1
fi

if [ ! -d $DESTINATION_DIR ]; then
    echo "--destination-dir must exist"
    exit 1
fi

rand_suffix=`cat /dev/urandom | LC_CTYPE=C tr -dc _A-Z-a-z-0-9 | head -c8`
working_dir="$TMP_DIR/go-install-as_$rand_suffix"
echo "working dir: $working_dir"
mkdir -p $working_dir

build_dir="$working_dir/src/$IMPORT_AS"
echo "build dir: $build_dir"
mkdir -p $build_dir

cp -R $SOURCE_DIR/* $build_dir
cd $build_dir
echo "go install'ing"
env GOPATH="$working_dir:$GOPATH" go install

goos=`go env GOOS`
goarch=`go env GOARCH`
pkg_dir="${goos}_${goarch}"
echo "copying to $DESTINATION_DIR/pkg/$pkg_dir/"
cp -R $working_dir/pkg/$pkg_dir/* $DESTINATION_DIR/pkg/$pkg_dir/
