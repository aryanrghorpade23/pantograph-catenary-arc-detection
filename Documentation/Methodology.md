# Methodology

## 1. Recorded signals

The MATLAB script expects a MAT-file containing:

| Variable | Meaning | Unit |
|---|---|---|
| `Vp` | Pantograph voltage | V |
| `Ip` | Pantograph current | A |
| `Vf` | Voltage downstream of the locomotive input filter | V |
| `x` (optional) | Recorded time vector | s |

The configured sampling frequency is `Fs = 50,000 Hz`, so the nominal sampling interval is `Ts = 1/Fs = 20 μs`. The script validates the three required arrays and uses `x` only when it has the correct length, finite values and strictly increasing timestamps.

## 2. Time-domain comparison

The script plots `Vp`, `Ip` and `Vf`, then extracts two pantograph-voltage intervals for descriptive statistics:

- Statistical baseline: 4.00–4.10 s
- Selected event interval: 4.29–4.40 s

For each interval it prints the mean, minimum, maximum and sample standard deviation. The ratio of event-interval to baseline standard deviation describes relative spread; it is not a detection-accuracy metric.

## 3. FFT comparison

The FFT comparison uses equal-duration segments:

- Baseline: 3.80–3.88 s
- Transient: 4.30–4.38 s

Each segment has an 80 ms nominal duration. The helper function removes the mean, applies a Hann window, computes the FFT, normalises by the window sum, and forms a single-sided amplitude spectrum. The plots are limited to 0–10 kHz. With an 80 ms segment, the nominal FFT-bin spacing is 12.5 Hz. Spectral changes describe differences in content; no frequency peak uniquely identifies an arc.

## 4. STFT

The STFT is applied to `Vp` over 4.20–4.45 s using:

| Parameter | Setting |
|---|---:|
| Window | 512 samples (10.24 ms) |
| Overlap | 384 samples (75%) |
| Hop | 128 samples (2.56 ms) |
| FFT length | 1024 points |
| Sampling frequency | 50 kHz |

The `spectrogram` function is used when available. The 1024-point FFT sets the plotted frequency grid spacing, while the actual time/frequency resolving ability remains limited by the 512-sample data window.

## 5. Wavelet analysis

When Wavelet Toolbox functions are available, the same transient segment is decomposed using Daubechies 4 (`db4`) at level 5. The script plots detail coefficients D1–D5. This analysis is supplementary: wavelet coefficients do not enter the six-feature diagnostic detector.

## 6. Sliding-window features

The detector divides the signals into 20 ms windows with a 10 ms hop, giving 50% overlap. For each window it calculates three features for `Vp` and the same three for `Ip`:

1. Sample standard deviation.
2. RMS of consecutive sample differences.
3. High-frequency energy ratio for frequency bins at or above 2 kHz.

The resulting feature vector has six elements. The high-frequency cutoff is a project implementation choice, not a universal railway-arc threshold.

## 7. Robust baseline detector

The model baseline is defined by window-centre times between 3.20 s and 4.00 s. For each feature, the script calculates its baseline median and median absolute deviation (MAD). It uses the robust scale `1.4826 × MAD`, with a small floor to prevent division by zero. The absolute deviation of every feature is divided by its baseline scale.

The diagnostic score for a window is the maximum of its six robust feature scores. A window is flagged when any feature score exceeds 4. The threshold is configurable. It is not a probability and does not identify the physical cause of a transient.

## 8. Synthetic disturbance tests

The interactive experiment creates a fresh copy of the measured `Vp` for each test and injects one of three user-configured disturbances:

- Sinusoidal burst.
- Voltage dip.
- Gaussian random-noise burst.

Only the copied voltage is modified; the original current signal is used for current features. The baseline statistics are calculated from the original recording before injection. Synthetic disturbances are controlled test inputs and are not real pantograph-arc measurements.

## 9. Reproducibility

The script calls `rng('default')` at startup. It saves `Pantograph_Diagnostic_Results.mat` in the MATLAB current working directory. The output contains the source filename, sampling frequency, window times, features, feature names, baseline median and scale, diagnostic scores, anomaly-candidate flags, selected intervals and threshold; the optional synthetic-test results are saved alongside them.

## 10. Interpretation limits

A flagged window indicates deviation from the selected baseline. It does not confirm an arc. The supplied real-data run reports many flagged windows after the initial transient, consistent with continued signal deviation from the reference baseline. The model has not been validated across a large labelled dataset and does not establish real-time or safety-critical performance.
