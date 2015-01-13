function varargout = Savedlg(varargin)
% SAVEDLG Application M-file for untitled.fig
%   SAVEDLG, by itself, creates a new SAVEDLG or raises the existing
%   singleton*.
%
%   H = SAVEDLG returns the handle to a new SAVEDLG or the handle to
%   the existing singleton*.
%
%   SAVEDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in SAVEDLG.M with the given input arguments.
%
%   SAVEDLG('Property','Value',...) creates a new SAVEDLG or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before modaldlg_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to Savedlg_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Copyright 2000-2006 The MathWorks, Inc.

% Last Modified by GUIDE v2.5 04-Jan-2011 13:32:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @Savedlg_OpeningFcn, ...
                   'gui_OutputFcn',     @Savedlg_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Savedlg is made visible.
function Savedlg_OpeningFcn(hObject, eventdata, handles,CurParamStr,ParamStr, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Savedlg (see VARARGIN)

% Choose default command line output for Savedlg
%handles.output = 'Yes';
handles.output{1} = false ;
handles.ParamStr = ParamStr ;
handles.CurParamStr = CurParamStr;
% Update handles structure

DlgType = 'SaveChange';
% Insert custom Title and Text if specified by the user
if(nargin > 5)
    for index = 1:2:(nargin-5),
        switch lower(varargin{index})
        case 'title'
            set(hObject, 'Name', varargin{index+1});
        case 'type'
            DlgType =  varargin{index+1} ;
        otherwise
            error('Invalid input arguments');
        end
    end
end

%Use DlgType
handles.DlgType = DlgType ;

fullfillPopUp(handles);
fullfillEditTag(handles);
fullfillListBox(handles);
updateYesButton(handles);

guidata(hObject, handles);
% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OPos = get(hObject,'position');
FigWidth=OPos(3);FigHeight=OPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','points');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','points');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'position', FigPos);
    
% UIWAIT makes Savedlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

function updateYesButton(handles)
Type = handles.DlgType;
switch lower(Type)
    case 'savechanges'
        btStr = 'Save' ;
    case 'load'
        btStr = 'Load';
        if ~checkItemValid(handles)
            set(handles.yes_button,'Enable','off');
        end
    case 'delete'
        if ~checkItemValid(handles)
            set(handles.yes_button,'Enable','off');
        end
        btStr = 'Delete';
    otherwise
        error('Invild input!');
end
set(handles.yes_button,'String',btStr);

function fullfillEditTag(handles)
Type = handles.DlgType;
StrArray = handles.ParamStr ;
if strcmpi(Type,'savechanges')
    EditTagEn = 'on';
    MaxPopUpNum = length(get(handles.PopItem,'String'));
    CurPopUpItm = int32(get(handles.PopItem,'Value'));
    if CurPopUpItm == MaxPopUpNum
        StrIn = 'Pls Type a Tag For this Parameter';
    else
        StrIn = StrArray(CurPopUpItm+1).Des;
    end
else
    EditTagEn = 'inactive';
    if ~checkItemValid(handles)
        if strcmpi(Type,'delete')
            StrIn = 'There is no Item to delete';
        elseif strcmpi(Type,'Load')
            StrIn = 'There is no Item to Load';
        else
            StrIn = 'Current Changes from Default Value';
        end
    else
        CurPopUpItm = int32(get(handles.PopItem,'Value'))+1;
        StrIn = StrArray(CurPopUpItm).Des;
    end
end

set(handles.EditTag,'Enable',EditTagEn);
set(handles.EditTag,'String',StrIn);

function fullfillPopUp(handles)
Type = handles.DlgType;
StrArray = handles.ParamStr ;
num = length(StrArray);
if strcmpi(Type,'savechanges')
    PopStr = cell(num,1);
    PopStr{num} = 'param_New';
else
    if num ==1
        PopStr{num} = 'NA';
    else
        PopStr = cell(num-1,1);
    end
end

if num > 1
    for i=1:num-1
        PopStr{i} = strcat('Param_',num2str(i));
    end
end
set(handles.PopItem,'String',PopStr);

function fullfillListBox(handles)
Type = handles.DlgType;
%fullfill ListBox accroding to the popmeun
if strcmpi(Type,'savechanges')
    %save changes case, check if it is in the new model
    MaxPopUpNum = length(get(handles.PopItem,'String'));
    CurPopUpItm = int32(get(handles.PopItem,'Value'));
    if CurPopUpItm == MaxPopUpNum
        rs = genListboxStr(handles.ParamStr(1),handles.CurParamStr);
    else
        rs = genListboxStr(handles.ParamStr(CurPopUpItm+1),handles.CurParamStr);
    end
elseif strcmpi(Type,'Load')
    if strcmpi(get(handles.PopItem,'String'),'NA')
        rs = genListboxStr(handles.ParamStr(1),handles.CurParamStr);
    else
        CurPopUpItm = int32(get(handles.PopItem,'Value'))+1;
        rs = genListboxStr(handles.ParamStr(1),handles.ParamStr(CurPopUpItm));
    end
