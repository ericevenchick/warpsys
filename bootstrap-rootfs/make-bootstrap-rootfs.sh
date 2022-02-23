set -euxo pipefail

# temp directory to store rootfs while building
TMPDIR=/tmp/rootfs

# suite (or release) to use
SUITE=focal

# debian/ubuntu mirror to use
MIRROR='deb http://mirrors.digitalocean.com/ubuntu focal main universe'

# this value is used as the timestamp for building the rootfs
# for a given value, this will create a repeatable build
# this needs to be exported for mmdebstrap
export SOURCE_DATE_EPOCH=1645037482

# create the warehouse in case it doesn't exist
mkdir -p $HOME/.warpforge/warehouse

# delete the existing rootfs, in case it exists
rm -rf $TMPDIR

# mmbootstrap the rootfs
./mmdebstrap/mmdebstrap --variant=minbase --include='bash binutils binutils-dev bison build-essential bzip2 coreutils diffutils findutils gawk gcc g++ grep gzip m4 make patch perl python3-dev sed tar texinfo xz-utils' $SUITE $TMPDIR "$MIRROR"

# chown all rootfs files to the current user so we can `rio pack` it
sudo chown -R $USER $TMPDIR

# pack the rootfs into our warehouse
rio pack --target=ca+file://$HOME/.warpforge/warehouse --filters=uid=0,gid=0,setid=ignore,mtime=@$SOURCE_DATE_EPOCH tar $TMPDIR

# delete the temp dir
rm -rf $TMPDIR
