# Pantograph–Catenary Arc Detection Using Time-Frequency Signal Analysis in MATLAB

**Offline analysis of recorded railway measurements and controlled synthetic-anomaly detection**

This repository contains an undergraduate Signals and Systems project that studies pantograph electrical measurements around a documented pantograph–catenary arc event. MATLAB is used to inspect recordings in the time and frequency domains, examine time-varying spectral content, perform supplementary wavelet decomposition, and flag unusual sliding windows with a robust baseline-based statistical detector.

> **Scope:** This is an offline signal-analysis and anomaly-candidate demonstration. A flagged window is not proof of an electrical arc. The project does not claim validated real-time detection, arc-classification accuracy, or readiness for railway protection applications.

## Project at a glance

| Item | Details |
|---|---|
| Primary recording | `MM_T_1.mat` (Metro de Madrid, traction) |
| Main signals | Pantograph voltage (`Vp`), pantograph current (`Ip`), input-filter output voltage (`Vf`) |
| Sampling frequency | 50 kHz |
| Main analyses | Time-domain plots, interval statistics, FFT, STFT, optional db4 wavelet decomposition |
| Diagnostic approach | Six sliding-window features; median/MAD robust deviation scores |
| Window / hop | 20 ms / 10 ms (50% overlap) |
| Feature threshold | 4 (configurable in the MATLAB script) |
| Environment | MATLAB; Signal Processing Toolbox for STFT/spectrogram; Wavelet Toolbox for wavelet plots |

## What the project does

1. Loads and validates recorded `Vp`, `Ip` and `Vf` arrays, plus an optional time vector `x`.
2. Plots the measured waveforms and compares selected baseline and event intervals.
3. Compares equal-duration voltage segments using a mean-removed, Hann-windowed single-sided FFT.
4. Uses an STFT spectrogram to view changing frequency content around the transient.
5. Optionally decomposes the transient segment using the Daubechies 4 (`db4`) wavelet at level 5.
6. Extracts six features from overlapping windows: standard deviation, RMS of first differences, and high-frequency energy ratio for both voltage and current.
7. Estimates a baseline median and MAD-based scale for each feature, calculates robust deviation scores, and flags a window when any feature score exceeds the threshold.
8. Offers controlled synthetic tests (sinusoidal burst, voltage dip, random-noise burst) by modifying a copy of `Vp`; the measured recording is not overwritten.

## Repository layout

```text
.
├── README.md
├── .gitignore
├── CITATION.cff
├── MATLAB/
│   └── Pantograph_Arc_Diagnostic_Final.m
├── Documentation/
│   ├── Project_Summary.md
│   ├── Methodology.md
│   └── References.md
├── Dataset/
│   └── README.md
└── Results/
    ├── README.md
    ├── Pantograph_Diagnostic_Results.mat
    └── Figures/
        ├── 01_real_signal_waveforms.png
        ├── 02_baseline_event_comparison.png
        ├── 03_fft_comparison.png
        ├── 04_stft_spectrogram.png
        ├── 05_wavelet_details.png
        └── 06_real_data_diagnostic_results.png
```

## Getting the dataset

The source recording is part of the public dataset **“Pantograph arcing in DC railway systems: Transient behavior of voltage and current recorded at pantograph”**, available from Mendeley Data:

