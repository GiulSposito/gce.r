# scritp to test parallel operations
library("boot")

run <- function(...) {
  cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
  cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
  b <- boot(cd4, corr, R = 10000, sim = "parametric", ran.gen = cd4.rg, mle = cd4.mle)
  return(list(Sys.info(), b))
}

## Attach doFuture (and foreach), and tell foreach to use futures
library("doFuture")
registerDoFuture()

## Sequentially on the local machine
plan(sequential)
system.time(boot <- foreach(i = 1:100, .packages = "boot") %dopar% { run() })

# In parallel on local machine (with 8 cores)
plan(multiprocess)
system.time(boot <- foreach(i = 1:100, .packages = "boot") %dopar% { run() })


##### CGE cluster
library(googleComputeEngineR)

vms <- lapply(paste0("gcer-node-", 1:5), FUN = googleComputeEngineR::gce_vm, template = "henrikbengtsson/r-base-future")

vms <- lapply(vms, FUN = gce_ssh_setup, 
              key.pub = file.path("C:/Users/gsposito/.ssh", "google_compute_engine.pub"),
              key.private = file.path("C:/Users/gsposito/.ssh", "google_compute_engine"))

cl <- as.cluster(vms) #, docker_image = "henrikbengtsson/r-base-future")
plan(cluster, workers = cl)
system.time(boot <- foreach(i = 1:100, .packages = "boot") %dopar% { run() })

lapply(vms, gce_vm_stop)


lapply(vms, gce_vm_delete)
