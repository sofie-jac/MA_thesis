% DONT FORGET TO ADD PATH TO IMPORTANT FILES    
% data structure:
    % 1) TDT file FP
    % 2) TDT file including EEG/EMG
    % 3) 1: 465 channel name
    % 4) 1: 405 channel name 
    % 5) 1: 560 channel name
    % 6) 2: 465 channel name
    % 7) 2: 405 channel name 
    % 8) 2: 560 channel name 
    % 9) EEG channel name
    % 10) EEG channel
    % 11) EMG channel name
    % 12) synchronization channel name FP rig
    % 13) synchronization channel name EEG rig
    % 14) interval for fitting (polyfit) - new polyfit which works better
    % with updated MATLAB version 

    %make sure to have path activated to TDTbin2mat + have certain files
    %open such as polyfit and binary_to_OnOff


%build-up
name = {'file_destination_FP' 'file_destination_EEG' 'channel_name_blue_1' 'channel_name_violet_1' 'channel_name_red_1' 'channel_name_blue_2' 'channel_name_violet_2' 'channel_name_red_2' 'EEG channel name' 'EEG channel name' 'EMG channel name 1' 'synchronization pulse name FP rig' 'synchronization pulse name EEG rig'  'time period for fitting' };

%example - does not match the below code entirely (does not have two EEG
%channels - check which mouse was recorded with which rig, naming of rigs
%can be different -> load mouse -> data_FPrig -> streams

% First path is for the FP and 2nd is for EEG traces

Mouse_117 = {'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_117' 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_117' 'x465A' 'x405A' 'red' 'x465C' 'x405C' 'red' 'EEGw' 1 'EMG1' 'PtC0' 'PtC0' (1:20000) 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_117\117_sleep\6h FP and EEG\Score_117.xlsx'};
Mouse_124 = {'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_124' 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_117' 'Dv2A' 'Dv1A' 'red' 'Dv4C' 'Dv5C' 'red' 'EEGw' 2 'EMG2' 'PtC0' 'PtC0' (1:20000) 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_124\Score_124.xlsx'};

%test
Mouse_3129_ctrl = {'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\FP\20200721 NE Sleep deprivation\20200721_1-307_2-319_sleep' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\FP\20200721 NE Sleep deprivation\20200721_1-307_2-319_sleep\319_NE_As_sleep\319_NE_As_sleep_2020-07-21_12-07-19-593.exp' 'x465A' 'x405A' 'red' 'x465C' 'x405C' 'red' 'EEGw' 1 'EMG1' 'PtC0' 'PtC0' (1:20000) 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\practice data\mouse_117\117_sleep\6h FP and EEG\Score_117.xlsx'};

Mouse_168 = {'J:\CTN\NedergaardLAB\KjaerbyLab\Sofie\mouse_168' 'J:\CTN\NedergaardLAB\KjaerbyLab\Sofie\mouse_168' 'channel_name_blue_1' 'channel_name_violet_1' 'channel_name_red_1' 'x465A' 'x405A' 'red' 'EEGw' 1 'EMG1' 'PtC0' 'PtC0' (1:18000) 'J:\CTN\NedergaardLAB\KjaerbyLab\Sofie\mouse_168\168_sleep_data'};
mouse = Mouse_124 ;
%% load data

data_FPrig = TDTbin2mat(mouse{1}); % FP rig 
data_EEGrig= TDTbin2mat(mouse{2}); %EEG rig - might be the same as above
%% extract channels

signal_fs = data_FPrig.streams.(mouse{6}).fs; % sampling frequency for fiber photometry signal
% %signal_560_FPrig = data_FPrig.streams.(mouse{5}).data; %red signal

signal_465_2 = data_FPrig.streams.(mouse{6}).data; %signal
signal_405_2 = data_FPrig.streams.(mouse{7}).data; %isosbetstic control
%signal_560_FPrig = data_FPrig.streams.(mouse{8}).data; %red signal

EEG_fs = data_EEGrig.streams.(mouse{9}).fs; %sampling frequency for EEG signal 

EEG_all = data_EEGrig.streams.(mouse{9}).data; %EEG signal
EEG = EEG_all(mouse{10},:); %add channel (1 or 2)
EMG = data_EEGrig.streams.(mouse{11}).data; %EMG 
%% Cut off 1st second due to FP noise

% Calculate the number of samples to remove (equivalent to 1 second)
samplesToRemove_EEG_EMG = EEG_fs; % Number of samples in 1 second for EEG and EMG
samplesToRemove_FP = signal_fs; % Number of samples in 1 second for photometry signals

% Directly trim the first second from EEG and EMG
EEG = EEG(samplesToRemove_EEG_EMG:end);
EMG = EMG(samplesToRemove_EEG_EMG:end);

% Directly trim the first second from signal_405_2 and signal_465_2
signal_405_2 = signal_405_2(samplesToRemove_FP:end);
signal_465_2 = signal_465_2(samplesToRemove_FP:end);

%% remove period before TTL pulse

% TTL pusle for FP
TTL_FP = data_FPrig.epocs.(mouse{12}).onset;
first_TTL = TTL_FP(1)*signal_fs;
onset_FP = first_TTL;
if first_TTL<1
    onset_FP = 1;
end

% TTL pusle for EEG
TTL_FP_EEG = data_EEGrig.epocs.(mouse{12}).onset; %CHOOSE RIG THAT EEG IS ACQUIRED ON
first_TTL_EEG = TTL_FP_EEG(1)*EEG_fs;
onset_FP_EEG = first_TTL_EEG;
if first_TTL_EEG<1
    onset_FP_EEG = 1;
end

signal_465_2 = signal_465_2(onset_FP:end);
signal_405_2 = signal_405_2(onset_FP:end);

EEG = EEG(onset_FP_EEG:end);
EMG = EMG(onset_FP_EEG:end);


%% time signal

fs_signal_2 = 1:1:length(signal_465_2);
sec_signal_2 = fs_signal_2/signal_fs; % time vector for fiber photometry signal

fs_signal_EEG = 1:1:length(EEG);
sec_signal_EEG = fs_signal_EEG/EEG_fs; % time vector for EEG signal

fs_signal_EMG = 1:1:length(EMG);
sec_signal_EMG = fs_signal_EMG/EEG_fs; % time vector for EMG signal



%% Normalize
% Here the fluorescence traces are normalised based on a fit of the 405 nm
% channel. This should remove the drift in the 465 nm channel. make sure to
% check the fit in the plot and adjust fitting interval if the fit is not
% working properly.

MeanFilterOrder = 1000; % for smoothing
MeanFilter = ones(MeanFilterOrder,1)/MeanFilterOrder;

MeanFilterOrder1 = 5000; % for smoothing
MeanFilter1 = ones(MeanFilterOrder1,1)/MeanFilterOrder1;

reg2 = polyfit_R2020a(signal_405_2, signal_465_2, 1);
a2 = reg2(1);
b2 = reg2(2);
controlFit_465_2 = a2.*signal_405_2 + b2;
controlFit_465_2 =  filtfilt(MeanFilter,1,double(controlFit_465_2));
normDat_2 = (signal_465_2 - controlFit_465_2)./controlFit_465_2;
delta_465_2 = normDat_2 * 100;

% smoothing traces
delta465_filt_2 = filtfilt(MeanFilter,1,double(delta_465_2));
ds_factor_FP = 100; % also used for plotting later (section 9b)

% downsampling traces for plotting
ds_delta465_filt_2 = downsample(delta465_filt_2, ds_factor_FP);
ds_sec_signal_2 = downsample(sec_signal_2, ds_factor_FP); % for plotting

% Design a bandpass filter
bpFilt = designfilt('bandpassfir', 'FilterOrder', 100, ...
    'CutoffFrequency1', 20, 'CutoffFrequency2', 300, ...
    'SampleRate', EEG_fs);

% Apply the bandpass filter to your EMG data
filtered_EMG = filtfilt(bpFilt, EMG);
%% Plot the normalization of FP
figure
a = subplot(4,1,1);
plot(sec_signal_2, signal_405_2);
title('raw control');
b = subplot(4,1,2);
plot(sec_signal_2, signal_465_2);
title('raw signal');
c = subplot(4,1,3);
plot(sec_signal_2, signal_465_2);
hold on
plot(sec_signal_2, controlFit_465_2);
title('fitted control');
d = subplot(4,1,4);
plot(sec_signal_2, delta465_filt_2);
title('normalized signal 465');
linkaxes([a,b,c,d],'x');

%% Plot the FP, EEG and EMG together
figure
a = subplot(3,1,1);
plot(ds_sec_signal_2,ds_delta465_filt_2)
title('NE');
b = subplot(3,1,2);
plot(sec_signal_EEG, EEG);
title('EEG');
c = subplot(3,1,3);
plot(sec_signal_EEG, EMG);
title('EMG');
linkaxes([a,b,c],'x');

%% SLEEP: Load sleep score

EEG_sleepscore = xlsread(mouse{15});

% Create binary vectors for sleep stages
%Awake
wake_onset = rmmissing(EEG_sleepscore(:, 2)); % onset of each wake bout in sec (NaNs are removed)
wake_duration = rmmissing(EEG_sleepscore(:, 3)); % duration of each wake bout in sec (NaNs are removed)

%Slow-wave sleep
sws_onset = rmmissing(EEG_sleepscore(:, 6)); % onset of each SWS bout in sec (NaNs are removed)
duration_sws = rmmissing(EEG_sleepscore(:, 7)); % duration of each SWS bout in sec (NaNs are removed)

%REM
REM_onset = rmmissing(EEG_sleepscore(:, 10)); % onset of each REM bout in sec (NaNs are removed)
REM_duration = rmmissing(EEG_sleepscore(:, 11)); % duration of each REM bout in sec (NaNs are removed)


% Most EEG scorings don't start at time 0 - which shifts the timeline of the
% scoring relative to the EEG/EMG traces - this is corrected for below
if min([wake_onset(1), sws_onset(1), REM_onset(1)]) ~= 0
    EEG_scoring_onset = min([wake_onset(1), sws_onset(1), REM_onset(1)]); % determines the number of seconds to be subtracted
    wake_onset = wake_onset - EEG_scoring_onset;
    sws_onset = sws_onset - EEG_scoring_onset;
    REM_onset = REM_onset - EEG_scoring_onset;
end


wake_binary_vector = zeros([1, round(sec_signal_EEG(end))+200]); 
for i=1:length(wake_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = wake_onset(i)+1; % +1 to put time 0 as index 1
    d = wake_duration(i)-1; % -1 compensates for adding 1
    wake_binary_vector(t:t+d) = 1;
end


sws_binary_vector =  zeros([1, round(sec_signal_EEG(end))+200]); 
for i=1:length(sws_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = sws_onset(i)+1; 
    d = duration_sws(i)-1;
    sws_binary_vector(t:t+d) = 1;
end


REM_binary_vector =  zeros([1, round(sec_signal_EEG(end))+200]);
for i=1:length(REM_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = REM_onset(i)+1;
    d = REM_duration(i)-1;
    REM_binary_vector(t:t+d) = 1;
end


%%  SLEEP: 5a) Make sleep periods  
% 2-column vectors with on- and offsets for each state
wake_periods = [wake_onset wake_onset+wake_duration];
sws_periods = [sws_onset sws_onset+duration_sws];
REM_periods = [REM_onset REM_onset+REM_duration];

%% SLEEP: 5b) Dividing wake bouts into microarousals (MA) and wake w/o MA

MA_maxdur = 15; % maximum duration of microarrousal
MA_idx = find(wake_duration < MA_maxdur);
MA_onset = wake_onset(MA_idx);
MA_duration = wake_duration(MA_idx);
MA_binary_vector =  zeros([1, round(sec_signal_EEG(end))+200]);
for i=1:length(MA_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = MA_onset(i)+1;
    d = MA_duration(i)-1;
    MA_binary_vector(t:t+d) = 1;
end

% remove micrarrousal from wake vectors
wake_woMA_onset = wake_onset;
wake_woMA_onset(MA_idx) = [];
wake_woMA_duration = wake_duration;
wake_woMA_duration(MA_idx) = [];
wake_woMA_binary_vector =  zeros([1, round(sec_signal_EEG(end))+200]);
for i=1:length(wake_woMA_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = wake_woMA_onset(i)+1;
    d = wake_woMA_duration(i)-1;
    wake_woMA_binary_vector(t:t+d) = 1;
end

% 2-column vectors with on- and offsets for each state
MA_periods = [MA_onset MA_onset+MA_duration];
wake_woMA_periods = [wake_woMA_onset wake_woMA_onset+wake_woMA_duration];



%% SLEEP: 6) Alingment of EEG recording and FP recording

TTL_EEG_onset = first_TTL_EEG;

% Remove first seconds of EEG score to align with FP trace
wake_binary_vector_cut = wake_binary_vector(round(TTL_EEG_onset):end);
sws_binary_vector_cut = sws_binary_vector(round(TTL_EEG_onset):end);
REM_binary_vector_cut = REM_binary_vector(round(TTL_EEG_onset):end);
MA_binary_vector_cut = MA_binary_vector(round(TTL_EEG_onset):end);
wake_woMA_binary_vector_cut = wake_woMA_binary_vector(round(TTL_EEG_onset):end);


% Align onset, offset, and duration vectors based on TTL
[wake_onset_cut, wake_offset_cut] = binary_to_OnOff(wake_binary_vector_cut);
wake_duration_cut = wake_offset_cut - wake_onset_cut;

[sws_onset_cut, sws_offset_cut] = binary_to_OnOff(sws_binary_vector_cut);
sws_duration_cut = sws_offset_cut - sws_onset_cut;

if ~isnan(REM_onset)
    [REM_onset_cut, REM_offset_cut] = binary_to_OnOff(REM_binary_vector_cut);
    REM_duration_cut = REM_offset_cut - REM_onset_cut;
else
    REM_onset_cut = NaN;    % in case of no REM bouts
    REM_offset_cut = NaN;
    REM_duration_cut = NaN;
end

    [MA_onset_cut, MA_offset_cut] = binary_to_OnOff(MA_binary_vector_cut);
    MA_duration_cut = MA_offset_cut - MA_onset_cut;

    [wake_woMA_onset_cut, wake_woMA_offset_cut] = binary_to_OnOff(wake_woMA_binary_vector_cut);
    wake_woMA_duration_cut = wake_woMA_offset_cut - wake_woMA_onset_cut;

% Align period arrays according to TTL
wake_periods_cut = [wake_onset_cut wake_offset_cut];
sws_periods_cut = [sws_onset_cut sws_offset_cut];
REM_periods_cut = [REM_onset_cut REM_offset_cut];
MA_periods_cut = [MA_onset_cut MA_offset_cut];
wake_woMA_periods_cut = [wake_woMA_onset_cut wake_woMA_offset_cut];
%TTL_EEG_onset = onset_FP_EEG/EEG_fs;
% TTL_EEG_onset = samplesToRemove_EEG_EMG;
% 
% 
% % Remove first seconds of EEG score to align with FP trace
% wake_binary_vector_cut = wake_binary_vector(round(TTL_EEG_onset):end);
% sws_binary_vector_cut = sws_binary_vector(round(TTL_EEG_onset):end);
% REM_binary_vector_cut = REM_binary_vector(round(TTL_EEG_onset):end);
% MA_binary_vector_cut = MA_binary_vector(round(TTL_EEG_onset):end);
% wake_woMA_binary_vector_cut = wake_woMA_binary_vector(round(TTL_EEG_onset):end);
% 
% 
% % Align onset, offset, and duration vectors based on TTL
% [wake_onset_cut, wake_offset_cut] = binary_to_OnOff(wake_binary_vector_cut);
% wake_duration_cut = wake_offset_cut - wake_onset_cut;
% 
% [sws_onset_cut, sws_offset_cut] = binary_to_OnOff(sws_binary_vector_cut);
% sws_duration_cut = sws_offset_cut - sws_onset_cut;
% 
% if ~isnan(REM_onset)
%     [REM_onset_cut, REM_offset_cut] = binary_to_OnOff(REM_binary_vector_cut);
%     REM_duration_cut = REM_offset_cut - REM_onset_cut;
% else
%     REM_onset_cut = NaN;    % in case of no REM bouts
%     REM_offset_cut = NaN;
%     REM_duration_cut = NaN;
% end
% 
%     [MA_onset_cut, MA_offset_cut] = binary_to_OnOff(MA_binary_vector_cut);
%     MA_duration_cut = MA_offset_cut - MA_onset_cut;
% 
%     [wake_woMA_onset_cut, wake_woMA_offset_cut] = binary_to_OnOff(wake_woMA_binary_vector_cut);
%     wake_woMA_duration_cut = wake_woMA_offset_cut - wake_woMA_onset_cut;
% 
% % Align period arrays according to TTL
% wake_periods_cut = [wake_onset_cut wake_offset_cut];
% sws_periods_cut = [sws_onset_cut sws_offset_cut];
% REM_periods_cut = [REM_onset_cut REM_offset_cut];
% MA_periods_cut = [MA_onset_cut MA_offset_cut];
% wake_woMA_periods_cut = [wake_woMA_onset_cut wake_woMA_offset_cut];

%% SLEEP: Re-classify MA as NREM using boutscore_vector
% Here you can pool MAs with NREM sleep which can be beneficial for some
% analyses related to infraslow oscillations (eg. PSD analysis), where you
% don't want to divide your traces into short/pure NREM bouts

%State transitions (uncut vectors)
% Creating one vector with different behaviors represented by unique
% numbers (1=wake, 4=sws, 9=REM, 15=MA) at frequency 1Hz
boutscore_vector = zeros([1, round(sec_signal_EEG(end))+200]);

% Here using the unaligned "uncut" vectors
for i=1:length(wake_woMA_onset)
    t = wake_woMA_onset(i)+1;
    d = wake_woMA_duration(i)-1;
    boutscore_vector(t:t+d) = 1; % wake=1
end

for i=1:length(sws_onset)
    t = sws_onset(i)+1;
    d = duration_sws(i)-1;
    boutscore_vector(t:t+d) = 4; % sws=4
end

if ~isnan(REM_onset)
    for i=1:length(REM_onset)
        t = REM_onset(i)+1;
        d = REM_duration(i)-1;
        boutscore_vector(t:t+d) = 9; %REM=9
    end
end

for i=1:length(MA_onset)
    t = MA_onset(i)+1;
    d = MA_duration(i)-1;
    boutscore_vector(t:t+d) = 15; %MA=15
end

% re-classify MA as NREM
NREMinclMA_binary_vector = boutscore_vector==4 | boutscore_vector==15;
%NREMinclMA_binary_vector_cut = NREMinclMA_binary_vector(round(TTL_EEG_onset+1):end);
% [NREMinclMA_onset_cut, NREMinclMA_offset_cut] = binary_to_OnOff(NREMinclMA_binary_vector_cut);
% NREMinclMA_duration_cut = NREMinclMA_offset_cut-NREMinclMA_onset_cut;
% NREMinclMA_periods_cut = [NREMinclMA_onset_cut NREMinclMA_offset_cut];
[NREMinclMA_onset, NREMinclMA_offset] = binary_to_OnOff(NREMinclMA_binary_vector);
NREMinclMA_duration = NREMinclMA_offset-NREMinclMA_onset;
NREMinclMA_periods = [NREMinclMA_onset NREMinclMA_offset];


%% Plot sleep phases
%Plotting the power bands with the RR-intervals and NE
%sleepscore_time_cut = 0:length(wake_woMA_binary_vector_cut )-1; % should be same length for wake/sws/REM
sleepscore_time = 0:length(wake_woMA_binary_vector_168 )-1; % should be same length for wake/sws/REM

figure();

% Subplot for NE
a = subplot(3, 1, 1);
plot_sleep(ds_sec_signal_2_168, ds_delta465_filt_2_168, sleepscore_time, wake_woMA_binary_vector_168, sws_binary_vector_168, REM_binary_vector_168, MA_binary_vector_168);
hold on;
%plot(NE_sws_MA_Trunk_Timestamps, ds_delta465_filt_2(NE_sws_MA_Trunk_Timestamps), 'ro', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
xlabel('time (s)');
ylabel('NE');
title('NE');
grid on;

% Subplot for EEG
b = subplot(3, 1, 2);
plot_sleep(sec_signal_EEG_168, EEG_168, sleepscore_time, wake_woMA_binary_vector_168, sws_binary_vector_168, REM_binary_vector_168, MA_binary_vector_168);
hold on;
xlabel('time (s)');
ylabel('Amplitude (V)');
title('EEG');
grid on;

% Subplot for EEG
c = subplot(3, 1, 3);
plot_sleep(sec_signal_EEG_168, EMG_168, sleepscore_time, wake_woMA_binary_vector_168, sws_binary_vector_168, REM_binary_vector_168, MA_binary_vector_168);
hold on;
xlabel('time (s)');
ylabel('Amplitude (V)');
title('EMG');
grid on;

linkaxes([a,b,c],'x');

%% Export EMG
% Ensure both signals are column vectors and convert filtered_EMG to double
sec_signal_EMG_col = sec_signal_EMG(:); % Convert to column vector if not already
filtered_EMG_col = double(filtered_EMG(:)); % Convert to double and column vector

% Combine into one variable with two columns
combined_EMG = [sec_signal_EMG_col, filtered_EMG_col];
% Define the filename
filename = 'combined_EMG.txt';

% Export the combined_signals matrix to a TXT file
writematrix(combined_EMG, filename);

%% Segment NE into hourly signals

% Parse start and end time from your data
startTimeStr = data_FPrig.info.utcStartTime;
endTimeStr = data_FPrig.info.utcStopTime;

% Convert time strings to datetime format
startTime = datetime(startTimeStr, 'InputFormat', 'HH:mm:ss');
endTime = datetime(endTimeStr, 'InputFormat', 'HH:mm:ss');

% Round start time to the next full hour and end time to the previous full hour
startTimeNextHour = dateshift(startTime, 'start', 'hour', 'next');
endTimePreviousHour = dateshift(endTime, 'end', 'hour', 'previous');

% Calculate total number of full hours in the recording
totalFullHours = hours(endTimePreviousHour - startTimeNextHour);

% Initialize the start time for the first segment
currentSegmentStart = startTimeNextHour;

% Loop through each full hour and create segments
for i = 1:totalFullHours
    % Calculate the end time for the current segment
    currentSegmentEnd = currentSegmentStart + hours(1);
    
    % Convert segment start and end time to seconds from start of recording
    segmentStartSec = seconds(currentSegmentStart - startTime);
    segmentEndSec = seconds(currentSegmentEnd - startTime);
    
    % Convert segment start and end times to indices
    segmentStartIndex = round(segmentStartSec * signal_fs) + 1;
    segmentEndIndex = round(segmentEndSec * signal_fs);
    
    % Extract the segment for delta465_filt_2 and sec_signal_2
    segmentName = sprintf('delta465_filt_2_%02d', hour(currentSegmentStart));
    eval([segmentName ' = delta465_filt_2(segmentStartIndex:segmentEndIndex);']);
    
    segmentTimeName = sprintf('sec_signal_2_%02d', hour(currentSegmentStart));
    eval([segmentTimeName ' = sec_signal_2(segmentStartIndex:segmentEndIndex);']);
    
    % Update the start time for the next segment
    currentSegmentStart = currentSegmentEnd;
end

%% Determine movement peak threshold through plotting
sec_signal_EMG = sec_signal_EEG_124;
EMG = EMG_124;

figure;
subplot(2,1,1);
plot(sec_signal_EMG, EMG);  % 'o-' specifies markers and lines

% Adding a horizontal line at mean + 3.5*SD
mean_EMG = mean(EMG);
sd_EMG = std(EMG);
line([min(sec_signal_EMG), max(sec_signal_EMG)], [mean_EMG + 3.5*sd_EMG, mean_EMG + 3.5*sd_EMG], 'Color', 'r', 'LineStyle', '--');

% Adding labels and title
xlabel('Time (s)');
ylabel('EMG');
title('EMG Data Plot');

% Adding grid (optional)
grid on;

subplot(2,1,2);
plot(sec_signal_EMG, EMG_filtered);  % 'o-' specifies markers and lines
% Adding a horizontal line at mean + 3.5*SD
mean_EMG = mean(EMG);
sd_EMG = std(EMG);
line([min(sec_signal_EMG), max(sec_signal_EMG)], [mean_EMG + 3.5*sd_EMG, mean_EMG + 3.5*sd_EMG], 'Color', 'r', 'LineStyle', '--');

% Adding labels and title
xlabel('Time (s)');
ylabel('EMG');
title('EMG Data Plot');

% Adding grid (optional)
grid on;

% Display the plot

linkaxes([subplot(2,1,1), subplot(2,1,2)], 'x');

%% Playground - wavelet transformation
% Define parameters
EMG_signal = EMG_124; % Your signal
waveletFunction = 'db4'; % Wavelet type
Fs = EEG_fs_124; % Sampling rate

freqThreshold = 50; % Threshold frequency in Hz
level = 0;
while Fs / (2^(level + 1)) > freqThreshold
    level = level + 1;
end

% Wavelet packet decomposition
wp = wpdec(EMG_signal, level, waveletFunction);

% Navigate through the packet tree and zero out coefficients above the threshold frequency
nodes = (2^level - 1):(2^(level + 1) - 2); % Nodes at the level corresponding to > threshold frequency
for node = nodes
    C = read(wp, 'data', node);
    C(:) = 0; % Zero out coefficients
    wp = write(wp, 'data', node, C);
end

% Reconstruct the signal from the modified wavelet packet tree
EMG_filtered = wprec(wp);


% Now, you can continue with your HR detection code on EMG_filtered
figure;

% % Plot the original EMG signal
subplot(2,1,1);
plot(sec_signal_EMG, EMG_124, 'b-');
hold on;
line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');
xlabel('Time (s)');
ylabel('EMG');
title('EMG Raw');
set(gcf,'color','white')
grid on;

% Plot the filtered EMG signal with selected peaks
subplot(2,1,2);
plot(sec_signal_EMG, EMG_filtered, 'b-');
xlabel('Time (s)');
ylabel('EMG (V)');
title('EMG Wavelet transformed');
set(gcf,'color','white')
grid on;

linkaxes([subplot(2,1,1), subplot(2,1,2)], 'x');
%% 
save('EMG_124.mat', 'EMG_124');
save('EMG_117.mat', 'EMG_117');
save('EGG_588.mat', 'EEG_588');
save('EMG_600.mat', 'EMG_600');
save('EMG_602.mat', 'EMG_602');
save('EMG_084.mat', 'EMG_084');
save('EMG_023.mat', 'EMG_023');

save('NE_100_new.mat', 'delta465_filt_2_100');
save('EMG_100.mat', 'EMG_100');
save('EEG_100.mat', 'EEG_100');
save('wake_100.mat', 'wake_woMA_binary_vector_100');
save('NREM_100.mat', 'sws_binary_vector_100');
save('REM_100.mat', 'REM_binary_vector_100');
save('micro_arousal_100.mat', 'MA_binary_vector_100');

%% Get clean sections for machine learning training
% Your provided variables and code for movement detection
sec_signal_EMG = sec_signal_EEG_124;
EMG = EMG_124;
EEG_fs = EEG_fs_124;

% Calculate mean and standard deviation of the filtered EMG signal
mean_EMG = mean(EMG);
sd_EMG = std(EMG);

% Set threshold as mean + 3.5 * SD for movement detection
threshold = mean_EMG + 3.5 * sd_EMG;

% Find movement peaks in the filtered EMG signal using the predefined threshold
[movement, movement_locs] = findpeaks(EMG, 'MinPeakHeight', threshold);

% Convert times for the clean sections buffer
buffer_after_movement = 3; % seconds after a movement
buffer_before_movement = 2; % seconds before the next movement
movement_sec = sec_signal_EMG(movement_locs);

% Initialize clean sections variable
clean_sections = [];

% Add the first section from start of recording to the first movement minus buffer
if ~isempty(movement_sec) && movement_sec(1) - buffer_before_movement > 0
    clean_sections = [clean_sections; [0, movement_sec(1) - buffer_before_movement]];
end

% Loop through movement peaks and create clean sections between them
for i = 1:length(movement_sec) - 1
    clean_start = movement_sec(i) + buffer_after_movement;
    clean_end = movement_sec(i + 1) - buffer_before_movement;
    
    % Check if the clean section is at least 5 seconds long
    if (clean_end - clean_start) >= 40
        clean_sections = [clean_sections; [clean_start, clean_end]];
    end
end

% Add the last section from the last movement plus buffer to the end of recording
if ~isempty(movement_sec) && (sec_signal_EMG(end) - (movement_sec(end) + buffer_after_movement)) > 0
    clean_sections = [clean_sections; [movement_sec(end) + buffer_after_movement, sec_signal_EMG(end)]];
    clean_sections(1, :) = [];
end



%% Determine HR and movement peaks - current version
sec_signal_EMG = sec_signal_EEG_387;
EMG = EMG_387;

filtered_EMG = EMG_387;
sec_signal_EMG = sec_signal_EEG_387;
EEG_fs = EEG_fs_387;

% Initialize selected peaks storage
selected_peaks = [];
selected_peak_locs = [];

% Calculate mean and standard deviation of the filtered EMG signal
mean_EMG = mean(EMG);
sd_EMG = std(EMG);

% Set threshold as mean + 3.5 * SD for movement detection
threshold = mean_EMG + 3.5 * sd_EMG;

% Find movement peaks in the filtered EMG signal using the predefined threshold
[movement, movement_locs] = findpeaks(EMG, 'MinPeakHeight', threshold);
movement_sec = sec_signal_EMG(movement_locs); % Assuming sec_signal_EMG is defined and corresponds to the timestamps of EMG data

% Define window length in seconds (1 second) and ensure window_length_samples is an integer
window_length_sec = 2;
window_length_samples = round(window_length_sec * EEG_fs);

% Initialize a variable to keep track of the last movement to handle consecutive movements
last_movement_end = -Inf;

% Convert 100 ms before and 250 ms after to samples
exclude_before_movement = ceil(EEG_fs * 0.1); % 100 ms before
exclude_after_movement = ceil(EEG_fs * 0.25); % 250 ms after

for start_idx = 1:window_length_samples:length(EMG) - window_length_samples + 1
    end_idx = start_idx + window_length_samples - 1;
    valid_indices = true(window_length_samples, 1); % Initialize all indices as valid

    % Check for movement within the current window
    movement_in_window = movement_sec(movement_sec >= sec_signal_EMG(start_idx) & movement_sec <= sec_signal_EMG(end_idx));
    
    for i = 1:length(movement_in_window)
        movement_time = movement_in_window(i);
        movement_idx = find(sec_signal_EMG == movement_time, 1, 'first');
        if ~isempty(movement_idx) && movement_idx <= end_idx
            start_exclude_idx = max(start_idx, movement_idx - exclude_before_movement); % Ensure not before start of window
            end_exclude_idx = min(end_idx, movement_idx + exclude_after_movement); % Ensure not beyond end of window
            
            % Update valid_indices to exclude the specified range
            valid_indices(start_exclude_idx - start_idx + 1:end_exclude_idx - start_idx + 1) = false;
        end
    end

% Apply exclusion and perform further analysis as needed
valid_data = EMG(start_idx:end_idx);
valid_data = valid_data(valid_indices);

if ~isempty(valid_data) && length(valid_data) >= 3
    mean_EMG_window = mean(valid_data);
    sd_EMG_window = std(valid_data);
    
    % Calculate the dynamic threshold for peak detection
    dynamic_threshold = mean_EMG_window + 2.5*sd_EMG_window;
    
    % Check if any data point exceeds the dynamic threshold
    if any(valid_data > dynamic_threshold)
        [peaks_window, locs_window] = findpeaks(valid_data, 'MinPeakHeight', dynamic_threshold);
        
        % Correct calculation of actual_locs_window
        valid_indices_cumsum = cumsum(valid_indices); % Get the cumulative sum of valid indices
        actual_locs_window = start_idx - 1 + valid_indices_cumsum(locs_window); % Map locs_window back to the global indices correctly

        % Ensure peaks_window and actual_locs_window are column vectors before concatenation
        peaks_window = peaks_window(:);
        actual_locs_window = actual_locs_window(:);

        % Concatenate peaks and locations
        selected_peaks = [selected_peaks; peaks_window];
        selected_peak_locs = [selected_peak_locs; actual_locs_window];
    end
end
    
    % If there is movement in the current window and the previous one, consider removing peaks between those movements
    % Specific logic will depend on your requirements
    
    % Update the last movement end index
    if ~isempty(movement_in_window)
        last_movement_end = end_idx;
    end
end
%% Remove selected peaks that are to quick
% Calculate the minimum time interval between peaks based on physiological bounds
min_interval_sec = 60 / 800; % Minimum time interval in seconds for 700 bpm

% Sort the peaks by their timestamps
% Remove zeros from selected_peak_locs if present
valid_indices = selected_peak_locs > 0;

% Apply the valid indices to filter both selected_peak_locs and selected_peaks
selected_peak_locs = selected_peak_locs(valid_indices);
selected_peaks = selected_peaks(valid_indices);

% Now selected_peak_locs no longer contains zeros and can be safely used for indexing
selected_peak_times = sec_signal_EMG(selected_peak_locs);
[sorted_peak_locs, sort_index] = sort(selected_peak_times);
sorted_peaks = selected_peaks(sort_index);

% Calculate the time differences between consecutive peaks
time_diffs = diff(sorted_peak_locs);

% Initialize an array of the same size as time_diffs and set the first element to true
valid_peaks_indices = [time_diffs >= min_interval_sec];

% Select only the peaks that are valid based on their time difference
quality_selected_peaks = sorted_peaks(valid_peaks_indices);
quality_selected_peak_locs = sorted_peak_locs(valid_peaks_indices);

%% New version of quality peaks
% Calculate the minimum time interval between peaks based on physiological bounds
min_interval_sec = 60 / 800; % Minimum time interval in seconds for 700 bpm

% Sort the peaks by their timestamps
% Remove zeros from selected_peak_locs if present
% Find indices where selected_peak_locs is greater than 0
valid_indices = selected_peak_locs > 0;

% Apply the valid indices to filter both selected_peak_locs and selected_peaks
selected_peak_locs = selected_peak_locs(valid_indices);
selected_peaks = selected_peaks(valid_indices);

% Now, selected_peak_locs no longer contains zeros, and selected_peaks has been reduced accordingly
selected_peak_times = sec_signal_EMG(selected_peak_locs);

% Sort the peaks by their timestamps
[sorted_peak_times, sort_index] = sort(selected_peak_times);
sorted_peaks = selected_peaks(sort_index);
sorted_peak_locs = selected_peak_locs(sort_index);

% Initialize lists to keep the peaks and locations that meet the criteria
quality_selected_peaks = [];
quality_selected_peak_locs = [];

i = 1;
while i <= length(sorted_peak_times)
    current_peak = sorted_peaks(i);
    current_loc = sorted_peak_locs(i);
    % Assume current peak is valid initially
    is_peak_valid = true;
    
    % Look ahead to check if the next peak is too close
    if i < length(sorted_peak_times) && (sorted_peak_times(i + 1) - sorted_peak_times(i) < min_interval_sec)
        next_peak = sorted_peaks(i + 1);
        % If the next peak is higher, mark the current peak as invalid
        if next_peak > current_peak
            is_peak_valid = false;
        else
            % Otherwise, mark the next peak as invalid by removing it
            % Note: we don't need to explicitly mark it, just skip adding it in the next iteration
            i = i + 1;  % Skip the next peak
        end
    end
    
    % If the peak is valid, add it to the kept lists
    if is_peak_valid
        quality_selected_peaks  = [quality_selected_peaks ; current_peak];
        quality_selected_peak_locs  = [quality_selected_peak_locs ; current_loc];
    end
    
    i = i + 1;  % Move to the next peak
end


%% 
% Example of calling the function with the required variables
EMG_section_reviewer(clean_sections, sec_signal_EMG, EMG, selected_peak_locs, selected_peaks, threshold);

% % Extract the first segment of EMG data and its corresponding binary peaks vector
% first_EMG_segment = EMG_data{8};
% first_binary_peaks = selected_peaks_data{8};
% 
% % Time vector for the first segment, assuming constant sampling interval
% time_vector = (0:length(first_EMG_segment)-1) / EEG_fs_124;
% 
% % Plot the first EMG segment
% figure; 
% plot(time_vector, first_EMG_segment);
% hold on;
% 
% % Overlay the peaks on the EMG trace
% % Peaks are marked as '1' in the binary vector, so multiply by max(EMG) for visualization
% peak_indices = find(first_binary_peaks == 1);
% peaks_plot = zeros(size(first_EMG_segment));
% peaks_plot(peak_indices) = max(first_EMG_segment) * 1.1; % 10% above max for visibility
% stem(time_vector, peaks_plot, 'Marker', 'none', 'Color', 'r', 'LineStyle', ':');
% 
% % Enhance the plot
% xlabel('Time (s)');
% ylabel('EMG Amplitude');
% title('First EMG Segment with Peaks');
% legend('EMG Signal', 'Detected Peaks');
% grid on;
%% Extract data for train/test based on the review
% Assuming 'review_answers' is loaded in your workspace and contains [row_index, decision] format
% where decision: 1=keep, 0=discard
% Assuming 'selected_peak_locs' are the indices of 'sec_signal_EMG' where peaks occur

fs = EEG_fs_124; % Sampling frequency

% Filter to keep only 'keep' decisions
keep_indices = review_answers(review_answers(:,2) == 1, 1);
clean_sections_to_use = clean_sections(keep_indices, :);

% Initialize arrays to store EMG data and labels
EMG_data = {};
selected_peaks_data = {};

% Assuming the conversion of peak times to indices introduced an extra offset,
% let's adjust the local peak index calculation by removing the additional +1 

for i = 1:length(clean_sections_to_use)
    % Time range for the current clean section
    time_range = clean_sections_to_use(i, :);
    indices_range = find(sec_signal_EMG >= time_range(1) & sec_signal_EMG <= time_range(2));
    
    % Extract the EMG trace for the current section
    EMG_trace = EMG(indices_range);
    EMG_data{end+1} = EMG_trace;
    
    % Initialize a binary vector for peaks in the current EMG trace
    binary_peaks = zeros(length(EMG_trace), 1);
    
    % Find peak times that fall within the current time range
    peak_times_in_range = sec_signal_EMG(selected_peak_locs(selected_peak_locs >= min(indices_range) & selected_peak_locs <= max(indices_range)));
    
    % Adjust the conversion of peak times to indices, considering the exact start time of the segment
    local_peak_indices = round((peak_times_in_range - time_range(1)) * fs) + 1;

    % To correct the offset issue, subtract 1 from local_peak_indices
    local_peak_indices_corrected = local_peak_indices - 1;
    
    % Ensure indices are within range after adjustment
    local_peak_indices_corrected = local_peak_indices_corrected(local_peak_indices_corrected > 0 & local_peak_indices_corrected <= length(EMG_trace));
    
    % Set '1' for peaks in the binary vector using the corrected indices
    binary_peaks(local_peak_indices_corrected) = 1;
    
    selected_peaks_data{end+1} = binary_peaks;
end

minSegmentLength = min(cellfun(@length, EMG_data));

% Truncate both EMG and peak data to the length of the shortest segment
truncated_EMG_data = cellfun(@(x) x(1:minSegmentLength), EMG_data, 'UniformOutput', false);
adjusted_peaks_data = cellfun(@(x) x(1:minSegmentLength), selected_peaks_data, 'UniformOutput', false);

% Determine the number of segments to be used for testing (10%)
numSegments = length(truncated_EMG_data);
numTest = floor(numSegments * 0.1);

% Generate random indices for test segments
rng(1); % For reproducibility
testIndices = randperm(numSegments, numTest);

% Convert binary labels to categorical, one cell per sequence
YTrainCategorical = cellfun(@(y) categorical(y), adjusted_peaks_data(trainIndices), 'UniformOutput', false);
YTestCategorical = cellfun(@(y) categorical(y), adjusted_peaks_data(testIndices), 'UniformOutput', false);

% Transpose each label vector in YTrainCategorical and YTestCategorical to be row vectors
YTrainCategorical = cellfun(@(y) y', YTrainCategorical, 'UniformOutput', false);
YTestCategorical = cellfun(@(y) y', YTestCategorical, 'UniformOutput', false);

% Verify that XTrainCell and XTestCell are cell arrays where each cell is a column vector of the data
XTrainCell = truncated_EMG_data(trainIndices);
XTestCell = truncated_EMG_data(testIndices);

% XTrainCell = cellfun(@(x) x', XTrainCell, 'UniformOutput', false);
% XTestCell = cellfun(@(x) x', XTestCell, 'UniformOutput', false);


%% Define the network and run the RNN

inputSize = 1;  % Since you're working with 1D time series data
numHiddenUnits = 100;  % Number of LSTM units
numClasses = 2;  % Binary classification (peak or no peak)

layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',30, ...
    'MiniBatchSize', 32, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress', ...
    'Shuffle','every-epoch', ...
    'ValidationData', {XTestCell, YTestCategorical}, ...
    'ValidationFrequency',30);


[trainedNet, trainInfo] = trainNetwork(XTrainCell, YTrainCategorical, layers, options);

YPred = classify(trainedNet, XTestCell);

% Initialize a variable to accumulate the number of correct predictions
numCorrect = 0;
totalTimesteps = 0;

% Iterate over each sequence to compare predictions with true labels
for i = 1:numel(YPred)
    % Calculate the number of correct predictions for the current sequence
    numCorrect = numCorrect + sum(YPred{i} == YTestCategorical{i});
    totalTimesteps = totalTimesteps + numel(YTestCategorical{i});
end

% Calculate overall accuracy
accuracy = numCorrect / totalTimesteps;
disp(['Test Accuracy: ', num2str(accuracy)]);

%% 
% Segment the new EMG data into sections of length 'minSegmentLength'
numFullSegments = floor(length(EMG_124) / minSegmentLength);
remainder = mod(length(EMG_124), minSegmentLength);
numNewSegments = numFullSegments + (remainder > 0);  % Add one more segment if there is a remainder
XNew = zeros(minSegmentLength, 1, 1, numNewSegments);

% Populate segments
for i = 1:numFullSegments
    startIndex = (i-1) * minSegmentLength + 1;
    endIndex = i * minSegmentLength;
    XNew(:, 1, 1, i) = EMG_124(startIndex:endIndex);
end

% Handle the remainder of the EMG data
if remainder > 0
    lastSegment = zeros(minSegmentLength, 1);
    lastSegment(1:remainder, 1) = EMG_124(end-remainder+1:end);
    XNew(:, 1, 1, numNewSegments) = lastSegment;
end

% Convert to a cell array, each cell containing a single column vector
XNewCell = squeeze(num2cell(XNew, [1]));
XNewCell = XNewCell';
XNewCell = cellfun(@(x) x', XNewCell, 'UniformOutput', false);
% Convert each cell's contents to single
XNewCell = cellfun(@(x) single(x), XNewCell, 'UniformOutput', false);

% Use the 'predict' function to get raw scores
scoresNew = predict(trainedNet, XNewCell);

% Convert scores to binary predictions using a custom threshold (e.g., 0.5)
threshold = 0.5;
binaryPredictions = cellfun(@(s) double(s(:, 2) > threshold), scoresNew, 'UniformOutput', false);

% Concatenate the binary results to form one full-length binary prediction vector
binaryFullPrediction = cat(1, binaryPredictions{:});

% Truncate the extra zeros from the last segment if there was a remainder
if remainder > 0
    binaryFullPrediction = binaryFullPrediction(1:end-(minSegmentLength-remainder));
end

% Count the number of detected peaks again
numDetectedPeaks = sum(binaryFullPrediction);
disp(['Number of Detected Peaks: ', num2str(numDetectedPeaks)]);


% binaryFullPrediction now corresponds to the full length of EMG_124
% First, find the locations of the predicted peaks
predicted_peak_locs = find(binaryFullPrediction);
predicted_peaks = EMG(predicted_peak_locs);

%% Plot movement and selected peaks


% Calculate mean and standard deviation of the filtered EMG signal
mean_EMG = mean(EMG);
sd_EMG = std(EMG);

% Set threshold as mean + 3.5 * SD for movement detection
threshold = mean_EMG + 3.5 * sd_EMG;
% Plotting peaks
figure;

% % Plot the original EMG signal
subplot(2,1,1);
plot(sec_signal_EMG, EMG, 'b-', quality_selected_peak_locs, quality_selected_peaks, 'ro');
hold on;
scatter(movement_sec, movement, 'y', 'filled'); % Plotting movement peaks in yellow
line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');
xlabel('sec\_signal\_EMG');
ylabel('Filtered EMG');
title('Original EMG Data w. peaks corrected v2');
grid on;

% Plot the filtered EMG signal with selected peaks
subplot(2,1,2);
plot(sec_signal_EMG, EMG, 'b-', sec_signal_EMG(selected_peak_locs), selected_peaks, 'ro');
hold on;
scatter(movement_sec, movement, 'y', 'filled'); % Plotting movement peaks in yellow
line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');
xlabel('Time (s)');
ylabel('EMG (V)');
title('EMG with Selected Peaks (dynamic window mean+2.5SD) and Movement Peaks');
set(gcf,'color','white')
grid on;

legend('Filtered EMG', 'Selected Peaks', 'Movement Peaks', 'Threshold');

linkaxes([subplot(2,1,1), subplot(2,1,2)], 'x');


% % Plot the filtered EMG signal with selected peaks
% subplot(3,1,2);
% plot(sec_signal_EMG, EMG, 'b-', quality_selected_peak_locs_v2, quality_selected_peaks_v2, 'ro');
% hold on;
% scatter(movement_sec, movement, 'y', 'filled'); % Plotting movement peaks in yellow
% line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');
% xlabel('sec\_signal\_EMG');
% ylabel('Filtered EMG');
% title('Original EMG Data w. peaks corrected v2');
% grid on;

plot(sec_signal_EMG, EMG_124, 'b-');
hold on;
% Overlay the machine learning detected peaks
scatter(sec_signal_EMG(predicted_peak_locs), predicted_peaks, ''); % 'm^' for magenta triangles
scatter(movement_sec, movement, 'y', 'filled'); % Plotting movement peaks in yellow
line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');
xlabel('Time (s)');
ylabel('EMG');
title('EMG with Machine Learning detected peak and Movement Peaks');
set(gcf,'color','white')
grid on;
legend('Filtered EMG', 'Selected Peaks', 'Movement Peaks', 'Threshold');

%% Make RR intervals & Remove selected peaks + RR's within movement chunks

% Find the time between selected peaks ('RR') and record the timestamp of the first peak for each RR observation ('RR_time')
RR = diff(quality_selected_peak_locs); % Time between selected peaks in seconds
RR_time = quality_selected_peak_locs(1:end-1); % Timestamp of the first peak for each RR observation

% Define minimum time between two movement peaks (in seconds)
minimum_time_between_movement = 1.5;

% Check if there is less than 1 second between two movement peaks
for i = 1:length(movement_sec)-1
    % Find the indices corresponding to selected peaks between two movement peaks
    indices_between_movements_selected = find(selected_peak_locs > movement_sec(i) & selected_peak_locs < movement_sec(i+1));

    % Find the indices corresponding to RR_time between two movement peaks
    indices_between_movements_RR = find(RR_time > movement_sec(i) & RR_time < movement_sec(i+1));

    % Check if there is less than minimum_time_between_movement between two movement peaks
    if movement_sec(i+1) - movement_sec(i) < minimum_time_between_movement
        % Remove the selected peaks and their corresponding locations between two movement peaks
        selected_peaks(indices_between_movements_selected) = [];
        selected_peak_locs(indices_between_movements_selected) = [];

        % Set RR and RR_time values to NaN for the observations between two movement peaks
        RR(indices_between_movements_RR) = NaN;
        RR_time(indices_between_movements_RR) = NaN;
    end
end
%% Plot RR's with selected/movement peaks

figure;

plot(sec_signal_EMG, filtered_EMG, 'b-', sec_signal_EMG(selected_peak_locs), selected_peaks, 'ro');
% plot(sec_signal_EMG, filtered_EMG, 'b-', quality_selected_peak_locs, quality_selected_peak_locs, 'ro');
hold on;
line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');

% Plot RR_time
scatter(RR_time, zeros(size(RR_time)), 'kx', 'LineWidth', 2); % Plotting RR_time at y=0
xlabel('sec\_signal\_EMG');
ylabel('Filtered EMG');
title('Filtered EMG with Selected Peaks, Movement Peaks, and RR_time');
set(gcf,'color','white')
grid on;

legend('Filtered EMG', 'Selected Peaks', 'Movement Peaks', 'Threshold', 'RR_time');

%% Remove RR outliers
%Outlier detection

% Calculate heart rate in beats per minute (bpm)
heart_rate = 60 ./ RR;

% Define the thresholds for filtering
upper_threshold = 800; % Maximum allowed heart rate in bpm
lower_threshold = 400; % Minimum allowed heart rate in bpm

% Find indices of RR intervals that meet the criteria
valid_indices = find(heart_rate <= upper_threshold & heart_rate >= lower_threshold);

% Filter RR and RR_time based on the valid indices
filtered_RR = RR(valid_indices);
filtered_RR_time = RR_time(valid_indices);

%% Plot RR's without outliers

% Plot RR_time
plot(filtered_RR_time, filtered_RR);
xlabel('Time (s)');
ylabel('RR intervals');
title('Filtered RR intervals');
grid on;

%% Smooth the filtered RR's for plotting
% Choose the window size for the moving average
window_size = 5;

% Apply the moving average - cahnge to RR if you haven't filtered
filtered_RR_smooth = movmean(filtered_RR, window_size);

% filtered_RR_smooth = filtfilt(MeanFilter,1,double(filtered_RR));

%% Resample RR at 64 hz

% Define the target sampling rate
new_fs = 64; % 64 Hz

% Create a new time vector with a fixed sampling rate of 64 Hz, starting from the first to the last observation in the original time vector
new_time_vector = filtered_RR_time(1):1/new_fs:filtered_RR_time(end);

% Use interpolation to resample RR intervals at these new time points
% 'linear' interpolation is commonly used, but you can choose another method if it fits your data better
resampled_RR = interp1(filtered_RR_time, filtered_RR_smooth, new_time_vector, 'spline');
resampled_RR_linear = interp1(filtered_RR_time, filtered_RR_smooth, new_time_vector, 'linear');
resampled_RR_nearest = interp1(filtered_RR_time, filtered_RR_smooth, new_time_vector, 'nearest');
resampled_RR_pchip = interp1(filtered_RR_time, filtered_RR_smooth, new_time_vector, 'pchip');


%% Assign mouse number to RR

new_fs_RR_392 = new_fs;
new_time_vector_392 = new_time_vector;
resampled_RR_pchip_392 = resampled_RR_pchip;


%% HRB calculation

[HRB, HRB_time] = findHRB(new_time_vector, resampled_RR_pchip);

%% 
% Your initial plot code (assuming it's already executed)
figure;
plot_sleep(new_time_vector, resampled_RR_pchip, sleepscore_time, wake_woMA_binary_vector_124, sws_binary_vector_124, REM_binary_vector_124, MA_binary_vector_124);
hold on;
scatter(HRB_time, HRB, 'b', 'filled'); % Plotting HRB
xlabel('Time (s)');
ylabel('RR intervals');
title('HRV p-chip (M124)');
grid on;

% Adding vertical dashed lines for each trough variable
% NREMexclMA_periods_pklocs_124 in black
for i = 1:length(NREMexclMA_periods_pklocs_124)
    xline(NREMexclMA_periods_pklocs_124(i), '--', 'Color', 'k');
end

% SWS_before_MA_pklocs_124 in yellow
for i = 1:length(SWS_before_MA_pklocs_124)
    xline(SWS_before_MA_pklocs_124(i), '--', 'Color', 'y');
end

% SWS_before_wake_pklocs_124 in blue
for i = 1:length(SWS_before_wake_pklocs_124)
    xline(SWS_before_wake_pklocs_124(i), '--', 'Color', 'b');
end

% REM_before_wake_pklocs_124 in white
for i = 1:length(REM_before_wake_pklocs_124)
    xline(REM_before_wake_pklocs_124(i), '--', 'Color', 'w');
end

hold off; % Release the plot for further commands

%% 


%Input which RR it should be based on
time = new_time_vector;
RR_data = resampled_RR_pchip;

% Assuming filtered_RR and filtered_RR_time are given (if these are your
% standard variables)
% Average heart rate for mice
average_mouse_HR = 600; % BPM

% Human window in minutes
human_window_minutes = 3;

% Calculate the equivalent mouse window in seconds
% First, find how many minutes it takes for 240 beats at 600 BPM
mouse_window_minutes = (3 * 80) / average_mouse_HR; % This is the duration in minutes for the mouse to have 240 beats
mouse_window_seconds = mouse_window_minutes * 60; % Convert minutes to seconds

% Initialize HRB and HRB_time
HRB = [];
HRB_time = [];

for i = 1:mouse_window_seconds:length(time)
    window_end = min(i + mouse_window_seconds - 1, length(time));
    window_RR = RR_data(i:window_end);
    window_RR_time = time(i:window_end);

    % Calculate the mean and standard deviation for the current window
    mean_RR_window = mean(window_RR);
    std_RR_window = std(window_RR);

    % Find local minima in the window
    localMinima = islocalmin(window_RR);
    minimaValues = window_RR(localMinima);
    minimaIndices = find(localMinima);
    minimaTimes = window_RR_time(localMinima);

    % Filter minima based on criteria
    criteriaIndices = minimaValues < mean_RR_window - 1.5 * std_RR_window;
    filteredMinimaValues = minimaValues(criteriaIndices);
    filteredMinimaTimes = minimaTimes(criteriaIndices);

    % Check if there are any minima that meet the criteria
    if ~isempty(filteredMinimaValues)
        % Find the minimal trough
        [min_val, min_criteria_idx] = min(filteredMinimaValues);
        min_time = filteredMinimaTimes(min_criteria_idx);

        % Store the minimal trough value and its corresponding time
        HRB = [HRB, min_val];
        HRB_time = [HRB_time, min_time];
    end
end

% Initialize new arrays for filtered HRB and HRB_time
filtered_HRB = [];
filtered_HRB_time = [];

% Iterate through HRB events
i = 1;
while i <= length(HRB_time)
    % Check if the next event is within 10 seconds
    if i < length(HRB_time) && (HRB_time(i + 1) - HRB_time(i) < 15)
        % Compare the R-R intervals and keep the one with the lower value
        if HRB(i) < HRB(i + 1)
            filtered_HRB = [filtered_HRB, HRB(i)];
            filtered_HRB_time = [filtered_HRB_time, HRB_time(i)];
        else
            filtered_HRB = [filtered_HRB, HRB(i + 1)];
            filtered_HRB_time = [filtered_HRB_time, HRB_time(i + 1)];
        end
        % Skip the next event as it has already been compared
        i = i + 2;
    else
        % Keep the current event
        filtered_HRB = [filtered_HRB, HRB(i)];
        filtered_HRB_time = [filtered_HRB_time, HRB_time(i)];
        i = i + 1;
    end
end

% Replace the original HRB and HRB_time with the filtered ones
HRB = filtered_HRB;
HRB_time = filtered_HRB_time;

%% plot HRB
sleepscore_time_cut = 0:length(wake_woMA_binary_vector_cut )-1; % should be same length for wake/sws/REM

% figure;
% plot_sleep(new_time_vector, resampled_RR, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
% hold on;
% plot(HRB_time, HRB, 'ro', 'MarkerFaceColor', 'g', 'MarkerSize', 4);
% xlabel('time (s)');
% ylabel('RR-intervals');
% title('HRV 64hz cubic spline');
% grid on;

% Plotting peaks
figure;

% Plot the original RR signal against resampled
subplot(4,1,1);
plot_sleep(new_time_vector, resampled_RR_nearest, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
hold on;
scatter(HRB_time, HRB, 'y', 'filled'); % Plotting movement peaks in yellow
xlabel('Time (s)');
ylabel('RR intervals');
title('HRV 64hz Nearest neighbor');
grid on;

% Plot the filtered EMG signal with selected peaks
subplot(4,1,2);
plot_sleep(new_time_vector, resampled_RR_pchip, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
hold on;
scatter(HRB_time, HRB, 'y', 'filled'); % Plotting movement peaks in yellow
xlabel('Time (s)');
ylabel('RR intervals');
title('HRV 64hz Shape-preserving piecewise cubic interpolation (pchip)');
grid on;

% Plot the filtered EMG signal with selected peaks
subplot(4,1,3);
plot_sleep(new_time_vector, resampled_RR_linear, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
hold on;
scatter(HRB_time, HRB, 'y', 'filled'); % Plotting movement peaks in yellow
xlabel('Time (s)');
ylabel('RR intervals');
title('HRV 64 hz Linear');
grid on;

% Plot the filtered EMG signal with selected peaks
subplot(4,1,4);
plot_sleep(filtered_RR_time, filtered_RR_smooth, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
hold on;
scatter(HRB_time, HRB, 'y', 'filled'); % Plotting movement peaks in yellow
xlabel('Time (s)');
ylabel('RR intervals');
title('HRV (un-resampled)');
grid on;
linkaxes([subplot(4,1,1), subplot(4,1,2), subplot(4,1,3), subplot(4,1,4)], 'x');



%% Plot NE, EMG, EEG and HRV for exloration

sleepscore_time_cut = 0:length(wake_woMA_binary_vector_cut )-1; % should be same length for wake/sws/REM

% Plot for determining RR look

figure;

a = subplot(4, 1, 1);
    plot_sleep(ds_sec_signal_2, ds_delta465_filt_2, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
    title('Norepinephrine');
    xlabel('time (s)');
    ylabel('NE (V)');
    grid on;

% Plot the original EMG signal
b = subplot(4, 1, 2);
    plot_sleep(sec_signal_EMG, filtered_EMG, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
    hold on;
    %scatter(movement_sec, movement, 'y', 'filled'); % Plotting movement peaks in yellow
    %line([min(sec_signal_EMG), max(sec_signal_EMG)], [threshold, threshold], 'Color', 'g', 'LineStyle', '--');

% Plot the filtered EMG signal with selected peaks
    plot(sec_signal_EMG, filtered_EMG, 'b-', sec_signal_EMG(selected_peak_locs), selected_peaks, 'ro');

% Adding RR_time on the plot
    %scatter(RR_time, zeros(size(RR_time)), 'kx', 'LineWidth', 2); % Plotting RR_time at y=0

    xlabel('time (s)');
    ylabel('EMG (V)');
    title('EMG with Selected Peaks');
    grid on;

c = subplot(4,1,3);
    plot_sleep(sec_signal_EEG, EEG, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
    xlabel('time (s)');
    ylabel('EEG (V)');
    title('EEG');
    grid on;

d = subplot(4,1,4);
    plot_sleep(filtered_RR_time, filtered_RR_smooth, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut,MA_binary_vector_cut);
    xlabel('time (s)');
    ylabel('RR-intervals');
    title('HRV')
    grid on;

% Add markers for negative peaks
    % hold on;
    % scatter(filtered_RR_time(negative_peaks_RR_time), negative_peaks_RR, 'g', '*', 'MarkerEdgeColor', 'k');


% Linking axes for synchronized zooming
linkaxes([a, b, c, d], 'x');


%% Power analysis

% Assuming EEG, sec_signal_EEG, and EEG_fs are defined in your workspace
Data_EEG = EEG; % EEG data vector
power_bands = {[0.5, 1], [1, 4], [4, 8], [8, 15], [15, 30]}; % define SO, delta, theta, sigma, and beta, respectively

frw = 0:0.2:30;
frq = EEG_fs; % sampling frequency of EEG data
window = 1; % sec. 1 for 30 sec

% Compute spectrogram
[transition_spectrogram, F, T] = spectrogram(Data_EEG, round(frq * window), [], frw, frq, 'yaxis');
mean_spectrogram = log(abs(transition_spectrogram));

% Handle potential -Inf values
small_positive_value = 1e-10;
mean_spectrogram(isinf(mean_spectrogram)) = small_positive_value;

time_spectrogram_zero = T;

% Create a Gaussian filter manually
sigma = 1; % Adjust the sigma as needed
filter_size = 5; % Adjust the size as needed
gaussian_filter = exp(-(1:filter_size).^2 / (2 * sigma^2));
gaussian_filter = gaussian_filter / sum(gaussian_filter);

% Use conv to apply the filter
filtered_mean_spectrogram = conv2(mean_spectrogram, gaussian_filter, 'same');

% % Continue with plotting or further analysis
% figure();
% imagesc(time_spectrogram_zero, F, filtered_mean_spectrogram);
% set(gca, 'YDir', 'normal');
% ylim([0, 30]);
% caxis([-6.7, -4]);
% colormap(gca, 'parula');
% title('Spectrogram');
% xlabel('time (s)');
% ylabel('freq (Hz)');

%% Determine transition phases in sleep 

% Time window in seconds before transition
time_window = 10; % seconds
time_window_REM = 20;

% Creating one vector with different behaviors represented by unique
% numbers (1=wake, 4=sws, 9=REM, 15=MA) at frequency 1Hz
boutscore_vector = zeros([1, round(sec_signal_EEG(end))+200]);

% Here using the aligned "cut" vectors
for i=1:length(wake_woMA_onset_cut)
    t = wake_woMA_onset_cut(i)+1;
    d = wake_woMA_duration_cut(i)-1;
    boutscore_vector(t:t+d) = 1; % wake=1
end

for i=1:length(sws_onset_cut)
    t = sws_onset_cut(i)+1;
    d = sws_duration_cut(i)-1;
    boutscore_vector(t:t+d) = 4; % sws=4
end

for i=1:length(REM_onset_cut)
    t = REM_onset_cut(i)+1;
    d = REM_duration_cut(i)-1;
    boutscore_vector(t:t+d) = 9; %REM=9
end

for i=1:length(MA_onset_cut)
    t = MA_onset_cut(i)+1;
    d = MA_duration_cut(i)-1;
    boutscore_vector(t:t+d) = 15; %MA=15
end

% Vectors indicate time of transitions in seconds
transition_sws_wake =  find(diff(boutscore_vector)== -3);
transition_wake_sws =  find(diff(boutscore_vector)== 3);
transition_REM_wake =  find(diff(boutscore_vector)== -8);
transition_sws_MA =  find(diff(boutscore_vector)== 11);
transition_REM_sws =  find(diff(boutscore_vector)== -5);
transition_sws_REM =  find(diff(boutscore_vector)== 5);
transition_REM_MA =  find(diff(boutscore_vector)== 6);

% Calculate the total duration of the signal
totalDuration = length(boutscore_vector);

% Identify periods before transitions
SWS_before_MA_periods = findPeriodsBeforeTransition(transition_sws_MA, time_window, totalDuration);
SWS_before_wake_periods = findPeriodsBeforeTransition(transition_sws_wake, time_window, totalDuration);
SWS_before_REM_periods = findPeriodsBeforeTransition(transition_sws_REM, time_window_REM, totalDuration);
REM_before_wake_periods = findPeriodsBeforeTransition(transition_REM_wake, time_window, totalDuration);

% Filter the identified periods to ensure they are within actual SWS periods
SWS_before_MA_filtered = filterSWSPeriods(SWS_before_MA_periods, NREMinclMA_periods_cut);
SWS_before_wake_filtered = filterSWSPeriods(SWS_before_wake_periods, NREMinclMA_periods_cut);
SWS_before_REM_filtered = filterSWSPeriods(SWS_before_REM_periods, NREMinclMA_periods_cut);
REM_before_wake_filtered = filterSWSPeriods(REM_before_wake_periods, REM_periods_cut);

%% Define NREMexclMA_periods_cut
% Set the exclusion interval in seconds
exclusion_interval = 10;

% Initialize NREMexclMA_periods_cut
NREMexclMA_periods_cut = [];

% Using boutscore_vector to identify SWS periods excluding MAs
for i = 1:length(sws_onset_cut)
    current_onset = sws_onset_cut(i);
    current_offset = sws_offset_cut(i);
    
    % Check for any transition to MA within this period and adjust the offset accordingly
    transition_to_MA_within_period = transition_sws_MA(transition_sws_MA >= current_onset & transition_sws_MA < current_offset);
    
    if ~isempty(transition_to_MA_within_period)
        % If there's a transition to MA, adjust the period to end before the exclusion interval
        for j = 1:length(transition_to_MA_within_period)
            transition_point = transition_to_MA_within_period(j);
            adjusted_offset = transition_point - exclusion_interval;
            
            % Only add the period if the adjusted offset is after the onset
            if adjusted_offset > current_onset
                NREMexclMA_periods_cut = [NREMexclMA_periods_cut; [current_onset, adjusted_offset]];
            end
            
            % Adjust the onset for the next period to be after the current transition, if applicable
            current_onset = transition_point + 1;
        end
    else
        % If no transitions to MA, add the period as is
        NREMexclMA_periods_cut = [NREMexclMA_periods_cut; [current_onset, current_offset]];
    end
end

REM_lead_up = [];
for i = 1:length(REM_onset_cut)
    REM_start = max(1, REM_onset_cut(i) - exclusion_interval);
    REM_end = REM_onset_cut(i) + REM_duration_cut(i) - 1;
    REM_lead_up = [REM_lead_up; [REM_start, REM_end]];
end

wake_lead_up = [];
for i = 1:length(wake_onset_cut)
    wake_start = max(1, wake_onset_cut(i) - exclusion_interval);
    wake_end = wake_onset_cut(i) + wake_duration_cut(i) - 1;
    wake_lead_up = [wake_lead_up; [wake_start, wake_end]];
end

% Use the function to remove overlaps from NREMexclMA_periods_cut
NREMexclMA_periods_cut = removeOverlaps(NREMexclMA_periods_cut, REM_lead_up);
NREMexclMA_periods_cut = removeOverlaps(NREMexclMA_periods_cut, wake_lead_up);

%% Devide the 4 sleep phase variables into the hours in which they occured

% Assuming startTimeNextHour and endTimePreviousHour are defined as before
hoursList = startTimeNextHour:hours(1):endTimePreviousHour;
secSignalHours = hours(hoursList - startTimeNextHour) * 3600; % Convert hours to seconds

% Example call for the REM_periods_cut variable
NREMinclMA_periods_cut_hourlySegments = segmentSleepDataIntoHours(NREMinclMA_periods_cut, secSignalHours, startTimeNextHour);
NREMexclMA_periods_cut_hourlySegments = segmentSleepDataIntoHours(NREMexclMA_periods_cut, secSignalHours, startTimeNextHour);
REM_hourlySegments = segmentSleepDataIntoHours(REM_periods_cut, secSignalHours, startTimeNextHour);
wake_hourlySegments = segmentSleepDataIntoHours(wake_periods_cut, secSignalHours, startTimeNextHour);

%% Get NE troughs for (transition) sleep periods
%Takes the peak values from each time interval

NREMinclMA_periods_cut_pklocs = find_NE_troughs(NREMinclMA_periods_cut, signal_fs, delta465_filt_2, sec_signal_2, 0.3);
REM_periods_cut_pklocs = find_NE_troughs(REM_periods_cut, signal_fs, delta465_filt_2, sec_signal_2, 0.5);
NREMexclMA_periods_cut_pklocs = find_NE_troughs(NREMexclMA_periods_124, signal_fs_124, delta465_filt_2_124, sec_signal_2_124, 1); % Change SD multiplyer to 1 for more selective troughs
wake_periods_cut_pklocs = find_NE_troughs(wake_woMA_periods_cut, signal_fs, delta465_filt_2, sec_signal_2, 0.3);
SWS_before_MA_filtered_pklocs = findPeriodsBeforeTransitionMA(SWS_before_MA_filtered_124, signal_fs_124, delta465_filt_2_124, sec_signal_2_124, MA_periods_124, 15);
SWS_before_wake_filtered_pklocs = find_NE_troughs_transistions(SWS_before_wake_filtered, signal_fs, delta465_filt_2, sec_signal_2, 0.3);
SWS_before_REM_filtered_pklocs = find_NE_troughs_transistions(SWS_before_REM_filtered, signal_fs, delta465_filt_2, sec_signal_2, 0.3);
REM_before_wake_filtered_pklocs = find_NE_troughs_transistions(REM_before_wake_filtered, signal_fs, delta465_filt_2, sec_signal_2, 0.3);
 
%% visualize NE troughs (plocs_all)
    sleepscore_time = 0:length(wake_woMA_binary_vector_124)-1; % Assuming all vectors are the same length

figure
plot_sleep(ds_sec_signal_2_124, ds_delta465_filt_2_124, sleepscore_time, wake_woMA_binary_vector_124, sws_binary_vector_124, REM_binary_vector_124, MA_binary_vector_124);
hold on
plot(SWS_before_MA_filtered_pklocs, delta465_filt_2_124(round(SWS_before_MA_filtered_pklocs*signal_fs)), 'r*')
title('NE with selected peaks');
%}
%pklocs_all has all the peaks (which really are dips/valleys)

%% Sanity check: NE trough plots for different sleep stages
% Assuming delta465_filt_2 is your NE data and sec_signal_2 contains timestamps
% signal_fs is the sampling frequency for NE data

% Assuming delta465_filt_2 is your NE data and sec_signal_2 contains timestamps
% signal_fs is the sampling frequency for NE data

pklocs_variables = {NREMexclMA_periods_cut_pklocs, SWS_before_MA_filtered_pklocs, SWS_before_wake_filtered_pklocs, REM_before_wake_filtered_pklocs};
titles = {'NREM', 'NREM to MA Transition', 'NREM to Wake Transition', 'REM to Wake Transition'};
figure; % Create a new figure

for subplot_idx = 1:4
    subplot(2, 2, subplot_idx);
    hold on;
    pklocs = pklocs_variables{subplot_idx};
    event_count = length(pklocs); % Count the number of events for the current sleep stage
    for i = 1:event_count
        pkloc_time = pklocs(i);
        % Find the index of pkloc_time in sec_signal_2
        [~, closest_index] = min(abs(ds_sec_signal_2 - pkloc_time)); % Corrected variable names
        start_index = max(1, closest_index - round(30 * signal_fs));
        end_index = min(length(ds_delta465_filt_2), closest_index + round(60 * signal_fs));
        
        % Extract and plot the NE trace for this event
        plot(ds_sec_signal_2(start_index:end_index) - ds_sec_signal_2(closest_index), ds_delta465_filt_2(start_index:end_index));
    end
    % Update title to include the number of events
    title([titles{subplot_idx}, ' (', num2str(event_count), ' Events)']);
    xlabel('Time (s)');
    ylabel('NE Activity');
    xlim([-30, 60]); % 30 seconds before to 60 seconds after the event
    hold off;
end

% Enhance plot readability
sgtitle('NE Activity around Troughs');

%% Sanity check: RR during HRB event plots for different sleep stages
% Define sleep stages and their periods
sleep_stages = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};
sleep_stage_periods = {NREMexclMA_periods_cut, NREMinclMA_periods_cut, wake_periods_cut, REM_periods_cut};

% Prepare figure
figure;
sgtitle('RR Values around HRB Events by Sleep Stage');

% Iterate over each sleep stage
for stage_idx = 1:length(sleep_stages)
    % Initialize counter for HRB events in the current sleep stage
    HRB_count = 0;

    % Current sleep stage periods
    current_stage_periods = sleep_stage_periods{stage_idx};

    % Iterate over each HRB event to count relevant events first
    for event_idx = 1:length(HRB)
        HRB_event_time = HRB_time(event_idx);

        % Check if HRB event falls within current sleep stage
        for period_idx = 1:size(current_stage_periods, 1)
            period_start = current_stage_periods(period_idx, 1);
            period_end = current_stage_periods(period_idx, 2);

            % Check if event is within the period
            if HRB_event_time >= period_start && HRB_event_time <= period_end
                HRB_count = HRB_count + 1; % Increment the HRB counter for the sleep stage
                break; % Break the loop once the event is counted
            end
        end
    end

    % Plot settings for current sleep stage
    subplot(2, 2, stage_idx);
    hold on;
    title([sleep_stages{stage_idx}, ' (', num2str(HRB_count), ' Events)']); % Include number of events in title

    % Repeat the iteration for plotting
    for event_idx = 1:length(HRB)
        HRB_event_time = HRB_time(event_idx);

        % Check if HRB event falls within current sleep stage again for plotting
        for period_idx = 1:size(current_stage_periods, 1)
            period_start = current_stage_periods(period_idx, 1);
            period_end = current_stage_periods(period_idx, 2);

            % Check if event is within the period for plotting
            if HRB_event_time >= period_start && HRB_event_time <= period_end
                window_start = HRB_event_time - 30;
                window_end = HRB_event_time + 60;

                % Find indices of RR values within the window
                indices = find(filtered_RR_time >= window_start & filtered_RR_time <= window_end);

                if ~isempty(indices)
                    plot(filtered_RR_time(indices) - HRB_event_time, filtered_RR(indices), 'DisplayName', ['Event ' num2str(event_idx)]);
                end

                break; % No need to check other periods for plotting once matched
            end
        end
    end
    
    xlabel('Time (s)');
    ylabel('RR Values');
    xlim([-30, 60]);
    legend('hide'); % Optionally hide legend if it's too cluttered
    hold off;
end

linkaxes(findobj(gcf, 'Type', 'Axes'), 'x'); % Sync x-axis across subplots


%% Plot power analysis with NE, EMG and HRV
sleepscore_time_cut = 0:length(wake_woMA_binary_vector_cut )-1; % should be same length for wake/sws/REM

 NE_sws_Trunk_Timestamps = NREMexclMA_periods_cut_pklocs;
 NE_sws_MA_Trunk_Timestamps = NREMinclMA_periods_cut_pklocs;
 RR_PeakTimestamps = HRB_time;
 RR_sws_MA_PeakTimestamps = HRB_NREM_time

allPeakTimestamps = HRB_time;

%Plotting the power bands with the RR-intervals and NE
figure();

% Subplot for NE
a = subplot(4, 1, 1);
plot_sleep(ds_sec_signal_2, ds_delta465_filt_2, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut, MA_binary_vector_cut);
hold on;
%plot(NE_sws_MA_Trunk_Timestamps, ds_delta465_filt_2(NE_sws_MA_Trunk_Timestamps), 'ro', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
xlabel('time (s)');
ylabel('NE');
title('NE');
grid on;

% Subplot for EEG
b = subplot(4, 1, 2);
plot_sleep(sec_signal_EEG, EEG, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut, MA_binary_vector_cut);
hold on;
xlabel('time (s)');
ylabel('Amplitude (V)');
title('EEG');
grid on;

% Subplot for EEG power bands
c = subplot(4, 1, 3);
band_power_collector = [T];
offset_increment = 2; % Set an appropriate offset increment
offset = 0; % Initialize offset

for band_i = 1:length(power_bands)
    power_band = power_bands{band_i};
    power_trace = mean(mean_spectrogram(find(F >= power_band(1) & F <= power_band(2)), :), 1);
    normalized_power_trace = power_trace + offset; % Apply offset
    band_power_collector = [band_power_collector; normalized_power_trace];
    plot(time_spectrogram_zero, normalized_power_trace);
    hold on;
    offset = offset + offset_increment; % Update offset for the next band
end

title('EEG Power Bands');
ylabel('Power');

% Separate loop for adding vertical lines
for i = 1:numel(allPeakTimestamps)
    subplot(4, 1, 1);
    hold on;
    plot([allPeakTimestamps(i), allPeakTimestamps(i)], ylim, 'r--', 'LineWidth', 0.01);

    subplot(4, 1, 2);
    hold on;
    plot([allPeakTimestamps(i), allPeakTimestamps(i)], ylim, 'r--', 'LineWidth', 0.01);

    subplot(4, 1, 3);
    hold on;
    plot([allPeakTimestamps(i), allPeakTimestamps(i)], ylim, 'r--', 'LineWidth', 0.01);
end

% Update Legend for EEG Power Bands
legend({'SO', 'delta', 'theta', 'sigma', 'beta'});

% Subplot for HRB
d = subplot(4, 1, 4);
plot_sleep(filtered_RR_time, filtered_RR_smooth, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut, MA_binary_vector_cut);
hold on;
plot(HRB_NREM_time, HRB_NREM, 'ro', 'MarkerFaceColor', 'g', 'MarkerSize', 2);
xlabel('time (s)');
ylabel('RR-intervals');
title('HRV');
grid on;

for i = 1:numel(allPeakTimestamps)
    subplot(4, 1, 4);
    hold on;
    plot([allPeakTimestamps(i), allPeakTimestamps(i)], ylim, 'r--', 'LineWidth', 0.01);
end

% Linking axes for synchronized zooming
linkaxes([a, b, c, d], 'x');



%% Get time averaged plot for events for 60 sec after

% variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time, REM_periods_cut_HRB_time, NREMexclMA_periods_cut_pklocs, NREMinclMA_periods_cut_pklocs, wake_periods_cut_pklocs, REM_periods_cut_pklocs};
% titles = {'HRB NREM excl MA', 'HRB NREM incl MA', 'HRB Wake', 'HRB REM', 'NE troughs NREM excl MA', 'NE troughs NREM incl MA', 'NE troughs Wake', 'NE troughs REM'};

pklocs_variables = {NREMexclMA_periods_cut_pklocs, SWS_before_MA_filtered_pklocs, SWS_before_wake_filtered_pklocs, REM_before_wake_filtered_pklocs};
titles = {'NREM', 'NREM to MA Transition', 'NREM to Wake Transition', 'REM to Wake Transition'};

power_bands = {[0.5, 1], [1, 4], [4, 8], [8, 15], [15, 30]}; % define SO, delta, theta, sigma, and beta, respectively

for idx = 1:length(pklocs_variables)
    % Correctly assign the current event set from variables
    event_type = pklocs_variables{idx};
    
    % Update event_name to reflect the current title and number of events
    event_name = sprintf('%s - %d events', titles{idx}, length(event_type));
    
    % Calculate RR intervals from the filtered_RR_time data
    RR_time_diff = diff(filtered_RR_time);
    
    % Compute the median of these intervals to find the average interval
    average_RR_time_interval = median(RR_time_diff);
    
    % Sampling frequencies
    NE_fs = signal_fs; % for fiber photometry
    EMG_fs = EEG_fs; % for EMG and EEG
    EEG_bands_fs = length(T)/T(end); % for EEG bands
    RR_fs = 1 / average_RR_time_interval;
    
    % Define epoch start and end times
    epoc_start = 30; % seconds before event
    % Update epoch end time to 60 seconds
    epoc_end = 60;
    epoch_duration_samples = round((epoc_start + epoc_end) * EEG_fs); % Total samples in the epoch
    
    % Calculate the length of the epochs
    max_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);
    total_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);
    mid_point = ceil(epoc_start * RR_fs);  % This should be the index of the event time
    
    % Re-initialize epoc_FPtime_EEG with the correct number of points
    %epoc_FPtime_EEG = linspace(-epoc_start, epoc_end, points_per_epoch);
    % Update the time vectors for all signals based on new epoch lengths
    epoc_FPtime_NE = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * NE_fs));
    %epoc_FPtime_EMG = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EMG_fs));
    %epoc_FPtime_EEG = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EEG_fs));
    epoc_FPtime_EEG = linspace(-epoc_start, epoc_end, epoch_duration_samples);
    epoc_FPtime_EEG_bands = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EEG_bands_fs));
    epoc_FPtime_RR = linspace(-epoc_start, epoc_end, max_epoch_length);
    
    % Number of points per epoch
    num_points_per_epoch = length(epoc_FPtime_EEG);
    
    % Initialize collectors for each signal
    NE_peak_epoc_collector = [];
    EEG_collector = NaN(epoch_duration_samples, length(event_type));  % Initialize with NaNs
    SO_collector = [];
    Delta_collector = [];
    Theta_collector = [];
    Sigma_collector = [];
    Beta_collector = [];
    RR_collector = NaN(total_epoch_length, length(event_type));
    
    % Extract power for specified bands
    band_powers = cell(1, length(power_bands));
    for b = 1:length(power_bands)
        freq_range = power_bands{b};
        band_powers{b} = mean(mean_spectrogram(F >= freq_range(1) & F <= freq_range(2), :), 1);
    end
    
    % Loop through events and extract epochs for each signal
    for i = 1:length(event_type)
        NEpk_i = event_type(i);
        if NEpk_i > sec_signal_2(end) - epoc_end % skip if event is too close to end of recording
            continue
        end
            % Ensure the event is within bounds to have a full epoch
        if NEpk_i < filtered_RR_time(1) + epoc_start || NEpk_i > filtered_RR_time(end) - epoc_end
            disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
            continue;  % Skip this event
        end
    
        % Find the index of the HRB event in filtered_RR_time
        % Find the index of the event in filtered_RR_time
        [~, event_idx] = min(abs(filtered_RR_time - NEpk_i));
    
        % Calculate the range of indices for the epoch
        epoch_start_idx = max(event_idx - mid_point + 1, 1);
        epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(filtered_RR_smooth));
    
        % Extract and assign epoch data to RR_collector, ensuring not to exceed its bounds
        epoch_data_length = epoch_end_idx - epoch_start_idx + 1;
        
        % Check if epoch_data_length matches expected total_epoch_length
        if epoch_data_length == total_epoch_length
            RR_collector(1:total_epoch_length, i) = filtered_RR_smooth(epoch_start_idx:epoch_end_idx);
        else
            disp(['Event ', num2str(i), ' epoch data length mismatch: ', num2str(epoch_data_length)]);
            % Fill with NaNs or adjust logic as needed
            RR_collector(1:epoch_data_length, i) = filtered_RR_smooth(epoch_start_idx:epoch_end_idx);
        end
        % Extract NE epochs
        NEpk_epoc_i = delta465_filt_2((NEpk_i - epoc_start) * NE_fs : (NEpk_i + epoc_end) * NE_fs);
        NE_peak_epoc_collector = [NE_peak_epoc_collector; NEpk_epoc_i];
        
        % Calculate the event's index based on its time and EEG_fs
        event_time_sec = event_type(i);
        event_index = round(event_time_sec * EEG_fs);
    
        % Calculate start and end indices for the epoch
        start_idx = max(1, event_index - round(epoc_start * EEG_fs));
        end_idx = min(length(EEG), start_idx + epoch_duration_samples - 1);  % Ensure the epoch doesn't exceed EEG length
    
        % Extract epoch
        epoch_data = EEG(start_idx:end_idx);
        
        % If the extracted epoch is shorter than expected, pad the end with NaNs
        if length(epoch_data) < epoch_duration_samples
            epoch_data = [epoch_data; NaN(epoch_duration_samples - length(epoch_data), 1)];  % Pad with NaNs
        end
    
        % Store the epoch
        EEG_collector(:, i) = epoch_data;
        
        % Extract epochs for EEG bands
        for b = 1:length(band_powers)
            EEG_band_epoc_i = band_powers{b}(:, (NEpk_i - epoc_start)*EEG_bands_fs:(NEpk_i + epoc_end)*EEG_bands_fs);
            switch b
                case 1
                    SO_collector = [SO_collector; EEG_band_epoc_i];
                case 2
                    Delta_collector = [Delta_collector; EEG_band_epoc_i];
                case 3
                    Theta_collector = [Theta_collector; EEG_band_epoc_i];
                case 4
                    Sigma_collector = [Sigma_collector; EEG_band_epoc_i];
                case 5
                    Beta_collector = [Beta_collector; EEG_band_epoc_i];
            end
        end
    end
    
    % Calculate mean of epochs for each signal using nanmean
    mean_NEpk_epocs = nanmean(NE_peak_epoc_collector, 1);
    mean_EEGpk_epocs = nanmean(EEG_collector, 2);
    mean_SO_pk_epocs = nanmean(SO_collector, 1);
    mean_Delta_pk_epocs = nanmean(Delta_collector, 1);
    mean_Theta_pk_epocs = nanmean(Theta_collector, 1);
    mean_Sigma_pk_epocs = nanmean(Sigma_collector, 1);
    mean_Beta_pk_epocs = nanmean(Beta_collector, 1);
    mean_filtered_RR_epocs = nanmean(RR_collector, 2);
    
    % Verify the output length matches the expected number of points
    disp(['Length of mean_EEGpk_epocs: ', num2str(length(mean_EEGpk_epocs))]);
    
    % Create subplots
    figure;
    
    % Subplot for NE
    subplot(4, 1, 1);
    plot(epoc_FPtime_NE, mean_NEpk_epocs);
    title(['NE during ' event_name]);
    line([0 0], ylim, 'Color', 'r', 'LineStyle', '--'); % Add vertical line at 0-timepoint
    
    % Subplot for EEG
    subplot(4, 1, 2);
    % Plotting
    plot(epoc_FPtime_EEG, mean_EEGpk_epocs);
    title(['EEG during ' event_name]);
    line([0 0], ylim, 'Color', 'r', 'LineStyle', '--'); % Add vertical line at 0-timepoint
    
    % Subplot for EEG bands
    subplot(4, 1, 3);
    hold on;
    offset = 0; % Initialize offset
    offset_increment = 0; % Define the offset increment
    % Plot each band with an offset
    plot(epoc_FPtime_EEG_bands, mean_SO_pk_epocs + offset, 'DisplayName', 'SO');
    offset = offset + offset_increment;
    plot(epoc_FPtime_EEG_bands, mean_Delta_pk_epocs + offset, 'DisplayName', 'Delta');
    offset = offset + offset_increment;
    plot(epoc_FPtime_EEG_bands, mean_Theta_pk_epocs + offset, 'DisplayName', 'Theta');
    offset = offset + offset_increment;
    plot(epoc_FPtime_EEG_bands, mean_Sigma_pk_epocs + offset, 'DisplayName', 'Sigma');
    offset = offset + offset_increment;
    plot(epoc_FPtime_EEG_bands, mean_Beta_pk_epocs + offset, 'DisplayName', 'Beta');
    title(['EEG Bands during ' event_name]);
    % Update Legend for EEG Power Bands
    line([0 0], ylim, 'Color', 'r', 'LineStyle', '--'); % Add vertical line at 0-timepoint
    legend({'SO', 'delta', 'theta', 'sigma', 'beta'});
    
    % Generate the time vector for the epochs, centered at 0
    epoc_time_vector_RR = ((1:total_epoch_length) - mid_point) / RR_fs;
    
    % Make sure the mean vector and time vector are of the same length
    if length(mean_filtered_RR_epocs) ~= length(epoc_time_vector_RR)
        if length(mean_filtered_RR_epocs) == length(epoc_time_vector_RR) + 1
            % If mean vector has one extra element, trim the last element
            mean_filtered_RR_epocs(end) = [];
        else
            % If there's a larger discrepancy, throw an error or warning
            error('The lengths of time vector and mean vector do not match.');
        end
    end
    
    % Now you can safely plot the data
    subplot(4, 1, 4);
    plot(epoc_time_vector_RR, mean_filtered_RR_epocs);
    title(['HRV during ' event_name]);
    line([0 0], ylim, 'Color', 'r', 'LineStyle', '--'); % Add vertical line at 0-timepoint
    xlabel('Time (s)');
    ylabel('RR interval');
    
    linkaxes([subplot(4, 1, 1), subplot(4, 1, 2), subplot(4, 1, 3), subplot(4, 1, 4)], 'x');
end
%% MAIN PLOT- Get time averaged plot NE and EEG 60 sec after

% Sampling frequencies and epoch definitions
NE_fs = signal_fs; % for fiber photometry
EEG_bands_fs = length(T)/T(end); % for EEG bands
RR_fs = new_fs;
RR = resampled_RR_pchip;
RR_time = new_time_vector;
epoc_start = 30; % seconds before event
epoc_end = 60; % seconds after event
max_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);

power_bands = {[0.5, 1], [1, 4], [4, 8], [8, 15], [15, 30]}; % define SO, delta, theta, sigma, and beta, respectively

% Sleep stage variables and titles
event_var = {NREMexclMA_periods_cut_pklocs, NREMinclMA_periods_cut_pklocs, wake_periods_cut_pklocs, REM_periods_cut_pklocs};
%titles = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};
%main_title = 'Averaged Activity During NE Troughs';

% pklocs_variables = {NREMexclMA_periods_cut_pklocs, SWS_before_MA_filtered_pklocs, SWS_before_wake_filtered_pklocs, REM_before_wake_filtered_pklocs};
% titles = {'NREM', 'NREM to MA Transition', 'NREM to Wake Transition', 'REM to Wake Transition'};

%HRB_variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time, REM_periods_cut_HRB_time};
titles = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};
main_title = 'Averaged Activity During HRB';

