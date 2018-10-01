#!/bin/bash
set -e -x

# Install Java for Jenkins
sudo yum install -y java

# Config jenkins user on slave node
sudo useradd --home-dir /home/jenkins --create-home --shell /bin/bash jenkins
mkdir /home/jenkins/jenkins-slave
sudo chown -R jenkins:jenkins /home/jenkins

# Get password and dependencies from master node
chmod 0600 /tmp/key.pem
ssh -oStrictHostKeyChecking=no -i /tmp/key.pem opc@${jenkins_master_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > /tmp/secret

# Get dependencies from master node
wget -P /tmp ${jenkins_master_url}/jnlpJars/jenkins-cli.jar
wget -P /tmp ${jenkins_master_url}/jnlpJars/slave.jar
sudo mv /tmp/slave.jar /home/jenkins/jenkins-slave/

# CodeOne demo
sudo yum install -y terraform terraform-provider-oci git
sudo -u opc ssh-keygen -t rsa -b 4096 -N "" -f /home/opc/.ssh/id_rsa
chown opc:opc /home/opc/.ssh/id_rsa
chmod 0600 /home/opc/.ssh/id_rsa

sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /home/jenkins/.ssh/id_rsa
chown opc:opc /home/jenkins/.ssh/id_rsa
chmod 0600 /home/jenkins/.ssh/id_rsa
