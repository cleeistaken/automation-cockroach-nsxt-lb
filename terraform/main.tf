#
# Connect to NSX-T Provider
#
provider "nsxt" {
  host = var.nsxt_manager
  username = var.nsxt_user
  password = var.nsxt_password
  # global_manager = true
  allow_unverified_ssl = var.nsxt_insecure_ssl
}

#
# Fetch environment information
#

# Create the data sources we will need to refer to later
data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = var.nsxt_policy_transport_zone
}

data "nsxt_policy_tier0_gateway" "tier0_gw" {
  display_name = var.nsxt_policy_tier0_gateway
}

data "nsxt_policy_edge_cluster" "edge_cluster1" {
  display_name = var.nsxt_policy_edge_cluster
}

data "nsxt_policy_lb_monitor" "nsxt_policy_lb_monitor_active" {
  type = "HTTP"
  display_name = var.nsxt_policy_lb_monitor_active_name
}

data "nsxt_policy_lb_monitor" "nsxt_policy_lb_monitor_passive" {
  type = "PASSIVE"
  display_name = var.nsxt_policy_lb_monitor_passive
}

data "nsxt_policy_lb_persistence_profile" "nsxt_policy_lb_persistence_profile1" {
  display_name = var.nsxt_policy_lb_persistence_profile
}

data "nsxt_policy_lb_app_profile" "nsxt_policy_lb_app_profile_http" {
  type = "HTTP"
  display_name = var.nsxt_policy_lb_app_profile_http
}

data "nsxt_policy_lb_app_profile" "nsxt_policy_lb_app_profile_tcp" {
  type = "TCP"
  display_name = var.nsxt_policy_lb_app_profile_tcp
}

#
# Build environment
#

# Create T1 gateway
resource "nsxt_policy_tier1_gateway" "tier1_gw" {
  display_name = "${var.global_prefix}-${var.nsxt_t1_gw_name_suffix}"
  description = "Terraform provisioned Tier-1"
  failover_mode = "PREEMPTIVE"
  tier0_path = data.nsxt_policy_tier0_gateway.tier0_gw.path
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster1.path
  route_advertisement_types = [
    "TIER1_STATIC_ROUTES",
    "TIER1_CONNECTED",
    "TIER1_LB_VIP"]
  pool_allocation = "LB_SMALL"

  tag {
    scope = var.nsxt_tag_scope
    tag = var.nsxt_tag
  }
  tag {
    scope = var.nsxt_tag_scope
    tag = var.global_prefix
  }

}

# Create Segment 1
resource "nsxt_policy_segment" "segment1" {
  display_name = "${var.global_prefix}-${var.nsxt_segment_1_name_suffix}"
  description = "Terraform provisioned Segment"
  connectivity_path = nsxt_policy_tier1_gateway.tier1_gw.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = var.nsxt_segment_1_cidr
  }

  tag {
    scope = var.nsxt_tag_scope
    tag = var.nsxt_tag
  }
  tag {
    scope = var.nsxt_tag_scope
    tag = var.global_prefix
  }
}

#
# Monitor
#
# The current version of the Terraform NSXT plugin does not support creating
# policy monitors. This must be created manually and imported.

#
# Inventory Group 1
#
resource "nsxt_policy_group" "group1" {
  display_name = "${var.global_prefix}-${var.nsxt_policy_group_1_suffix}"
  description = "Terraform provisioned Group"

  tag {
    scope = var.nsxt_tag_scope
    tag = var.nsxt_tag
  }
  tag {
    scope = var.nsxt_tag_scope
    tag = var.global_prefix
  }

  criteria {
    condition {
      key = "Name"
      member_type = "VirtualMachine"
      operator = "STARTSWITH"
      value = var.global_prefix
    }
  }
}