- Dataset DOI: [10.17632/74nz86wcgy.1](https://doi.org/10.17632/74nz86wcgy.1)
- Dataset landing page: <https://data.mendeley.com/datasets/74nz86wcgy/1>
- Primary file used in this project: `MM_T_1.mat`

Download the dataset from its original source and keep its original attribution and reuse terms. The full third-party dataset archive is **not redistributed in this repository**. See [Dataset/README.md](Dataset/README.md) for the expected variables and source details.

## Run the MATLAB analysis

1. Install MATLAB. The core time-domain, FFT and feature-based diagnostic portions use standard MATLAB functionality.
2. For the STFT/spectrogram section, install the **Signal Processing Toolbox**.
3. For the optional wavelet section, install the **Wavelet Toolbox**.
4. Download the Mendeley dataset above and locate `MM_T_1.mat`.
5. Open `MATLAB/Pantograph_Arc_Diagnostic_Final.m` in MATLAB and run it.
6. When the file picker opens, select `MM_T_1.mat`.
7. Review the figures and Command Window output. The script saves `Pantograph_Diagnostic_Results.mat` in MATLAB's current working folder.

The script checks that `Vp`, `Ip` and `Vf` exist, have matching lengths and contain finite values. It uses the supplied `x` vector if it is valid; otherwise it reconstructs time from the configured sampling frequency.

### Intervals and parameters used for the supplied recording

| Analysis | Interval / setting |
|---|---|
| Statistical baseline | 4.00–4.10 s |
| Selected statistical event interval | 4.29–4.40 s |
| FFT baseline | 3.80–3.88 s |
| FFT transient segment | 4.30–4.38 s |
| STFT / wavelet segment | 4.20–4.45 s |
| Diagnostic model baseline | 3.20–4.00 s |
| Sliding window / hop | 20 ms / 10 ms |
| High-frequency feature cutoff | 2 kHz |
| Robust-score threshold | 4 |

These intervals are configured for the supplied `MM_T_1.mat` example. They may need adjustment for another recording or time axis.

## Results snapshot

The supplied MATLAB output and project report record the following real-data diagnostic outputs for this run. A compact copy of the reported metrics is available in [Results/Diagnostic_Summary.csv](Results/Diagnostic_Summary.csv):

| Metric | Recorded result |
|---|---:|
| Feature windows | 299 |
| Windows in model baseline | 80 |
| Flagged windows across recording | 189 / 299 |
| Flagged windows in selected event interval | 11 / 11 |
| Flagged windows in model baseline | 0 / 80 |
| Maximum robust diagnostic score | 908.31 |

The 11/11 figure applies only to the selected interval in this one recording. The 189 flagged windows are **not 189 separate arcs**. Many windows remain flagged after the initial transient because signal characteristics continue to differ from the selected baseline; overlapping windows can also respond to the same disturbance. These are anomaly candidates, not confirmed arc events and not a general detection-accuracy measurement.

The saved MATLAB results supplied for review confirm the sinusoidal synthetic-burst test (2 of 5 windows flagged). The voltage-dip and random-noise entries in the report's synthetic-results table remain marked as requiring verification; do not treat those two entries as confirmed results until the tests are rerun and their outputs saved.

**Statistical-table note:** The supplied report contains descriptive voltage statistics for the stated 4.00–4.10 s and 4.29–4.40 s intervals. Those values are reproduced in the report, but they have not been independently recalculated from the full source recording as part of this repository setup. Re-run the script and verify the Command Window values before using those individual statistics in further analysis.

## Figures

The supplied MATLAB run produced six figures: real signal waveforms, baseline/event comparison, FFT comparison, STFT spectrogram, wavelet detail coefficients, and diagnostic results. Their inventory is documented in [Results/Figures/README.md](Results/Figures/README.md). Image files can be added to that folder when uploaded.

## Documentation

- [Project summary](Documentation/Project_Summary.md)
- [Methodology and parameter notes](Documentation/Methodology.md)
- [References and dataset attribution](Documentation/References.md)
- [Dataset access and variables](Dataset/README.md)
- [Results and figure notes](Results/README.md)

## Limitations and responsible interpretation

- This is offline analysis of one primary recording, not a live railway monitoring system.
- The detector is a statistical, feature-based anomaly detector; it is not a trained machine-learning classifier.
- The threshold is an engineering setting, not a probability or a universal railway-arc criterion.
- A transient or an anomaly flag does not establish the physical cause. The detector does not independently confirm an arc.
- One recording and a small number of synthetic tests do not support sensitivity, specificity, precision or overall classification-accuracy claims.
- Robust evaluation requires more labelled normal and arc recordings, a carefully validated baseline, false-alarm analysis, and systematic parameter testing.
- Optional STFT and wavelet outputs depend on the corresponding MATLAB toolboxes.

## Dataset and publication notes

The dataset and the paper describing it are third-party research materials. This repository links to the original dataset rather than republishing the complete archive or the paper PDF. The supplied paper manuscript states that its author-accepted version is under **CC BY-NC-ND 4.0**; consult the publisher/source terms before redistributing it or adapting its content. See the source paper DOI in [Documentation/References.md](Documentation/References.md).

The full DOCX report was reviewed during repository preparation but is not included in this initial GitHub snapshot.

## Acknowledgement

The project uses the pantograph-arc measurements published by Signorino et al. and collaborators. Full attribution is provided in the documentation references.
