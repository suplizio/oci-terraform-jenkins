# SSH -Must use fully qualified paths to files, ~ not supported
fingerprint="8b:ad:e0:1b:e5:5d:c7:bf:df:5e:9f:c0:58:6a:1e:6a"
private_key_path="/Users/jasonsuplizio/.oci/oci_api_key.pem"
ssh_private_key="/Users/jasonsuplizio/.ssh/id_rsa"
ssh_authorized_keys="/Users/jasonsuplizio/.ssh/id_rsa.pub"

# Regions
region="us-phoenix-1"

# Tenancy
tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaaej42v3hufhtwz7ssrsynoslc7eunq2nrkepvqjhxj3dbxknnhhwa"

# IAM
user_ocid="ocid1.user.oc1..aaaaaaaabdym3x2s3zhuumgzbp6tkgawk2l2lcxnkskgcnbq5fsve5ak25ba"
#compartment_ocid="ocid1.compartment.oc1..aaaaaaaat2axyzcauvxp4jcaco7mvu7zbeuot72gqaufb3ydbjbd7dbvfaxq"
compartment_ocid="ocid1.compartment.oc1..aaaaaaaap6w5spmp62dq35zk7nkby5jiizchbg42l56dz6lfovefjzx4n5xq"

#Jenkins
slave_count = 1
plugins = [
  "git",
  "ssh-slaves",
  "oracle-cloud-infrastructure-compute",
  "blueocean",
  "github",
  "github-branch-source",
  "github-api"
]
