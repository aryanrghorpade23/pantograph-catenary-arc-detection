11%% PANTOGRAPH ARC DIAGNOSTIC - FINAL OFFLINE PROJECT
% Experiment 1: Analyse REAL recorded railway pantograph measurements.
% Experiment 2: Create user-configured synthetic anomalies and test the
% same baseline-based diagnostic model.
%
% Expected variables in MAT file: Vp, Ip, Vf and optionally x.
% Vp = pantograph voltage, Ip = pantograph current, Vf = measured
% voltage downstream of the locomotive input filter, x = time (s).
%
% Sampling frequency for this dataset: 50 kHz.
% IMPORTANT: A flagged window is an ANOMALY CANDIDATE, not proof of an arc.

clc;
clear;
close all;
rng('default'); % Reproducible random-noise experiment

%% 1. LOAD REAL DATA
[file, folder] = uigetfile('*.mat', ...
    'Select the pantograph dataset (e.g. MM_T_1.mat)');
if isequal(file, 0)
    error('No file selected. Run the script again and select a MAT file.');
end

S = load(fullfile(folder, file));
requiredVars = {'Vp','Ip','Vf'};
for k = 1:numel(requiredVars)
    if ~isfield(S, requiredVars{k})
        error('The selected MAT file does not contain variable %s.', requiredVars{k});
    end
end

Vp = double(S.Vp(:));
Ip = double(S.Ip(:));
Vf = double(S.Vf(:));
Fs = 50000;                 % Sampling frequency, Hz
Ts = 1/Fs;
N = numel(Vp);

if numel(Ip) ~= N || numel(Vf) ~= N
    error('Vp, Ip and Vf must have the same number of samples.');
end
if any(~isfinite(Vp)) || any(~isfinite(Ip)) || any(~isfinite(Vf))
    error('One or more signals contain NaN or Inf values.');
end

if isfield(S,'x') && numel(S.x) == N
    t = double(S.x(:));
    if any(~isfinite(t)) || any(diff(t) <= 0)
        warning('The time vector is invalid; reconstructing it from Fs.');
        t = (0:N-1)'/Fs;
    end
else
    t = (0:N-1)'/Fs;
end

fprintf('\n==================================================\n');
fprintf(' PANTOGRAPH ARC DIAGNOSTIC - OFFLINE MATLAB MODEL\n');
fprintf('==================================================\n');
fprintf('File: %s\n', file);
fprintf('Samples: %d | Fs: %.0f Hz | Ts: %.2f microseconds\n', ...
    N, Fs, Ts*1e6);
fprintf('Time range: %.5f to %.5f s | Duration: %.4f s\n', ...
    t(1), t(end), t(end)-t(1));

%% 2. PLOT THE REAL RECORDED SIGNALS
figure('Name','Experiment 1 - Real signals','Color','w');
subplot(3,1,1);
plot(t,Vp); title('Real pantograph voltage (Vp)');
xlabel('Time (s)'); ylabel('Voltage (V)'); grid on;
subplot(3,1,2);
plot(t,Ip); title('Real pantograph current (Ip)');
xlabel('Time (s)'); ylabel('Current (A)'); grid on;
subplot(3,1,3);
plot(t,Vf); title('Measured voltage downstream of input filter (Vf)');
xlabel('Time (s)'); ylabel('Voltage (V)'); grid on;

%% 3. REAL-DATA STATISTICS: BASELINE VS DOCUMENTED EVENT
% These times correspond to the MM_T_1 recording previously examined.
% Change them if you select another recording or if your time axis differs.
statsBaseStart = 4.00;
statsBaseEnd   = 4.10;
eventStart     = 4.29;
eventEnd       = 4.40;

idxStatsBase = t >= statsBaseStart & t <= statsBaseEnd;
idxStatsEvent = t >= eventStart & t <= eventEnd;
if nnz(idxStatsBase) < 2 || nnz(idxStatsEvent) < 2
    error(['Statistical comparison intervals are outside the selected recording. ', ...
        'Edit statsBaseStart/statsBaseEnd/eventStart/eventEnd.']);
end

fprintf('\n--- REAL-DATA VOLTAGE STATISTICS ---\n');
printStats('Baseline interval',Vp(idxStatsBase));
printStats('Event interval',Vp(idxStatsEvent));