# Create Pool 1 (Management)
resource "nsxt_policy_lb_pool" "pool1" {
  display_name = "${var.global_prefix}-${var.nsxt_policy_lb_pool_1_name_suffix}"
  description = "Terraform provisioned LB Pool"
  algorithm = var.nsxt_policy_lb_pool_1_algorithm
  active_monitor_path = data.nsxt_policy_lb_monitor.nsxt_policy_lb_monitor_active.path
  passive_monitor_path = data.nsxt_policy_lb_monitor.nsxt_policy_lb_monitor_passive.path
  tcp_multiplexing_enabled = true
  tcp_multiplexing_number = 6

  member_group {
    group_path = nsxt_policy_group.group1.path
    allow_ipv4 = true
    allow_ipv6 = false
  }

  snat {
    type = "AUTOMAP"
  }
}

# Create Pool 2 (SQL)
resource "nsxt_policy_lb_pool" "pool2" {
  display_name = "${var.global_prefix}-${var.nsxt_policy_lb_pool_2_name_suffix}"
  description = "Terraform provisioned LB Pool"
  algorithm = var.nsxt_policy_lb_pool_2_algorithm
  active_monitor_path = data.nsxt_policy_lb_monitor.nsxt_policy_lb_monitor_active.path
  passive_monitor_path = data.nsxt_policy_lb_monitor.nsxt_policy_lb_monitor_passive.path
  tcp_multiplexing_enabled = true
  tcp_multiplexing_number = 6

  member_group {
    group_path = nsxt_policy_group.group1.path
    allow_ipv4 = true
    allow_ipv6 = false
  }

  snat {
    type = "AUTOMAP"
  }
}

# Create Load Balancer 1
resource "nsxt_policy_lb_service" "lb1" {
  display_name = "${var.global_prefix}-${var.nsxt_policy_lb_service_name_suffix}"
  description = "Terraform provisioned Service"
  connectivity_path = nsxt_policy_tier1_gateway.tier1_gw.path
  size = var.nsxt_policy_lb_service_size
  enabled = true
  error_log_level = "ERROR"
}

# Create Virtual Server 1 (Management)
resource "nsxt_policy_lb_virtual_server" "vs1" {
  display_name = "${var.global_prefix}-${var.nsxt_policy_lb_virtual_server_1_name_suffix}"
  description = "Terraform provisioned Virtual Server"
  access_log_enabled = true
  application_profile_path = data.nsxt_policy_lb_app_profile.nsxt_policy_lb_app_profile_http.path
  enabled = true
  ip_address = var.nsxt_policy_lb_virtual_server_ip
  ports = var.nsxt_policy_lb_virtual_server_1_ports
  default_pool_member_ports = var.nsxt_policy_lb_virtual_server_1_pool_ports
  service_path = nsxt_policy_lb_service.lb1.path
  pool_path = nsxt_policy_lb_pool.pool1.path
  persistence_profile_path = data.nsxt_policy_lb_persistence_profile.nsxt_policy_lb_persistence_profile1.path
}

# Create Virtual Server 2 (SQL)
resource "nsxt_policy_lb_virtual_server" "vs2" {
  display_name = "${var.global_prefix}-${var.nsxt_policy_lb_virtual_server_2_name_suffix}"
  description = "Terraform provisioned Virtual Server"
  access_log_enabled = true
  application_profile_path = data.nsxt_policy_lb_app_profile.nsxt_policy_lb_app_profile_tcp.path
  enabled = true
  ip_address = var.nsxt_policy_lb_virtual_server_ip
  ports = var.nsxt_policy_lb_virtual_server_2_ports
  default_pool_member_ports = var.nsxt_policy_lb_virtual_server_2_pool_ports
  service_path = nsxt_policy_lb_service.lb1.path
  pool_path = nsxt_policy_lb_pool.pool2.path
}

output "configuration" {
  value = {
    lb = {
      http = {
        ip = nsxt_policy_lb_virtual_server.vs1.ip_address
        port = nsxt_policy_lb_virtual_server.vs1.ports[0]
      }
      sql = {
        ip = nsxt_policy_lb_virtual_server.vs2.ip_address
        port = nsxt_policy_lb_virtual_server.vs2.ports[0]
      }
    }
    segment = {
      name = nsxt_policy_segment.segment1.display_name
      subnet = nsxt_policy_segment.segment1.subnet.*.cidr[0]
    }
  }
}
