# Example 1 Heterogeneous-Variance Mixed-Effects model code



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
load("ex1.Rda")

### Generate indicator variables specifying which region the transects, 
### observers, and plots occur in. Each row is associated with numerical value
### assigned to these in the data set (e.g., observer 1 = row 1, 
### plot 10 = row 10).

#### fixed-effects indicator matrix
b = ex1 %>% 
  select(litter, region) %>% 
  mutate(region = as.factor(region)) %>%
  dummy_cols(select_columns = "region") %>% 
  select(region_1, region_2, region_3) %>%
  as.matrix()

#### observer variance covariates indicator matrix
d = ex1 %>% 
  select(obs, region) %>% 
  mutate(region = as.factor(region)) %>% 
  distinct() %>% 
  arrange(obs) %>%
  dummy_cols(select_columns = "region") %>% 
  select(region_1, region_2, region_3) %>% 
  as.matrix()

#### plot variance covariates indicator matrix
g = ex1 %>% 
  select(plot, region) %>% 
  mutate(region = as.factor(region)) %>% 
  distinct() %>% 
  arrange(plot) %>%
  dummy_cols(select_columns = "region") %>% 
  select(region_1, region_2, region_3) %>% 
  as.matrix()

### All data required in the model need to be added to a list. This variables 
### should match the beginning of first section of the stan model. See the model
### for details. 
Data<- list(n = nrow(ex1), 
            nobs = max(ex1$obs), 
            nplot = max(ex1$plot),
            nbeta = ncol(b), 
            ndelta = ncol(d), 
            ngamma = ncol(g),
            b = b, 
            d = d, 
            g = g, 
            y = as.vector(ex1$litter), 
            obs = as.vector(ex1$obs), 
            plot = as.vector(ex1$plot))



## Fit the stan model to obtain the sample posterior distribution. 

### The model is called from the saved stan file. The parameters to be sampled 
### need to be listed (this is what they're called in the model)as well as the 
### total number of iterations, the number of warm-up, and number of chains. 
fit = stan(file= "ex1_heterogeneous_variance_mixed_effects.stan", 
           data = Data, 
           pars = c("beta", "sigmau2", "sigmav2", "sigmae2", "obsvar", "vartotal",
                      "diff", "prob"), 
           iter = 10000, 
           warmup = 3000, 
           chains = 4)



## Output

### Trace plots to visualize mixing of MCMC
#### Run with other parameters
traceplot(fit, pars = c("obsvar"))

### Basic summary of the sample posterior distribution. 
#### The median (50% quantile) is presented in the paper figures. 
#### Some values maybe also be slightly different as this is a **sample** of the
#### posterior distribution.
summary(fit)

### Basic visualization of posterior distribution
#### Run with other parameters
mcmc_intervals(fit, regex_pars = c("obsvar"),
           prob = 0.95,
           prob_outer = 1, 
           point_est = "median")
