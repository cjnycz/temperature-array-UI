function [TemperatureData] = processtemperaturedata(ADCdata)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Define the order that the thermistors are recieved from the
% microcontroller
SortOrder = [2, 6, 11, 19, 32, 40, 12, 20, 45, 37, 29, 25, 1, 5, 9, 17,...
             18, 10, 31, 39, 46, 38, 30, 26, 23, 15, 8, 4, 36, 44, 16,...
             24, 47, 41, 33, 27, 21, 13, 7, 3, 14, 22, 43, 35, 48, ...
             42, 34, 28, 49, 50, 51, 52, 53, 54];

% Convert the ADC data to temperautre in Degrees Farenheit   
[T] = thermistorequation(ADCdata);

T(:,47) = thermistorequation_RESET(ADCdata(:,47));
T(:,23) = thermistorequation_RESET(ADCdata(:,23));

%T(:,48) = T(:,47);
%T(:,24) = T(:,23);

% Determine the dimension of the T matrix
[Rows,Columns] = size(T);

% Create an empty matrix for sorting the temperature data into
TemperatureData = zeros(Rows,Columns);

% Sort the temperature data
for i = 1:Rows
    for k = 1:Columns
        TemperatureData(i,SortOrder(k)) = T(i,k);
    end    
end

end

