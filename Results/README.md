# Results

This folder contains the supplied MATLAB output file and six screenshots from the real-data experiment.

## Saved diagnostic output

`Pantograph_Diagnostic_Results.mat` is the MATLAB output supplied for this project. The real-data run reports:

| Metric | Value |
|---|---:|
| Sampling frequency | 50 kHz |
| Feature-window duration | 20 ms |
| Hop | 10 ms |
| Threshold | 4 |
| Extracted windows | 299 |
| Windows in model baseline | 80 |
| Total flagged windows | 189 / 299 |
| Selected event interval flags (4.29–4.40 s) | 11 / 11 |
| Model-baseline flags (3.20–4.00 s) | 0 / 80 |
| Maximum robust diagnostic score | 908.31 |

The event-interval count applies only to the selected interval of this recording. The 189 flags are overlapping-window anomaly candidates, not 189 confirmed or separate arcs.

The saved synthetic-test results confirm one sinusoidal-burst test: 2 of 5 windows flagged. The voltage-dip and random-noise test values shown in the report remain unverified and are not presented here as confirmed results.

The report's interval-voltage statistics are reproduced from the report but have not been independently recalculated during repository preparation. See the main README before relying on those individual values.

## Figures

| File | Content |
|---|---|
| `01_real_signal_waveforms.png` | Recorded pantograph voltage, pantograph current and filter output voltage |
| `02_baseline_event_comparison.png` | Selected baseline and event voltage intervals |
| `03_fft_comparison.png` | Baseline and transient FFT amplitude spectra |
| `04_stft_spectrogram.png` | STFT spectrogram around the transient |
| `05_wavelet_details.png` | Wavelet detail coefficients D1–D5 |
| `06_real_data_diagnostic_results.png` | Sliding-window features and real-data diagnostic scores |
