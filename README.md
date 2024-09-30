# [hydazz/k3s-homelab](https://github.com/hydazz/k3s-homelab)

This is the repo for my k3s cluster, largly based on [Michaelpalacce/HomeLab](https://github.com/Michaelpalacce/HomeLab).
Everything is managed via flux, nothing has been configed/applied manually outside of this repo (except the sops secret).

Previous setup was docker-compose based + virtualmin for mail and webhosting, now its all moved to manifests and helm templates.
Pain in the ass to get started, and possibly overkill but :shrug:.

# Main Tools Used
1. **FluxCD 2** - GitOps for my HomeLab.
2. **Renovate** - Checks for updates to actions, helm charts, helm releases, docker containers.
3. **ingress-nginx** - Kubernetes ingress. This is used to access services using reverse proxy instead of exposing them on a port.
4. **cert-manager + reflector** - cert-manager generates certificates for my services and reflector duplicates the generated ssl
   certificate secret to all the namespaces. The secret is called `ingress`.
5. **Longhorn** - K8S native storage.
6. **Ansible** - Used to provision the architecture
7. **Velero** - K8S and PVC backup. Free and open source by VMware
8. **MetalLB** - LoadBalancer for bare-metal k8s clusters

## Environment Overview
3x Node Proxmox Cluster...