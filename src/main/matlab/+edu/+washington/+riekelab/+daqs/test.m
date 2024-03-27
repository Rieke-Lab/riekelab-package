

session = daq.createSession('ni');

devices = daq.getDevices;

device_name = 'Dev1';

% Set the sampling rate for the session.
session.Rate = 1000;
session.DurationInSeconds = 2;

addAnalogInputChannel(session,device_name, 0, 'Voltage');
%addAnalogInputChannel(s,deviceID,channelID,measurementType)
%addAnalogOutputChannel(s,deviceName,channelID,measurementType)
% addDigitalChannel(s,'Dev2','port0/line0:3','OutputOnly');
%addDigitalChannel(s,deviceID,channelID,measurementType)'InputOnly' or
%'OutputOnly'

session.startBackground();

session.wait();

% addTriggerConnection(session,'External','Dev4/PFI0','StartTrigger');

session.Connections

s.ExternalTriggerTimeout = 30;

s.TriggersPerRun = 1;


