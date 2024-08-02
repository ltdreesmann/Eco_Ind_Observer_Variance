// Example 1 heterogeneous-variance mixed-effects stan model 



// specify data input into model
data{
int<lower=0> n; // number of transects
int<lower=0> nobs; // number of observers
int<lower=0> nplot; // number of plots
int<lower=0> nbeta; // number fixed-effects covariates
int<lower=0> ndelta; // number of observer random-effect covariates
int<lower=0> ngamma; // number of plot random-effect covariates
matrix[n,nbeta] b; // matrix of fixed-effects covariates
matrix[nobs, ndelta] d; // matrix of observer random-effects covariates
matrix[nplot, ngamma] g; // matrix of plot random-effects covariates
int<lower=1> obs[n]; //vector of observers
int<lower=1> plot[n]; //vector of plots
vector[n] y; //vector of indicator measurements
}
//specify parameters in model
parameters{
vector[nbeta] beta; // fixed-effects coefficients
vector[ndelta] delta; //observer random-effects variance covariate coefficients
vector[ngamma] gamma; //plot random-effects variance covariate coefficients
real<lower=0> sigmae2;// error variance
vector[nobs] u; //observer random-effect
vector[nplot] v; //plot random-effect
}
//specify transformed parameters in model
transformed parameters{
vector[ndelta] sigmau2; // observer variance by covariate
vector[ngamma] sigmav2; // plot variance by covariate
sigmau2 = exp(delta);
sigmav2 = exp(gamma);
vector[ndelta] vartotal; // total variance
vector[ndelta] obsvar; // observer proportion of total variance
vartotal[1] = sigmae2 + sigmau2[1] + sigmav2[1];
vartotal[2] = sigmae2 + sigmau2[2] + sigmav2[2];
vartotal[3] = sigmae2 + sigmau2[3] + sigmav2[3];
obsvar[1] = sigmau2[1] / vartotal[1];
obsvar[2] = sigmau2[2] / vartotal[2];
obsvar[3] = sigmau2[3] / vartotal[3];
vector[ndelta] prob; // pairwise probability different proportion of observer variance
if(obsvar[2] < obsvar[1]){ prob[1] = 1;}
else{ prob[1] = 0;}
if(obsvar[3] < obsvar[1]){ prob[2] = 1;}
else{ prob[2] = 0;}
if(obsvar[2] < obsvar[3]){ prob[3] = 1;}
else{ prob[3] = 0;}
vector[ndelta] diff; // pairwise comparison of difference in proportion of variance
diff[1] = abs(obsvar[1] - obsvar[2]);
diff[2] = abs(obsvar[1] - obsvar[3]);
diff[3] = abs(obsvar[3] - obsvar[2]);
}
//specify likelihood model
model{
vector[nobs] sigmau; // observer standard deviation by covariate
vector[nplot] sigmav; // plot standard deviation by covariate
real sigmae; // error standard deviation
vector[n] x; // fixed-effects
vector[n] eta; // mixed-effects
sigmau= sqrt(exp( d * delta));
u ~ normal(0, sigmau); // observer random-effect distribution
sigmav = sqrt(exp(g * gamma));
v ~ normal(0, sigmav); // plot random-effect distribution
x = b * beta;
eta = x + u[obs] + v[plot];
sigmae = sqrt(sigmae2);
y ~ normal(eta, sigmae); // full model distribution
//priors for variance and variance covariate terms
sigmae2 ~ cauchy(0,10);
gamma[1] ~ normal(0,2);
gamma[2] ~ normal(0,2);
gamma[3] ~ normal(0,2);
delta[1] ~ normal(0,1);
delta[2] ~ normal(0,1);
delta[3] ~ normal(0,1);
}