%Add in the time variable for plotting
epoc_FPtime_NE = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * NE_fs));
epoc_FPtime_EEG_bands = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EEG_bands_fs));
epoc_FPtime_RR = linspace(-epoc_start, epoc_end, max_epoch_length);

% Initialize the figure
figure;

% Iterate over each sleep stage and its NE trough variables
for stage_idx = 1:length(event_var)
    event_type = event_var{stage_idx}; % Select the current event type
    event_name = titles{stage_idx}; % Current event name for titles
    num_events = length(event_type); % Number of events for the current sleep stage
    
    % Resetting collectors for each sleep stage
    NE_peak_epoc_collector = [];
    SO_collector = [];
    Delta_collector = [];
    Theta_collector = [];
    Sigma_collector = [];
    Beta_collector = [];

        % Extract power for specified bands
    band_powers = cell(1, length(power_bands));
    for b = 1:length(power_bands)
        freq_range = power_bands{b};
        band_powers{b} = mean(mean_spectrogram(F >= freq_range(1) & F <= freq_range(2), :), 1);
    end

    % Extract NE and EEG band epochs for the current sleep stage
    for i = 1:length(event_type)
        NEpk_i = event_type(i);
        if NEpk_i > sec_signal_2(end) - epoc_end % Skip if event is too close to end of recording
            continue;
        end
        
        % Extract NE epochs
        NEpk_epoc_i = delta465_filt_2((NEpk_i - epoc_start) * NE_fs : (NEpk_i + epoc_end) * NE_fs);
        NE_peak_epoc_collector = [NE_peak_epoc_collector; NEpk_epoc_i];

        HRB_i = event_type(i);
        if HRB_i < RR_time(1) + epoc_start || HRB_i > RR_time(end) - epoc_end
            disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
            continue;  % Skip this event
        end

        [~, event_idx] = min(abs(RR_time - HRB_i));  % Find the event index in filtered_RR_time

        epoch_start_idx = max(event_idx - mid_point + 1, 1);
        epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(RR));

        if epoch_end_idx - epoch_start_idx + 1 <= total_epoch_length
            RR_collector(1:(epoch_end_idx - epoch_start_idx + 1), i) = RR(epoch_start_idx:epoch_end_idx);
        end

        
        % Extract epochs for EEG bands
        for b = 1:length(band_powers)
            EEG_band_epoc_i = band_powers{b}(:, (NEpk_i - epoc_start)*EEG_bands_fs:(NEpk_i + epoc_end)*EEG_bands_fs);
        switch b
            case 1
                SO_collector = [SO_collector; EEG_band_epoc_i];
            case 2
                Delta_collector = [Delta_collector; EEG_band_epoc_i];
            case 3
                Theta_collector = [Theta_collector; EEG_band_epoc_i];
            case 4
                Sigma_collector = [Sigma_collector; EEG_band_epoc_i];
            case 5
                Beta_collector = [Beta_collector; EEG_band_epoc_i];
            end
        end
    end
    

    % Calculate mean of epochs for NE and EEG bands
    mean_NEpk_epocs = nanmean(NE_peak_epoc_collector, 1);
    mean_filtered_RR_epocs = nanmean(RR_collector, 2);
    mean_SO_pk_epocs = nanmean(SO_collector, 1);
    mean_Delta_pk_epocs = nanmean(Delta_collector, 1);
    mean_Theta_pk_epocs = nanmean(Theta_collector, 1);
    mean_Sigma_pk_epocs = nanmean(Sigma_collector, 1);
    mean_Beta_pk_epocs = nanmean(Beta_collector, 1);
    
    % Plotting NE data
    subplot_position_ne = (stage_idx-1)*3 + 1;
    subplot(4, 3, subplot_position_ne);
    hold on;
    plot(epoc_FPtime_NE, mean_NEpk_epocs);
    plot([0 0], ylim, 'r--'); % Red dotted line at timepoint 0
    hold off;
    title([event_name ' NE (' num2str(num_events) ' Events)']); % Including number of events in the title
    ylabel('NE Activity');
    xlim([-30, 60]);

    subplot_idx_RR = subplot_position_ne + 1;  % Odd positions for RR
    subplot(4, 3, subplot_idx_RR);
    plot(epoc_FPtime_RR, mean_filtered_RR_epocs, 'Color', [0.8500 0.3250 0.0980]);
    hold on;
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    hold off;
    title([event_name ' RR interval (' num2str(length(event_type)) ' Events)']);  % Correcting the number of events
    ylabel('RR interval');
    xlim([-30, 60]);

    % Plotting EEG bands data
    subplot_position_eeg = subplot_position_ne + 2;
    subplot(4, 3, subplot_position_eeg);
    hold on;
    plot(epoc_FPtime_EEG_bands, mean_SO_pk_epocs, 'DisplayName', 'SO');
    plot(epoc_FPtime_EEG_bands, mean_Delta_pk_epocs, 'DisplayName', 'Delta');
    plot(epoc_FPtime_EEG_bands, mean_Theta_pk_epocs, 'DisplayName', 'Theta');
    plot(epoc_FPtime_EEG_bands, mean_Sigma_pk_epocs, 'DisplayName', 'Sigma');
    plot(epoc_FPtime_EEG_bands, mean_Beta_pk_epocs, 'DisplayName', 'Beta');
    plot([0 0], ylim, 'r--'); % Red dotted line at timepoint 0
    hold off;
    title([event_name ' EEG Bands (' num2str(length(event_type)) ' Events)']);
    legend({'SO', 'delta', 'theta', 'sigma', 'beta'});
    ylabel('Power');
    xlim([-30, 60]);
    legend;
    set(gcf,'color','white')
    
    % Adjusting the subplot index for column placement
    if stage_idx == 2 % After plotting the second sleep stage, switch to second column
        subplot_base = 4; % Adjusting base for second column
    else
        subplot_base = 0; % Keep base at 0 for first column
    end
