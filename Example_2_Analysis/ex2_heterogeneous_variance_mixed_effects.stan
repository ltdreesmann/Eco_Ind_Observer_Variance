// Example 2 heterogeneous-variance mixed-effects stan model 



// specify data input into data
data{
int<lower=0> n; // number of transects
int<lower=0> nobs; // number of observers
int<lower=0> nplot; // number of plots
int<lower=0> nbeta; // number fixed-effects covariates
int<lower=0> ndelta; // number of observer random-effect covariates
int<lower=0> ngamma; // number of plot random-effect covariates
int<lower=0> nalpha; // number of error covariates
int<lower=0> nvar; // number of unique combination of covariates
matrix[n,nbeta] b; // matrix of fixed-effects covariates
matrix[nobs, ndelta] d; // matrix of observer random-effects covariates
matrix[nplot, ngamma] g; // matrix of plot random-effects covariates
matrix[n, nalpha] a;//matrix of error covariates
int<lower=1> obs[n]; //vector of observers
int<lower=1> plot[n]; //vector of plots
vector[n] y; //vector of indicator measurements
}
//specify parameters in model
parameters{
vector[nbeta] beta; // fixed-effects coefficients
vector[ndelta] delta; //observer random-effects variance covariate coefficients
vector[ngamma] gamma; //plot random-effects variance covariate coefficients
vector[nalpha] alpha; // error variance covariate coefficients
vector[nobs] u; //observer random-effect
vector[nplot] v; //plot random-effect
}
//specify transformed parameters in model
transformed parameters{
vector[ndelta] sigmau2; // observer variance by covariate
vector[ngamma] sigmav2; // plot variance by covariate
vector[nalpha] sigmae2; // error variance by covariate
sigmau2 = exp(delta);
sigmav2 = exp(gamma);
sigmae2 = exp(alpha);
vector[nvar] vartotal; // total variance
vector[nvar] obsvar; // observer proportion of total variance
vartotal[1] = sigmae2[1] + sigmau2[1] + sigmav2[1];
vartotal[2] = sigmae2[2] + sigmau2[2] + sigmav2[1];
vartotal[3] = sigmae2[3] + sigmau2[3] + sigmav2[1];
vartotal[4] = sigmae2[4] + sigmau2[4] + sigmav2[1];
vartotal[5] = sigmae2[5] + sigmau2[5] + sigmav2[1];
vartotal[6] = sigmae2[6] + sigmau2[6] + sigmav2[1];
vartotal[7] = sigmae2[7] + sigmau2[7] + sigmav2[1];
vartotal[8] = sigmae2[8] + sigmau2[8] + sigmav2[1];
vartotal[9] = sigmae2[1] + sigmau2[1] + sigmav2[2];
vartotal[10] = sigmae2[2] + sigmau2[2] + sigmav2[2];
vartotal[11] = sigmae2[3] + sigmau2[3] + sigmav2[2];
vartotal[12] = sigmae2[4] + sigmau2[4] + sigmav2[2];
vartotal[13] = sigmae2[5] + sigmau2[5] + sigmav2[2];
vartotal[14] = sigmae2[6] + sigmau2[6] + sigmav2[2];
vartotal[15] = sigmae2[7] + sigmau2[7] + sigmav2[2];
vartotal[16] = sigmae2[8] + sigmau2[8] + sigmav2[2];
vartotal[17] = sigmae2[1] + sigmau2[1] + sigmav2[3];
vartotal[18] = sigmae2[2] + sigmau2[2] + sigmav2[3];
vartotal[19] = sigmae2[3] + sigmau2[3] + sigmav2[3];
vartotal[20] = sigmae2[4] + sigmau2[4] + sigmav2[3];
vartotal[21] = sigmae2[5] + sigmau2[5] + sigmav2[3];
vartotal[22] = sigmae2[6] + sigmau2[6] + sigmav2[3];
vartotal[23] = sigmae2[7] + sigmau2[7] + sigmav2[3];
vartotal[24] = sigmae2[8] + sigmau2[8] + sigmav2[3];
obsvar[1:8] = sigmau2 ./ vartotal[1:8];
obsvar[9:16] = sigmau2 ./ vartotal[9:16];
obsvar[17:24] = sigmau2./ vartotal[17:24];
}
//specify likelihood model
model{
vector[nobs] sigmau; // observer standard deviation by covariate
vector[nplot] sigmav; // plot standard deviation by covariate
vector[nalpha] sigmae;//error standard deviation by covariate
vector[n] x; //fixed-effects
vector[n] eta; //mixed-effects
sigmau = sqrt(exp(d*delta));
u ~ normal(0, sigmau); // observer random-effect distribution
sigmav = sqrt(exp(g*gamma));
v ~ normal(0, sigmav); // plot random-effect distribution
x = b* beta;
eta = x + v[plot] + u[obs];
sigmae = sqrt(exp(a *alpha));
y ~ normal(eta, sigmae); // full model distribution
//priors for variance covariate coefficient terms
alpha[1] ~ normal(0,2);
alpha[2] ~ normal(0,2);
alpha[3] ~ normal(0,2);
alpha[4] ~ normal(0,2);
alpha[5] ~ normal(0,2);
alpha[6] ~ normal(0,2);
alpha[7] ~ normal(0,2);
alpha[8] ~ normal(0,2);
gamma[1] ~ normal(0,2);
gamma[2] ~ normal(0,2);
gamma[3] ~ normal(0,2);
delta[1] ~ normal(0,2);
delta[2] ~ normal(0,2);
delta[3] ~ normal(0,2);
delta[4] ~ normal(0,2);
delta[5] ~ normal(0,2);
delta[6] ~ normal(0,2);
delta[7] ~ normal(0,2);
delta[8] ~ normal(0,2);
}

