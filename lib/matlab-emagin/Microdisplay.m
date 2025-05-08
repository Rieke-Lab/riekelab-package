classdef Microdisplay < handle
    
    properties (Access = private, Transient)
        serialPort
    end
    
    methods
        
        function obj = Microdisplay(port)
            if nargin < 1
                port = 'COM4';
            end
            
            obj.serialPort = serial(port);
        end
        
        function delete(obj)
            obj.disconnect();
            delete(obj.serialPort);
        end
        
        function connect(obj)
            fopen(obj.serialPort);
            
            % Test connection.
            fwrite(obj.serialPort, 'T');
            
            [~, ~, msg] = fread(obj.serialPort, 3);
            if ~strcmp(msg, '')
                obj.disconnect();
                error(['Unable to connect: ' msg]);
            end
        end
        
        function disconnect(obj)
            fclose(obj.serialPort);
        end
        
        function setBrightness(obj, brightness)
            fwrite(obj.serialPort, ['U', char(uint8(brightness))]);
            pause(0.1);
        end
        
        function b = getBrightness(obj)
            fwrite(obj.serialPort, 'S');
            
            [data, ~, msg] = fread(obj.serialPort, 4);
            if ~strcmp(msg, '')
                error(msg);
            end
            
            b = data(1);
        end
        
    end
    
end