end

% Adjust overall plot settings
sgtitle(main_title);

%% Get HRB_time for each sleep stage
% Define sleep stages and their periods
sleep_stages = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};
sleep_stage_periods = {NREMexclMA_periods_cut, NREMinclMA_periods_cut, wake_periods_cut, REM_periods_cut};

% Initialize variables to hold HRB timestamps for each sleep stage
NREMexclMA_periods_cut_HRB_time = [];
NREMinclMA_periods_cut_HRB_time = [];
wake_periods_cut_HRB_time = [];
REM_periods_cut_HRB_time = [];

% Prepare to collect HRB timestamps for each sleep stage
HRB_timestamps_by_stage = {[], [], [], []}; % Corresponds to the sleep stages defined above

% Iterate over each HRB event
for event_idx = 1:length(HRB)
    HRB_event_time = HRB_time(event_idx);

    % Check which sleep stage(s) the HRB event falls into
    for stage_idx = 1:length(sleep_stages)
        current_stage_periods = sleep_stage_periods{stage_idx};
        
        % Check if HRB event falls within current sleep stage
        for period_idx = 1:size(current_stage_periods, 1)
            period_start = current_stage_periods(period_idx, 1);
            period_end = current_stage_periods(period_idx, 2);

            if HRB_event_time >= period_start && HRB_event_time <= period_end
                % Append HRB timestamp to the corresponding stage's HRB timestamps
                HRB_timestamps_by_stage{stage_idx} = [HRB_timestamps_by_stage{stage_idx}, HRB_event_time];
                break; % Assumes an HRB event can only belong to one stage at a time
            end
        end
    end
