classdef MEAWithLightCrafter < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = MEAWithLightCrafter()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            import edu.washington.*;

            % Add the HEKA A/D board.
            daq = HekaDaqController();
            obj.daqController = daq;
            
            % Add the Multiclamp device (demo mode).
            amp1 = MultiClampDevice('Amp1', 1).bindStream(daq.getStream('ao0')).bindStream(daq.getStream('ai0'));
            obj.addDevice(amp1);
            
            % Add the LightCrafter
            ramps = containers.Map();
            ramps('red')    = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'red_gamma_ramp.txt'));
            ramps('green')  = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'green_gamma_ramp.txt'));
            ramps('blue')   = 65535 * importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'blue_gamma_ramp.txt'));
            
            lightCrafter = manookinlab.devices.LcrVideoDevice(...
                'micronsPerPixel', 2.67, ...
                'gammaRamps', ramps, ...
                'host', '192.168.0.102', ...
                'ledCurrents',[10,7,50],...
                'customLightEngine',true);
            
            myspect = containers.Map( ...
                {'red', 'green_505', 'green_565', 'blue'}, { ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Red_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Green_505nm_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Green_570nm_spectrum.txt')), ...
                importdata(riekelab.Package.getCalibrationResource('rigs', 'suction', 'lightcrafter_Blue_spectrum.txt'))});
            
            lightCrafter.addResource('spectrum', myspect);
            
            % Binding the lightCrafter to an unused stream only so its configuration settings are written to each epoch.
            daq = obj.daqController;
            lightCrafter.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(lightCrafter, 15);
            
            qCatch = zeros(3,4);
            names = {'red','green_565','blue'};
            for jj = 1 : length(names)
                q = myspect(names{jj});
                qCatch(jj,:) = manookinlab.util.computeQuantalCatch(q(:, 1), q(:, 2));
            end
            lightCrafter.addResource('quantalCatch', qCatch);
            obj.addDevice(lightCrafter);
            
            % Add the frame monitor to record the timing of the monitor refresh.
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(daq.getStream('ai7'));
            obj.addDevice(frameMonitor);
            
            % Add a device for external triggering to synchronize MEA DAQ clock with Symphony DAQ clock.
            trigger = riekelab.devices.TriggerDevice();
            trigger.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(trigger, 0);
            obj.addDevice(trigger);
            
            % Add the filter wheel.
            filterWheel = edu.washington.riekelab.devices.FilterWheelDevice('comPort', 'COM5');
            
            % Binding the filter wheel to an unused stream only so its configuration settings are written to each epoch.
            filterWheel.bindStream(daq.getStream('doport1'));
            daq.getStream('doport1').setBitPosition(filterWheel, 14);
            obj.addDevice(filterWheel);
            
            % Get the red sync pulse from the lightcrafter.
            red_ttl = UnitConvertingDevice('Red Sync', 'V').bindStream(daq.getStream('ai5'));
            obj.addDevice(red_ttl);
            
            % Add the MEA device controller. This waits for the stream from Vision, strips of the header, and runs the block.
%             mea = manookinlab.devices.MEADevice('host', '192.168.0.100');
            mea = manookinlab.devices.MEADevice(9001);
            obj.addDevice(mea);
        end
    end
end

