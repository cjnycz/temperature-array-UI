function [DataArray, DataStreamRemainder] = parsetemperaturepacket(DataStream)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

PacketLength = 108;
TempArrayIndex = 1;
StopIndex = length(DataStream);

% Each packet contains a start and stop byte, and 2 bytes per channel
NumberOfChannels = (PacketLength)/2; 

% Initialize some matricies, extra rows of zeros will be truncated at the
DataArray = zeros(length(DataStream),NumberOfChannels);
DataStreamRemainder = [];

%Packet Structure 
% StopByte
% 0xff 0xff [ Data Bytes] 0xff 0xff [ Data Bytes ] 0xff 0xff

for i = 2:(length(DataStream)-(PacketLength+2))
    
   % Check if the current index could be the start of a new packet. 
   if DataStream(i) == 255 && DataStream(i-1) == 255
       
       % If it can be, Check that the stop byte is a packet length away
       if DataStream(i + PacketLength + 1) == 255 && DataStream(i + PacketLength +2) == 255
           
           % Define the start index of the data
           StartIndex = i + 1;
           StopIndex  = i + PacketLength;
           
           for k = 1:NumberOfChannels
               MSBIndex = StartIndex + (k-1)*2;
               LSBIndex = MSBIndex + 1; 
               DataArray(TempArrayIndex,k) = DataStream(MSBIndex)*256 + DataStream(LSBIndex);
           end 
           TempArrayIndex = TempArrayIndex + 1;
       end
   end  
    
end

% Truncate the 0s from the returned matricies
if TempArrayIndex > 1
    DataArray = DataArray(1:(TempArrayIndex-1),:);
else
    DataArray = [];
end

if StopIndex <= length(DataStream)
    DataStreamRemainder = DataStream(StopIndex:end);
end