end

% Assign collected HRB timestamps to their respective variables
NREMexclMA_periods_cut_HRB_time = HRB_timestamps_by_stage{1};
NREMinclMA_periods_cut_HRB_time = HRB_timestamps_by_stage{2};
wake_periods_cut_HRB_time = HRB_timestamps_by_stage{3};
REM_periods_cut_HRB_time = HRB_timestamps_by_stage{4};

%% Get time averaged plot RR and EEG 60 sec after HRB

% Calculate RR intervals from the filtered_RR_time data
RR_time_diff = diff(filtered_RR_time);

% Compute the median of these intervals to find the average interval
average_RR_time_interval = median(RR_time_diff);

% Sampling frequencies
EEG_bands_fs = length(T)/T(end); % for EEG bands
RR_fs = 1 / average_RR_time_interval;

% Define epoch start and end times
epoc_start = 30; % seconds before event
% Update epoch end time to 60 seconds
epoc_end = 60;

% Calculate the length of the epochs
max_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);
total_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);
mid_point = ceil(epoc_start * RR_fs);  % This should be the index of the event time

% Re-initialize epoc_FPtime_EEG with the correct number of points
epoc_FPtime_EEG_bands = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EEG_bands_fs));
epoc_FPtime_RR = linspace(-epoc_start, epoc_end, max_epoch_length);

