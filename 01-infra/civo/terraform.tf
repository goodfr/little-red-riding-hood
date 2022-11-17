terraform {
  required_providers {
    civo = {
      source = "civo/civo"
      version = "1.0.24"
    }
  }
}

provider "civo" {
  # Configuration options
  # region = "FRA1"
  region = "FRA1"
}