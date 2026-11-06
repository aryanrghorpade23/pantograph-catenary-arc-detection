# Dataset access

This project uses the public pantograph-arc dataset described in:

D. Signorino et al., “Dataset of measured and commented pantograph electric arcs in DC railways,” *Data in Brief*, 31 (2020), 105978. DOI: [10.1016/j.dib.2020.105978](https://doi.org/10.1016/j.dib.2020.105978).

The raw recordings are hosted separately on Mendeley Data:

- [Mendeley Data — version 1](https://data.mendeley.com/datasets/74nz86wcgy/1)
- [Dataset DOI](https://doi.org/10.17632/74nz86wcgy.1)

## Recording used

`MM_T_1.mat` is the primary example used by the MATLAB script. It is a Metro de Madrid traction-phase recording. The MATLAB script expects the MAT-file to contain:

| Variable | Physical quantity | Unit |
|---|---|---|
| `Vp` | Pantograph voltage | V |
| `Ip` | Pantograph current | A |
| `Vf` | Voltage downstream of the locomotive input filter | V |
| `x` (optional) | Time vector | s |

The script uses a nominal sampling frequency of 50 kHz. The dataset paper describes a 50 kSa/s, 16-bit acquisition system and documents the variables and measurement setup.

## Download and use

1. Download the dataset archive from the Mendeley Data page.
2. Extract the archive locally.
3. Select `MM_T_1.mat` when the MATLAB script opens its file picker.

The complete third-party archive is intentionally not stored in this GitHub repository. This avoids duplicating a large external dataset and keeps the original data source and reuse terms authoritative. Please cite the dataset paper and dataset DOI when using the recording.
