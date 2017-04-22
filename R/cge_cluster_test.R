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

vms <- lapply(paste0("gcer-node-", 1:5), FUN = googleComputeEngineR::gce_vm, template = "r-base")

vms <- lapply(vms, FUN = gce_ssh_setup, 
              key.pub = file.path("C:/Users/gsposito/.ssh", "google_compute_engine.pub"),
              key.private = file.path("C:/Users/gsposito/.ssh", "google_compute_engine"))

vms <- lapply(vms,
              gce_future_install_packages,
              docker_image = "henrikbengtsson/r-base-future",
              cran_packages = c("doFuture","Future","googleComputeEngineR"))
              

cl <- as.cluster(vms, docker_image = "henrikbengtsson/r-base-future")
plan(cluster, workers = cl)
system.time(boot <- foreach(i = 1:100, .packages = "boot") %dopar% { run() })

lapply(vms, gce_vm_stop)


lapply(vms, gce_vm_delete)


plan(multiprocess)

result <- foreach(i=2:5, .packages = c("googleComputeEngineR")) %dopar% { 
  gce_future_install_packages(vms[[i]],docker_image = "henrikbengtsson/r-base-future",
                              cran_packages = c("doFuture","Future","googleComputeEngineR"))
}
