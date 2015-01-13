function varargout = FFTCalMain(varargin)
% FFTCALMAIN MATLAB code for FFTCalMain.fig
%      FFTCALMAIN, by itself, creates a new FFTCALMAIN or raises the existing
%      singleton*.
%
%      H = FFTCALMAIN returns the handle to a new FFTCALMAIN or the handle to
%      the existing singleton*.
%
%      FFTCALMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FFTCALMAIN.M with the given input arguments.
%
%      FFTCALMAIN('Property','Value',...) creates a new FFTCALMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FFTCalMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FFTCalMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FFTCalMain

% Last Modified by GUIDE v2.5 30-Sep-2011 17:02:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FFTCalMain_OpeningFcn, ...
                   'gui_OutputFcn',  @FFTCalMain_OutputFcn, ...
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

%--------------------User Define Function------------------------------

% --------------------------------------------------------------------
function handelsR = UpdateSignalList(handles)
%only variable prefix with FFT will be listed
%Then save the Data info into handles.U_Var for future useage.
handles.U_Var.OSigPlot = false ;
Vars = evalin('base','who(''FFT*'')');
if isempty(Vars)
    Vars = 'No Input Data';
    handles.U_Var.Data = '';
    handles.U_Var.PtSig1 = 0 ;
    handles.U_Var.PtSig2 = 0 ;
else
    VarNum = length(Vars);
    TempCell = cell(VarNum,1);
    for i=1:VarNum
        TempCell{i} = evalin('base',Vars{i});
    end
    handles.U_Var.PtSig1 = 1 ;
    handles.U_Var.PtSig2 = 1 ;
    set(handles.PopWsList, 'Value',1) ;
    handles.U_Var.Data = TempCell ;
end
UpdateSignal2List(handles);
handelsR = handles ;
set(handles.PopWsList,'String',Vars);


%---------------------------------------------------------------------
function UpdateSignal2List(handles)
%get 2 level signal
%first check if the signal is valid.
SignalList2 = 'N/A' ;
DataIndex = handles.U_Var.PtSig1 ;

if ~isempty(handles.U_Var.Data)
   Data = handles.U_Var.Data{DataIndex} ;
   [DummyVar SigNum] = size(Data) ;
    if SigNum == 1
        SignalList2 = '1' ;
    else
        SignalList2 = cell(SigNum+1,1);
        for i = 1:SigNum
            SignalList2{i} = int2str(i);
        end
        SignalList2{SigNum+1} = 'All' ;
    end
end
set(handles.PopWs2List,'String',SignalList2);
set(handles.PopWs2List, 'Value',1) ;

%----------------------------------------------------------------------
function VarReturn = isSig2All(handles,SelSig2)

VarReturn = false ;

if ~isempty(handles.U_Var.Data)
    [DummyVar, a] = size(handles.U_Var.Data{handles.U_Var.PtSig1}) ;
    if SelSig2>a 
        VarReturn = true ;
    end
end
    
% ---------------------------------------------------------------------
function handles = UpdateFs(handles)

Fs = str2double(get(handles.EdFs,'String')) ;
handles.U_Var.Fs = Fs ;

% ---------------------------------------------------------------------
function handles = PlotOringinalSig(handles)
%get Select Item
  plotColor = {'b','g','c','m','y','k'};
  ColorNum = length(plotColor) ;
  handles = UpdateFs(handles) ;
if ~isempty(handles.U_Var.Data)
    NumSig1 = handles.U_Var.PtSig1 ;
    NumSig2 = handles.U_Var.PtSig2 ;
    CurVar = handles.U_Var.Data{NumSig1} ;      
    [Tempa,Tempb] = size(CurVar);
    handles.U_Var.SLength = Tempa ;
        T = 1/handles.U_Var.Fs ;
        handles.U_Var.TimeVec = (0:handles.U_Var.SLength-1)*T;
    if ~isSig2All(handles,NumSig2)
        plot(handles.U_Var.TimeVec,CurVar(:,NumSig2));
    else
        PlotData = cell(3*Tempb,1) ;
        for ctVal = 1:Tempb
            PlotData{(ctVal*3)-2,1} = handles.U_Var.TimeVec;
            PlotData{(ctVal*3)-1,1} = CurVar(:,ctVal);	
            numColor = ctVal - ColorNum*( floor((ctVal-1)/ColorNum) );
            PlotData{ctVal*3,1} = plotColor{numColor};
        end
        plot(PlotData{:,1});
    end
    xlabel('Time(s)');
    ylabel('y');
    handles.U_Var.OSigPlot = true ;
