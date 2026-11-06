# Project summary

## Title
Pantograph–Catenary Arc Detection Using Time-Frequency Signal Analysis in MATLAB

## Background and objective
The pantograph collects electrical power from an overhead catenary. A brief loss or reduction of contact can produce an electrical arc and a transient response in the railway vehicle's input filter. This project analyses recorded pantograph voltage and current measurements to understand a documented transient using time-domain, frequency-domain and time-frequency methods.

The aim is to build an offline MATLAB workflow that visualises real measurements, examines transient behaviour with FFT, STFT and supplementary wavelet decomposition, and flags unusual time windows using a baseline-based statistical detector.

## Dataset and signals
The primary example is `MM_T_1.mat`, a Metro de Madrid traction-phase recording from the Mendeley Data pantograph-arc dataset. The input variables are:
- `Vp`: pantograph voltage (V)
- `Ip`: pantograph current (A)
- `Vf`: voltage downstream of the locomotive input filter (V)
- `x`: optional recorded time vector (s)

The configured sampling frequency is 50 kHz. The original dataset is hosted at <https://doi.org/10.17632/74nz86wcgy.1> and is not bundled in this repository.

## Signal-analysis methods
- **Time-domain and descriptive statistics:** plot the recorded signals and compare selected baseline/event intervals using mean, minimum, maximum and sample standard deviation.
- **FFT:** compare equal 80 ms voltage segments, after mean removal and Hann windowing, using a single-sided amplitude spectrum. The selected baseline is 3.80–3.88 s and the transient segment is 4.30–4.38 s.
- **STFT:** inspect the 4.20–4.45 s segment using a 512-sample Hann window, 384-sample overlap and 1024-point FFT.
- **Wavelet decomposition:** optionally apply Daubechies 4 at decomposition level 5 and inspect detail coefficients D1–D5. This is supplementary and does not feed the detector.
- **Sliding-window features:** compute six features for 20 ms windows with 10 ms hops: standard deviation, RMS of first differences and high-frequency energy ratio for both `Vp` and `Ip`. The high-frequency cutoff is 2 kHz.

## Statistical diagnostic model
The model baseline is the 3.20–4.00 s interval. For each feature, the baseline median and median absolute deviation (MAD) are calculated. A robust scale is formed using `1.4826 × MAD`, with a small floor to avoid division by zero. A window is flagged when any of its six robust deviation scores exceeds 4.

This is a statistical, feature-based anomaly detector. It is not a trained machine-learning classifier and does not independently confirm that an anomaly is an electrical arc.

## Reported real-data results
The supplied result file and report record:
- 299 feature windows
- 80 windows in the model baseline
- 189 flagged windows across the recording
- 11 of 11 windows flagged in the selected 4.29–4.40 s interval
- 0 of 80 windows flagged in the model baseline
- maximum robust diagnostic score of 908.31

The event-interval count applies only to the selected interval of this one recording. The 189 flags are not 189 separate arcs. Many later windows remain flagged because signal characteristics continue to differ from the selected baseline, and overlapping windows can respond to the same disturbance.

The saved results file confirms the sinusoidal synthetic-burst test (2 of 5 windows flagged). Voltage-dip and random-noise entries in the report remain marked as requiring verification.

## Scope and limitations
The model operates offline on one primary recording. A flagged window is an anomaly candidate, not proof of an arc. These experiments do not establish detection accuracy on a large labelled dataset, validated real-time operation, arc classification or railway protection readiness. More labelled normal and arc recordings, baseline validation and false-alarm evaluation are required.

## Further reading
- [Methodology](Methodology.md)
- [References and source attribution](References.md)
- [Dataset access](../Dataset/README.md)
- [Results notes](../Results/README.md)
