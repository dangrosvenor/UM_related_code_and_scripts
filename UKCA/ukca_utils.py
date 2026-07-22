import os
host = os.environ['HOSTNAME']

if 'xcslc' not in host and 'shared' not in host and 'mom' not in host:  #xcslc0 and sharedNN (qsub from Monsoon) does not have the IPython toolkit
        from IPython import embed       #Insert embed() to enable a breakpoint

import numpy as np
import scipy as sp

#from thermodynamics import rho_from_T_P
#import physics_constants as phys

#k_Boltzmann = 1.38e-23

#UKCA lognormal mode properties
#Can find these from the UM code in ukca_mode_setup.F90. Are a few choices, but can check what i_mode_setup is from the directory in roses. UKESM nudged run from James Keeble had i_mode_setup=2, which corresponds to ukca_mode_sussbcoc_5mode.
rho_H2SO4 = 1769.0
rho_BC = 1500.0
rho_OM = 1500.0
rho_sea_salt = 1600.0

nuc_sigma = 1.59
aitken_sigma = 1.59
accum_sigma = 1.4
coarse_sigma = 2.0
aitken_insol_sigma = 1.59

def ukca_aerosol_totvol(air_density,nuc_number,aitken_number,accum_number,coarse_number,aitken_insol_number, nuc_sol_H2SO4_mmr,nuc_sol_OM_mmr,aitken_sol_H2SO4_mmr,aitken_sol_BC_mmr,aitken_sol_OM_mmr,accum_sol_H2SO4_mmr,accum_sol_BC_mmr,accum_sol_OM_mmr,accum_sol_sea_salt_mmr,coarse_sol_H2SO4_mmr,coarse_sol_BC_mmr,coarse_sol_OM_mmr,coarse_sol_sea_salt_mmr,aitken_insol_BC_mmr,aitken_insol_OM_mmr):	

	#air_density = air density : kg m^-3
	#MMRs are in kg/kg (native UKCA output)
	#Number concentrations : # m^-3


	#Sum the volumes of all components for each mode, where volume = MMR / rho_aerosol for each component - convert MMRs (kg/kg) into kg/m3 too by multiplying by the air density
	nuc_vol = air_density * ( nuc_sol_H2SO4_mmr/rho_H2SO4 + nuc_sol_OM_mmr / rho_OM )
	aitken_vol = air_density * (aitken_sol_H2SO4_mmr/rho_H2SO4 + aitken_sol_BC_mmr/rho_BC + aitken_sol_OM_mmr/rho_OM + aitken_insol_BC_mmr/rho_BC + aitken_insol_OM_mmr/rho_OM )
	accum_vol = air_density * (accum_sol_H2SO4_mmr/rho_H2SO4 + accum_sol_BC_mmr/rho_BC + accum_sol_OM_mmr/rho_OM + accum_sol_sea_salt_mmr/rho_sea_salt )
	coarse_vol = air_density * (coarse_sol_H2SO4_mmr/rho_H2SO4 + coarse_sol_BC_mmr/rho_BC + coarse_sol_sea_salt_mmr/rho_sea_salt )
	aitken_insol_vol = air_density * (aitken_insol_BC_mmr/rho_BC + aitken_insol_OM_mmr/rho_OM  )

	#Calculate the mode radius given the mode total volume, number concentration (per m3) and distribution width.
	nuc_rad = ucka_aerosol_radius(nuc_vol, nuc_number, nuc_sigma)
	aitken_rad = ucka_aerosol_radius(aitken_vol, aitken_number, aitken_sigma)
	accum_rad = ucka_aerosol_radius(accum_vol, accum_number, accum_sigma)
	coarse_rad = ucka_aerosol_radius(coarse_vol, coarse_number, coarse_sigma)
	aitken_insol_rad = ucka_aerosol_radius(aitken_insol_vol, aitken_insol_number, aitken_insol_sigma)


	return (nuc_vol,aitken_vol,accum_vol,coarse_vol,aitken_insol_vol,nuc_rad,aitken_rad,accum_rad,coarse_rad,aitken_insol_rad)



def ucka_aerosol_radius(mode_volume,mode_number,mode_sigma):

	#This calculates the median radius of the specified lognormal distribution in m (mode_median_radius)
	#Outputs: mode_median_radius (m)
	#Inputs: 
		#mode_volume = total volume of aerosol in the mode : m3
		#mode_number = total number concentration of the mode : m^{-3}  (# per m3)
		#mode_sigma = width of the lognormal aerosol distribution : m
	

	mode_median_radius = 0.5 * ( (6*mode_volume/mode_number) / (np.pi*np.exp(4.5*(np.log(mode_sigma))**2)) )**(1./3.)
	#One derivation of the above is from the Don Grainger PDF on aerosol distrbiutions (Eqn. 58) where he calculates the total volume of the lognormal size distribution as a function of total number and the median radius.
	#Note, that the median radius is different to the mean radius. Can calculate the mean radius using: mode_median_radius*exp(0.5*(np.log(mode_sigma))**2); Eqn. 54 of Grainger document.
	
	return (mode_median_radius)

	
def lognormal_number_below_threshold_radius(N,r_thresh,r_median,sigma): 
 
	# Looks like this comes from Eqn. 8.39 of Seinfeld and Pandis textbook.
	# Calculates the number of particles, N_partial, (in same units as N) in a lognormal size dist below a given threshold radius.
	# N = total number of particles in the distribution : #/m3 (although could be any units).
	# r = threshold_radius : m
	# r_median = median radius of the distribution : m

	N_partial = (N/2)*(1+sp.special.erf(np.log(r_thresh/r_median)/np.sqrt(2)/np.log(sigma)))
 
	return N_partial
