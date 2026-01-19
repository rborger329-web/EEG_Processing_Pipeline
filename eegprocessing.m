%% ===============================
% EEG PROCESSING PIPELINE
% OpenNeuro – derivatives/eegprep
% Author: Ria Borger
% ===============================

clear; clc; close all;

addpath(genpath('C:\Users\ria20\Desktop\BME499_EEGProcessing\eeglab_current'));
savepath
eeglab

%% -------- 1. Add EEGLAB to path --------
eeglab_path = 'C:\Users\ria20\Desktop\BME499_EEGProcessing\eeglab_current';
addpath(eeglab_path);
eeglab; close;   % initialize EEGLAB without GUI

%% -------- 2. Define EEG data path --------
data_path = 'C:\Users\ria20\Desktop\BME499_EEGProcessing\ses_001_sub_02';

% Find .set file
files = dir(fullfile(data_path,'*.set'));
assert(~isempty(files), 'No .set file found in directory.');

setfile = files(1).name;

%% -------- 3. Load EEG dataset --------
EEG = pop_loadset('filename', setfile, 'filepath', data_path);
EEG = eeg_checkset(EEG);

fprintf('Loaded EEG: %d channels, %d points, %d epochs\n', ...
        EEG.nbchan, EEG.pnts, EEG.trials);

fs = EEG.srate;

%% -------- 4. ERP Extraction --------
% Average across trials
ERP = mean(EEG.data, 3);  % channels x time

timevec = linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts);

figure;
plot(timevec, ERP(1,:));
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('ERP – Channel 1');
grid on;

%% -------- 5. Frequency Band Power --------
bands = struct( ...
    'delta', [1 4], ...
    'theta', [4 8], ...
    'alpha', [8 13], ...
    'beta',  [13 30], ...
    'gamma', [30 45]);

band_power = struct();

for fn = fieldnames(bands)'
    band = fn{1};
    freq_range = bands.(band);

    % Bandpass filter
    EEG_filt = pop_eegfiltnew(EEG, freq_range(1), freq_range(2));

    % Power = mean squared amplitude
    band_power.(band) = mean(mean(EEG_filt.data.^2,3),2);
end

disp('Band power computed.');

%% -------- 5b. Visualize Band Power --------
figure;
bands_names = fieldnames(band_power);
power_vals = zeros(length(bands_names),1);

for i = 1:length(bands_names)
    power_vals(i) = mean(band_power.(bands_names{i})); % average across channels
end

bar(power_vals);
xticks(1:length(bands_names));
xticklabels(bands_names);
ylabel('Mean Power (\muV^2)');
title('EEG Band Power Across Channels');
grid on;

% Optional: save figure
saveas(gcf, fullfile(results_path, 'BandPower_Figure.png'));

%% -------- 5b. Visualize Band Power --------
figure;
bands_names = fieldnames(band_power);
power_vals = zeros(length(bands_names),1);

for i = 1:length(bands_names)
    power_vals(i) = mean(band_power.(bands_names{i})); % average across channels
end

bar(power_vals);
xticks(1:length(bands_names));
xticklabels(bands_names);
ylabel('Mean Power (\muV^2)');
title('EEG Band Power Across Channels');
grid on;

% Optional: save figure
saveas(gcf, fullfile(results_path, 'BandPower_Figure.png'));

%% -------- 6. Time-Frequency (optional visualization) --------
chan = 1;
figure;
pop_newtimef(EEG, 1, chan, ...
    [EEG.xmin*1000 EEG.xmax*1000], ...
    [3 0.5], ...
    'plotersp','on','plotitc','off');
title('Time-Frequency Representation');

%% -------- 7. Entropy Calculation --------
% Shannon entropy per channel
entropy_vals = zeros(EEG.nbchan,1);

for ch = 1:EEG.nbchan
    sig = EEG.data(ch,:,:);
    sig = sig(:);
    sig = sig(~isnan(sig));

    % Histogram-based probability
    [counts,~] = histcounts(sig, 100, 'Normalization','probability');
    counts(counts==0) = [];
    entropy_vals(ch) = -sum(counts .* log2(counts));
end

fprintf('Entropy computed for all channels.\n');

%% -------- 7b. Visualize Entropy --------
figure;
bar(entropy_vals);
xlabel('Channel');
ylabel('Shannon Entropy (bits)');
title('EEG Signal Entropy per Channel');
grid on;

% Optional: highlight channels with high/low entropy
[~, max_ch] = max(entropy_vals);
[~, min_ch] = min(entropy_vals);
hold on;
plot(max_ch, entropy_vals(max_ch), 'ro', 'MarkerSize',10,'LineWidth',2);
plot(min_ch, entropy_vals(min_ch), 'go', 'MarkerSize',10,'LineWidth',2);
legend('Entropy','Max','Min');

% Save figure
saveas(gcf, fullfile(results_path,'Entropy_Figure.png'));


%% -------- 8. Save Outputs --------
results_path = fullfile(data_path,'EEG_results');
if ~exist(results_path, 'dir')
    mkdir(results_path);
end

save(fullfile(results_path,'ERP.mat'), 'ERP', 'timevec');
save(fullfile(results_path,'BandPower.mat'), 'band_power');
save(fullfile(results_path,'Entropy.mat'), 'entropy_vals');

disp('All results saved successfully.');