figure('Name','Real-data baseline and event comparison','Color','w');
subplot(2,1,1);
plot(t(idxStatsBase),Vp(idxStatsBase));
title('Real data: selected baseline voltage interval');
xlabel('Time (s)'); ylabel('Vp (V)'); grid on;
subplot(2,1,2);
plot(t(idxStatsEvent),Vp(idxStatsEvent));
title('Real data: selected arc-event interval');
xlabel('Time (s)'); ylabel('Vp (V)'); grid on;

%% 4. FFT COMPARISON USING EQUAL-LENGTH WINDOWS
% Remove DC and apply a Hann window to reduce spectral leakage.
fftDuration = 0.080;       % seconds
fftBaseStart = 3.80;       % chosen inside proposed stable region
fftEventStart = 4.30;      % chosen around the documented transient
idxFFTBase = t >= fftBaseStart & t < fftBaseStart + fftDuration;
idxFFTEvent = t >= fftEventStart & t < fftEventStart + fftDuration;

if nnz(idxFFTBase) < 100 || nnz(idxFFTEvent) < 100
    warning('FFT intervals are not fully present; skipping FFT comparison.');
else
    ib = find(idxFFTBase);
    ie = find(idxFFTEvent);
    Lfft = min(numel(ib),numel(ie));
    [fBase,ABase] = singleSidedFFT(Vp(ib(1:Lfft)),Fs);
    [fEvent,AEvent] = singleSidedFFT(Vp(ie(1:Lfft)),Fs);

    figure('Name','Experiment 1 - FFT comparison','Color','w');
    subplot(2,1,1);
    plot(fBase,ABase); title('FFT: baseline voltage');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (V)');
    xlim([0 10000]); grid on;
    subplot(2,1,2);
    plot(fEvent,AEvent); title('FFT: transient interval voltage');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (V)');
    xlim([0 10000]); grid on;
end

%% 5. STFT / SPECTROGRAM AROUND THE REAL TRANSIENT
stftStart = 4.20;
stftEnd = 4.45;
idxSTFT = t >= stftStart & t <= stftEnd;
if nnz(idxSTFT) >= 1024 && exist('spectrogram','file') == 2
    vSTFT = Vp(idxSTFT);
    vSTFT = vSTFT - mean(vSTFT);
    stftWinLength = 512;     % 10.24 ms at 50 kHz
    stftOverlap = 384;       % 75% overlap
    stftNfft = 1024;
    figure('Name','Experiment 1 - STFT spectrogram','Color','w');
    spectrogram(vSTFT,hann(stftWinLength),stftOverlap,stftNfft,Fs,'yaxis');
    title('STFT spectrogram of real pantograph voltage');
    ylim([0 10]); colorbar;
else
    fprintf('\nSTFT skipped: interval too short or spectrogram() unavailable.\n');
    fprintf('The spectrogram section may require the Signal Processing Toolbox.\n');
end

%% 6. OPTIONAL WAVELET DECOMPOSITION
% Requires Wavelet Toolbox. This is supplementary, not required for the
% baseline anomaly detector below.
if exist('wavedec','file') == 2 && exist('detcoef','file') == 2
    idxW = t >= stftStart & t <= stftEnd;
    vW = Vp(idxW);
    if numel(vW) > 128
        vW = vW - mean(vW);
        waveletName = 'db4';
        decompositionLevel = 5;
        [C,Lw] = wavedec(vW,decompositionLevel,waveletName);
        figure('Name','Experiment 1 - Wavelet details','Color','w');
        subplot(decompositionLevel+1,1,1);
        plot(vW); title('Real transient segment'); grid on;
        for lev = 1:decompositionLevel
            detail = detcoef(C,Lw,lev);
            subplot(decompositionLevel+1,1,lev+1);
            plot(detail); title(sprintf('Wavelet detail D%d',lev)); grid on;
        end
    end
else
    fprintf('\nWavelet plots skipped: Wavelet Toolbox not detected.\n');
end

%% 7. SLIDING-WINDOW FEATURE EXTRACTION ON REAL DATA
% 20 ms window and 10 ms hop. Features for each window:
% Vp standard deviation, Vp difference RMS, Vp high-frequency ratio,
% Ip standard deviation, Ip difference RMS, Ip high-frequency ratio.
windowSamples = round(0.020*Fs);
hopSamples = round(0.010*Fs);
if N < windowSamples
    error('Recording is shorter than one analysis window.');
