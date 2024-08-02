//Example 1 mixed-effects stan model 



//specify data input into the model
data{
int<lower=0> n; // number of transects
int<lower=0> nobs; // number of observers
int<lower=0> nplot; // number of plots
int<lower=0> nbeta; // number of fixed-effects covariates
matrix[n,nbeta] b; // matrix of fixed-effects covariates
int<lower=1> obs[n]; //vector of observer
int<lower=1> plot[n]; //vector of plots
vector[n] y; //vector of indicator measurements
}
// specify parameters in model
parameters{
vector[nbeta] beta; // fixed-effects covariate coefficients
real<lower=0> sigmau2; //observer random-effects variance
real<lower=0> sigmav2; //plot random-effect variance
real<lower=0> sigmae2;// error variance
vector[nobs] u; //observer random-effect
vector[nplot] v; //plot random-effect
}
// specify transformed parameters in model
transformed parameters{
real vartotal; // total variance
real obsvar; //observer proportion of total variance
vartotal = (sigmau2 + sigmav2 + sigmae2);
obsvar = sigmau2 / vartotal;
}
// specify likelihood model
model{
real sigmau; // observer random-effect standard deviation
real sigmav; // plot random-effect standard deviation
real sigmae; // error standard deviation
vector[n] x; // fixed-effects
vector[n] eta; // mixed-effects
sigmau = sqrt(sigmau2);
u ~ normal(0, sigmau); // observer random-effects distribution
sigmav = sqrt(sigmav2);
v ~ normal(0, sigmav); // plot random-effect distribution
sigmae = sqrt(sigmae2);
x = b * beta;
eta = x + u[obs] + v[plot];
y ~ normal(eta, sigmae); // mixed-effects distribution
sigmau2 ~ cauchy(0,10); // observer random-effect variance prior
sigmae2 ~ cauchy(0,10); //error variance prior
sigmav2 ~ cauchy(0,10); // plot random-effect variance prior
}
