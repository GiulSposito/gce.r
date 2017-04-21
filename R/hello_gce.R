# this script creates, starts, stops and delete a GCE instance with RStudio Server
#
# You should first follow this procedure, setting the .Renviron file:
# https://cloudyr.github.io/googleComputeEngineR/articles/installation-and-authentication.html
#
# project.id, zone and auth_credentials will be define in the .Renviron and json_key file
#

# setup
library(googleComputeEngineR)

# check projeto
gce_get_project()

##### starting a pre-existent VM 

# what VMs are available?
vms <- googleComputeEngineR::gce_list_instances()

# choose the first
vm <- vms$items[1,]$name

# start one
job <- gce_vm(vm)

# IP?
ip <- gce_get_external_ip(vm)

## log in 
gce_ssh_browser(vm)

# stop one
job <- gce_vm_stop(vm)

# check the job
gce_check_zone_op(job$name, wait=5)

##### Creating a new VM with RStudio (from yaml package template) 
#
#  Package Templates: https://github.com/cloudyr/googleComputeEngineR/tree/master/inst/cloudconfig
#  Default machine type: f1-micro
#
rstudio_vm <- gce_vm(
  template = "rstudio",
  name     = "rstudio-server-gcer",
  username = "giul",
  password = "rgiul"
)

# aboug the vm
rstudio_vm

# instances
gce_list_instances()

# types of VMs
gce_list_machinetype()

# images: https://cloud.google.com/compute/docs/images
gce_list_images(image_project="debian-cloud")

# stoping the VM
job <- gce_vm_stop(rstudio_vm)
gce_check_zone_op(job, wait=5)

# killing the VM
job <- gce_vm_delete(rstudio_vm)