end
windowStarts = 1:hopSamples:(N-windowSamples+1);
numWindows = numel(windowStarts);
windowTime = zeros(numWindows,1);
F = zeros(numWindows,6);
featureNames = {'VpStd','VpDiffRMS','VpHighFreqRatio', ...
                'IpStd','IpDiffRMS','IpHighFreqRatio'};

for k = 1:numWindows
    ii = windowStarts(k):(windowStarts(k)+windowSamples-1);
    windowTime(k) = mean(t(ii));
    fVp = signalFeatures(Vp(ii),Fs);
    fIp = signalFeatures(Ip(ii),Fs);
    F(k,:) = [fVp,fIp];
end
fprintf('\nExtracted %d real-data feature windows.\n',numWindows);

%% 8. BASELINE-BASED DIAGNOSTIC MODEL FOR REAL DATA
% Use a longer candidate baseline to estimate typical feature behaviour.
% Verify visually that this interval is sufficiently stable before
% interpreting false alarms or detection results.
modelBaselineStart = 3.20;
modelBaselineEnd = 4.00;
featureThreshold = 4;
baseWindows = windowTime >= modelBaselineStart & ...
              windowTime <= modelBaselineEnd;
if nnz(baseWindows) < 10
    error(['Fewer than 10 baseline windows were found. Check the time axis ', ...
        'or edit modelBaselineStart/modelBaselineEnd.']);
end

baseMedian = median(F(baseWindows,:),1);
baseMAD = median(abs(bsxfun(@minus,F(baseWindows,:),baseMedian)),1);
baseScale = 1.4826*baseMAD;
% Floor scales to avoid dividing by zero/nearly zero.
scaleFloor = 1e-9*max(1,abs(baseMedian));
baseScale = max(baseScale,scaleFloor);

Z = abs(bsxfun(@rdivide,bsxfun(@minus,F,baseMedian),baseScale));
anomalyCandidate = any(Z > featureThreshold,2);
diagnosticScore = max(Z,[],2);

fprintf('\n--- REAL-DATA DIAGNOSTIC MODEL ---\n');
fprintf('Diagnostic baseline: %.3f to %.3f s (%d windows)\n', ...
    modelBaselineStart,modelBaselineEnd,nnz(baseWindows));
fprintf('Threshold: %.1f robust deviation units\n',featureThreshold);
fprintf('Flagged windows in entire recording: %d of %d\n', ...
    nnz(anomalyCandidate),numWindows);

eventWindows = windowTime >= eventStart & windowTime <= eventEnd;
if any(eventWindows)
    fprintf('Flagged windows in selected event interval: %d of %d\n', ...
        nnz(anomalyCandidate(eventWindows)),nnz(eventWindows));
else
    fprintf('No feature-window centre fell inside the selected event interval.\n');
end
fprintf('Flagged windows in model-baseline interval: %d of %d\n', ...
    nnz(anomalyCandidate(baseWindows)),nnz(baseWindows));

figure('Name','Experiment 1 - Real-data diagnostic results','Color','w');
subplot(3,1,1);
plot(windowTime,F(:,1)); hold on;
yline(baseMedian(1)+featureThreshold*baseScale(1),'--r','Upper baseline guide');
title('Voltage standard deviation'); xlabel('Time (s)'); ylabel('Vp std (V)'); grid on;
subplot(3,1,2);
plot(windowTime,F(:,3)); hold on;
yline(baseMedian(3)+featureThreshold*baseScale(3),'--r','Upper baseline guide');
title('Voltage high-frequency energy ratio'); xlabel('Time (s)'); ylabel('Ratio'); grid on;
subplot(3,1,3);
plot(windowTime,diagnosticScore,'b'); hold on;
yline(featureThreshold,'--r','Threshold');
plot(windowTime(anomalyCandidate),diagnosticScore(anomalyCandidate),'ro');
title('Real-data diagnostic score (red circles = anomaly candidates)');
xlabel('Time (s)'); ylabel('Max robust score'); grid on;

