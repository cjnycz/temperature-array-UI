function [serialPortInfo, returnMessage] = xbeeconnect(ComPort,BaudRate)
%Christopher Nycz
%9/3/16

%   Inputs:  comPort - Name of the usb port which connects the computer to
%                      the arduino

%   Outputs: serialPortInfo - The struct describing the serial port just
%                             created
%            returnMessage  - Message returned from the hand exo. If
%                             connection was established, this will be 
%                             returned as 'connected'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function which sets up serial communication with the wireless radio used
%to communicate with the hand exo. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check available serial ports
AvailableSerialPorts = seriallist;
returnMessage = 'not connected';
serialPortInfo = [];

if ismember(ComPort,AvailableSerialPorts)

%Create Serial Object
serialPortInfo = serial(ComPort);
serialPortInfo.InputBufferSize = 16400;
%Connect to Serial Port
fopen(serialPortInfo);

%Set serial port parameters
set(serialPortInfo,'BaudRate',BaudRate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Send the string "readytoconnect" to the handexo and wait for a reply,
%resend periodically if no response is recieved. Timeout after a short
%period of time
returnMessage = 'connected';
end
% 
% pause on
% tic
% while ~strcmp('connected', returnMessage) && toc < 5
% %     %Send message to the hand exo and wait for a response
% %     fprintf(serialPortInfo, 'readytoconnect')
% %     pause(.05)
% % 
%     if serialPortInfo.BytesAvailable > 0
%         %Get the recieved message and convert into a string
% %         returnMessage = fgetl(serialPortInfo);
% %         returnMessage = strcat(returnMessage);
%         returnMessage = 'connected';
%     end
%     pause(.05)
% end

end

