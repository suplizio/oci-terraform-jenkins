## DATASOURCE
# Init Script Files
data "template_file" "setup_jenkins" {
  template = "${file("${path.module}/scripts/setup.sh")}"

  vars {
    http_port = "${var.http_port}"
    jnlp_port = "${var.jnlp_port}"
    plugins   = "${join(" ", var.plugins)}"
  }
}

## JENKINS MASTER INSTANCE
resource "oci_core_instance" "TFJenkinsMaster" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.master_display_name}"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_id}"
    display_name     = "${var.label_prefix}${var.master_display_name}"
    assign_public_ip = "${var.assign_public_ip}"
    hostname_label   = "${var.master_display_name}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }

  connection {
    host        = "${self.public_ip}"
    agent       = false
    timeout     = "5m"
    user        = "opc"
    private_key = "${file("${var.ssh_private_key}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.setup_jenkins.rendered}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }


  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible -i ${oci_core_instance.TFJenkinsMaster.public_ip}, -u opc -b -m fetch -a 'src=/var/lib/jenkins/secrets/initialAdminPassword dest=./JenkinsMasterAdminPassword flat=yes' all"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible -i ${oci_core_instance.TFJenkinsMaster.public_ip}, -u opc -b -m fetch -a 'src=/var/lib/jenkins/.ssh/id_rsa.pub dest=./JenkinsMasterPublicKey flat=yes' all"
  }

  timeouts {
    create = "10m"
  }
}