end
% ---------------------------------------------------------------------
function handles = UpdateFFTInfo(handles)

%Fundamental Freq
handles.U_Var.FunFreq = str2double(get(handles.EdFunFreq,'String'));

%Max Freq
MaxFreq = str2double(get(handles.EdMaxFreq,'String'));
if MaxFreq <= handles.U_Var.Fs
       handles.U_Var.MaxFreq = MaxFreq ;
end

%StartTime
handles.U_Var.StartTime = str2double(get(handles.EdStartTime,'String'));

%cycles
handles.U_Var.Cycles = str2num(get(handles.EdCycles,'String'));

%Should add check info

%----------------------------------------------------------------------
%when Data is not empty
function handles = GetFFTData(handles)
FunNum = round(handles.U_Var.Fs/handles.U_Var.FunFreq);
handles.U_Var.FFTN = FunNum*handles.U_Var.Cycles ;

%start point;
StartT = handles.U_Var.StartTime ;

StartP = round(StartT*handles.U_Var.Fs)+1 ;
handles.U_Var.FFTStartP = StartP ;
if isSig2All(handles,handles.U_Var.PtSig2)
    Sig2 = 1 ;
else
    Sig2 = handles.U_Var.PtSig2 ;
end
handles.U_Var.FFTData = handles.U_Var.Data{handles.U_Var.PtSig1}(StartP:StartP+handles.U_Var.FFTN,Sig2);
handles.U_Var.FFTDataAll = handles.U_Var.Data{handles.U_Var.PtSig1}(StartP:StartP+handles.U_Var.FFTN,:);


% ---------------------------------------------------------------------
function hanldes = DrawFFTArea(handles)
%set FFT invalid ;
handles.U_Var.FFTValid = false ;
axes(handles.axes1);
cla ;

XVec = handles.U_Var.TimeVec(handles.U_Var.FFTStartP:handles.U_Var.FFTN+handles.U_Var.FFTStartP);
PlotOringinalSig(handles) ;
hold on ;
plot(XVec,handles.U_Var.FFTData,'red');
hold off ;

function handles = UpdateFFT(handles)
if ~isempty(handles.U_Var.Data)
    handles = UpdateFFTInfo(handles);
    handles = GetFFTData(handles);
    DrawFFTArea(handles);
end
handles.U_Var.FFTValid = true ;

% ---------------------------------------------------------------------
function handles = FFTCal(handles)

%get FFT
%length of Signal:
if ~isSig2All(handles,handles.U_Var.PtSig2)
    FFTData = handles.U_Var.FFTData ;
else
    
    FFTData = handles.U_Var.FFTDataAll ;
end
Fs = handles.U_Var.Fs ;
Maxf = Fs/2 ;
Cycles = handles.U_Var.Cycles;

[Length,DataNum] = size(FFTData);
Length = floor(Length/2)*2 ;

FFT = fft(FFTData,Length)/Length;

FFTMagRs = 2*abs(FFT(1:Length/2+1,:)) ;

%get fundamental index
FunIndex = handles.U_Var.Cycles+1;

FFTMagRs2Fun = zeros(size(FFTMagRs)) ;

for curColunm = 1:DataNum
    FFTMagRs2Fun(:,curColunm) = FFTMagRs(:,curColunm)./FFTMagRs(FunIndex,curColunm) ;
end
%Gen Freq Info
%f = (handles.U_Var.FunFreq/Cycles)*linspace(0,1,Length/2+1);
f = (handles.U_Var.FunFreq/Cycles)*(0:Length/2);
%Total Display Num
if handles.U_Var.MaxFreq < Maxf
    FFTNum = floor(handles.U_Var.MaxFreq*Length/(2*Maxf))+1;
else
    FFTNum = Length/2+1 ;
end

%First Print THD of all the signals
DisTxt = cell(DataNum*(FFTNum+6)+DataNum+1,1) ;
DisTxt{1} = 'FFT Result';

%get THD harmonics
ValidFFTMagRs = FFTMagRs(1:FFTNum,:) ;
AllThd = zeros(DataNum,1) ;
for curData = 1:DataNum
    AllThd(curData) = sqrt(sum(ValidFFTMagRs(:,curData).^2)-ValidFFTMagRs(FunIndex,curData)^2)/ValidFFTMagRs(FunIndex,curData)*100 ;
    DisTxt{curData} = sprintf(['THD of',' Signal ',num2str(curData,'%d'),' is: ',num2str(AllThd(curData),' %5.2f'),'%%']);
