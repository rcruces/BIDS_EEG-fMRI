#!/bin/bash
#
# singularity one shot | EEG-fMRI
#
# Note: the freesurfer directory must be mounted too
# 
# sub MUST be in the form: "sub-ep1586"
# mics MUST be: "sub-PX005_ses-01"
#

# ------------------------------------------------------------------------------
# Inputs
sub=$1
mics=$2

# ------------------------------------------------------------------------------
# Define variables

# micaipe singularity image
micapipe_img=/data_/mica1/01_programs/micapipe-v0.2.0/micapipe_v0.2.3.sif

# BIDS path
bids=/data_/mica3/BIDS_EEG-fMRI/rawdata

# Output directory path
out=/data_/mica3/BIDS_EEG-fMRI/derivatives

# Freesurfer licence
fs_lic=/data_/mica3/BIDS_CI/license_fc.txt

# Temporary directory
tmp=/data/mica2/tmpDir

# Freesurfer subject directory
fs_dir=/data_/mica3/BIDS_MICs/derivatives/freesurfer/${mics}

# ------------------------------------------------------------------------------
# micapipe command singularity
cmd="singularity run --writable-tmpfs --containall -B ${bids}:/bids -B ${out}:/out -B ${tmp}:/tmp -B ${fs_lic}:/opt/licence.txt -B ${fs_dir}:/fs_dir ${micapipe_img}"

# ------------------------------------------------------------------------------
# Run micapipe structural  processing
${cmd} -bids /bids -out /out -fs_licence /opt/licence.txt -threads 10 -sub ${sub} \
   -proc_structural -proc_surf -post_structural -GD -regSynth \
   -surf_dir /fs_dir -freesurfer
  
# ------------------------------------------------------------------------------
# Run micapipe functional processing
# Array of each func run
funcs=()
for i in $(ls ${bids}/${sub}/func/*gz); do
funcs+=($(echo "${i}" | awk -F "${sub}_" '{print $2}' | cut -d'.' -f1))
done

# Process each func run seaparetelly
for func in "${funcs[@]}"; do
  ${cmd} -bids /bids -out /out -fs_licence /opt/licence.txt -threads 10 -sub ${sub} -proc_func -mainScanStr ${func}
done


