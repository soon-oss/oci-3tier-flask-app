# terraform/main.tf

# 1. Create the VCN (Virtual Cloud Network)
resource "oci_core_vcn" "flask_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "flask-app-vcn"
  dns_label      = "flaskvcn"
}

# 2. Create an Internet Gateway (so the public can see the app)
resource "oci_core_internet_gateway" "flask_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.flask_vcn.id
  display_name   = "flask-internet-gateway"
}

# 3. Create a Route Table for the Public Subnet
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.flask_vcn.id
  display_name   = "flask-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.flask_ig.id
  }
}

# 4. Create the Public Subnet (For Flask App / Load Balancer)
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.flask_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "flask-public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_vcn.flask_vcn.default_security_list_id]
}

# 5. Create the Private Subnet (For Oracle Database)
resource "oci_core_subnet" "private_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.flask_vcn.id
  cidr_block                 = "10.0.2.0/24"
  display_name               = "flask-private-subnet"
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true # This makes it strictly private
}