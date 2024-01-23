#!/bin/bash

# Declare an array of subject numbers
sub=("1586" "1731" "1748" "1766" "1804" "1826" "2030" "2120" "2123" "2063" "2157")
dir="/data_/mica3/BIDS_EEG-fMRI/rawdata"
tmp_dir="${dir}/tmp"

# Create a temporary directory if it doesn't exist
mkdir -p "${tmp_dir}"

for num in "${sub[@]}"; do
    anatomical="${dir}/sub-ep${num}/anatomical/ep${num}_anatomical.nii"
    if [[ ${num} == "1586" || ${num} == "1731" || ${num} == "1748" || ${num} == "1766" || ${num} == "1804" || ${num} == "1826" || ${num} == "2030" || ${num} == "2120" || ${num} == "2123" ]]; then
        t1w="${dir}/sub-ep${num}/anat/sub-ep${num}_T1w.nii.gz"
    elif [[ ${num} == "2063" || ${num} == "2157" ]]; then
        t1w="${dir}/sub-ep${num}/anat/sub-ep${num}_run-1_T1w.nii.gz"
    else
        echo "Unknown subject: ${num}"
        continue
    fi
    output_prefix="${tmp_dir}/sub-ep${num}_space-T1w_"

    # Run antsRegistrationSyN.sh
    antsRegistrationSyN.sh -d 3 -m "${anatomical}" -f "${t1w}" -o "${output_prefix}" -t a -p d

    # Run antsApplyTransforms for different types
    for type in "type01" "type02" "type03" "type04" "type05"; do
        input_fdr="${dir}/sub-ep${num}/main_result/sub-ep${num}_analysis01_${type}_t_fdr04*.nii"
        input_usedhrf="${dir}/sub-ep${num}/main_result/sub-ep${num}_analysis01_${type}_usedhrf.nii"

        # Get the random number from the input file
	random_number=$(basename "${input_fdr}" | sed 's/.*_fdr\([0-9.]*\)\.nii/\1/' | tr '.' 'p')

        # Create the output file name with the same random number
        output_fdr="${dir}/sub-ep${num}/maps/sub-ep${num}_space-T1w_desc-${type}_fdr${random_number}_EEG-fMRI.nii.gz"
        output_usedhrf="${dir}/sub-ep${num}/maps/sub-ep${num}_space-T1w_desc-${type}_usedhrf_EEG-fMRI.nii.gz"   

        # Run antsApplyTransforms
        antsApplyTransforms -d 3 -i "${input_fdr}" -r "${t1w}" \
            -t "${output_prefix}1Warp.nii.gz" -t "${output_prefix}0GenericAffine.mat" \
            -o "${output_fdr}"
        antsApplyTransforms -d 3 -i "${input_usedhrf}" -r "${t1w}" \
            -t "${output_prefix}1Warp.nii.gz" -t "${output_prefix}0GenericAffine.mat" \
            -o "${output_usedhrf}"
    done
done

for i in `ls sub*/*/*json`; do sed -i 's/":/": /g' $i; done
