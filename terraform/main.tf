# --- Network Architecture ---
# VCN with strict separation between Public and Private subnets

resource "oci_core_vcn" "main_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "OCI-3Tier-VCN"
  dns_label      = "mainvcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "InternetGateway"
}

# --- Public Subnet Configuration ---
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "PublicRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "PublicSecurityList"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow SSH for troubleshooting
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow Flask App Traffic
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 5000
      max = 5000
    }
  }
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block        = var.public_subnet_cidr
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main_vcn.id
  display_name      = "Public-Subnet-App"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

# --- Private Subnet Configuration ---
resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "PrivateSecurityList"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Security: Allow Oracle DB access ONLY from inside the VCN CIDR
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      min = 1521
      max = 1521
    }
  }
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet_cidr
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main_vcn.id
  display_name               = "Private-Subnet-DB"
  prohibit_public_ip_on_vnic = true # Security: Isolate DB from Internet
  security_list_ids          = [oci_core_security_list.private_sl.id]
}

# --- Outputs ---
output "vcn_id" {
  value = oci_core_vcn.main_vcn.id
}
output "public_subnet_id" {
  value = oci_core_subnet.public_subnet.id
}