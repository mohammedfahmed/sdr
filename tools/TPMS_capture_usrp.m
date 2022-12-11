% connectedRadios = findsdru


mins = 1;
logTime_s = mins*60; % log duration in seconds

MasterClockRate = 32e6;
samplesPerFrame = 3e5; % Expected FrameLength to be a scalar with value <= 375000.
sampleRate = 2e6;
DecimationFactor = MasterClockRate/sampleRate;
CenterFrequency = 315e6;
Gain = 70;

numFrames = ceil(logTime_s*sampleRate/samplesPerFrame)
frame_time_ms = (samplesPerFrame/sampleRate)*1e3
numFramesInBurst = ceil(60*1000/frame_time_ms)
NumBursts = floor(numFrames/numFramesInBurst)

% The maximum burst size (in frames) is imposed by the operating system
% and the USRP device UHD. The maximum size imposed by the UHD is
% approximately 1 GB, or 256 megasamples.
% Expected SamplesPerFrame to be a scalar with value <= 375000.

% samplesPerFrame = 0.1*sampleRate
% numFrames = 600
% numFramesInBurst = 600
% NumBursts = floor(numFrames/numFramesInBurst)

if (samplesPerFrame*numFramesInBurst)>256e6
    disp('error')
    numFramesInBurst = ceil(60*1000/frame_time_ms)/10
    NumBursts = floor(numFrames/numFramesInBurst)
    
end

frame_time_ms = (samplesPerFrame/sampleRate)*1e3

if strncmp(connectedRadios(1).Status, 'Success', 7)
    Platform = connectedRadios(1).Platform;
    Address = connectedRadios(1).SerialNum;
else
    error("Can't find USRP")
end


radio = comm.SDRuReceiver(...
    'Platform',          Platform, ...
    'SerialNum',         Address, ...
    'CenterFrequency',   CenterFrequency, ...
    'MasterClockRate',   MasterClockRate, ...
    'DecimationFactor',  DecimationFactor, ...
    'Gain',              Gain, ...
    'EnableBurstMode',   true,...
    'NumFramesInBurst',  numFramesInBurst, ...
    'SamplesPerFrame',   samplesPerFrame, ...
    'TransportDataType', 'int8', ...
    'OutputDataType',    'double');


info(radio)

rx = zeros(samplesPerFrame, numFrames);

disp('Start Capture!')
tic
    
len = 0;
for frame = 1:numFrames
    while len == 0
        [data, len, overrun(frame)] = radio();
        rx(:,frame) = data;
    end
    len = 0;
    
end

t = toc
disp('End Capture!')

Bursts = reshape(rx(:), samplesPerFrame*numFramesInBurst, NumBursts);


plot(abs(Bursts(:)))

for i = 1:size(Bursts,2)
    xline(i*size(Bursts,1));
end

% clear rx

release(radio);
