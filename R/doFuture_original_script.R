library(boot)
library(doFuture)
library(googleComputeEngineR)
registerDoFuture()

run <- function(...) {
  cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
  cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
  boot(cd4, corr, R = 10000, sim = "parametric", ran.gen = cd4.rg, mle = cd4.mle)
}


vms <- lapply(paste0("node", 1:10), FUN = googleComputeEngineR::gce_vm, template = "r-base")

vms <- lapply(vms, FUN = gce_ssh_setup,
              key.pub = file.path("C:/Users/gsposito/.ssh", "google_compute_engine.pub"),
              key.private = file.path("C:/Users/gsposito/.ssh", "google_compute_engine"))

cl <- as.cluster(vms, docker_image = "henrikbengtsson/r-base-future")

plan(cluster, workers = cl)

system.time(boot <- foreach(i = 1:100, .packages = "boot") %dopar% { run() })

lapply(vms,gce_vm_stop)
