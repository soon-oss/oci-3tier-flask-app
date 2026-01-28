# 1. THE VCN (The Network Hub)
resource "oci_core_vcn" "main_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "OCI-3Tier-VCN"
  dns_label      = "mainvcn"
}

# 2. INTERNET GATEWAY (Allows Traffic In/Out)
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "InternetGateway"
}

# 3. ROUTE TABLE (Public Subnet) - Route to Internet
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

# 4. SECURITY LIST (Public Subnet) - Allow Web + SSH
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "PublicSecurityList"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow SSH (Port 22)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow Flask App (Port 5000)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 5000
      max = 5000
    }
  }
}

# 5. PUBLIC SUBNET (Where the Flask App lives)
resource "oci_core_subnet" "public_subnet" {
  cidr_block        = var.public_subnet_cidr
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main_vcn.id
  display_name      = "Public-Subnet-App"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

# 6. SECURITY LIST (Private Subnet) - Allow DB access only from VCN
resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "PrivateSecurityList"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow Oracle DB (Port 1521) ONLY from inside the VCN
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr # Strict Internal Access Only
    tcp_options {
      min = 1521
      max = 1521
    }
  }
}

# 7. PRIVATE SUBNET (Where the DB lives)
resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet_cidr
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main_vcn.id
  display_name               = "Private-Subnet-DB"
  prohibit_public_ip_on_vnic = true # No Public IP allowed!
  security_list_ids          = [oci_core_security_list.private_sl.id]
}

# 8. OUTPUTS (What did we build?)
output "vcn_id" {
  value = oci_core_vcn.main_vcn.id
}
output "public_subnet_id" {
  value = oci_core_subnet.public_subnet.id
}