% Generate the time vector for the epochs, centered at 0
epoc_time_vector_RR = ((1:total_epoch_length) - mid_point) / RR_fs;

% Sleep stage variables and titles
HRB_variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time, REM_periods_cut_HRB_time};
titles = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};

% Initialize the figure
figure;

% Iterate over each sleep stage and its HRB variables
for stage_idx = 1:length(HRB_variables)
    event_type = HRB_variables{stage_idx};  % Select the current event type
    event_name = titles{stage_idx};  % Current event name for titles
    
    % Since num_events is used before the loop, initialize RR_collector based on event_type length
    RR_collector = NaN(max_epoch_length, length(event_type));

    % Resetting EEG band collectors for each sleep stage
    SO_collector = [];
    Delta_collector = [];
    Theta_collector = [];
    Sigma_collector = [];
    Beta_collector = [];

    for i = 1:length(event_type)
        HRB_i = event_type(i);

        if HRB_i < filtered_RR_time(1) + epoc_start || HRB_i > filtered_RR_time(end) - epoc_end
            disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
            continue;  % Skip this event
        end

        [~, event_idx] = min(abs(filtered_RR_time - HRB_i));  % Find the event index in filtered_RR_time

        epoch_start_idx = max(event_idx - mid_point + 1, 1);
        epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(filtered_RR_smooth));

        if epoch_end_idx - epoch_start_idx + 1 <= total_epoch_length
            RR_collector(1:(epoch_end_idx - epoch_start_idx + 1), i) = filtered_RR_smooth(epoch_start_idx:epoch_end_idx);
        end

        % Extract epochs for EEG bands
        for b = 1:length(band_powers)
            EEG_band_epoc_i = band_powers{b}(:, max(1, (HRB_i - epoc_start)*EEG_bands_fs):min(length(T), (HRB_i + epoc_end)*EEG_bands_fs));
        switch b
            case 1
                SO_collector = [SO_collector; EEG_band_epoc_i];
            case 2
                Delta_collector = [Delta_collector; EEG_band_epoc_i];
            case 3
                Theta_collector = [Theta_collector; EEG_band_epoc_i];
            case 4
                Sigma_collector = [Sigma_collector; EEG_band_epoc_i];
            case 5
                Beta_collector = [Beta_collector; EEG_band_epoc_i];
            end
        end
    end

    mean_filtered_RR_epocs = nanmean(RR_collector, 2);
    % Ensure the time vector for EEG bands matches the length of mean EEG data
    epoc_FPtime_EEG_bands_adjusted = linspace(-epoc_start, epoc_end, size(SO_collector, 1));
    
    % Plotting adjustments and corrections
    subplot_idx_RR = (stage_idx-1)*2 + 1;  % Odd positions for RR
    subplot(4, 2, subplot_idx_RR);
    plot(epoc_FPtime_RR, mean_filtered_RR_epocs);
    hold on;
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    hold off;
    title([event_name ' RR interval (' num2str(length(event_type)) ' Events)']);  % Correcting the number of events
    ylabel('RR interval');
    xlim([-30, 60]);

    subplot_idx_EEG = subplot_idx_RR + 1;  % Even positions for EEG bands
    subplot(4, 2, subplot_idx_EEG);
    hold on;
    plot(epoc_FPtime_EEG_bands_adjusted, nanmean(SO_collector, 2), 'DisplayName', 'SO');
    plot(epoc_FPtime_EEG_bands_adjusted, nanmean(Delta_collector, 2), 'DisplayName', 'Delta');
    plot(epoc_FPtime_EEG_bands_adjusted, nanmean(Theta_collector, 2), 'DisplayName', 'Theta');
    plot(epoc_FPtime_EEG_bands_adjusted, nanmean(Sigma_collector, 2), 'DisplayName', 'Sigma');
    plot(epoc_FPtime_EEG_bands_adjusted, nanmean(Beta_collector, 2), 'DisplayName', 'Beta');
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    hold off;
    title([event_name ' EEG Bands']);
    legend({'SO', 'delta', 'theta', 'sigma', 'beta'});
    ylabel('Power');
    xlim([-30, 60]);
    legend;
