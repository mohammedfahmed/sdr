clear
clc

mins = 1;
logTime_s = mins*60; % log duration in seconds
sampleRate = 0.3e6;
samplesPerFrame = 300000; % SamplesPerFrame <= 375000.
numFramesInBurst = mins*60;
numFrames = ceil(logTime_s*sampleRate/samplesPerFrame)
NumBursts = floor(numFrames/numFramesInBurst)
frame_time_ms = (samplesPerFrame/sampleRate)*1e3
CenterFrequency = 315e6;
Gain = 33.8;

rxsdr = comm.SDRRTLReceiver(...
    'RadioAddress','0',...
    'CenterFrequency',CenterFrequency,...
    'SampleRate', sampleRate , ...
    'SamplesPerFrame', samplesPerFrame,...
    'EnableTunerAGC',false,...
    'TunerGain', Gain, ...
    'OutputDataType','double',...p
    'EnableBurstMode', true, ...
    'NumFramesInBurst', numFramesInBurst);

radioInfo = info(rxsdr)


rx = [];

tic
for p = 1:numFrames
    rx(:,p) = rxsdr();
end

t = toc

release(rxsdr)



Bursts = reshape(rx(:), samplesPerFrame*numFramesInBurst, NumBursts);


plot(abs(Bursts(:)))

for i = 1:size(Bursts,2)
    xline(i*size(Bursts,1));
end

clear rx 
%
% figure
% plot(sum(abs(Bursts)))
