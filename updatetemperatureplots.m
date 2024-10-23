function [] = updatetemperatureplots(handles,TemperatureData,DataIndex)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Define the coordinates of all thermistors
[ThermistorCoordinates] = thermistorcoordinates();    

axes(handles.TemperaturePlot);
cla
hold on
title('Temperature Map')
xlabel('x(mm)')
ylabel('y(mm)')

% Define the ambient temperature from thermistors 49-54
AmbientTemp = TemperatureData(DataIndex-1,49:54);

% Create the interpolant using the thermistors clustered around the probe
interpolant = scatteredInterpolant(ThermistorCoordinates(:,1),ThermistorCoordinates(:,2),TemperatureData(DataIndex-1,1:48)','linear');
[xx,yy] = meshgrid(linspace(-20,20,80));  % replace, 0 1, 10 with range of your values

% Interpolate
caxis([60 100])
intensity_interp = interpolant(xx,yy);
contourf(xx,yy,intensity_interp,'edgecolor','none');
%colormap(jet);
colorbar()
axis equal
plot(ThermistorCoordinates(:,1),ThermistorCoordinates(:,2),'.k')


% Plot the time history of the selected individual channels
axes(handles.SingleTemperaturePlot);
cla
contents = get(handles.TemperatureSelect1,'String'); 
PlotLine{1} = contents{get(handles.TemperatureSelect1,'Value')};
PlotLine{2} = contents{get(handles.TemperatureSelect2,'Value')};
PlotLine{3} = contents{get(handles.TemperatureSelect3,'Value')};
PlotLine{4} = contents{get(handles.TemperatureSelect4,'Value')};

Legend = [];
k = 1;
for i = 1:4  
    if PlotLine{i}(1) == 'T' 
        ChannelNumber = str2double(PlotLine{i}(2:end));
        plot(TemperatureData(1:(DataIndex-1),ChannelNumber),'LineWidth',1.5)
        DisplayField = ['TemperatureDisplay',num2str(i)];
        set(handles.(DisplayField),'String',num2str(TemperatureData((DataIndex-1),ChannelNumber)));
%         Legend{k} = convertCharsToStrings(PlotLine{i}); % This line is
%         not compatible with Matlab 2017b
        k = k+1;
    else
        DisplayField = ['TemperatureDisplay',num2str(i)];
        set(handles.(DisplayField),'String','-');
    end
end

% legend(Legend)

end

