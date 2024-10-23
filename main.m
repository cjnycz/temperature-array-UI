function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 18-Nov-2018 22:02:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Insert the background image
[I2,map]=imread('Images\Background.jpg');
axes(handles.Background)
axis off
imshow(I2);

%Define the coordinates of all thermistors
[ThermistorCoordinates] = thermistorcoordinates();                  

%Setup the pop-up menus to select the various thermistor channels
ThermistorChannels = {'-',...
                      'T1','T2','T3','T4','T5','T6','T7','T8','T9','T10',...
                      'T11','T12','T13','T14','T15','T16','T17','T18',...
                      'T19','T20','T21','T22','T23','T24','T25','T26',...
                      'T27','T28','T29','T30','T31','T32','T33','T34',...
                      'T35','T36','T37','T38','T39','T40','T41','T42',...
                      'T43','T44','T45','T46','T47','T48','T49','T50',...
                      'T51','T52','T53','T54'};               

set(handles.TemperatureSelect1,'string',ThermistorChannels);
set(handles.TemperatureSelect2,'string',ThermistorChannels);
set(handles.TemperatureSelect3,'string',ThermistorChannels);
set(handles.TemperatureSelect4,'string',ThermistorChannels);

%Setup plot axes
axes(handles.TemperaturePlot);
cla
hold on
title('Temperature Map')
xlabel('x(mm)')
ylabel('y(mm)')

% Initialize the contour plot
intensity = 98.6*ones(length(ThermistorCoordinates),1);
intensity(1) = 110;
intensity(2) = 100;
intensity(4) = 100;
intensity(5) = 105;
intensity(25) = 108;
intensity(26) = 108;
intensity(36) = 102;
intensity(31) = 102;
intensity(29) = 102;
intensity(30) = 102;

interpolant = scatteredInterpolant(ThermistorCoordinates(:,1),ThermistorCoordinates(:,2),intensity,'linear');
[xx,yy] = meshgrid(linspace(-20,20,80));  % replace, 0 1, 10 with range of your values

% Interpolate
intensity_interp = interpolant(xx,yy);
contourf(xx,yy,intensity_interp,'edgecolor','none');
colormap(jet);
colorbar()
axis equal

plot(ThermistorCoordinates(:,1),ThermistorCoordinates(:,2),'.k')
%[X,Y] = meshgrid(ThermistorCoordinates(:,1),ThermistorCoordinates(:,2));
%surf(X,Y,Z)

axes(handles.SingleTemperaturePlot);
cla
hold on
grid on
title('Channel Plots')
xlabel('time(s)')
ylabel('Temperature (^\circF)')





% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ComPort_Callback(hObject, eventdata, handles)
% hObject    handle to ComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ComPort as text
%        str2double(get(hObject,'String')) returns contents of ComPort as a double



% --- Executes during object creation, after setting all properties.
function ComPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SerialConnect.
function SerialConnect_Callback(hObject, eventdata, handles)
% hObject    handle to SerialConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stop
stop = false;

% Define the baud rate for communication with the arduino
BaudRate = 115200;

% Define the number of ADC channels being recieved
NumberOfChannels = 54;

%Define some matricies for storing and reading data
DataStreamRemainder = []; % Remainder of a packet not fully read
TemperatureData = zeros(1000000,NumberOfChannels);
DataIndex = 1;

%Load temperature offsets for each thermistor
load('TempOffsets.mat');
Median_offset = round(Median_offset,1);
T_selfheating = 3; % 3F of self heating is measured in air

%Specify the number of points to display in the plot
PlotWindow = 100;

%Clear any currently in-use devices
delete(instrfind)

%Specify the number of bytes to read from the serial buffer. 
NumberOfBytesToRead = 500;

%Connect to the serial port 
PortName = get(handles.ComPort,'String');
[SerialPort, ErrorMessage] = xbeeconnect(PortName,BaudRate);
flushinput(SerialPort);

pause on

while ~stop
    
    % Read data if it's available 
    if SerialPort.BytesAvailable >= NumberOfBytesToRead
        
        % Read the byte data from the serial port
        DataStream = fread(SerialPort,NumberOfBytesToRead);
        
        % Parse the data into ADC readings for the various thermistors
        [ADCdata, DataStreamRemainder] = parsetemperaturepacket([DataStreamRemainder;DataStream]);
        
        % Calculate the temperature from the data and sort
        [T] = processtemperaturedata(ADCdata);
        
        %Find the size of the newly recieved temperature array
        [Rows,Columns] = size(T);
        
        % Remove the offset of each thermistor
        for i = 1:48 %Columns
            T(:,i) = T(:,i) - Median_offset(i);%- T_selfheating
        end
        
        % Record the temperature data in the array
        TemperatureData(DataIndex:(DataIndex+Rows-1),:) = T;
        DataIndex = DataIndex+Rows;
        
        % Plot the temperature
        updatetemperatureplots(handles,TemperatureData,DataIndex);

        %flushinput(SerialPort);
    end
    pause(.005)
end

delete(instrfind)

% If Data has been collected, write the data to a file
if ~isempty(DataIndex) && DataIndex > 1
    FileName = datestr(now,'mm-dd-yyyy HH MM SS');
    csvwrite(['DataFiles\',FileName,'.csv'],TemperatureData(1:DataIndex,:));
    %logmessage(SessionLog,handles,[num2str(DataIndex),' samples of data written to file: "',FileName,'.csv"']);
end



% --- Executes on button press in SerialDisconnect.
function SerialDisconnect_Callback(hObject, eventdata, handles)
% hObject    handle to SerialDisconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stop
stop = true;



function TemperatureDisplay1_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TemperatureDisplay1 as text
%        str2double(get(hObject,'String')) returns contents of TemperatureDisplay1 as a double


% --- Executes during object creation, after setting all properties.
function TemperatureDisplay1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TemperatureSelect1.
function TemperatureSelect1_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TemperatureSelect1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TemperatureSelect1


% --- Executes during object creation, after setting all properties.
function TemperatureSelect1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TemperatureDisplay2_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TemperatureDisplay2 as text
%        str2double(get(hObject,'String')) returns contents of TemperatureDisplay2 as a double


% --- Executes during object creation, after setting all properties.
function TemperatureDisplay2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TemperatureSelect2.
function TemperatureSelect2_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TemperatureSelect2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TemperatureSelect2


% --- Executes during object creation, after setting all properties.
function TemperatureSelect2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TemperatureDisplay3_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TemperatureDisplay3 as text
%        str2double(get(hObject,'String')) returns contents of TemperatureDisplay3 as a double


% --- Executes during object creation, after setting all properties.
function TemperatureDisplay3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TemperatureSelect3.
function TemperatureSelect3_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TemperatureSelect3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TemperatureSelect3


% --- Executes during object creation, after setting all properties.
function TemperatureSelect3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TemperatureDisplay4_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TemperatureDisplay4 as text
%        str2double(get(hObject,'String')) returns contents of TemperatureDisplay4 as a double


% --- Executes during object creation, after setting all properties.
function TemperatureDisplay4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureDisplay4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TemperatureSelect4.
function TemperatureSelect4_Callback(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TemperatureSelect4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TemperatureSelect4


% --- Executes during object creation, after setting all properties.
function TemperatureSelect4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TemperatureSelect4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