end

% Adjust overall plot settings
sgtitle('Averaged RR Interval Activity and EEG Bands for Different Sleep Stages');

%% PSD on NE trace

signal_trace = delta465_filt_2; %             <<< Specify which trace the analysis should be used for
sec_signal = sec_signal_2;
fs = signal_fs; %                           <<< Specify sampling frequency of your signal trace
min_period_dur = 120; %                     <<< Specify minimum bout duration for bout to be included in the analysis

sleep_variables = {NREMinclMA_periods_cut, NREMexclMA_periods_cut, REM_periods_cut, wake_woMA_periods_cut};
titles = {'NREM incl MA', 'NREM excl MA', 'REM', 'Wake'};
colors = {'blue', 'red', 'green', 'black'}; % Color for each sleep phase
titles_table = {'NREM_incl_MA', 'NREM_excl_MA', 'REM', 'Wake'};

max_freq = 0.1;
sample_pr_sec = 0.0005;

results = struct('sleep_type', {}, 'Name', {}, 'PeakPowerValue', {}, 'PeakFrequency', {}, ...
                 'MinFrequency', {}, 'Freq25Quartile', {}, 'MedianFrequency', {}, ...
                 'Freq75Quartile', {}, 'Freq95Quartile', {}, 'MaxFrequency', {}, ...
                 'AUC', {}, 'TotalPower', {});

figure;
hold on;

for stage_idx = 1:length(sleep_variables)
    analysis_periods = sleep_variables{stage_idx};
    % power spectral densities
    t1 = analysis_periods(:,1);
    t2 = analysis_periods(:,2);
    
    tsamp1 = floor(t1*fs); %eeg start time 
    tsamp2 = floor(t2*fs); %eeg end time
    NREM_data = cell(1, numel(tsamp1));

    PXX = [];
    PXXlog = [];
    PXX_pk_f = [];
    PXX_pk = [];
    
    NREM_data_collect = [];
    period_duration = [];
    for i=1:numel(tsamp1)
        period_length_i = tsamp2(i)-tsamp1(i);
        if period_length_i < min_period_dur*fs % periods shorter than 120 s are excluded from analysis
            continue
        end
        if tsamp2(i) > length(signal_trace) % if last period ends after trace 
           tsamp2(i) = length(signal_trace);
        end
            % Check if there are enough data points to fit a 5th-degree polynomial
        if (tsamp2(i) - tsamp1(i) + 1) < 6
            continue; % Skip to the next iteration if there are not enough data points
        end

        % Adjust tsamp1 to ensure it starts from at least 1
        tsamp1(i) = max(tsamp1(i), 1);

        period_duration = [period_duration period_length_i/fs];
    
        NREM_data{i} = signal_trace(tsamp1(i):tsamp2(i));
        timetrace_i = sec_signal(tsamp1(i):tsamp2(i));
        
        %detrend (and center around 0)
        [p,s,mu] = polyfit((1:numel(NREM_data{i}))',NREM_data{i},5);
        f_y = polyval(p,(1:numel(NREM_data{i}))',[],mu);
        detrend_data = NREM_data{i} - f_y';        % Detrend data
        
        [pxx, f] = pwelch(detrend_data, [], [],[0:sample_pr_sec:max_freq], fs); %
        logpxx = 10*log10(pxx);
        FX{i} = f;
        [pxx_pk_psd, max_idx] = max(pxx);
        PXX_pk = [PXX_pk pxx_pk_psd];
        pxx_pk_f = f(max_idx);
        PXX_pk_f = [PXX_pk_f pxx_pk_f];
        %PXXlog = [PXXlog logpxx'];
        PXX = [PXX pxx'];
        
        figure
        set(gcf, 'Position',  [100, 300, 1500, 250])
        a = subplot(1,2,1);
            %a.Position = [0.1300 0.1100 0.6200 0.8150];
            plot(timetrace_i,NREM_data{i});
            hold on
            plot(timetrace_i,detrend_data);
            legend({'raw','fitted'})
            hold off
        b = subplot(1,2,2);
            %b.Position = [0.8140 0.1100 0.1533 0.8150];
            plot(f,pxx);
    end
    
    weighted_mean_PXX_iso = sum(period_duration.*PXX,2)/sum(period_duration); % weigthed mean trace (period durations are used as weights)
    
    [PXX_iso_pk_mean, PXX_iso_pk_idx] = max(weighted_mean_PXX_iso); % peak power from mean trace
    PXX_iso_f_mean = f(PXX_iso_pk_idx);
    
    prism_psd_iso = weighted_mean_PXX_iso;
    prism_freq_iso = f;

    plot(prism_freq_iso,prism_psd_iso, Color= colors{stage_idx}, DisplayName = titles{stage_idx})

    % Calculate additional metrics based on 'weighted_mean_PXX_iso' and 'f'
    peak_power_value = PXX_iso_pk_mean;
    peak_frequency = PXX_iso_f_mean;
    min_frequency = f(find(weighted_mean_PXX_iso > 0, 1, 'first'));
    max_frequency = f(find(weighted_mean_PXX_iso > 0, 1, 'last'));
    auc = trapz(f, weighted_mean_PXX_iso);
    total_power = sum(weighted_mean_PXX_iso); % Sum of all powers
    
    % Calculate quartiles based on cumulative distribution of power
    cum_dist = cumtrapz(f, weighted_mean_PXX_iso) / auc; % Normalize to get CDF
    freq25Quartile = interp1(cum_dist, f, 0.25, 'linear', 'extrap');
    median_frequency = interp1(cum_dist, f, 0.5, 'linear', 'extrap');
    freq75Quartile = interp1(cum_dist, f, 0.75, 'linear', 'extrap');
    freq95Quartile = interp1(cum_dist, f, 0.95, 'linear', 'extrap');
    
    % Determine sleep_type from titles_table
    current_title = titles_table{stage_idx};
    if startsWith(current_title, 'NREM_incl')
        sleep_type = 'NREM_incl_MA';
    elseif startsWith(current_title, 'NREM_excl')
        sleep_type = 'NREM_excl_MA';
    elseif startsWith(current_title, 'REM')
        sleep_type = 'REM';
    elseif startsWith(current_title, 'Wake')
        sleep_type = 'Wake';
    else
        sleep_type = 'Unknown';
    end
    
    % Store the calculated values in the results structure
    results(stage_idx) = struct('sleep_type', sleep_type, 'Name', titles_table{stage_idx}, ...
                                'PeakPowerValue', peak_power_value, 'PeakFrequency', peak_frequency, ...
                                'MinFrequency', min_frequency, 'Freq25Quartile', freq25Quartile, ...
                                'MedianFrequency', median_frequency, 'Freq75Quartile', freq75Quartile, 'Freq95Quartile', freq95Quartile, ...
                                'MaxFrequency', max_frequency, 'AUC', auc, 'TotalPower', total_power);

end
xlabel('frequency (Hz)');
ylabel('PSD');
legend('show');
title('NE power across sleep stages')
grid on;
hold off;

PSD_NE_table = struct2table(results);
%% PSD on RR trace

%Please ensure that filtered_RR_smooth and filtered_RR_time has been defined!

% Define the sampling frequency for R-R intervals
% RR_fs = 1 / median(diff(filtered_RR_time));
% signal_trace = filtered_RR_smooth'; %             <<< Specify which trace the analysis should be used for
% fs = RR_fs; %                           <<< Specify sampling frequency of your signal trace
% min_period_dur = 180; %                     <<< Specify minimum bout duration for bout to be included in the analysis
% sec_signal = filtered_RR_time
% sampling_hz = 0.002

% Define the sampling frequency for R-R intervals - THIS IS RESAMPLED!!!
signal_trace = resampled_RR_pchip; %             <<< Specify which trace the analysis should be used for
fs = new_fs; %                           <<< Specify sampling frequency of your signal trace
min_period_dur = 180; %                     <<< Specify minimum bout duration for bout to be included in the analysis
sec_signal = new_time_vector;
sampling_hz = 0.0002;
min_period_dur = 180; % Specify minimum bout duration for bout to be included in the analysis

sleep_variables = {NREMinclMA_periods_cut, NREMexclMA_periods_cut, REM_periods_cut, wake_woMA_periods_cut};
titles = {'NREM incl MA', 'NREM excl MA', 'REM', 'Wake'};
colors = {'blue', 'red', 'green', 'black'}; % Color for each sleep phase
titles_table = {'NREM_incl_MA', 'NREM_excl_MA', 'REM', 'Wake'};


% sleep_variables = {NREMinclMA_periods_cut};
% titles = {'NREM incl MA'};
% colors = {'blue'}; % Color for each sleep phase

figure;
hold on;

for stage_idx = 1:length(sleep_variables)
    analysis_periods = sleep_variables{stage_idx};
    % power spectral densities
    t1 = analysis_periods(:,1);
    t2 = analysis_periods(:,2);
    
    tsamp1 = floor(t1*fs); %RR start time 
    tsamp2 = floor(t2*fs); %RR end time
    NREM_data = cell(1, numel(tsamp1));
    
    PXX = [];
    PXXlog = [];
    PXX_pk_f = [];
    PXX_pk = [];
    
    NREM_data_collect = [];
    period_duration = [];
    for i=1:numel(tsamp1)
        period_length_i = tsamp2(i)-tsamp1(i);
        if period_length_i < min_period_dur*fs % periods shorter than 120 s are excluded from analysis
            continue
        end
        if tsamp2(i) > length(signal_trace) % if last period ends after trace 
           tsamp2(i) = length(signal_trace);
        end
            % Check if there are enough data points to fit a 5th-degree polynomial
        if (tsamp2(i) - tsamp1(i) + 1) < 6
            continue; % Skip to the next iteration if there are not enough data points
        end
        period_duration = [period_duration period_length_i/fs];
    
        NREM_data{i} = signal_trace(tsamp1(i):tsamp2(i));
        timetrace_i = sec_signal(tsamp1(i):tsamp2(i));
        
        %detrend (and center around 0)
        [p,s,mu] = polyfit((1:numel(NREM_data{i}))',NREM_data{i},5);
        f_y = polyval(p,(1:numel(NREM_data{i}))',[],mu);
        detrend_data = NREM_data{i} - f_y';        % Detrend data
        
        [pxx, f] = pwelch(detrend_data, [], [],[0:sampling_hz:3], fs); %
        logpxx = 10*log10(pxx);
        FX{i} = f;
        [pxx_pk_psd, max_idx] = max(pxx);
        PXX_pk = [PXX_pk pxx_pk_psd];
        pxx_pk_f = f(max_idx);
        PXX_pk_f = [PXX_pk_f pxx_pk_f];
        %PXXlog = [PXXlog logpxx'];
        PXX = [PXX pxx'];
        
        % figure
        % set(gcf, 'Position',  [100, 300, 1500, 250])
        % a = subplot(1,2,1);
        %     %a.Position = [0.1300 0.1100 0.6200 0.8150];
        %     plot(timetrace_i,NREM_data{i});
        %     hold on
        %     plot(timetrace_i,detrend_data);
        %     legend({'raw','fitted'})
        %     hold off
        % b = subplot(1,2,2);
        %     %b.Position = [0.8140 0.1100 0.1533 0.8150];
        %     plot(f,pxx);
    end
    
    weighted_mean_PXX_iso = sum(period_duration.*PXX,2)/sum(period_duration); % weigthed mean trace (period durations are used as weights)
    
    [PXX_iso_pk_mean, PXX_iso_pk_idx] = max(weighted_mean_PXX_iso); % peak power from mean trace
    PXX_iso_f_mean = f(PXX_iso_pk_idx);
    
    prism_psd_iso = weighted_mean_PXX_iso;
    prism_freq_iso = f;

    plot(prism_freq_iso,prism_psd_iso, Color= colors{stage_idx}, DisplayName = titles{stage_idx})

    % Total Power
    total_power = sum(weighted_mean_PXX_iso);
    
    % Power in VLF, LF, HF bands and their percentages
    vlf_range = f >= 0 & f < 0.15;
    lf_range = f >= 0.15 & f < 1.5;
    hf_range = f >= 1.5 & f <= 5;
    
    power_vlf = sum(weighted_mean_PXX_iso(vlf_range));
    percent_vlf = (power_vlf / total_power) * 100;
    
    power_lf = sum(weighted_mean_PXX_iso(lf_range));
    percent_lf = (power_lf / total_power) * 100;
    
    power_hf = sum(weighted_mean_PXX_iso(hf_range));
    percent_hf = (power_hf / total_power) * 100;
    
    % AUC for total, VLF, LF, HF
    auc_total = trapz(f, weighted_mean_PXX_iso);
    auc_vlf = trapz(f(vlf_range), weighted_mean_PXX_iso(vlf_range));
    auc_lf = trapz(f(lf_range), weighted_mean_PXX_iso(lf_range));
    auc_hf = trapz(f(hf_range), weighted_mean_PXX_iso(hf_range));
    
    % Peak frequency calculation using 'findpeaks' for VLF, LF, HF ranges
    [peaks_vlf, locs_vlf] = findpeaks(weighted_mean_PXX_iso(vlf_range));
    [peaks_lf, locs_lf] = findpeaks(weighted_mean_PXX_iso(lf_range));
    [peaks_hf, locs_hf] = findpeaks(weighted_mean_PXX_iso(hf_range));
    
    % VLF peak with the highest power
    if ~isempty(peaks_vlf)
        [~, max_peak_idx_vlf] = max(peaks_vlf); % Find index of the highest peak
        peak_freq_vlf = f(vlf_range);
        peak_freq_vlf = peak_freq_vlf(locs_vlf(max_peak_idx_vlf)); 
    else
        peak_freq_vlf = NaN; % In case no peak is found
    end
    
    % LF peak with the highest power
    if ~isempty(peaks_lf)
        [~, max_peak_idx_lf] = max(peaks_lf); % Find index of the highest peak
        peak_freq_lf = f(lf_range);
        peak_freq_lf = peak_freq_lf(locs_lf(max_peak_idx_lf));
    else
        peak_freq_lf = NaN; % In case no peak is found
    end
    
    % HF peak with the highest power
    if ~isempty(peaks_hf)
        [~, max_peak_idx_hf] = max(peaks_hf); % Find index of the highest peak
        peak_freq_hf = f(hf_range);
        peak_freq_hf = peak_freq_hf(locs_hf(max_peak_idx_hf));
    else
        peak_freq_hf = NaN; % In case no peak is found
    end

    % Set sleep_type based on titles_table
    current_title = titles_table{stage_idx}; % Assuming stage_idx is your loop variable
    if startsWith(current_title, 'NREM_incl')
        sleep_type = 'NREM_incl_MA';
    elseif startsWith(current_title, 'NREM_excl')
        sleep_type = 'NREM_excl_MA';
    elseif startsWith(current_title, 'REM')
        sleep_type = 'REM';
    elseif startsWith(current_title, 'Wake')
        sleep_type = 'Wake';
    else
        sleep_type = 'Unknown'; % Fallback in case of an unexpected title
        disp(['Unknown sleep type detected: ' current_title])
    end

    % Store the calculated values in the results structure
    results(stage_idx) = struct('sleep_type', sleep_type, 'Name', titles_table{stage_idx}, 'TotalPower', total_power, ...
                                'PowerVLF', power_vlf, 'PercentVLF', percent_vlf, ...
                                'PowerLF', power_lf, 'PercentLF', percent_lf, ...
                                'PowerHF', power_hf, 'PercentHF', percent_hf, ...
                                'AUCTotal', auc_total, 'AUCVLF', auc_vlf, ...
                                'AUCLF', auc_lf, 'AUCHF', auc_hf, ...
                                'PeakFreqVLF', peak_freq_vlf, 'PeakFreqLF', peak_freq_lf, 'PeakFreqHF', peak_freq_hf);
end

xlabel('frequency (Hz)');
ylabel('PSD');
legend('show');
title('RR power across sleep stages (pchip interpolation)')
grid on;
hold off;

% Convert the structure to a table for easier viewing and manipulation
PSD_RR_table = struct2table(results);
%% PSD NE - hourerly

% Assuming you have hourlySegments structures for each sleep variable as before
hourlySegmentsVariables = {NREMinclMA_periods_cut_hourlySegments, NREMexclMA_periods_cut_hourlySegments, REM_hourlySegments, wake_hourlySegments};
titles = {'NREM incl MA', 'NREM excl MA', 'REM', 'Wake'};
colors = {'blue', 'red', 'green', 'black'}; % Color for each sleep phase
titles_table = {'NREM_incl_MA', 'NREM_excl_MA', 'REM', 'Wake'};

max_freq = 0.1; % Maximum frequency for PSD
sample_pr_sec = 0.0005; % Sampling resolution
fs = signal_fs; % Sampling frequency
min_period_dur = 120; % Minimum bout duration

% Initialize the results array
results = [];

% Define variables for plotting outside the sleep stage loop
allHours = unique(cellfun(@(x) str2double(extractAfter(x, 'h')), segmentFields));
allSleepStages = titles;

% Loop through each hour
for hourIdx = 1:length(allHours)
    currentHour = allHours(hourIdx);
    
    % Prepare for a new PSD plot for the current hour
    figure;
    hold on;
    
    % Loop through each sleep variable (stage)
    for segIdx = 1:length(hourlySegmentsVariables)
        hourlySegments = hourlySegmentsVariables{segIdx}; % Access sleep variable's hourly segments
        segmentFields = fieldnames(hourlySegments); % Get names of the fields (hours)
        currentHourField = sprintf('h%02d', currentHour); % Format current hour field name
        
        if isfield(hourlySegments, currentHourField)
            currentHourData = hourlySegments.(currentHourField); % Data for the current hour

        % Initialize variables for storing combined results of this hour
        hourResults = [];
        
        % Initialize variables for each period's data analysis
        PXX = [];
        period_duration = [];
        
        % Loop through each period in the current hour's data
        for i = 1:size(currentHourData, 1)
            t1 = currentHourData(i, 1);
            t2 = currentHourData(i, 2);
            
            tsamp1 = floor(t1*fs);
            tsamp2 = floor(t2*fs);
            
            if tsamp2 > length(signal_trace)
                tsamp2 = length(signal_trace);
            end
            
            if (tsamp2 - tsamp1 + 1) < 6 || (tsamp2 - tsamp1) < min_period_dur*fs
                continue; % Skip if too short for analysis
            end
            
            period_signal = signal_trace(tsamp1:tsamp2);
            period_length = (tsamp2 - tsamp1 + 1) / fs;
            period_duration = [period_duration; period_length];
            
            detrended_signal = detrend(period_signal, 5); % Detrend and center
            [pxx, f] = pwelch(detrended_signal, [], [], [0:sample_pr_sec:max_freq], fs);
            
            PXX = [PXX, pxx * period_length]; % Weight by period length
        end
        
        % Skip to next if no valid data found
        if isempty(PXX)
            title(sprintf('No valid data for %s - Hour %02d', titles{segIdx}, currentHour));
            hold off;
            continue;
        end
        
        % Aggregate and normalize PXX by total duration
        weighted_mean_PXX = sum(PXX, 2) / sum(period_duration);
        
        % Plot the PSD
        plot(f, 10*log10(weighted_mean_PXX), 'Color', colors{segIdx}, 'DisplayName', titles{segIdx});
        xlabel('Frequency (Hz)');
        ylabel('Power/Frequency (dB/Hz)');
        title(sprintf('%s power across sleep stages - Hour %02d', titles{segIdx}, currentHour));
        legend('show');
        grid on;
        hold off;
        
        % Collect results
        % After computing weighted_mean_PXX and having the frequency vector 'f'
        
        % Peak power value and the frequency at the peak
        % Use findpeaks to identify all peaks in the power spectrum
       % Check if there are enough samples for findpeaks
        if length(weighted_mean_PXX) >= 3
            % Use findpeaks to identify all peaks in the power spectrum
            [peaks, locs] = findpeaks(weighted_mean_PXX, f);
            
            % Check if any peaks were found
            if ~isempty(peaks)
                % If multiple peaks are found, take the one with the highest power value
                [peakPower, highestPeakIdx] = max(peaks);
                peakFrequency = locs(highestPeakIdx);
            else
                % If no peaks are found, use max to find the peak power and frequency
                [peakPower, peakIdx] = max(weighted_mean_PXX);
                peakFrequency = f(peakIdx);
            end
        else
            % Not enough data for findpeaks, use max to find the peak power and frequency
            [peakPower, peakIdx] = max(weighted_mean_PXX);
            peakFrequency = f(peakIdx);
        end
        
        % Minimal and maximal frequency with any power detected
        minFrequency = f(find(weighted_mean_PXX > 0, 1, 'first'));
        maxFrequency = f(find(weighted_mean_PXX > 0, 1, 'last'));
        
        % AUC of the power distribution
        auc = trapz(f, weighted_mean_PXX);
        
        % Total Power (Sum of all PSD values)
        totalPower = sum(weighted_mean_PXX);
        
        % Calculate quartiles and median of the frequency distribution
        % Normalize weighted_mean_PXX to get a probability distribution
        % Calculate quartiles and other statistics from weighted_mean_PXX and f
        % Normalize weighted_mean_PXX to get a probability distribution for the quartile calculation
        normalizedPXX = weighted_mean_PXX / sum(weighted_mean_PXX);
        cumulativeDist = cumtrapz(f, normalizedPXX);
        
        freq25Quartile = interp1(cumulativeDist, f, 0.25, 'linear', 'extrap');
        medianFrequency = interp1(cumulativeDist, f, 0.5, 'linear', 'extrap');
        freq75Quartile = interp1(cumulativeDist, f, 0.75, 'linear', 'extrap');
        freq95Quartile = interp1(cumulativeDist, f, 0.95, 'linear', 'extrap');
        meanFrequency = sum(f .* normalizedPXX);
        
        % Append calculated metrics to the hourResults for the current sleep stage
        hourResults(end+1) = struct(...
            'Hour', currentHour, ...
            'SleepStage', titles{segIdx}, ...
            'PeakPowerValue', peakPower, ...
            'PeakFrequency', peakFrequency, ...
            'MinFrequency', minFrequency, ...
            'MaxFrequency', maxFrequency, ...
            'Freq25Quartile', freq25Quartile, ...
            'MedianFrequency', medianFrequency, ...
            'Freq75Quartile', freq75Quartile, ...
            'Freq95Quartile', freq95Quartile, ...
            'MeanFrequency', meanFrequency, ...
            'AUC', auc, ...
            'TotalPower', totalPower);
    end
end
    % Finalize the plot for the current hour
    title(sprintf('Power across sleep stages - Hour %02d', currentHour));
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    legend(allSleepStages);
    hold off;
end

% Convert results to a table after finishing all hours and sleep stages
PSD_NE_table_hourly = struct2table(hourResults);

%% DEBUGGING
NREMexclMA_periods_cut_HRB_time_short = NREMexclMA_periods_cut_HRB_time(1:5);
NREMinclMA_periods_cut_HRB_time_short = NREMinclMA_periods_cut_HRB_time(1:5);
wake_periods_cut_HRB_time_short = wake_periods_cut_HRB_time(1:5);

NREMexclMA_periods_cut_pklocs_short = NREMexclMA_periods_cut_pklocs(1:5);
NREMinclMA_periods_cut_pklocs_short = NREMinclMA_periods_cut_pklocs(1:5);
wake_periods_cut_pklocs_short = wake_periods_cut_pklocs(1:5);
REM_periods_cut_pklocs_short = REM_periods_cut_pklocs(1:5);


%% power-histograms of each EEG_band surrounding HRB events split by sleep stages (updated)

% Define the frequency bands of interest for EEG
power_bands = { {0.5, 1, 'SO'}, {1, 4, 'Delta'}, {4, 8, 'Theta'}, {8, 15, 'Sigma'}, {15, 30, 'Beta'} };

% Define events and their timestamps. Assuming each cell array contains event times in seconds
NE_trough_variables = {NREMexclMA_periods_cut_pklocs_short, NREMinclMA_periods_cut_pklocs_short, wake_periods_cut_pklocs_short, REM_periods_cut_pklocs_short};
titles = {'NE troughs NREM excl MA', 'NE troughs NREM incl MA', 'NE troughs Wake', 'NE troughs REM'};

pre_event_time = 30; % seconds before event
post_event_time = 60; % seconds after event
bin_size = 5; % seconds
    
for i = 1:length(NE_trough_variables)
    events = NE_trough_variables{i};
    power_bands_matrix = calculate_power_bands_PSD(Data_EEG, EEG_fs, events, pre_event_time, post_event_time, bin_size, power_bands);
    
    figure;
    sgtitle(titles{i}); % Title for each sleep stage
    
    for band_idx = 1:length(power_bands)
        subplot(length(power_bands), 1, band_idx);
        
        band_power = squeeze(power_bands_matrix(band_idx, :, :));
        mean_power = mean(band_power, 2);
        sem_power = std(band_power, 0, 2) / sqrt(size(band_power, 2));
        
        bin_centers = (-pre_event_time:bin_size:post_event_time-bin_size) + bin_size/2;
        
        b = bar(bin_centers, mean_power, 'FaceColor', 'flat');
        hold on;
        e = errorbar(bin_centers, mean_power, sem_power, 'k', 'linestyle', 'none');
        hold off;
        
        title([power_bands{band_idx}{3} ' Band']);
        xlabel('Time relative to event (s)');
        ylabel('Mean PSD (dB/Hz)');
        xlim([-pre_event_time, post_event_time]);
        grid on; % Add grid
        
        % Dynamic Y-axis adjustment based on error bars
        allErrorTops = mean_power + sem_power;
        allErrorBottoms = mean_power - sem_power;
        minYValue = min(allErrorBottoms);
        maxYValue = max(allErrorTops);
        
        yAxisLength = maxYValue - minYValue;
        minYAxisLimit = minYValue - 0.1 * yAxisLength; % Adjust so bottom is at 10% of y-axis length
        maxYAxisLimit = maxYValue + 0.1 * yAxisLength; % Adjust so top is at 90% of y-axis length
        
        ylim([minYAxisLimit, maxYAxisLimit]);
    end
end
%% Plots power for each band as a line around each event (NE troughs or HRB)

% Define the frequency bands of interest for EEG
power_bands = { {0.5, 1, 'SO'}, {1, 4, 'Delta'}, {4, 8, 'Theta'}, {8, 15, 'Sigma'}, {15, 30, 'Beta'} };

% Assuming NE_trough_variables and titles are defined as before
% Define events and their timestamps
NE_trough_variables = {NREMexclMA_periods_cut_pklocs, NREMinclMA_periods_cut_pklocs, wake_periods_cut_pklocs, REM_periods_cut_pklocs};
titles = {'NE troughs NREM excl MA', 'NE troughs NREM incl MA', 'NE troughs Wake', 'NE troughs REM'};

pre_event_time = 30; % seconds before event
post_event_time = 60; % seconds after event

% Adjusted code begins here
for i = 1:length(NE_trough_variables)
    events = NE_trough_variables{i};
    
    figure;
    sgtitle(titles{i}); % Title for each sleep stage
    
    for band_idx = 1:length(power_bands)
        band = power_bands{band_idx};
        band_freq_indices = F >= band{1} & F <= band{2}; % Find indices of frequencies within the band
        
        % Initialize arrays for mean power and SEM
        all_event_power_values = []; % This will store the power values for all events

        for event_idx = 1:length(events)
            event_time = events(event_idx);
            % Find indices of times within the window around the current event
            event_time_indices = find(time_spectrogram_zero >= (event_time - pre_event_time) & time_spectrogram_zero <= (event_time + post_event_time));
            
            if ~isempty(event_time_indices)
                % Extract power values for the band and time around the current event
                event_power_values = filtered_mean_spectrogram(band_freq_indices, event_time_indices);
                all_event_power_values = [all_event_power_values, event_power_values]; % Concatenate power values from each event
            end
        end

        % Now calculate mean and SEM across all events
        mean_power = mean(all_event_power_values, 2).'; % Compute mean power across all events and transpose
        sem_power = std(all_event_power_values, 0, 2).' / sqrt(size(all_event_power_values, 2)); % Compute SEM across all events and transpose
        
        % Ensure time_points has the same length as mean_power and sem_power
        time_points = linspace(-pre_event_time, post_event_time, length(mean_power)); % time_points is now a row vector
        
        subplot(length(power_bands), 1, band_idx);
        
        % Plotting mean power as a line
        plot(time_points, mean_power, 'LineWidth', 1.5, 'Color', [0.4660 0.6740 0.1880]); % Plot mean power
        hold on;
        % Adding shading for SEM
        fill([time_points, fliplr(time_points)], [mean_power+sem_power, fliplr(mean_power-sem_power)], ...
             'g', 'linestyle', 'none', 'FaceAlpha', 0.3); % Add shading for SEM with semi-transparent green
        hold off;
        
        title([band{3} ' Band']);
        xlabel('Time relative to event (s)');
        ylabel('Mean Power (log unit)');
        xlim([-pre_event_time, post_event_time]);
        grid on; % Add grid
    end
end


%% Get just RR for each HRB event
% Calculate RR intervals from the filtered_RR_time data
RR_time_diff = diff(filtered_RR_time);

% Compute the median of these intervals to find the average interval
average_RR_time_interval = median(RR_time_diff);

% Sampling frequencies
RR_fs = 1 / average_RR_time_interval;

% Define epoch start and end times
epoc_start = 30; % seconds before event
% Update epoch end time to 60 seconds
epoc_end = 60;

% Calculate the length of the epochs
max_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);
total_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);
mid_point = ceil(epoc_start * RR_fs);  % This should be the index of the event time

% Re-initialize epoc_FPtime_EEG with the correct number of points
epoc_FPtime_RR = linspace(-epoc_start, epoc_end, max_epoch_length);

% Sleep stage variables and titles
HRB_variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time_short, REM_periods_cut_HRB_time};
titles = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};

% Iterate over each sleep stage and its HRB variables
for stage_idx = 1:length(HRB_variables)
    event_type = HRB_variables{stage_idx};  % Select the current event type
    event_name = titles{stage_idx};  % Current event name for titles
    num_events = length(event_type); % Number of events for the current sleep stage

    
    % Since num_events is used before the loop, initialize RR_collector based on event_type length
    RR_collector = NaN(max_epoch_length, length(event_type));

    for i = 1:length(event_type)
        HRB_i = event_type(i);

        if HRB_i < filtered_RR_time(1) + epoc_start || HRB_i > filtered_RR_time(end) - epoc_end
            disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
            continue;  % Skip this event
        end

        [~, event_idx] = min(abs(filtered_RR_time - HRB_i));  % Find the event index in filtered_RR_time

        epoch_start_idx = max(event_idx - mid_point + 1, 1);
        epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(filtered_RR_smooth));

        if epoch_end_idx - epoch_start_idx + 1 <= total_epoch_length
            RR_collector(1:(epoch_end_idx - epoch_start_idx + 1), i) = filtered_RR_smooth(epoch_start_idx:epoch_end_idx);
        end

    end
    mean_filtered_RR_epocs = nanmean(RR_collector, 2);
    
    % Create a new figure for each plot
    figure; % This line creates a new figure window for each sleep stage's RR interval plot
    plot(epoc_FPtime_RR, mean_filtered_RR_epocs);
    hold on;
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    hold off;
    title([event_name ' RR interval (' num2str(length(event_type)) ' Events)']);  % Correcting the number of events
    ylabel('RR interval');
    xlabel('Time (s)');
    xlim([-30, 60]);

    % Adjust the figure title or additional settings as needed
end
%% Get just NE for each HRB events - Add to combined plot with RR + EEG power hist

% Sampling frequencies
NE_fs = signal_fs;

% Define epoch start and end times
epoc_start = 30; % seconds before event
% Update epoch end time to 60 seconds
epoc_end = 60;

% Sleep stage variables and titles
HRB_variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time, REM_periods_cut_HRB_time};
titles = {'NREM excl MA', 'NREM incl MA', 'Wake', 'REM'};

epoc_FPtime_NE = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * NE_fs));

