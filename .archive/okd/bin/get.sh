MAJOR=39
RELEASE=39.20240225.3.0

mkdir ${MAJOR}

for i in live-kernel-x86_64 initramfs.x86_64.img rootfs.x86_64.img; do 
	wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${RELEASE}/x86_64/fedora-coreos-${RELEASE}-${i};
done

wget https://github.com/okd-project/okd/releases/download/4.15.0-0.okd-2024-03-10-010116/openshift-client-linux-4.15.0-0.okd-2024-03-10-010116.tar.gz
wget https://github.com/okd-project/okd/releases/download/4.15.0-0.okd-2024-03-10-010116/openshift-install-linux-4.15.0-0.okd-2024-03-10-010116.tar.gz
