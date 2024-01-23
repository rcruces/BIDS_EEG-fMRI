#!/bin/bash
#
# Sample each of the peak activation maps under rawdata/<sub>/maps to midthickness surface
#
#
# sub MUST be in the form: "sub-ep1586"
# micapipe structural processing MUST have been successfully run before this step
#

# ------------------------------------------------------------------------------
# Inputs
sub=$1

# ------------------------------------------------------------------------------
# Define variables

# BIDS path
bids=/data_/mica3/BIDS_EEG-fMRI/rawdata

# Output directory path
out=/data_/mica3/BIDS_EEG-fMRI/derivatives

# Source micapipe environment
MICAPIPE=/data_/mica1/01_programs/micapipe-v0.2.0
source "${MICAPIPE}/functions/init.sh" "10"

function map_to-surfaces(){
  # -----------------------------------------------
  # Volume to surface mapping
  # Function that maps a MRI volume to a surfaces
  # Using work bench commands and multiple surfaces:
  # fsnative, fsaverage5, fsLR-5k and fsLR-32k
  # -----------------------------------------------
  # Input variables
  sub=$1                      # BIDS subject ID. e.g. sub-xxx
  mri_map=$2                  # Nifti image in nativepro space to mat to the surface
  out=$3                      # micapipe main out directory
  H=$4                        # Hemisphere {L, R}
  label=$5                    # label surface to map e.g. midthickness, pial, white, etc.
  map_str=$6                  # string to name the output data mapped to the surfaces
  # Surface directory of micapipe
  util_surface=${MICAPIPE}/surfaces   # MICAPIPE MUST be defined on the local env

  # micapipe subject surface directory
  dir_surf=${out}/micapipe_v0.2.0/${sub}/surf

  # micapipe subject maps directory
  dir_maps=${out}/micapipe_v0.2.0/${sub}/maps

  # Native surface on nativepro space for ${label}
  surf_nativepro="${dir_surf}/${sub}_hemi-${H}_space-nativepro_surf-fsnative_label-${label}.surf.gii"

  # Map to highest resolution surface (fsnative: more vertices)
  surf_id=${sub}_hemi-${H}_surf
  map_on_surf="${dir_maps}/${surf_id}-fsnative_label-${label}_${map_str}.func.gii"
  wb_command -volume-to-surface-mapping "${mri_map}" "${surf_nativepro}" "${map_on_surf}" -trilinear

  # Map from volume to surface for each surfaces
  for Surf in "fsLR-32k" "fsaverage5" "fsLR-5k"; do
    wb_command -metric-resample "${map_on_surf}" \
        "${dir_surf}/${surf_id}-fsnative_label-sphere.surf.gii" \
        "${util_surface}/${Surf}.${H}.sphere.reg.surf.gii" \
        BARYCENTRIC "${dir_maps}/${surf_id}-${Surf}_label-${label}_${map_str}.func.gii"
  done
}

# Only midthickness will be mapped
label="midthickness"

# ------------------------------------------------------------------------------
# Sample each peak map from /maps to all micapipe surfaces
# Array of each func run
for map in $(ls ${bids}/${sub}/maps/*gz); do

  # Get the map string identifier
  map_str=$(echo "${map}" | awk -F "${sub}_space-T1w_" '{print $2}' | cut -d'.' -f1)

  # For each hemisphere: L-left and R-right
  for HEMI in L R; do
    echo "[INFO].... Mapping ${map_str} to ${HEMI} ${label} surface"
    map_to-surfaces "${sub}" "${map}" "${out}" "${HEMI}" "${label}" "${map_str}"
  done
done