% Iterate over each sleep stage and its HRB variables
for stage_idx = 1:length(HRB_variables)
    event_type = HRB_variables{stage_idx};  % Select the current event type
    event_name = titles{stage_idx};  % Current event name for titles
    num_events = length(event_type); % Number of events for the current sleep stage

    % Calculate the expected length of each epoch
    epoch_length = round((epoc_end + epoc_start) * NE_fs);
    
    % Pre-allocate NE_peak_epoc_collector with NaNs
    % Assuming `length(HRB_variables{stage_idx})` gives the number of events for the current sleep stage
    NE_peak_epoc_collector = NaN(length(event_type), epoch_length);
    
    for i = 1:length(event_type)
        NEpk_i = event_type(i);
        if NEpk_i > sec_signal_2(end) - epoc_end % Skip if event is too close to end of recording
            continue;
        end
        
        % Calculate rounded indices for start and end of the epoch
        start_idx = round((NEpk_i - epoc_start) * NE_fs);
        end_idx = round((NEpk_i + epoc_end) * NE_fs);
        
        % Ensure indices are within the bounds of the delta465_filt_2 array
        start_idx = max(start_idx, 1);
        end_idx = min(end_idx, length(delta465_filt_2));
        
        % Extract the epoch, adjusting for possible index out-of-bounds
        epoch_length_actual = end_idx - start_idx + 1;
        NEpk_epoc_i = delta465_filt_2(start_idx:end_idx);
        
        % Fill the current row of NE_peak_epoc_collector, adjusting for potential length differences
        NE_peak_epoc_collector(i, 1:epoch_length_actual) = NEpk_epoc_i;
    end

% Calculate the expected length of each epoch based on the adjusted sampling frequency
epoch_length = round((epoc_end + epoc_start) * NE_fs);

% Adjust epoc_FPtime_NE to match this epoch length
epoc_FPtime_NE = linspace(-epoc_start, epoc_end, epoch_length);

% Assuming NE_peak_epoc_collector has been correctly filled as per the previous steps
mean_NEpk_epocs = nanmean(NE_peak_epoc_collector, 1);


% Adjust epoc_FPtime_NE to match the exact length of mean_NEpk_epocs
epoc_FPtime_NE = linspace(-epoc_start, epoc_end, length(mean_NEpk_epocs));


% Now plot, ensuring the vectors match in length
figure;
plot(epoc_FPtime_NE, mean_NEpk_epocs);
hold on;
plot([0 0], ylim, 'r--');  % Add a red dashed line at timepoint 0 for reference
hold off;
title([event_name ' NE (' num2str(num_events) ' Events)']);  % Include number of events in the title
ylabel('NE Activity');
xlabel('Time (s)');
xlim([-30, 60]);

end

%% Combine RR, NE, and EEG power hist (updated)

% Define power bands and their corresponding titles
power_bands = { {0.5, 1, 'SO'}, {1, 4, 'Delta'}, {4, 8, 'Theta'}, {8, 15, 'Sigma'}, {15, 30, 'Beta'} };

% Assuming T is defined as a timeline for EEG data and represents the total recording time
EEG_bands_fs = length(T)/T(end);

% Define epoch start and end times for both RR intervals and EEG bands
epoc_start = 30; % seconds before event
epoc_end = 60; % seconds after event
bin_size = 5;

% Calculate the expected length of each epoch
epoch_length = round((epoc_end + epoc_start) * NE_fs);

% Calculate lengths and time vectors for epochs
max_epoch_length = ceil((epoc_start + epoc_end) * (1 / median(diff(filtered_RR_time)))); %last part is RR_fs
epoc_FPtime_RR = linspace(-epoc_start, epoc_end, max_epoch_length);
epoch_times_EEG = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EEG_bands_fs));

% Sleep stage variables and titles
NE_trough_variables = {NREMexclMA_periods_cut_pklocs, NREMinclMA_periods_cut_pklocs, wake_periods_cut_pklocs, REM_periods_cut_pklocs};
titles = {'NE troughs NREM excl MA', 'NE troughs NREM incl MA', 'NE troughs Wake', 'NE troughs REM'};

%HRB_variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time, REM_periods_cut_HRB_time};
%titles = {'HRB NREM excl MA', 'HRB NREM incl MA', 'HRB Wake', 'HRB REM'};

% Define colors for EEG power bands for visual distinction
colors = lines(length(power_bands));

% Assuming all necessary variables are defined and calculate_power_bands_PSD is correctly implemented
for stage_idx = 1:length(NE_trough_variables)
    figure; % One figure per sleep stage
    sgtitle([titles{stage_idx} ' - EEG Power Bands']);
    
    event_type = NE_trough_variables{stage_idx};
    event_name = titles{stage_idx};  % Current event name for titles
    num_events = length(event_type); % Assuming this is correctly calculated elsewhere
    
    % Call your function to calculate power bands matrix
    power_bands_matrix = calculate_power_bands_PSD(Data_EEG, EEG_bands_fs, event_type, epoc_start, epoc_end, bin_size, power_bands);
    
    for band_idx = 1:length(power_bands)
        subplot(length(power_bands) + 2, 1, band_idx + 2);
        
        band_power = squeeze(power_bands_matrix(band_idx, :, :));
        mean_power = mean(band_power, 2);
        sem_power = std(band_power, 0, 2) / sqrt(size(band_power, 2));
        
        bin_centers = (-epoc_start:bin_size:epoc_end-bin_size) + bin_size/2;
        
        bar(bin_centers, mean_power, 'FaceColor', colors(band_idx, :));
        hold on;
        errorbar(bin_centers, mean_power, sem_power, 'k', 'linestyle', 'none');
        hold off;
        
        minYValue = min(mean_power - sem_power);
        maxYValue = max(mean_power + sem_power);
        yAxisRange = maxYValue - minYValue;
        ylim([minYValue - 0.1 * yAxisRange, maxYValue + 0.1 * yAxisRange]); % Dynamic y-axis adjustment
        
        grid on; % Adding grid
        
        xlabel('Time (s)');
        ylabel(' Power (dB/Hz)');
        xlim([-epoc_start, epoc_end]);
        title([power_bands{band_idx}{3} ' Power (' num2str(num_events) ' Events)']);
    end

    % Since num_events is used before the loop, initialize RR_collector based on event_type length
    RR_collector = NaN(max_epoch_length, length(event_type));

    for i = 1:length(event_type)
        HRB_i = event_type(i);

        if HRB_i < filtered_RR_time(1) + epoc_start || HRB_i > filtered_RR_time(end) - epoc_end
            disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
            continue;  % Skip this event
        end

        [~, event_idx] = min(abs(filtered_RR_time - HRB_i));  % Find the event index in filtered_RR_time

        epoch_start_idx = max(event_idx - mid_point + 1, 1);
        epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(filtered_RR_smooth));

        if epoch_end_idx - epoch_start_idx + 1 <= total_epoch_length
            RR_collector(1:(epoch_end_idx - epoch_start_idx + 1), i) = filtered_RR_smooth(epoch_start_idx:epoch_end_idx);
        end

    end
    mean_filtered_RR_epocs = nanmean(RR_collector, 2);
    
    % Add shading for SE
    RR_sem = std(RR_collector, 0, 2) / sqrt(size(RR_collector, 2));
    RR_upper_bound = mean_filtered_RR_epocs + RR_sem;
    RR_lower_bound = mean_filtered_RR_epocs - RR_sem;

    % Plot RR intervals as the first subplot
    subplot(length(power_bands) + 2, 1, 1); % Allocate space for RR interval plot at the top
    % Create a new figure for each plot
    plot(epoc_FPtime_RR, mean_filtered_RR_epocs, 'LineWidth', 1);
    hold on;
    plot(epoc_FPtime_RR, RR_upper_bound, 'r--'); % Upper bound for shading
    plot(epoc_FPtime_RR, RR_lower_bound, 'r--'); % Lower bound for shading
    fill([epoc_FPtime_RR, fliplr(epoc_FPtime_RR)], [RR_upper_bound', fliplr(RR_lower_bound')], 'r', 'FaceAlpha', 0.3); % Fill between upper and lower bounds
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    hold off;
    title([event_name ' RR interval (' num2str(length(event_type)) ' Events)']);  % Correcting the number of events
    ylabel('RR interval');
    xlabel('Time (s)');
    xlim([-30, 60]);
    % Note: This section will use epoc_FPtime_RR, filtered_RR_time, and filtered_RR_smooth with modifications to fit into the subplot.
     
    % Pre-allocate NE_peak_epoc_collector with NaNs
        % Assuming `length(HRB_variables{stage_idx})` gives the number of events for the current sleep stage
        NE_peak_epoc_collector = NaN(length(event_type), epoch_length);
        
        for i = 1:length(event_type)
            NEpk_i = event_type(i);
            if NEpk_i > sec_signal_2(end) - epoc_end % Skip if event is too close to end of recording
                continue;
            end
            
            % Calculate rounded indices for start and end of the epoch
            start_idx = round((NEpk_i - epoc_start) * NE_fs);
            end_idx = round((NEpk_i + epoc_end) * NE_fs);
            
            % Ensure indices are within the bounds of the delta465_filt_2 array
            start_idx = max(start_idx, 1);
            end_idx = min(end_idx, length(delta465_filt_2));
            
            % Extract the epoch, adjusting for possible index out-of-bounds
            epoch_length_actual = end_idx - start_idx + 1;
            NEpk_epoc_i = delta465_filt_2(start_idx:end_idx);
            
            % Fill the current row of NE_peak_epoc_collector, adjusting for potential length differences
            NE_peak_epoc_collector(i, 1:epoch_length_actual) = NEpk_epoc_i;
        end
    
    % Calculate the expected length of each epoch based on the adjusted sampling frequency
    epoch_length = round((epoc_end + epoc_start) * NE_fs);
    
    % Adjust epoc_FPtime_NE to match this epoch length
    epoc_FPtime_NE = linspace(-epoc_start, epoc_end, epoch_length);
    
    % Assuming NE_peak_epoc_collector has been correctly filled as per the previous steps
    mean_NEpk_epocs = nanmean(NE_peak_epoc_collector, 1);
    
    % Correctly adjust epoc_FPtime_NE to match the epoch length
    epoc_FPtime_NE = linspace(-epoc_start, epoc_end, length(mean_NEpk_epocs));
    
    % Calculate standard error of the mean (SEM) for shading
    NE_sem = std(NE_peak_epoc_collector, 0, 1) / sqrt(size(NE_peak_epoc_collector, 1));
    NE_upper_bound = mean_NEpk_epocs + NE_sem;
    NE_lower_bound = mean_NEpk_epocs - NE_sem;
    
    % Plot for NE activity
    subplot(length(power_bands) + 2, 1, 2);
    hold on;
    
    % Plotting the mean NEpk epochs
    plot(epoc_FPtime_NE, mean_NEpk_epocs, 'LineWidth', 1); 
    
    % Add shading for SEM
    fill([epoc_FPtime_NE, fliplr(epoc_FPtime_NE)], [NE_upper_bound, fliplr(NE_lower_bound)], 'b', 'FaceAlpha', 0.3);
    
    % Ensure the line at x=0 is correctly drawn
    current_ylim = ylim; % Get current y-axis limits
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    
    hold off;
    title([event_name ' NE (' num2str(num_events) ' Events)']);
    ylabel('NE Activity');
    xlabel('Time (s)');
    xlim([-30, 60]);
