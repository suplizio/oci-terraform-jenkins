#!/bin/bash
set -e -x

function waitForJenkins() {
    echo "Waiting for Jenkins to launch on ${http_port}..."

    while ! timeout 1 bash -c "echo > /dev/tcp/localhost/${http_port}"; do
      sleep 1
    done

    echo "Jenkins launched"
}

function waitForPasswordFile() {
    echo "Waiting for Jenkins to generate password..."

    while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
      sleep 2 # wait for 1/10 of the second before check again
    done

    sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /tmp/secret
    echo "Password created"
}


# Install Java for Jenkins
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"
sudo rpm -ivh jdk-8u181-linux-x64.rpm

# Install xmlstarlet used for XML config manipulation
sudo yum install -y xmlstarlet

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum install -y jenkins

# Config Jenkins Http Port
sudo sed -i '/JENKINS_PORT/c\ \JENKINS_PORT=\"${http_port}\"' /etc/sysconfig/jenkins

# Start Jenkins
sudo service jenkins restart
sudo chkconfig --add jenkins

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=${jnlp_port}/tcp
sudo firewall-cmd --reload

waitForJenkins

# UPDATE PLUGIN LIST
curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:${http_port}/updateCenter/byId/default/postBack

sleep 10

waitForJenkins

# INSTALL CLI
sudo cp /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar /var/lib/jenkins/jenkins-cli.jar

waitForPasswordFile

PASS=$(sudo bash -c "cat /var/lib/jenkins/secrets/initialAdminPassword")

sleep 10

# SET AGENT PORT
xmlstarlet ed -u "//slaveAgentPort" -v "${jnlp_port}" /var/lib/jenkins/config.xml > /tmp/jenkins_config.xml
sudo mv /tmp/jenkins_config.xml /var/lib/jenkins/config.xml
sudo service jenkins restart

waitForJenkins

sleep 10

# INSTALL PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS install-plugin ${plugins}

# RESTART JENKINS TO ACTIVATE PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS restart

# CodeOne demo
sudo yum install -y terraform terraform-provider-oci git ansible
sudo -u opc ssh-keygen -t rsa -b 4096 -N "" -f /home/opc/.ssh/id_rsa
chown opc:opc /home/opc/.ssh/id_rsa
chmod 0600 /home/opc/.ssh/id_rsa

sudo -u jenkins mkdir /var/lib/jenkins/.ssh
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa
sudo -u jenkins ssh-keyscan -t rsa github.com >> /var/lib/jenkins/.ssh/known_hosts
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
sudo chown jenkins.jenkins /ttvar/lib/jenkins/.ssh/known_hosts
sudo chmod 0600 /var/lib/jenkins/.ssh/id_rsa
sudo cat /var/lib/jenkins/.ssh/id_rsa.pub >> /home/opc/sshJenkinsPublicKey
sudo chown opc:opc /home/opc/sshJenkinsPublicKey
