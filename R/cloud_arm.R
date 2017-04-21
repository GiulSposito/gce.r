# template script to create r-bases instances, start them
# compute some distributed operations, stop them and kill them all
library(needs)
library(future)
library(doFuture)
library(googleComputeEngineR)

# where am i?
gce_get_project()

# creates the R instances army
vm1 <- gce_vm("r-army-cl1", template = "r-base")
vm2 <- gce_vm("r-army-cl2", template = "r-base")
vm3 <- gce_vm("r-army-cl3", template = "r-base")
vms <- list(vm1, vm2, vm3)

# setup ssh connection
vms <- lapply(vms, 
              gce_ssh_setup, 
              key.pub = file.path("C:/Users/gsposito/.ssh", "google_compute_engine.pub"),
              key.private = file.path("C:/Users/gsposito/.ssh", "google_compute_engine"))


cl <- as.cluster(vms, docker_image = "henrikbengtsson/r-base-future")

# create the cluster
# cl <- lapply(vms, FUN = as.cluster)
plan(cluster, workers = cl)

## use futures %<-% to send a function to the cluster
si %<-% Sys.info()
print(si)

## stop vms
lapply(vms, FUN = gce_vm_stop)

## optionally delete instances
# gce_vm_delete(vm1)
# gce_vm_delete(vm2)
# gce_vm_delete(vm3)