end
%% Same as above but with EEG as a line
% Define power bands and their corresponding titles
power_bands = { {0.5, 1, 'SO'}, {1, 4, 'Delta'}, {4, 8, 'Theta'}, {8, 15, 'Sigma'}, {15, 30, 'Beta'} };

NE_fs = signal_fs; % for fiber photometry
EMG_fs = EEG_fs; % for EMG and EEG
EEG_bands_fs = length(T)/T(end); % for EEG bands
RR = resampled_RR_linear;
RR_fs = new_fs;
RR_time = new_time_vector;

% Define epoch start and end times for both RR intervals and EEG bands
epoc_start = 30; % seconds before event
epoc_end = 60; % seconds after event

% Calculate the expected length of each epoch
epoch_length = round((epoc_end + epoc_start) * NE_fs);

% Calculate lengths and time vectors for epochs
max_epoch_length = ceil((epoc_start + epoc_end) * (1 / median(diff(RR_time)))); %last part is RR_fs
epoc_FPtime_RR = linspace(-epoc_start, epoc_end, max_epoch_length);
epoch_times_EEG = linspace(-epoc_start, epoc_end, ceil((epoc_start + epoc_end) * EEG_bands_fs));
mid_point = ceil(epoc_start * RR_fs);  % This should be the index of the event time
total_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);


% Sleep stage variables and titles
% NE_trough_variables = {NREMexclMA_periods_cut_pklocs, NREMinclMA_periods_cut_pklocs, wake_periods_cut_pklocs, REM_periods_cut_pklocs};
% titles = {'NE troughs NREM excl MA', 'NE troughs NREM incl MA', 'NE troughs Wake', 'NE troughs REM'};

%HRB_variables = {NREMexclMA_periods_cut_HRB_time, NREMinclMA_periods_cut_HRB_time, wake_periods_cut_HRB_time, REM_periods_cut_HRB_time};
%titles = {'HRB NREM excl MA', 'HRB NREM incl MA', 'HRB Wake', 'HRB REM'};

pklocs_variables = {NREMexclMA_periods_cut_pklocs, SWS_before_MA_filtered_pklocs, SWS_before_wake_filtered_pklocs, REM_before_wake_filtered_pklocs};
titles = {'NE troughs NREM', 'NE troughs NREM to MA Transition', 'NE troughs NREM to Wake Transition', 'NE troughs REM to Wake Transition'};

% Assuming all necessary variables are defined and calculate_power_bands_PSD is correctly implemented
for stage_idx = 1:length(pklocs_variables)
    figure; % One figure per sleep stage
    sgtitle([titles{stage_idx} ' - EEG Power Bands']);
    
    event_type = pklocs_variables{stage_idx};
    event_name = titles{stage_idx};  % Current event name for titles
    num_events = length(event_type); % Assuming this is correctly calculated elsewhere
    
    for band_idx = 1:length(power_bands)
        band = power_bands{band_idx};
        band_freq_indices = F >= band{1} & F <= band{2}; % Find indices of frequencies within the band
        
        % Initialize arrays for mean power and SEM
        all_event_power_values = []; % This will store the power values for all events

        for event_idx = 1:length(event_type)  % <-- Here is where the typo was fixed
            event_time = event_type(event_idx);  % <-- Correct variable name
            % Find indices of times within the window around the current event
            event_time_indices = find(time_spectrogram_zero >= (event_time - pre_event_time) & time_spectrogram_zero <= (event_time + post_event_time));
            
            if ~isempty(event_time_indices)
                % Extract power values for the band and time around the current event
                event_power_values = filtered_mean_spectrogram(band_freq_indices, event_time_indices);
                all_event_power_values = [all_event_power_values, event_power_values]; % Concatenate power values from each event
            end
        end

        % Now calculate mean and SEM across all events
        mean_power = mean(all_event_power_values, 2).'; % Compute mean power across all events and transpose
        sem_power = std(all_event_power_values, 0, 2).' / sqrt(size(all_event_power_values, 2)); % Compute SEM across all events and transpose
        
        % Ensure time_points has the same length as mean_power and sem_power
        time_points = linspace(-pre_event_time, post_event_time, length(mean_power)); % time_points is now a row vector

        subplot(length(power_bands) + 2, 1, band_idx + 2);
        
        % Plotting mean power as a line
        plot(time_points, mean_power, 'LineWidth', 1.5, 'Color', [0.4660 0.6740 0.1880]); % Plot mean power
        hold on;
        % Adding shading for SEM
        fill([time_points, fliplr(time_points)], [mean_power+sem_power, fliplr(mean_power-sem_power)], ...
             [0 1 0], 'linestyle', 'none', 'FaceAlpha', 0.3); % Add shading for SEM
        hold off;
        
        title([band{3} ' Band']);
        xlabel('Time relative to event (s)');
        ylabel('Mean Power (log)');
        xlim([-epoc_start, epoc_end]);
        grid on; % Add grid
    end

    % Since num_events is used before the loop, initialize RR_collector based on event_type length
    RR_collector = NaN(max_epoch_length, length(event_type));

    for i = 1:length(event_type)
        HRB_i = event_type(i);

        if HRB_i < RR_time(1) + epoc_start || HRB_i > RR_time(end) - epoc_end
            disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
            continue;  % Skip this event
        end

        [~, event_idx] = min(abs(RR_time - HRB_i));  % Find the event index in RR_time

        epoch_start_idx = max(event_idx - mid_point + 1, 1);
        epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(RR));

        if epoch_end_idx - epoch_start_idx + 1 <= total_epoch_length
            RR_collector(1:(epoch_end_idx - epoch_start_idx + 1), i) = RR(epoch_start_idx:epoch_end_idx);
        end

    end
    mean_filtered_RR_epocs = nanmean(RR_collector, 2);
    
    % Add shading for SE
    % Calculate the standard deviation while ignoring NaNs
    RR_std = nanstd(RR_collector, 0, 2);
        
    % Calculate the number of non-NaN observations for each time point to use in the SEM calculation
    nonNaN_counts_RR = sum(~isnan(RR_collector), 2);
        
    % Calculate SEM, protecting against division by zero for time points with no valid data
    RR_sem = RR_std ./ sqrt(nonNaN_counts_RR);
    
    % Calculate upper and lower SEM bounds
    upper_SEM_bound = mean_filtered_RR_epocs + RR_sem;
    lower_SEM_bound = mean_filtered_RR_epocs - RR_sem;
    
    % Transpose upper and lower SEM bounds to match the orientation of epoc_FPtime_RR
    upper_SEM_bound = upper_SEM_bound';
    lower_SEM_bound = lower_SEM_bound';
    
    % Prepare the fill area coordinates
    fill_area_x = [epoc_FPtime_RR, fliplr(epoc_FPtime_RR)];
    fill_area_y = [upper_SEM_bound, fliplr(lower_SEM_bound)];
    
    % Ensure the fill area has the correct dimensions
    if numel(epoc_FPtime_RR) ~= numel(upper_SEM_bound)
        error('SEM bounds and time vector do not match in length.');
    end
    
    % Plot RR intervals as the first subplot
    subplot(length(power_bands) + 2, 1, 1); % Allocate space for RR interval plot at the top
    plot(epoc_FPtime_RR, mean_filtered_RR_epocs, 'LineWidth', 1);
    hold on;
    fill(fill_area_x, fill_area_y, 'r', 'FaceAlpha', 0.3); % Fill between upper and lower bounds
    plot([0 0], ylim, 'r--'); % Red dotted line at timepoint 0
    hold off;
    title([' RR interval (' num2str(length(event_type)) ' Events)']);
    ylabel('RR interval');
    xlabel('Time (s)');
    xlim([-30, 60]);
    % Note: This section will use epoc_FPtime_RR, RR_time, and RR with modifications to fit into the subplot.
     
    % Pre-allocate NE_peak_epoc_collector with NaNs
        % Assuming `length(HRB_variables{stage_idx})` gives the number of events for the current sleep stage
        NE_peak_epoc_collector = NaN(length(event_type), epoch_length);
        
        for i = 1:length(event_type)
            NEpk_i = event_type(i);
            if NEpk_i > sec_signal_2(end) - epoc_end % Skip if event is too close to end of recording
                continue;
            end
            
            % Calculate rounded indices for start and end of the epoch
            start_idx = round((NEpk_i - epoc_start) * NE_fs);
            end_idx = round((NEpk_i + epoc_end) * NE_fs);
            
            % Ensure indices are within the bounds of the delta465_filt_2 array
            start_idx = max(start_idx, 1);
            end_idx = min(end_idx, length(delta465_filt_2));
            
            % Extract the epoch, adjusting for possible index out-of-bounds
            epoch_length_actual = end_idx - start_idx + 1;
            NEpk_epoc_i = delta465_filt_2(start_idx:end_idx);
            
            % Fill the current row of NE_peak_epoc_collector, adjusting for potential length differences
            NE_peak_epoc_collector(i, 1:epoch_length_actual) = NEpk_epoc_i;
        end
    
    % Calculate the expected length of each epoch based on the adjusted sampling frequency
    epoch_length = round((epoc_end + epoc_start) * NE_fs);
    
    % Adjust epoc_FPtime_NE to match this epoch length
    epoc_FPtime_NE = linspace(-epoc_start, epoc_end, epoch_length);
    
    % Assuming NE_peak_epoc_collector has been correctly filled as per the previous steps
    mean_NEpk_epocs = nanmean(NE_peak_epoc_collector, 1);
    
    % Correctly adjust epoc_FPtime_NE to match the epoch length
    epoc_FPtime_NE = linspace(-epoc_start, epoc_end, length(mean_NEpk_epocs));
    
    % Calculate standard error of the mean (SEM) for shading
    % Calculate the standard deviation while ignoring NaNs for NE activity
    NE_std = nanstd(NE_peak_epoc_collector, 0, 1);
    
    % Calculate the number of non-NaN observations for each time point
    nonNaN_counts_NE = sum(~isnan(NE_peak_epoc_collector), 1);
    
    % Calculate SEM for NE activity, with protection against division by zero
    NE_sem = NE_std ./ sqrt(nonNaN_counts_NE);

    % Plot for NE activity
    subplot(length(power_bands) + 2, 1, 2);
    hold on;
    
    % Plotting the mean NEpk epochs
    plot(epoc_FPtime_NE, mean_NEpk_epocs, 'LineWidth', 1); 
    
    % Add shading for SEM
    fill([epoc_FPtime_NE, fliplr(epoc_FPtime_NE)], [mean_NEpk_epocs + NE_sem, fliplr(mean_NEpk_epocs - NE_sem)], 'b', 'linestyle', 'none', 'FaceAlpha', 0.3);
    
    % Ensure the line at x=0 is correctly drawn
    current_ylim = ylim; % Get current y-axis limits
    plot([0 0], ylim, 'r--');  % Red dotted line at timepoint 0
    
    hold off;
    title([' NE (' num2str(num_events) ' Events)']);
    ylabel('NE Activity');
    xlabel('Time (s)');
    xlim([-30, 60]);
end
%% Playground

% Assuming filtered_RR_smooth and filtered_RR_time are already loaded in your workspace

% Define the target sampling rate
new_fs = 64; % 64 Hz

% Create a new time vector with a fixed sampling rate of 64 Hz, starting from the first to the last observation in the original time vector
new_time_vector = filtered_RR_time(1):1/new_fs:filtered_RR_time(end);

% Use interpolation to resample RR intervals at these new time points
% 'linear' interpolation is commonly used, but you can choose another method if it fits your data better
resampled_RR = interp1(filtered_RR_time, filtered_RR_smooth, new_time_vector, 'linear');

% 2. Segmentation
segment_length = 16 * new_fs; % 16 seconds * 64 Hz
overlap = segment_length / 2; % 50% overlap
num_segments = floor((length(resampled_RR) - overlap) / (segment_length - overlap));

% Initialize variables for LF%, time for LF%, power spectrum, and frequencies
LF_percent = zeros(1, num_segments);
time_LF_percent = zeros(1, num_segments);
power_spectrums = cell(1, num_segments); % For storing power spectrum of each window
frequencies = cell(1, num_segments); % For storing frequencies of each window

% Loop through segments
for i = 1:num_segments
    start_index = 1 + (i-1) * (segment_length - overlap);
    end_index = start_index + segment_length - 1;
    
    % 3. Windowing
    segment = resampled_RR(start_index:end_index);
    windowed_segment = segment .* hamming(length(segment));
    
    % 4. FFT and Power Spectrum Calculation
    NFFT = 2^nextpow2(length(windowed_segment));
    fft_segment = fft(windowed_segment, NFFT) / length(windowed_segment);
    f = new_fs/2 * linspace(0, 1, NFFT/2+1);
    Pxx = (1/(new_fs*NFFT)) * abs(fft_segment(1:NFFT/2+1)).^2;
    Pxx(2:end-1) = 2*Pxx(2:end-1); % Single-sided spectrum
    
    % Store power spectrum and frequencies
    power_spectrums{i} = Pxx;
    frequencies{i} = f;
    
    % 6. Band Power Calculation
    TP = bandpower(Pxx, f, [0.4, 6], 'psd');
    LF = bandpower(Pxx, f, [0.4, 1.5], 'psd');
    HF = bandpower(Pxx, f, [1.5, 4.0], 'psd');

    LF_percent(i) = (LF / TP) * 100;
    HF_percent(i) = (HF/ TP) * 100;
    LF(i) = LF;
    
    % Time vector for LF%
    time_LF_percent(i) = mean(resampled_time(start_index:end_index));
end

all_powers = zeros(length(freqs), length(power_spectrums));
% Loop through each power spectrum, adding it to the matrix
for i = 1:length(power_spectrums)
    all_powers(:, i) = power_spectrums{i};
end

% % Plotting
% figure;
% plot(freqs, mean_power_spectrum);
% xlabel('Frequency (Hz)');
% ylabel('Power Spectrum (Mean across all windows)');
% title('Average Power Spectrum Across All Windows');

% Calculate the mean power spectrum across all windows
mean_power_spectrum = mean(all_powers, 2);
% Convert time_LF_percent back to match original filtered_RR_time scale
% Assuming linear mapping is sufficient due to uniform resampling
original_time_indices = interp1(filtered_RR_time, 1:length(filtered_RR_time), time_LF_percent, 'nearest', 'extrap');


%% 

% 7. Plotting LF% Over Time
figure;
plot(filtered_RR_time(original_time_indices), LF_percent);
xlabel('Time (s)');
ylabel('LF%');
title('LF% Over Time');

figure;
plot(filtered_RR_time(original_time_indices), HF_percent);
xlabel('Time (s)');
ylabel('HF%');
title('HF% Over Time');

%% Playground 2

% Preliminary setup
RR_fs = 1 / median(diff(filtered_RR_time)); % Your existing sample rate calculation
new_fs = 64; % Target sampling rate

% Resample RR intervals at 64 Hz
[p, q] = rat(new_fs / RR_fs); % Determine resampling factors
resampled_RR = resample(filtered_RR_smooth, p, q);

% Time vector for resampled data
resampled_time = linspace(filtered_RR_time(1), filtered_RR_time(end), length(resampled_RR));

% Segmenting data with 50% overlap
segment_duration = 16; % seconds
segment_samples = segment_duration * new_fs; % 1024 samples
overlap_samples = segment_samples / 2;
num_segments = floor((length(resampled_RR) - overlap_samples) / (segment_samples - overlap_samples));

% Initialize variables to store LF% and segment times
LF_percent = zeros(1, num_segments);
segment_times = zeros(1, num_segments);

% Loop through segments
for i = 1:num_segments
    % Calculate segment indices
    start_idx = (i-1) * (segment_samples - overlap_samples) + 1;
    end_idx = start_idx + segment_samples - 1;
    
    % Extract segment
    segment = resampled_RR(start_idx:end_idx);
    
    % Apply Hamming window
    windowed_segment = segment .* hamming(segment_samples);
    
    % FFT and power spectrum
    fft_segment = fft(windowed_segment);
    power_spectrum = abs(fft_segment).^2 / segment_samples;
    
    % Frequency vector
    freqs = new_fs / 2 * linspace(0, 1, segment_samples / 2 + 1);
    
    % Calculate power bands
    TP = bandpower(power_spectrum, new_fs, [0.4, new_fs/2]);
    LF = bandpower(power_spectrum, new_fs, [0.4, 1.5]);
    HF = bandpower(power_spectrum, new_fs, [1.5, 4.0]);
    LF_percent(i) = LF / TP * 100;
    
    % Calculate mid-segment time
    segment_times(i) = mean(resampled_time(start_idx:end_idx));
end
figure;
% Plot LF% over time
plot(segment_times, LF_percent);
xlabel('Time (seconds)');
ylabel('LF%');
title('LF% over Original Time');

%% ICA playground
filtered_EMG_ICA = double(filtered_EMG);
[coeffs, L] = wavedec(filtered_EMG_ICA, 8, 'db4');
coeffs_rescaled = coeffs * 1000; % Example scaling factor
[icasig, A, W] = fastica(coeffs_rescaled);
for i = 1:size(icasig, 1)
    componentEnvelope = abs(hilbert(icasig(i, :)));
    % Further analysis to identify ECG components
end
% Assume 'icasig' contains the independent components obtained from ICA
numComponents = size(icasig, 1);

% Plotting all components
figure;
for i = 1:numComponents
    subplot(numComponents, 1, i);
    plot(icasig(i, :));
    title(['ICA Component ', num2str(i)]);
end
