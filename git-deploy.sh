#!/bin/bash
DIRNAME="$(dirname $0)"
ROOTDIR="$DIRNAME/.."
shutdown() {

		>&2 echo "error: exiting " $1
		exit 2
}

usage() {
	echo
	echo "git-deploy, set up a git env to easily deploy your projects"
	echo ""
	echo ""
	echo ""
	echo ""
	echo "-b  Bare repository"

	echo "-s  source directory"

		echo "-p  Project string"
}

OPTIND=1
shift $((OPTIND-1))

[ "$1" = "--" ] && shift



BARE=""
SOURCE=""
PROJECT=""
while getopts "s:b:p:" opt; do
		case "$opt" in
		b)

			BARE=$OPTARG
				;;
		s)
			SOURCE=$OPTARG
			;;
		p)
		PROJECT=$OPTARG
		;;


		esac
done



if [ ! -d $BARE ];then
	mkdir -p $BARE
fi
pushd $BARE
git init --bare

cat > hooks/post-update <<- EOM
#!/bin/sh
echo
echo "**** Pulling changes into Live [$PROJECT]"
echo
cd $SOURCE || exit
unset GIT_DIR
git pull hub master
exec git update-server-info
EOM
chmod u+x hooks/post-update
popd
if [ ! -d $SOURCE ];then
	mkdir -p $SOURCE
fi
pushd $SOURCE
git init
cat > .git/config <<- EOM
[remote "hub"]
  url = $BARE
  fetch = +refs/heads/*:refs/remotes/hub/*
EOM



popd
