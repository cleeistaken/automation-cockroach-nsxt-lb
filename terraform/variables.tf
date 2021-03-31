#
# NSX-T Manager Configuration
#
variable nsxt_manager {
  description = "NSX-T manager hostname or IP"
  type = string
}

variable nsxt_user {
  description = "NSX-T manager username"
  type = string
}

variable nsxt_password {
  description = "NSX-T manager password"
  type = string
}

variable nsxt_insecure_ssl {
  description = "Allow insecure connection to the NSX-T manager (unverified SSL certificate)"
  type = bool
  default = false
}

#
# Environment Configuration
#
variable "nsxt_policy_transport_zone" {
  type = string
}

variable "nsxt_policy_tier0_gateway" {
  type = string
}

variable "nsxt_policy_edge_cluster" {
  type = string
}

#
# General Configuration
#
variable "crdb_management_port" {
  type = number
  default = 8080
}

variable "crdb_sql_port" {
  type = number
  default = 26257
}

#
# Build Configuration
#
# Global deployment prefix
variable "global_prefix" {
  type = string
  default = "crdb-01"
}

# Tag Scope
variable "nsxt_tag_scope" {
  type = string
  default = "Terraform"
}

# Tag
variable "nsxt_tag" {
  type = string
  default = "CockroachDB"
}

# Gateway
variable "nsxt_t1_gw_name_suffix" {
  type = string
  default = "t1-gw01"
}

# Segment 1
variable "nsxt_segment_1_name_suffix" {
  type = string
  default = "seg01"
}

variable "nsxt_segment_1_cidr" {
  type = string
  default = "192.168.1.1/24"
}

#
# Monitors
#
variable nsxt_policy_lb_monitor_active_name {
  type = string
  #default = "crdb-http-lb-monitor"
}

variable nsxt_policy_lb_monitor_passive {
  type = string
  default = "default-passive-lb-monitor"
}

#
# Profiles
#
variable nsxt_policy_lb_persistence_profile {
  type = string
  default = "default-source-ip-lb-persistence-profile"
}

variable nsxt_policy_lb_app_profile_http {
  type = string
  default = "default-http-lb-app-profile"
}

variable nsxt_policy_lb_app_profile_tcp {
  type = string
  default = "default-tcp-lb-app-profile"
}

# Group 1
variable "nsxt_policy_group_1_suffix" {
  type = string
  default = "group-01"
}

# Server Pool 1
variable "nsxt_policy_lb_pool_1_name_suffix" {
  type = string
  default = "http-pool"
}

variable "nsxt_policy_lb_pool_1_algorithm" {
  type = string
  default = "ROUND_ROBIN"
}

# Server Pool 2
variable "nsxt_policy_lb_pool_2_name_suffix" {
  type = string
  default = "sql-pool"
}

variable "nsxt_policy_lb_pool_2_algorithm" {
  type = string
  default = "ROUND_ROBIN"
}

# Load Balancer 01
variable "nsxt_policy_lb_service_name_suffix" {
  type = string
  default = "lb"
}

variable "nsxt_policy_lb_service_size" {
  type = string
  default = "SMALL"
}

variable "nsxt_policy_lb_service_error_log_level" {
  type = string
  default = "ERROR"
}

# Virtual Server
variable "nsxt_policy_lb_virtual_server_ip" {
  type = string
}

# Virtual Server 01
variable "nsxt_policy_lb_virtual_server_1_name_suffix" {
  type = string
  default = "http-vs"
}

variable "nsxt_policy_lb_virtual_server_1_ports" {
  type = list(string)
  default = ["8080"]
}

variable "nsxt_policy_lb_virtual_server_1_pool_ports" {
  type = list(string)
  default = ["8080"]
}

# Virtual Server 02
variable "nsxt_policy_lb_virtual_server_2_name_suffix" {
  type = string
  default = "sql-vs"
}

variable "nsxt_policy_lb_virtual_server_2_ports" {
  type = list(number)
  default = ["26257"]
}

variable "nsxt_policy_lb_virtual_server_2_pool_ports" {
  type = list(number)
  default = ["26257"]
}
