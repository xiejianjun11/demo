# How to use, RPMs repo dir is required
if [ -z $1 ]; then
    echo "Usage: install.sh <dir>"
    exit
fi

# Use the absolute file path
path=`readlink -f $1`

# Configure a local repo
rm -rf /etc/yum.repos.d/local.repo
cat <<EOF>>/etc/yum.repos.d/local.repo
[local]
name=Local Repo
baseurl=file://$path
enabled=1
gpgcheck=0
EOF

# Prepare for the local repo
#$ pre-rpms.sh
rpm -ivh $path/deltarpm*
rpm -ivh $path/python-deltarpm*
rpm -ivh $path/createrepo*

# Setup the local repo
createrepo $path
chmod o-w+r $path

# Install using yum
# yum repolist => base,extras,updates
packages=`ls -A $path/*.rpm | awk '{print}'`
for i in $packages
do
    yum --disablerepo=base,extras,updates install -y $i
done

#$ post-install.sh