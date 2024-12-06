# Example 2 Heterogeneous-Variance Mixed-Effects model code


## Required packages
library(this.path)
library(rstan)


## Helps decrease the run time of the models (may need to be modified for your computer)
### number of chains for
nchains <- 10
rstan_options(auto_write = TRUE)
options(mc.cores = nchains)


## Set working directory
### Models and data must be saved in the same folder as Rscript. 
setwd(this.dir())


## Format data

### load data
load("ex2.Rda")

### Design matrices 
x_loc <- with(d, cbind(1, e2, e3, y1, y2, y3, y4, y5, y6, y7,
  e2*y1, e2*y2, e2*y3, e2*y4, e2*y5, e2*y6, e2*y7,
  e3*y1, e3*y2, e3*y3, e3*y4, e3*y5, e3*y6, e3*y7))
x_plt_loc <- with(d, cbind(e1, e2, e3))
x_scl <- with(d, cbind(e1, e2, e3))
x_obs_loc <- with(d, cbind(y1, y2, y3, y4, y5, y6, y7, y8))

### All data required in the model need to be added to a list. This variables 
### should match the beginning of first section of the stan model. See the model
### for details. 
dat <- list(nt = nrow(d), 
            no = max(d$obs), 
            np = max(d$plot), 
            p_loc = ncol(x_loc), 
            p_scl = ncol(x_scl),
            p_plt_loc = ncol(x_plt_loc), 
            p_obs_loc = ncol(x_obs_loc), 
            plt_indx = d$plot, 
            obs_indx = d$obs, 
            y = d$y, 
            x_loc = x_loc, 
            x_scl = x_scl, 
            x_plt_loc = x_plt_loc, 
            x_obs_loc = x_obs_loc)


## Fit the stan model 
m <- stan_model(file = "ex2_heterogeneous_variance_mixed_effects.stan")
s <- sampling(m, data = dat, iter = 10000, init = "random", chains = nchains,
	pars = c("vdelt","vgamm","valph","prop1","prop2","prop3"))
