# BIDS_EEG-fMRI
Scripts to process and organize the **EEG-fMRI** dataset

# 1. Organizing the dataset
Each subject MUST have the following organization, where `/maps` contains the result of the peak maps analysis derived from the EEG-fMRI registered to the fisrt run of `/anat/<sub>_T1w.nii.gz`

```bash
sub-ep1586
├── anat
│   ├── sub-ep1586_T1w.json
│   └── sub-ep1586_T1w.nii.gz
├── fmap
│   ├── sub-ep1586_magnitude1.json
│   ├── sub-ep1586_magnitude1.nii.gz
│   ├── sub-ep1586_magnitude2.json
│   ├── sub-ep1586_magnitude2.nii.gz
│   ├── sub-ep1586_phasediff.json
│   └── sub-ep1586_phasediff.nii.gz
├── func
│   ├── sub-ep1586_task-spike_run-1_bold.json
│   ├── sub-ep1586_task-spike_run-1_bold.nii.gz
│   ├── sub-ep1586_task-spike_run-1_events.tsv
│   ├── sub-ep1586_task-spike_run-2_bold.json
│   ├── sub-ep1586_task-spike_run-2_bold.nii.gz
│   └── sub-ep1586_task-spike_run-2_events.tsv
└── maps
    ├── sub-ep1586_space-T1w_desc-type01_fdr04p92_EEG-fMRI.nii.gz
    ├── sub-ep1586_space-T1w_desc-type01_usedhrf_EEG-fMRI.nii.gz
    ├── sub-ep1586_space-T1w_desc-type02_fdr04p66_EEG-fMRI.nii.gz
    ├── sub-ep1586_space-T1w_desc-type02_usedhrf_EEG-fMRI.nii.gz
    ├── sub-ep1586_space-T1w_desc-type03_fdr04p51_EEG-fMRI.nii.gz
    └── sub-ep1586_space-T1w_desc-type03_usedhrf_EEG-fMRI.nii.gz
```

# 2. Processing with `micapipe`
## Example: how to run one subject locally
> The first positional argument MUST be the subject ID with the string `sub-`.
> The second positional argument MUST be the FULL subjects's MICs freesurfer ID. (e.g. `sub-PX000_ses-01`)

```bash
sub=sub-ep1586
mics=sub-PX005_ses-01
singularity_micapipe_EEG-fMRI.sh "${sub}" "${mics}"
```

## Example: how to run one subject on the mica.q (SGE)
```bash
sub=sub-ep1586
mics=sub-PX005_ses-01
logs=/data_/mica2/tmpDir/"${sub}"

qsub -q mica.q -pe smp 10 -l h_vmem=6G -N "${sub/sub-/}" -e "${logs}".e -o "${logs}".txt \
/<full path to>/BIDS_EEG-fMRI/functions/singularity_micapipe_EEG-fMRI.sh "${sub}" "${mics}"
```

# 3. Sample all peak maps to surface
> `micapipe` structural processing MUST have been successfully run before this step.

```bash
sub=sub-ep1586
/<full path to>/BIDS_EEG-fMRI/functions/map2surf.sh "${sub}"
```