else
    if strcmpi(get(handles.PopItem,'String'),'NA')
        rs = genListboxStr(handles.ParamStr(1),handles.CurParamStr);
    else
        CurPopUpItm = int32(get(handles.PopItem,'Value'))+1;
        rs = genListboxStr(handles.ParamStr(1),handles.ParamStr(CurPopUpItm));
    end
end
set(handles.lstParam,'String',rs);


function rs = genListboxStr(PreStr,NextStr)
PreParam = ParamStore.struct2ParamStore(PreStr);
NextParam = ParamStore.struct2ParamStore(NextStr);
Differ = ParamStore.getdiffer(PreParam,NextParam);
if ~isempty(Differ(1).Name)
    num = length(Differ);
    rs = cell(num,1);
    for i=1:num
        rs{i,:} = strcat(Differ(i).Name,':',Differ(i).PreValue,'  -->',Differ(i).CurValue);
    end
else
    rs = cell(1,1);
    rs{1,:} = 'Nothing has been changed';
end

function handles = goSaveAction(handles)
%do save action
%step1 get Description
StrDes = get(handles.EditTag,'String');
if strcmpi(StrDes,'Pls Type a Tag For this Parameter')
    TimeNow = clock;
    TimeNowStr = '';
    for i=1:5
        TimeNowStr = strcat(TimeNowStr,'_',num2str(TimeNow(i)));
    end
    StrDes = strcat('Param Saved at',TimeNowStr);
end
%Step2 get the save Pos
CurPopUpItm = int32(get(handles.PopItem,'Value'));
%update struct array
handles.ParamStr(CurPopUpItm+1) = handles.CurParamStr ;
handles.ParamStr(CurPopUpItm+1).Des = StrDes ;

function handles = goLoadAction(handles)
%do save action
%Step2 get the save Pos
CurPopUpItm = int32(get(handles.PopItem,'Value'));
%update struct array
handles.CurParamStr = handles.ParamStr(CurPopUpItm+1);

function handles = goDelAction(handles)
%do save action
%Step2 get the save Pos
CurPopUpItm = int32(get(handles.PopItem,'Value'));
%update struct array
handles.ParamStr(CurPopUpItm+1) = [] ;

function rs = checkItemValid(handles)
rs = true;
PopStr = get(handles.PopItem,'String');
if length(PopStr)==1
    StrItem = PopStr{1};
    if strcmpi(StrItem,'NA')
        rs = false;
    end
end


% --- Outputs from this function are returned to the command line.
function varargout = Savedlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in yes_button.
function yes_button_Callback(hObject, eventdata, handles)
% hObject    handle to yes_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

user_response = modaldlg('Title','Confirm','String','Are you Sure?');
if user_response
    rs =false;
    ButtonStr = get(hObject,'String');
    if ~strcmpi(ButtonStr,'Close')
        rs = true ;
    end
    
    handles.output = cell(2,1);
    
    switch lower(handles.DlgType)
        case 'savechanges'
            handles = goSaveAction(handles);
            handles.output{2} = handles.ParamStr ;
        case 'delete'
            if checkItemValid(handles)
                handles = goDelAction(handles);
            else
                rs = false;
            end
            handles.output{2} = handles.ParamStr ;
        case 'load'
            if checkItemValid(handles) 
                handles = goLoadAction(handles);
            else
                rs = false;
            end
            handles.output{2} = handles.CurParamStr ;
    end
    handles.output{1} = rs;
    %handles.output = get(hObject,'String');
    %handles.output = [rs,handles.ParamStr] ;

    % Update handles structure
    guidata(hObject, handles);

    % Use UIRESUME instead of delete because the OutputFcn needs
    % to get the updated handles structure.
    uiresume(handles.figure1);
end

% --- Executes on button press in no_button.
function no_button_Callback(hObject, eventdata, handles)
% hObject    handle to no_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rs =false;
%handles.output = get(hObject,'String');
handles.output = cell(1) ;
handles.output{1} = rs ;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" - do uiresume if we get it
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    


% --- Executes on selection change in lstParam.
function lstParam_Callback(hObject, eventdata, handles)
% hObject    handle to lstParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstParam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstParam


% --- Executes during object creation, after setting all properties.
function lstParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopItem.
function PopItem_Callback(hObject, eventdata, handles)
% hObject    handle to PopItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopItem contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopItem
fullfillEditTag(handles);
fullfillListBox(handles);


% --- Executes during object creation, after setting all properties.
function PopItem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditTag_Callback(hObject, eventdata, handles)
% hObject    handle to EditTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTag as text
%        str2double(get(hObject,'String')) returns contents of EditTag as a double


% --- Executes during object creation, after setting all properties.
function EditTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
