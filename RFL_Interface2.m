function varargout = RFL_Interface2(varargin)
% RFL_INTERFACE2 MATLAB code for RFL_Interface2.fig
%      RFL_INTERFACE2, by itself, creates a new RFL_INTERFACE2 or raises the existing
%      singleton*.
%
%      H = RFL_INTERFACE2 returns the handle to a new RFL_INTERFACE2 or the handle to
%      the existing singleton*.
%
%      RFL_INTERFACE2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RFL_INTERFACE2.M with the given input arguments.
%
%      RFL_INTERFACE2('Property','Value',...) creates a new RFL_INTERFACE2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RFL_Interface2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RFL_Interface2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RFL_Interface2

% Last Modified by GUIDE v2.5 26-Apr-2016 10:23:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RFL_Interface2_OpeningFcn, ...
                   'gui_OutputFcn',  @RFL_Interface2_OutputFcn, ...
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


% --- Executes just before RFL_Interface2 is made visible.
function RFL_Interface2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RFL_Interface2 (see VARARGIN)

% Choose default command line output for RFL_Interface2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RFL_Interface2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RFL_Interface2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_fname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fname as text
%        str2double(get(hObject,'String')) returns contents of edit_fname as a double


% --- Executes during object creation, after setting all properties.
function edit_fname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Fload.
function pushbutton_Fload_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Fload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname,pname] = uigetfile('*.xls;*.xlsx','Select The Product List File');
handles.xlspath = fullfile(pname,fname);
set(handles.edit_fname,'String',handles.xlspath);
guidata(hObject,handles);


function edit_Maxno_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Maxno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Maxno as text
%        str2double(get(hObject,'String')) returns contents of edit_Maxno as a double


% --- Executes during object creation, after setting all properties.
function edit_Maxno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Maxno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_grid_Callback(hObject, eventdata, handles)
% hObject    handle to edit_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_grid as text
%        str2double(get(hObject,'String')) returns contents of edit_grid as a double


% --- Executes during object creation, after setting all properties.
function edit_grid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_wsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wsize as text
%        str2double(get(hObject,'String')) returns contents of edit_wsize as a double


% --- Executes during object creation, after setting all properties.
function edit_wsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ArrangeDice.
function pushbutton_ArrangeDice_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ArrangeDice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Maxno = str2num(get(handles.edit_Maxno,'String'));
handles.gsize = str2num(get(handles.edit_grid,'String'));
handles.wsize = str2num(get(handles.edit_wsize,'String'));
handles.slwidth = str2num(get(handles.edit_slwidth,'String'));
handles.Rxmax = str2num(get(handles.edit_Rxmax,'String'));
handles.Rymax = str2num(get(handles.edit_Rymax,'String'));

[~,~,Dice_data] = xlsread(handles.xlspath,1,['B2:J' num2str(handles.Maxno+1)]);
Did = 1:size(Dice_data,1);
Ddim = cell2mat(Dice_data(:,2:3))+handles.slwidth;
Dvol = cell2mat(Dice_data(:,4));
Dreq = cell2mat(Dice_data(:,5:8));

Gpara.Rmax = [handles.Rxmax handles.Rymax]*10^3;
Gpara.Sline = handles.slwidth;

[Fcor,Fsets] = DicePacking( Did,Ddim(:,1),Ddim(:,2),Dvol,Dreq,Gpara,handles.axes1);
Rnew = [max(Fcor(:,3))-min(Fcor(:,1)) max(Fcor(:,4))-min(Fcor(:,2))]/10^3;
[map_in,map_on,xx,yy,xoffset,yoffset] = DieOffset(Rnew(1),Rnew(2),handles.wsize,handles.axes2);
% Options for Stepper/Normal Reticle
% RFL import function (Group Info + Same Cut-set Info) with decided coordinates

set(handles.edit_bsize,'String',num2str(Rnew));
set(handles.edit_bshift,'String',num2str([xoffset,yoffset]));
set(handles.edit_shotno,'String',num2str(sum(map_in(:))));

guidata(hObject,handles);


function edit_bsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bsize as text
%        str2double(get(hObject,'String')) returns contents of edit_bsize as a double


% --- Executes during object creation, after setting all properties.
function edit_bsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_bshift_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bshift as text
%        str2double(get(hObject,'String')) returns contents of edit_bshift as a double


% --- Executes during object creation, after setting all properties.
function edit_bshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_shotno_Callback(hObject, eventdata, handles)
% hObject    handle to edit_shotno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_shotno as text
%        str2double(get(hObject,'String')) returns contents of edit_shotno as a double


% --- Executes during object creation, after setting all properties.
function edit_shotno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_shotno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_slwidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_slwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_slwidth as text
%        str2double(get(hObject,'String')) returns contents of edit_slwidth as a double


% --- Executes during object creation, after setting all properties.
function edit_slwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_slwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Rymax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Rymax as text
%        str2double(get(hObject,'String')) returns contents of edit_Rymax as a double


% --- Executes during object creation, after setting all properties.
function edit_Rymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Rymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Rxmax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Rxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Rxmax as text
%        str2double(get(hObject,'String')) returns contents of edit_Rxmax as a double


% --- Executes during object creation, after setting all properties.
function edit_Rxmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Rxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