end

DisLeng = floor(log10(handles.U_Var.MaxFreq))+1 ;

for curData = 1:DataNum
    % Cal THD:
    %curTHD = sqrt(sum(FFTMagRs(:,curData).^2)-FFTMagRs(FunIndex,curData)^2)/FFTMagRs(FunIndex,curData)*100 ;
    curTHD = AllThd(curData , 1) ;
    FunPeak = FFTMagRs(FunIndex,curData) ;
    Rms = sqrt(sum(FFTData(:,curData).^2)/Length) ;
    DisTxt{(curData-1)*(FFTNum+6)+1+DataNum+1} = '' ;
    DisTxt{(curData-1)*(FFTNum+6)+2+DataNum+1} = sprintf([' Signal ',num2str(curData,'%d')]) ;
    DisTxt{(curData-1)*(FFTNum+6)+3+DataNum+1} = sprintf([' THD',': ',num2str(curTHD,' %5.2f'),'%%']) ;
    DisTxt{(curData-1)*(FFTNum+6)+4+DataNum+1} = sprintf([' Fundamental Peak',': ',num2str(FunPeak,' %f')]) ;
    DisTxt{(curData-1)*(FFTNum+6)+5+DataNum+1} = sprintf([' Rms',': ',num2str(Rms,' %f')]) ;
    DisTxt{(curData-1)*(FFTNum+6)+6+DataNum+1} = sprintf(' harmonics component are:') ;
    
    for curf = 1:FFTNum
        if mod(curf-1,Cycles) == 0
            if curf-1 ==0
               %TempS = ['harmonics of  ',num2str(f(curf),' %010.2f'),'Hz ',' (DC Component)',' is ',' ',num2str(FFTMagRs2Fun(curf)*100,'%6.4g'),'%%'] ;
               TempS = [' ',AdjNum2Str(f(curf),DisLeng+2,2),'Hz ', '(DC   ) ',AdjNum2Str(FFTMagRs2Fun(curf,curData)*100,7,4),'%%'] ;
            else
                TempS = [' ',AdjNum2Str(f(curf),DisLeng+2,2),'Hz ','(h',AdjNum2Str((curf-1)/Cycles,3,0),') ',AdjNum2Str(FFTMagRs2Fun(curf,curData)*100,7,4),'%%'] ;
            end
        else
            TempS = [' ',AdjNum2Str(f(curf),DisLeng+2,2),'Hz ','        ',AdjNum2Str(FFTMagRs2Fun(curf,curData)*100,7,4),'%%'] ;
        end
        DisTxt{(curData-1)*(FFTNum+6)+curf+6+DataNum+1} = sprintf(TempS) ;
    end
end

% Plot
axes(handles.axesFFT);
cla ;

if get(handles.PopFFT,'Value') == 1
    BarX = (0:FFTNum-1)/Cycles ;
else
    BarX = f(1:FFTNum) ;
end 
    
bar(BarX,FFTMagRs2Fun(1:FFTNum,:),'group');


set(handles.LbDisplay,'String',DisTxt) ;



function RsStr = AdjNum2Str(Num,Width,precision)
%check if Num is larger then maximum possible value indicated by Width
IDC = ['%',num2str(Width,'%d'),'.',num2str(precision,'%d'),'f'] ;
NumStr = num2str(Num,IDC) ;
[Dunmmy LengthNum] = size(NumStr) ;

length = Width+1 ;
RsStr = '';
for i = 1:length
    RsStr = [RsStr,' '];
end

if (Num>=1 && log10(Num)+1 <= (Width-precision)) ||(Num<1 && Num>=0)
    RsStr(length+1-LengthNum:length) = NumStr ;
else
    RsStr = NumStr ;
end
%----------------End of User Define Function---------------------------

% --- Executes just before FFTCalMain is made visible.
function FFTCalMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FFTCalMain (see VARARGIN)

% Choose default command line output for FFTCalMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%inital global param
U_Var = struct('Fs',[],'TimeVec',[],'SNum',[],'SLength',[],'Data',[],'PtSig1',...
                [],'PtSig2',[],'FunFreq',[],'MaxFreq',[],'StarTime',[],'Cycles',[],...
                'FFTData',[],'FFTN',[],'FFTStartP',[],'OSigPlot',[],'FFTValid',[],'FFTDataAll',[]);

            
