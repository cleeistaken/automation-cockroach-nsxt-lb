terraform {
    required_version = ">= 0.13"
    required_providers {
        nsxt = {
            source = "terraform-providers/nsxt"
            version = ">= 3.1.1"
        }
    }
}