%% 9. EXPERIMENT 2: INTERACTIVE SYNTHETIC-ANOMALY TESTS
% This experiment always modifies a COPY of Vp. The original measured
% Vp and all real-data results remain unchanged.
% Types: 1 = sinusoidal burst, 2 = short voltage dip, 3 = random-noise burst.
% Every experiment starts from the ORIGINAL signal; anomalies do not stack.
syntheticResults = struct('type',{},'amplitudeMultiplier',{}, ...
    'durationMs',{},'frequencyHz',{},'amplitudeV',{},'burstStart',{}, ...
    'burstEnd',{},'flaggedWindows',{},'windowsInRegion',{},'score',{}, ...
    'flags',{},'time',{});

baseSignalSD = std(Vp(t >= modelBaselineStart & t <= modelBaselineEnd));
if ~isfinite(baseSignalSD) || baseSignalSD <= eps
    error('Could not estimate a usable baseline voltage scale.');
end

while true
    fprintf('\n==================================================\n');
    fprintf(' EXPERIMENT 2 - CREATE A SYNTHETIC ANOMALY\n');
    fprintf('==================================================\n');
    runChoice = input('Create a synthetic anomaly? (1=yes, 0=no) [1]: ');
    if isempty(runChoice), runChoice = 1; end
    if ~isscalar(runChoice) || ~ismember(runChoice,[0 1])
        fprintf('Please enter 1 for yes or 0 for no.\n');
        continue;
    end
    if runChoice == 0
        break;
    end

    fprintf('\nAnomaly type:\n');
    fprintf('  1 = Sinusoidal oscillation burst\n');
    fprintf('  2 = Short voltage dip\n');
    fprintf('  3 = Random-noise burst\n');
    anomalyType = input('Choose anomaly type [1]: ');
    if isempty(anomalyType), anomalyType = 1; end
    if ~isscalar(anomalyType) || ~ismember(anomalyType,[1 2 3])
        fprintf('Invalid type. Start the test again and choose 1, 2 or 3.\n');
        continue;
    end

    ampMultiplier = input('Amplitude multiplier [1.5]: ');
    if isempty(ampMultiplier), ampMultiplier = 1.5; end
    durationMs = input('Duration in milliseconds [10]: ');
    if isempty(durationMs), durationMs = 10; end
    if anomalyType == 1
        frequencyHz = input('Burst frequency in Hz [3000]: ');
        if isempty(frequencyHz), frequencyHz = 3000; end
    else
        frequencyHz = NaN;
    end

    % Validate inputs before modifying anything.
    validAmp = isnumeric(ampMultiplier) && isscalar(ampMultiplier) && ...
        isfinite(ampMultiplier) && ampMultiplier > 0;
    validDur = isnumeric(durationMs) && isscalar(durationMs) && ...
        isfinite(durationMs) && durationMs >= 1 && durationMs <= 100;
    validFreq = anomalyType ~= 1 || ...
        (isnumeric(frequencyHz) && isscalar(frequencyHz) && ...
         isfinite(frequencyHz) && frequencyHz > 0 && frequencyHz < Fs/2);
    if ~(validAmp && validDur && validFreq)
        fprintf(['Invalid parameters. Amplitude must be positive, duration ', ...
            '1-100 ms, and sinusoid frequency between 0 and %.0f Hz.\n'],Fs/2);
        continue;
    end

    % Start from original recorded data every time.
    VpSynthetic = Vp;
    burstDuration = durationMs/1000;
    burstStart = modelBaselineStart + 0.35;
    burstEnd = burstStart + burstDuration;
    if burstEnd > modelBaselineEnd
        fprintf('Burst does not fit in the baseline region. Reduce its duration.\n');
        continue;
    end
    burstIdx = t >= burstStart & t < burstEnd;
    if nnz(burstIdx) < 2
        fprintf('Burst interval contains too few samples. Try again.\n');
        continue;
    end

    amplitudeV = ampMultiplier*baseSignalSD;
    switch anomalyType
        case 1
            VpSynthetic(burstIdx) = VpSynthetic(burstIdx) + ...
                amplitudeV*sin(2*pi*frequencyHz*t(burstIdx));
            anomalyLabel = 'Sinusoidal burst';
        case 2
            VpSynthetic(burstIdx) = VpSynthetic(burstIdx) - amplitudeV;
            anomalyLabel = 'Voltage dip';
        case 3
            VpSynthetic(burstIdx) = VpSynthetic(burstIdx) + ...
                amplitudeV*randn(nnz(burstIdx),1);
            anomalyLabel = 'Random-noise burst';
    end

    % Recalculate all six features on the modified voltage plus the
    % ORIGINAL current (we only injected an anomaly into Vp).
    Fsynthetic = zeros(numWindows,6);
    for k = 1:numWindows
        ii = windowStarts(k):(windowStarts(k)+windowSamples-1);
        fVpSyn = signalFeatures(VpSynthetic(ii),Fs);
        fIpOriginal = signalFeatures(Ip(ii),Fs);
        Fsynthetic(k,:) = [fVpSyn,fIpOriginal];
    end
    Zsynthetic = abs(bsxfun(@rdivide, ...
        bsxfun(@minus,Fsynthetic,baseMedian),baseScale));
    syntheticFlags = any(Zsynthetic > featureThreshold,2);
    syntheticScore = max(Zsynthetic,[],2);

    % Include one window duration of margin around the burst to account
    % for sliding-window overlap and boundary effects.
    burstRegion = windowTime >= burstStart-windowSamples/Fs & ...
                  windowTime <= burstEnd+windowSamples/Fs;
    flaggedCount = nnz(syntheticFlags(burstRegion));
    regionCount = nnz(burstRegion);

    fprintf('\n--- SYNTHETIC TEST RESULT ---\n');
    fprintf('Anomaly type: %s\n',anomalyLabel);
    fprintf('Amplitude added: %.3f V (%.2f x baseline SD)\n', ...
        amplitudeV,ampMultiplier);
    fprintf('Duration: %.2f ms\n',durationMs);
    if anomalyType == 1
        fprintf('Frequency: %.0f Hz\n',frequencyHz);
    end
    fprintf('Injected time: %.5f to %.5f s\n',burstStart,burstEnd);
    fprintf('Flagged windows near disturbance: %d of %d\n', ...
        flaggedCount,regionCount);

    % Plot original vs modified around the burst.
    zoomMask = t >= burstStart-0.030 & t <= burstEnd+0.030;
    figure('Name','Experiment 2 - Synthetic anomaly waveform','Color','w');
    plot(t(zoomMask),Vp(zoomMask),'b'); hold on;
    plot(t(zoomMask),VpSynthetic(zoomMask),'r');
    xline(burstStart,'--k','Burst start');
    xline(burstEnd,'--k','Burst end');
    title(['Original vs modified signal: ',anomalyLabel]);
    xlabel('Time (s)'); ylabel('Voltage (V)');
    legend('Original measured Vp','Synthetic copy','Location','best'); grid on;

    % Plot diagnostic scores before and after synthetic injection.
    figure('Name','Experiment 2 - Synthetic anomaly diagnostic score','Color','w');
    plot(windowTime,diagnosticScore,'Color',[0.2 0.45 0.75]); hold on;
    plot(windowTime,syntheticScore,'r');
    yline(featureThreshold,'--k','Threshold');
    plot(windowTime(syntheticFlags),syntheticScore(syntheticFlags),'ro');
    xline(burstStart,'--','Burst start');
    xline(burstEnd,'--','Burst end');
    xlim([burstStart-0.08,burstEnd+0.08]);
    title('Diagnostic score: real signal vs synthetic copy');
    xlabel('Time (s)'); ylabel('Maximum robust score');
    legend('Original score','Synthetic score','Threshold', ...
        'Synthetic flagged windows','Location','best'); grid on;

    % Keep a record of each interactive experiment.
    nr = numel(syntheticResults)+1;
    syntheticResults(nr).type = anomalyLabel;
    syntheticResults(nr).amplitudeMultiplier = ampMultiplier;
    syntheticResults(nr).durationMs = durationMs;
    syntheticResults(nr).frequencyHz = frequencyHz;
    syntheticResults(nr).amplitudeV = amplitudeV;
    syntheticResults(nr).burstStart = burstStart;
    syntheticResults(nr).burstEnd = burstEnd;
    syntheticResults(nr).flaggedWindows = flaggedCount;
    syntheticResults(nr).windowsInRegion = regionCount;
    syntheticResults(nr).score = syntheticScore;
    syntheticResults(nr).flags = syntheticFlags;
    syntheticResults(nr).time = windowTime;

    saveChoice = input('Save this test in the results file now? (1=yes, 0=no) [1]: ');
    if isempty(saveChoice), saveChoice = 1; end
    if ~isscalar(saveChoice) || ~ismember(saveChoice,[0 1])
        saveChoice = 1;
    end
    if saveChoice == 1
        results = makeResultsStruct(file,Fs,windowTime,F,featureNames, ...
            baseMedian,baseScale,diagnosticScore,anomalyCandidate, ...
            modelBaselineStart,modelBaselineEnd,eventStart,eventEnd);
        save('Pantograph_Diagnostic_Results.mat','results','syntheticResults');
        fprintf('Saved to Pantograph_Diagnostic_Results.mat\n');
    end
