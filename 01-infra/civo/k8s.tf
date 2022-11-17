resource "civo_firewall" "my-firewall" {
    name = "my-firewall"
    region = "FRA1"
}

# Create a firewall rule
resource "civo_firewall_rule" "kubernetes" {
    firewall_id = civo_firewall.my-firewall.id
    protocol = "tcp"
    start_port = "6443"
    end_port = "6443"
    cidr = ["0.0.0.0/0"]
    direction = "ingress"
    label = "kubernetes-api-server"
    action = "allow"
}

data "civo_size" "xsmall" {
    filter {
        key = "name"
        values = ["g3.xsmall"]
        match_by = "re"
    }

    filter {
        key = "type"
        values = ["instance"]
    }

}

data "civo_size" "medium" {
    filter {
        key = "name"
        values = ["g3.medium"]
        match_by = "re"
    }

    filter {
        key = "type"
        values = ["instance"]
    }

}

# Create a cluster
resource "civo_kubernetes_cluster" "my-cluster" {
    name = "little-red-riding-hood"
    applications = "cert-manager,Traefik-v2-nodeport,Linkerd:Linkerd & Jaeger"
    firewall_id = civo_firewall.my-firewall.id
    pools {
        label = "little-red-riding-hood" // Optional
        size = element(data.civo_size.medium.sizes, 0).name
        node_count = 3
    }
}


# Add a node pool
resource "civo_kubernetes_node_pool" "green" {
   cluster_id = civo_kubernetes_cluster.my-cluster.id
   label = "green" // Optional
   node_count = 3 // Optional
   size = element(data.civo_size.medium.sizes, 0).name // Optional
   region = "FRA1"
}

resource "local_file" "kubeconfig" {
    content  = civo_kubernetes_cluster.my-cluster.kubeconfig
    filename = "${path.root}/kubeconfig"
}