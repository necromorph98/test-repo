echo "Removing Azure Linux agent..."
# Stop the service first
systemctl stop walinuxagent || true
systemctl disable walinuxagent || true

# Remove configuration and data
rm -rf /var/lib/waagent/
rm -rf /etc/waagent.conf

# Purge the package
apt purge -y walinuxagent

# Install AWS-compatible packages
echo "Installing AWS-compatible packages..."
apt install -y cloud-utils cloud-init ec2-instance-connect

echo "Configuring cloud-init for AWS EC2..."
cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg << 'CLOUD_CFG'
datasource_list: [ NoCloud, ConfigDrive, OpenNebula, DigitalOcean, Azure, AltCloud, OVF, MAAS, GCE, OpenStack, CloudSigma, SmartOS, Bigstep, Scaleway, AliYun, Ec2, CloudStack, Hetzner, IBMCloud, Oracle, Exoscale, RbxCloud, UpCloud, VMware, Vultr, LXD, NWCS, Akamai, None ]
CLOUD_CFG

echo "Cleaning cloud-init state..."
cloud-init clean --logs

echo "Cleaning up packages..."
apt autoremove -y
apt autoclean
apt clean