end

%% 10. SAVE FINAL REAL-DATA AND SYNTHETIC-TEST RESULTS
results = makeResultsStruct(file,Fs,windowTime,F,featureNames, ...
    baseMedian,baseScale,diagnosticScore,anomalyCandidate, ...
    modelBaselineStart,modelBaselineEnd,eventStart,eventEnd);
save('Pantograph_Diagnostic_Results.mat','results','syntheticResults');
fprintf('\nFinal results saved to Pantograph_Diagnostic_Results.mat\n');
fprintf('Offline analysis complete.\n');
fprintf(['Reminder: detections are anomaly candidates; validate against ', ...
    'more labelled recordings before making arc-specific claims.\n']);

%% LOCAL FUNCTIONS
function printStats(label,signal)
    fprintf('\n%s\n',label);
    fprintf('  Mean: %.3f\n',mean(signal));
    fprintf('  Minimum: %.3f\n',min(signal));
    fprintf('  Maximum: %.3f\n',max(signal));
    fprintf('  Standard deviation: %.3f\n',std(signal));
end

function [f,A] = singleSidedFFT(signal,Fs)
    signal = signal(:);
    signal = signal - mean(signal);
    L = numel(signal);
    if L < 2
        error('FFT signal must contain at least two samples.');
    end
    w = 0.5 - 0.5*cos(2*pi*(0:L-1)'/(L-1));
    Y = fft(signal.*w);
    nHalf = floor(L/2)+1;
    A2 = abs(Y)/sum(w);
    A = A2(1:nHalf);
    if rem(L,2) == 0
        A(2:end-1) = 2*A(2:end-1);
    else
        A(2:end) = 2*A(2:end);
    end
    f = Fs*(0:nHalf-1)'/L;
end

function feat = signalFeatures(signal,Fs)
    signal = double(signal(:));
    if numel(signal) < 2 || any(~isfinite(signal))
        feat = [NaN NaN NaN];
        return;
    end
    % Feature 1: spread of the samples.
    sampleStd = std(signal);
    % Feature 2: RMS of first differences, a rapid-change proxy.
    d = diff(signal);
    diffRMS = sqrt(mean(d.^2));
    % Feature 3: energy ratio at frequencies >= 2 kHz.
    q = signal - mean(signal);
    L = numel(q);
    w = 0.5 - 0.5*cos(2*pi*(0:L-1)'/(L-1));
    Y = fft(q.*w);
    nHalf = floor(L/2)+1;
    P = abs(Y(1:nHalf)).^2;
    if rem(L,2) == 0
        if numel(P) > 2, P(2:end-1) = 2*P(2:end-1); end
    else
        if numel(P) > 1, P(2:end) = 2*P(2:end); end
    end
    f = Fs*(0:nHalf-1)'/L;
    totalEnergy = sum(P);
    if totalEnergy > eps
        highFreqRatio = sum(P(f >= 2000))/totalEnergy;
    else
        highFreqRatio = 0;
    end
    feat = [sampleStd,diffRMS,highFreqRatio];
end

function results = makeResultsStruct(file,Fs,windowTime,F,featureNames, ...
    baseMedian,baseScale,diagnosticScore,anomalyCandidate, ...
    modelBaselineStart,modelBaselineEnd,eventStart,eventEnd)
    results.sourceFile = file;
    results.samplingFrequency = Fs;
    results.windowTime = windowTime;
    results.features = F;
    results.featureNames = featureNames;
    results.baselineMedian = baseMedian;
    results.baselineScale = baseScale;
    results.diagnosticScore = diagnosticScore;
    results.anomalyCandidate = anomalyCandidate;
    results.modelBaselineInterval = [modelBaselineStart modelBaselineEnd];
    results.selectedEventInterval = [eventStart eventEnd];
    results.threshold = 4;
end