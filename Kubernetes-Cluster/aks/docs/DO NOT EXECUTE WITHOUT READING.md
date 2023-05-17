Follow the diagram

# REQUIREMENTS
- the resoruce group MUST have an ssh key with the following pattern 
  name ssh-${name}-${env}
- (optional) if part of your requirements is internal only services then use the nginx-controller.bash to deploy an internal nginx controller with a proper load balancer (keep in mind this doesnt support waf)



this infrastructure should have the following core components
- aplication gateway ingress controller (agic)
- azure kubernetes service (aks)
- VPN

# AGIC
this component should do the following
- serve as an ingress controller for the AKS
- should handle fqdn routing to internal k8s services
- should handle ssl offloading
- should implement a WAF (Web Application Firewall)
- rules will be constantly be wiped out and remade by the cluster ingress controller
# AKS
this component should do the following
- Should have a private control plane
- Should be able to pull secrets from keyvaults
- should be able to pull images from  a private registry (native, no aditional pull-secret config)
- should have RBAC with azure AD
- should have local accounts disabled to enforce the use of azure AD
- should have monitoring
- should have an ingress controller
- should have OPS group as the cluster admins
- should autoscale nodes 
# VNET 
this component should do the following
(with internal means on premise network)
- should peer to hub vnet
- should connect the cluster's nodes with internal dbs
- should connect the cluster's nodes with internal services/servers
- should connect the cluster's control plane with office vpn subnet (this will be the only acces to the control plane)
- should work for all environments (dev/staging/prod/etc)

# AGENT
this component should do the following
- should have access to the AKS control plane API (network access)
- should be mounted as an environment in azure devops
- should have its own subnet to be able to add more agents in the future if needed be
- should use an SP to deploy to AKS
- youll most likely need to reset the pipeline agent SP credentials in order to get them
- you shoulde enable ssh only access
- ATENTION you should only execute this bicep file if a ssh key resource already exists in the rg, you've been warnned