#! /bin/bash

run=$1 #run='xkqk'
mass_dir=$2 #crum, devfc, etc.
stream=$3 #apm.pp, etc
savedir=$4
stash=$5
#tag=$6 #tag='geo_T_RH_plevels'
T1=$6
T2=$7


echo 'input vars'
echo $1 $2 $3 $4 $5 $6 $7


#months='1988sep 1988oct 1988nov 1988dec 1989jan 1989feb 1989mar 1989apr 1989may 1989jun 1989jul 1989aug' #N.B. - to get all of the data (e.g., monthly .pm files for the hygroscopicity case) don't need to specify the pp_file and don't need to loop.
#for i in $months; do #N.B. - to get all of the data (e.g., monthly .pm files for the hygroscopicity case) don't need to specify the pp_file and don't need to loop.

# --- Use this part to limit the files used by the extraction (e.g., *pm* files only, etc.)

#fn_all=['"'${model}_pa0000.pp'"'..'"'${model}_pz9999.pp'"']
#fn_all=['"'20180601T0000Z_Regn1_resn_1_ra3t_p1_casim_pa000.pp'"'..'"'20180601T0000Z_Regn1_resn_1_ra3t_p1_casim_pz999.pp'"']
#fn_all=['"'${model}.pm0000*.pp'"'..'"'${model}.pm9999*.pp'"']
  #Actually the files don't have to exist - so can put pa0000 to pz9999 to include all files

#20180614T0000Z_Regn1_resn_1_ra3t_p1_casim_pk033

#fn_all=['"'cw416a.pm1988jan.pp cw416a.pm1988feb.pp'"']
#fn_all=['"cw418a.pm1988sep.pp"' '"cw418a.pm1988oct.pp"']
#fn_all='"cw418a.pm1988sep.pp"'
#run_end=`echo $run|cut -c 3-`
#echo $run_end
#fn_all='"${run_end}a.pm'${i}'.pp"'
#echo $fn_all

#echo fn_all=$fn_all

#echo 'Files to retrieve are: ' $fn_all

#echo "/tmp/fllist.$$"

# Some STASH codes:-
#  04   = Theta after timestep (K)
#  010  = Specific humidity after timestep (kg/kg)
#  075  = Cloud number after timestep (#/kg?)
#  076  = Rain number
#  078  = Ice number
#  079  = Snow number
#  081  = Grapuel number

#  083  = Activated soluble aerosol in liquid after timestep (?)
#  084  = Activated soluble aerosol in rain after timestep (?)
#  085  = Activated soluble IN aerosol in ice after timestep (?)
#  086  = Activated soluble aerosol in ice after timestep (?)
#  087  = Activated soluble IN aerosol in liquid after timestep (?)

#  0253 = Density*R*R (R is the radius of the Earth!)
#  0254 = Cloud liquid MR after timestep (kg/kg)
#  0272 = Rain MR after timestep (kg/kg)

#  0266 = Bulk cloud fraction (3D)
#  0267 = Liquid cloud fraction (3D)
#  0268 = Frozen cloud fraction (3D)
#  0272 = Rain after timestep (3D, kg/kg?)

#  2201 = Net downward LW
#  9202 = Very low cloud amount
#  9203 = Low cloud amount
#  9204 = Medium cloud amount
#  9205 = High cloud amount
# 16222 = Pressure at sea level (presumably can calc. all P from this and the eta levels?)
#  33001 = Aitken mode sol MR (kg/kg?)
#  33002 = Aitken mode sol number (#/kg?)
#  33003 = Accumulation mode sol number (#/kg?)
#  33004 = Accumulation mode sol number (#/kg?)
#  33005 = Coarse mode sol number (#/kg?)
#  33006 = Coarse mode sol number (#/kg?)

#The folowing line causes everything after it up to EOF1 to be put into the
#fllist file
#date_str=$(date +"%Y-%m-%d_%H:%M:%S") #Make a unique string to identify a copy of the namelist using the date and time.
random_str=`echo $RANDOM | md5sum | head -c 20`
mkdir -p qry_files
qry_file='qry_files/atomic_query_'${random_str}.qry
#cat > atomic_query.qry << EOF1
cat > ${qry_file} << EOF1

begin

T1>=$T1 
T1<=$T2

#stash=2201   #for single items don't use brackets
#stash=(4401,4402,4406,4407,4408,4409,4410,4411)

stash=$stash

#pp_file = $fn_all #N.B. - to get all of the data (e.g., monthly .pm files for the hygroscopicity case) don't need to specify the pp_file and don't need to loop.

end
EOF1

#stash_num=$( ./convert_stash.sh $stash ) #convert to m01s33i004 format


#Make the output dir if it does not already exist (-p option will prevent failure if it does)
echo savedir=$savedir
echo datadir=$DATADIR
mkdir -p $savedir/$run/atomic_output/$stash/$stream

#fn_out=$run'_'$tag'_'
echo 'Files will be ouput to: ' $savedir/$run/atomic_output/$stash/$stream/

#moo select -Cf /tmp/fllist.$$  moose:/devfc/$run/field.pp $savedir/$run/atomic_output/${fn_out}.pp
#moo select -f atomic_query.qry moose:/$mass_dir/$run/$stream $savedir/$run/atomic_output/$stash/$stream/
#moo select -f ${qry_file} moose:/$mass_dir/$run/$stream $savedir/$run/atomic_output/$stash/$stream/
moo select -I ${qry_file} moose:/$mass_dir/$run/$stream $savedir/$run/atomic_output/$stash/$stream/

#Dan - the -C option makes it write everything to a single file.
#    - the -f option forces an overwrite of the output file if it already exists
#    - the -I option only retrieves what is missing.

#done #N.B. - to get all of the data (e.g., monthly .pm files for the hygroscopicity case) don't need to specify the pp_file and don't need to loop.