U_Var.FunFreq = 50 ;
U_Var.MaxFreq = 1000;
U_Var.StarTime = 0.0 ;
U_Var.Cycles = 1 ;
U_Var.FFTStartP = 1 ;
U_Var.FFTN = 1 ;
U_Var.OSigPlot = false ;
U_Var.FFTValid = false ;
handles.U_Var = U_Var;

% This sets up the initial plot - only do when we are invisible
% so window can get raised using FFTCalMain.
handles = UpdateSignalList(handles);
handles = UpdateFs(handles);


% UIWAIT makes FFTCalMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%format axes
axes(handles.axes1);
cla;
plot(0:0.01:1,0);
xlabel('Time (s)')
ylabel('y')
axes(handles.axesFFT);
cla;
plot(0:0.01:1,0);
guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = FFTCalMain_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in UpddateWSList.
function UpddateWSList_Callback(hObject, eventdata, handles)
% hObject    handle to UpddateWSList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = UpdateSignalList(handles);
guidata(hObject,handles);




% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in PopWsList.
function PopWsList_Callback(hObject, eventdata, handles)
% hObject    handle to PopWsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PopWsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopWsList
if ~isempty(handles.U_Var.Data)
    handles.U_Var.PtSig1 = get(handles.PopWsList, 'Value');
    handles.U_Var.PtSig2 = 1 ;
    UpdateSignal2List(handles) ;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function PopWsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopWsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.



% --- Executes on button press in PlotSignal.
function PlotSignal_Callback(hObject, eventdata, handles)
% hObject    handle to PlotSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

%get Select Item
handles = PlotOringinalSig(handles) ;

guidata(hObject,handles);



function EdFs_Callback(hObject, eventdata, handles)
% hObject    handle to EdFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdFs as text
%        str2double(get(hObject,'String')) returns contents of EdFs as a double
handles = UpdateFs(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EdFs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopWs2List.
function PopWs2List_Callback(hObject, eventdata, handles)
% hObject    handle to PopWs2List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopWs2List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopWs2List

%get select Sig2 index
if ~isempty(handles.U_Var.Data)
    handles.U_Var.PtSig2 = get(handles.PopWs2List,'Value');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PopWs2List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopWs2List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LbDisplay.
function LbDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to LbDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LbDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LbDisplay


% --- Executes during object creation, after setting all properties.
function LbDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LbDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PbFFT.
function PbFFT_Callback(hObject, eventdata, handles)
% hObject    handle to PbFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.U_Var.FFTValid
    handles = FFTCal(handles) ;
end
guidata(hObject,handles);

% --- Executes on selection change in PopFFT.
function PopFFT_Callback(hObject, eventdata, handles)
% hObject    handle to PopFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopFFT contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopFFT


% --- Executes during object creation, after setting all properties.
function PopFFT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdFunFreq_Callback(hObject, eventdata, handles)
% hObject    handle to EdFunFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdFunFreq as text
%        str2double(get(hObject,'String')) returns contents of EdFunFreq as a double





% --- Executes during object creation, after setting all properties.
function EdFunFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdFunFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdMaxFreq_Callback(hObject, eventdata, handles)
% hObject    handle to EdMaxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdMaxFreq as text
%        str2double(get(hObject,'String')) returns contents of EdMaxFreq as a double


% --- Executes during object creation, after setting all properties.
function EdMaxFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdMaxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdCycles_Callback(hObject, eventdata, handles)
% hObject    handle to EdCycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdCycles as text
%        str2double(get(hObject,'String')) returns contents of EdCycles as a double


% --- Executes during object creation, after setting all properties.
function EdCycles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdCycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to EdStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdStartTime as text
%        str2double(get(hObject,'String')) returns contents of EdStartTime as a double


% --- Executes during object creation, after setting all properties.
function EdStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EdStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on EdFunFreq and none of its controls.
function EdFunFreq_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to EdFunFreq (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in PbShowFFTWin.
function PbShowFFTWin_Callback(hObject, eventdata, handles)
% hObject    handle to PbShowFFTWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.U_Var.OSigPlot ;
    try
        handles = UpdateFFT(handles) ;
        guidata(hObject,handles);
    catch ex
        errordlg({'FFT Window Setting is invalid!','Pls Check the ''fundarment freq'',''Start Time'',''Cycles'' Setting'},'Error') ;
    end
end 
