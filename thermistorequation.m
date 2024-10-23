function [Temperature] = thermistorequation(ADCReading)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Define some properties of the thermistors
B = 3428;
R0 = 10000;
T0 = 25+273.15;

% Define some properties of the ADC
ADCResolution = 10*1024;  %ADC reading corresponding to AVCC
AVCC = 5;                 %5V ADC voltage reference 

% Convert the ADC reading into volts
Vt = (ADCReading./ADCResolution) .* AVCC;

% Calculate the thermistor resistance
Rt = (10000.*Vt)./(5 - Vt);

% Convert this resistance to temperature
Temperature = 1./((1./B).*log(Rt./R0)+1/T0);

% Convert this temperature into degrees farenheit
Temperature = ((Temperature-273.15).*(9/5)) + 32;

% Round the temperature to 2 significant digits
Temperature = round(Temperature,2);

end

