data {
	int<lower = 1> nt; // number of observations (total)
	int<lower = 1> no; // number of observers
	int<lower = 1> np; // number of plots
	
	int<lower = 1> p_loc; // number of parameters for location
	int<lower = 1> p_scl; // number of parameters for scale
	int<lower = 1> p_obs_loc; // number of parameters for observer location variance
	int<lower = 1> p_plt_loc; // number of parameters for plot location variance
	
	int<lower = 1, upper = no> obs_indx[nt]; // integer index for observer
	int<lower = 1, upper = nt> plt_indx[nt]; // integer index for plot
	
	vector[nt] y; // response variable
	
	row_vector[p_loc] x_loc[nt]; // design matrix for location
	row_vector[p_scl] x_scl[nt]; // design matrix for scale (error variance)
	
  row_vector[p_plt_loc] x_plt_loc[nt]; // design matrix for plot location variance
	row_vector[p_obs_loc] x_obs_loc[nt]; // design matrix for observer location variance
}
parameters {
	vector[p_loc] beta; // parameters for fixed effects (location)
	vector<lower = 0>[p_scl] alph; //parameters for the error variance
	vector<lower = 0>[p_plt_loc] gamm; //parameters for the plot variance
	vector<lower = 0>[p_obs_loc] delt; //parameters for the observer variance
	
	vector[no] zeta_obs;
	vector[np] zeta_plt;
}
model {
	beta ~ normal(0.0, 5);
	alph ~ cauchy(0.0, 20);
	gamm ~ cauchy(0.0, 20);
	delt ~ cauchy(0.0, 20);
	
	vector[nt] mu;
	vector[nt] sigma;
	vector[nt] zeta_plt_loc;
	vector[nt] zeta_obs_loc;
	
	for (i in 1:no) {
		zeta_obs[i] ~ normal(0, 1);
	}
	for (i in 1:np) {
	  zeta_plt[i] ~ normal(0, 1);
	}
	for (i in 1:nt) {
	  zeta_plt_loc[i] = zeta_plt[plt_indx[i]] * (x_plt_loc[i] * gamm);
	  zeta_obs_loc[i] = zeta_obs[obs_indx[i]] * (x_obs_loc[i] * delt);
	  
		mu[i] = x_loc[i] * beta + zeta_plt_loc[i] + zeta_obs_loc[i];

		sigma[i] = (x_scl[i] * alph);
	}
	
	y ~ normal(mu, sigma);
}

generated quantities {
  vector[p_plt_loc] vgamm;
  vector[p_obs_loc] vdelt;
  vector[p_scl] valph;
  
  vector[p_obs_loc] prop1;
  vector[p_obs_loc] prop2;
  vector[p_obs_loc] prop3;
  
  vdelt = pow(delt, 2);
  vgamm = pow(gamm, 2);
  valph = pow(alph, 2);
  
  prop1 = vdelt ./ (vdelt + vgamm[1] + valph[1]);
  prop2 = vdelt ./ (vdelt + vgamm[2] + valph[2]);
  prop3 = vdelt ./ (vdelt + vgamm[3] + valph[3]);
}