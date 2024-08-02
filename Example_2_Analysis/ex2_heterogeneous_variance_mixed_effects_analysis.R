# Example 2 Heterogeneous-Variance Mixed-Effects model code



## Required packages
library("this.path")
library("tidyverse")
library("fastDummies")
library("rstan") 

## Helps decrease the run time of the models and recommended.
options(mc.cores = parallel::detectCores()-1)
rstan_options(auto_write = TRUE)

##Set working directory
### Models and data must be saved in the  same folder as Rscript.
setwd(this.dir())



## Format data

###load data
load("ex2.Rda")

### Generate indicator variables specifying which region the transects, 
### observers, and plots occur in. Each row is associated with numerical value
### assigned to these in the data set (e.g., observer 1 = row 1, 
### plot 10 = row 10).

#### fixed-effects indicator matrix
b = ex2 %>% 
  select(gap,eco) %>% 
  mutate(eco = as.factor(eco)) %>%
  dummy_cols(select_columns = "eco") %>% 
  select(-c(1:2)) %>% 
  as.matrix()

#### observer variance covariates indicator matrix
d = ex2 %>%
  select(obs, yr) %>% 
  mutate(yr = as.factor(yr)) %>% 
  distinct() %>% 
  arrange(obs) %>%
  dummy_cols(select_columns = "yr") %>% 
  select(-c(1:2)) %>% 
  as.matrix()

#### plot variance covariates indicator matrix
g = ex2 %>% 
  select(plot, eco) %>% 
  mutate(eco = as.factor(eco)) %>% 
  distinct() %>% arrange(plot) %>%
  dummy_cols(select_columns = "eco") %>% 
  select(-c(1:2)) %>% 
  as.matrix()

#### error variance covariates indicator matrix
a = ex2 %>% 
  select(gap, yr) %>% 
  mutate(yr = as.factor(yr)) %>%
  dummy_cols(select_columns = "yr") %>% 
  select(-c(1:2)) %>% 
  as.matrix()

### All data required in the model need to be added to a list. This variables 
### should match the beginning of first section of the stan model. See the model
### for details. 
Data <- list(n = nrow(ex2),
             nplot = max(ex2$plot),
             nobs = max(ex2$obs),
             nalpha = ncol(a),
             nbeta = ncol(b),
             ngamma = ncol(g),
             ndelta = ncol(d),
             nvar = (ncol(g) * ncol(d)),
             a = a,
             b = b,
             g = g,
             d = d,
             y = as.vector(ex2$gap),
             plot = as.vector(ex2$plot),
             obs = as.vector(ex2$obs)
)



## Fit the stan model to obtain the sample posterior distribution. 

### The model is called from the saved stan file. The parameters to be sampled 
### need to be listed (this is what they're called in the model)as well as the 
### total number of iterations, the number of warm-up, and number of chains. 
#### This will probably take a quite a while to run, we recommend starting with
#### a smaller number of iterations (and warmup) to check model is working first! 

fit = stan(file= "ex2_heterogeneous_variance_mixed_effects.stan", 
           data = Data, 
           pars = c("beta", "sigmau2", "sigmav2", "sigmae2", "obsvar", "vartotal"), 
           iter = 20000, 
           warmup = 6000, 
           chains = 4)



## Output

### Trace plots to visualize mixing of MCMC
#### Run with other parameters
traceplot(fit, pars = c("sigmau2"))

### Basic summary of the sample posterior distribution. 
#### The median (50% quantile) is presented in the paper figures. 
#### Some values maybe also be slightly different as this is a **sample** of the
#### posterior distribution.
summary(fit)

### Basic visualization of posterior distribution
#### Run with other parameters
mcmc_intervals(fit, regex_pars = c("sigmav2"),
               prob = 0.95,
               prob_outer = 1, 
               point_est = "median")



