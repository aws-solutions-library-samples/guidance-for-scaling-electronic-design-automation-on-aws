#!/bin/bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

echo "*** BEGIN LSF HOST BOOTSTRAP ***"

# Export user data, which is defined with the "UserData" attribute
# in the template
%EXPORT_USER_DATA%

export PATH=/sbin:/usr/sbin:/usr/local/bin:/bin:/usr/bin
export AWS_DEFAULT_REGION="$( curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/[a-z]*$//' )"
export EC2_INSTANCE_TYPE="$( curl -s http://169.254.169.254/latest/meta-data/instance-type | sed -e 's/\./_/' )"
export LSF_INSTALL_DIR_ROOT="/`echo $LSF_INSTALL_DIR | cut -d / -f2`"
export LSF_ADMIN=lsfadmin
export ARCH="`uname -p`"

# Add the LSF admin account
useradd -m -u 1500 $LSF_ADMIN
# Add DCV login user account
useradd -m -u 1501 $DCV_USER_NAME

# Install SSM so we can use SSM Session Manager and avoid ssh logins.
if [[ $ARCH == "aarch64" ]]; then
   yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
else
   yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
fi
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Disable Hyperthreading
if [[ $ARCH == "x86_64" ]]; then
   echo "Disabling Hyperthreading"
   for cpunum in $(cut -s -d, -f2- /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | tr ',' '\n' | sort -un)
   do
      echo 0 > /sys/devices/system/cpu/cpu${cpunum}/online
   done
fi

# enable NFS for aarch64 AMI
if [[ $ARCH == "aarch64" ]]; then
   yum -y install nfs-utils
   service nfs start
fi

# mount shared file systems
mkdir $LSF_INSTALL_DIR_ROOT
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFS_FS_DNS_NAME}:/ $LSF_INSTALL_DIR_ROOT


if [[ $LSF_CLUSTER_NAME == *"Region-A"* ]]; then
  FLEXCACHE_MOUNTPOINT="/scratch"
  ORIGIN_VOLUME_MOUNTPOINT='/eda_tools'
  FLEXCACHE_VOLNAME="scratch_cached"
  ORIGIN_VOLNAME="vol1_onprem"
  # Mount Origin
   mkdir ${ORIGIN_VOLUME_MOUNTPOINT}
   mount -t nfs ${ONTAP_HOST_NAME}:/${ORIGIN_VOLNAME} ${ORIGIN_VOLUME_MOUNTPOINT}
   # Mount FlexCache
   mkdir ${FLEXCACHE_MOUNTPOINT}
   mount -t nfs ${ONTAP_HOST_NAME}:/${FLEXCACHE_VOLNAME} ${FLEXCACHE_MOUNTPOINT}
else
   FLEXCACHE_MOUNTPOINT="/eda_tools"
   ORIGIN_VOLUME_MOUNTPOINT='/scratch'
   FLEXCACHE_VOLNAME="tool_cached"
   ORIGIN_VOLNAME="vol1_cloud"
   # Mount Origin
   mkdir ${ORIGIN_VOLUME_MOUNTPOINT}
   mount -t nfs ${CLOUD_ONTAP_HOST_NAME}:/${ORIGIN_VOLNAME} ${ORIGIN_VOLUME_MOUNTPOINT}
   # Mount FlexCache
   mkdir ${FLEXCACHE_MOUNTPOINT}
   mount -t nfs ${CLOUD_ONTAP_HOST_NAME}:/${FLEXCACHE_VOLNAME} ${FLEXCACHE_MOUNTPOINT}
fi

## Set up Python3 environment for OpenLane
sudo yum install -y python3 python3-pip
python3 -m pip install --upgrade --no-cache-dir volare

## Install Git for OpenLane
sudo yum install -y git

## Set up Docker environment for OpenLane
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker

## Add "simuser" as docker group to run docker without root
sudo groupadd docker
sudo usermod -aG docker simuser

## Set up the LSF environment
# if [[ $ARCH == "aarch64" ]]; then
#    export LSF_MASTER_SERVER=`cat $LSF_INSTALL_DIR/conf/lsf.conf | grep -e MASTER | awk -F= '{print $2}'`

#    yum install -y jre
#    yum install -y ed
#    cp $LSF_INSTALL_DIR/10.1/install/lsf10.1_lnx312-lib217-armv8.tar.Z /tmp/
#    cp $LSF_INSTALL_DIR/10.1/install/lsf10.1_no_jre_lsfinstall.tar.Z /tmp/
#    cd /tmp
#    tar xvf lsf10.1_no_jre_lsfinstall.tar.Z
#    cp lsf10.1_lnx312-lib217-armv8.tar.Z lsf10.1_lsfinstall
#    cd lsf10.1_lsfinstall

# # Create LSF installer config file
# cat << EOF > compute.config
# LSF_TOP="/usr/local/lsf"
# LSF_ADMINS="$LSF_ADMIN"
# LSF_TARDIR="/tmp/lsf10.1_lsfinstall"
# SILENT_INSTALL="Y"
# LSF_SILENT_INSTALL_TARLIST="ALL"
# ACCEPT_LICENSE="Y"
# LSF_ENTITLEMENT_FILE="$LSF_INSTALL_DIR/conf/lsf.entitlement"
# LSF_SERVER_HOSTS=$LSF_MASTER_SERVER
# LSF_LIM_PORT="7869"
# ENABLE_EGO="Y"
# EOF

   # ./lsfinstall -s -f compute.config
# fi

# Create LSF log and conf directories
mkdir /var/log/lsf && chmod 777 /var/log/lsf
mkdir /etc/lsf && chmod 777 /etc/lsf

LSF_TOP=$LSF_INSTALL_DIR
source $LSF_TOP/conf/profile.lsf

# Create local lsf.conf file and update LSF_LOCAL_RESOURCES
# parameter to support dynamic resources
cp $LSF_ENVDIR/lsf.conf /etc/lsf/lsf.conf
chmod 444 /etc/lsf/lsf.conf
export LSF_ENVDIR=/etc/lsf

# Add instance_type resource
sed -i "s/\(LSF_LOCAL_RESOURCES=.*\)\"/\1 [resourcemap ${EC2_INSTANCE_TYPE}*instance_type]\"/" $LSF_ENVDIR/lsf.conf
echo "Updated LSF_LOCAL_RESOURCES lsf.conf with [resourcemap ${EC2_INSTANCE_TYPE}*instance_type]"

if [ -n "${rc_account}" ]; then
   sed -i "s/\(LSF_LOCAL_RESOURCES=.*\)\"/\1 [resourcemap ${rc_account}*rc_account]\"/" $LSF_ENVDIR/lsf.conf
   echo "Updated LSF_LOCAL_RESOURCES lsf.conf with [resourcemap ${rc_account}*rc_account]"
fi

if [ -n "${spot}" ]; then
   sed -i "s/\(LSF_LOCAL_RESOURCES=.*\)\"/\1 [resource ${spot}]\"/" $LSF_ENVDIR/lsf.conf
   echo "Updated LSF_LOCAL_RESOURCES lsf.conf with [resource ${spot}]"
fi

if [ -n "${ssd}" ]; then
   sed -i "s/\(LSF_LOCAL_RESOURCES=.*\)\"/\1 [resource ${ssd}]\"/" $LSF_ENVDIR/lsf.conf
   echo "Updated LSF_LOCAL_RESOURCES lsf.conf with [resource ${ssd}]"
fi

# Start LSF Daemons
lsadmin limstartup
lsadmin resstartup
sleep 2
badmin hstartup

echo "*** END LSF HOST BOOTSTRAP ***"