function varargout = simBB(varargin)
% SIMBB MATLAB code for simBB.fig
%      SIMBB, by itself, creates a new SIMBB or raises the existing
%      singleton*.
%
%      H = SIMBB returns the handle to a new SIMBB or the handle to
%      the existing singleton*.
%
%      SIMBB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMBB.M with the given input arguments.
%
%      SIMBB('Property','Value',...) creates a new SIMBB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simBB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simBB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simBB

% Last Modified by GUIDE v2.5 24-Jul-2014 10:09:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simBB_OpeningFcn, ...
                   'gui_OutputFcn',  @simBB_OutputFcn, ...
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


% --- Executes just before simBB is made visible.
function simBB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simBB (see VARARGIN)
%fig = handles.figTest ;
%model_open(handles);
% Choose default command line output for simBB
handles.output = hObject;
handles = modelInitialParaSetting(handles) ;
handles = updateCalParam(handles);
handles = updateController(handles);
updateCurLmt(handles);

%init Setting 
setStepEnable(handles);
setinitSimDisturbStruct(handles);
updateSimdis(handles,0,0);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes simBB wait for user response (see UIRESUME)
% uiwait(handles.figTest);


% --- Outputs from this function are returned to the command line.
function varargout = simBB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%=================user define functions================================
function model_open(handles)
% Make sure the diagram is still open
  if  isempty(find_system('Name','PowerController')),
    open_system('PowerController'); 
    %open_system('f14/Controller')
    %set_param('f14/Controller/Gain','Position',[275 14 340 56])
    figure(handles.figTest);
    % Put  values of Kf and Ki from the GUI into the Block dialogs
    %set_param('f14/Controller/Gain','Gain',...
    %                        get(handles.KfCurrentValue,'String'))
    %set_param('f14/Controller/Proportional plus integral compensator',...
    %          'Numerator',...
    %          get(handles.KiCurrentValue,'String'))
  end
  

  function handles = modelInitialParaSetting(handles)
    %handles = guihandles(hObject);
    %BES System
    %first construct a struct to store paramater in the handle
    %get Data from the saved xml file
    SaveFileName = 'Mdl_Param.xml';
    handles.SaveFileName = SaveFileName ;
    SysParamSetArray = getSysParamFromXml(SaveFileName) ;
    %save SysParamSetArray to handles;
    handles.SysParamSetArray = SysParamSetArray ;
    SysParamSet = SysParamSetArray(1);
    handles.SysParamSet = SysParamSet ;
    %set intial value
    updateSetUi(handles)
    

 function updateSetUi(handles)
    set(handles.EditBESSMaxPower,'String',handles.SysParamSet.BESSMaxPower/1e3);
    set(handles.EditCurOptTime,'String',handles.SysParamSet.CurOptTime);
    set(handles.EditDCCap,'String',handles.SysParamSet.DCCap*1e6);
    set(handles.EditDCVref,'String',handles.SysParamSet.DCVref);
    set(handles.EditDCfreq,'String',handles.SysParamSet.DCfreq);
    set(handles.EditDCfs,'String',handles.SysParamSet.DCfs);
    set(handles.EditESEBatteryV,'String',handles.SysParamSet.ESEBatteryV);
    set(handles.EditESESCUV,'String',handles.SysParamSet.ESESCUV);
    set(handles.EditESESCLV,'String',handles.SysParamSet.ESESCLV);
    set(handles.EditESESCMargin,'String',handles.SysParamSet.ESESCMargin*100);
    set(handles.EditConFs,'String',handles.SysParamSet.ConFs/1e3);
    set(handles.EditConBLs,'String',handles.SysParamSet.ConBLs*1e3);
    set(handles.EditConBCurLmt,'String',handles.SysParamSet.ConBCurLmt);
    set(handles.EditConSCLs,'String',handles.SysParamSet.ConSCLs*1e3);
    set(handles.EditConSCCurLmt,'String',handles.SysParamSet.ConSCCurLmt);
    set(handles.edStopTime,'String',handles.SysParamSet.StopTime);

    
function handles = updateUi(handles)
%no return
    updateSetUi(handles);
updateCurLmt(handles);

handles = updateController(handles);
handles = updateCalParam(handles);

    
function FileExist = checkFileExist(FileNameIn)
    FileExist = false;
    FileName = FileNameIn ;
    FileDir = dir;
    for i = 1:length(FileDir)
        if ~FileDir(i).isdir
            if strcmp(FileDir(i).name,FileName)
                FileExist = true;
            end
        end
    end
    
function saveSysParam2Xml(strArrayIn,FileName)
    %first converter strArrayIn to ParamStore
    PM = ParamMg;
    ParamCnt = length(strArrayIn);
    for i=1:ParamCnt
        CurP = ParamStore.struct2ParamStore(strArrayIn(i));
        PM.ParamStoreArray(i) = CurP;
    end
    ParamMg.writeXmlFile(PM,FileName);

%read from Save File, if there is no default value, then creat a new one
function SysParamSetArray = getSysParamFromXml(FileName)
    %first check if the file exist
    FileExist = checkFileExist(FileName);    
    %if file do not exist, then creat a file using factory settings
    if FileExist
        PM = ParamMg.readXmlFile(FileName);
        ParamCnt = length(PM.ParamStoreArray);
        for i=1:ParamCnt
            curP = PM.ParamStoreArray(i) ;
            SysParamSetArray(i) = ParamStore.ParamStore2struct(curP);
        end
    else
        SysParamSet = struct('BESSMaxPower',[],'CurOptTime',[],...
        'DCCap',[],'DCVref',[],'DCfreq',[],'ESEBatteryV',[],'ESESCUV',[],...
        'ESESCLV',[],'ESESCMargin',[],'ConFs',[],...
        'ConBLs',[],'ConBCurLmt',[],'ConSCLs',[],'ConSCCurLmt',[],'StopTime',[],'Des','');
        SysParamSet.BESSMaxPower = 100e3 ;
        SysParamSet.CurOptTime = 1;
        SysParamSet.DCCap = 100*4700e-6 ;
        SysParamSet.DCVref = 400 ;
        SysParamSet.DCfreq = 10 ;
        SysParamSet.DCfs = 1e3 ;
        SysParamSet.ESEBatteryV = 300 ;
        SysParamSet.ESESCUV = 300 ;
        SysParamSet.ESESCLV = 200 ;
        SysParamSet.ESESCMargin = 0.1 ;
        SysParamSet.ConFs = 10e3;
        SysParamSet.ConBLs = 10e-3;
        SysParamSet.ConBCurLmt = 500;
        SysParamSet.ConSCLs = 1e-3;
        SysParamSet.ConSCCurLmt = 1200 ;
        SysParamSet.StopTime = 10;
        SysParamSet.Des = 'Default';
        ParamS = ParamStore.struct2ParamStore(SysParamSet);
        ParamS.Des = SysParamSet.Des;
        PM = ParamMg(ParamS);
        ParamMg.writeXmlFile(PM,FileName);
        SysParamSetArray = SysParamSet ;
    end
            
          
function handles = updateCalParam(handles)
    %handles = guihandles(hObject);
    if ~isfield(handles,'SysParamCal')
        handles.SysParamCal = struct('SCCap',[],'VSCInit',[],'DCTs',[],...
            'Tsconv',[]);
    end
    
    %============SCCap & VSCInit=========================
    %update Calculation Parameter
    handles = updateSCCap(handles); 
    
    %============TsDC===================================
    handles.SysParamCal.DCTs = 1/handles.SysParamSet.DCfs ;
    %============Tsconv=================================
    handles.SysParamCal.Tsconv = 1/handles.SysParamSet.ConFs;
    
function handles = updateCurLmt(handles)
    Pmax = handles.SysParamSet.BESSMaxPower ;
    BV = handles.SysParamSet.ESEBatteryV ;
    BCurLmt = Pmax/BV ;
    USCmin = handles.SysParamSet.ESESCLV ;
    SCCurLmt = 2*Pmax/USCmin ;
    set(handles.EditBCurLmtRmd,'String',num2str(BCurLmt));
    set(handles.EditSCCurLmtRmd,'String',num2str(SCCurLmt));
    
    
function handles = updateSCCap(handles)
    Pmax = handles.SysParamSet.BESSMaxPower ;
    T = handles.SysParamSet.CurOptTime ;
    SCmargin = handles.SysParamSet.ESESCMargin; %Margin 10%
    USCmax = handles.SysParamSet.ESESCUV;
    USCmin = handles.SysParamSet.ESESCLV;
    %calculate the capacity of the super-capacitor
    if(USCmax>=USCmin)
        USCnorm = sqrt((USCmax^2+USCmin^2)/2);
        Cap = (1+SCmargin)*(Pmax*T/(USCnorm^2-USCmin^2));
    else
        USCnorm = 0;
        Cap = 0;
    end
    handles.SysParamCal.SCCap = Cap ;
    handles.SysParamCal.VSCInit = USCnorm ;
    set(handles.EditSCCap,'String',Cap);
    set(handles.EditVSCInit,'String',USCnorm);

%====================Controller Calculation============================
function handles = updateController(handles)
    %Dc Bus Controller
    if ~isfield(handles,'DCController')
        handles.DCController = struct('wc',[],'Kp',[],'Ki',[]);
    end
    handles.DCController.wc = pi*handles.SysParamSet.DCfreq ;
    [handles.DCController.Kp,handles.DCController.Ki] = PiConCal(handles.DCController.wc,...
        1/(handles.SysParamSet.DCCap*handles.SysParamSet.DCVref));
    
    %Battery Converter Controller
    if ~isfield(handles,'BatteryController')
        handles.BatteryController = struct('wc',[],'Kp',[],'Ki',[]);
    end
    handles.BatteryController.wc = 1/handles.SysParamSet.ConBLs;
    [handles.BatteryController.Kp,handles.BatteryController.Ki] = PiConCal(handles.BatteryController.wc,...
        handles.SysParamSet.DCVref/handles.SysParamSet.ConBLs);
    
    %Super Capacitor Controller
    if ~isfield(handles,'SCController')
        handles.SCController = struct('wc',[],'Kp',[],'Ki',[]);
    end
    handles.SCController.wc = 1/handles.SysParamSet.ConSCLs ;
    [handles.SCController.Kp,handles.SCController.Ki] = PiConCal(handles.SCController.wc,...
       handles.SysParamSet.DCVref/handles.SysParamSet.ConSCLs);
   
   %Battery Current Optimal Controller
   if ~isfield(handles,'OpController')
        handles.OpController = struct('DelayNum',[],'NL',[],'OmegaLP',[]);
   end
    handles.OpController.DelayNum = round(handles.SysParamSet.CurOptTime/...
        handles.SysParamCal.DCTs);
    handles.OpController.NL = 10;
    handles.OpController.OmegaLP = 2*pi*handles.OpController.NL/...
        handles.SysParamSet.CurOptTime;
 
function setSimParam(handles)
%first make sure model is opened
model_open(handles);
%==============Vdcref===========================
set_param('PowerController/Vdcref','Value',...
    num2str(handles.SysParamSet.DCVref));
set_param('PowerController/Battery','Value',...
    num2str(handles.SysParamSet.ESEBatteryV));
%==============DC_Bank==========================
set_param('PowerController/DC_Bank','Cdc',...
    num2str(handles.SysParamSet.DCCap));
set_param('PowerController/DC_Bank','Vdcinit',...
    num2str(handles.SysParamSet.DCVref));
%=====================SC_Bank===================
set_param('PowerController/SC_Bank','CSC',...
    num2str(handles.SysParamCal.SCCap));
set_param('PowerController/SC_Bank','Vscinit',...
    num2str(handles.SysParamCal.VSCInit));
%==============Dc2Dc_Battery======================
set_param('PowerController/Dc2Dc_Battery','Tsconv',...
    num2str(handles.SysParamCal.Tsconv));
set_param('PowerController/Dc2Dc_Battery','imax',...
    num2str(handles.SysParamSet.ConBCurLmt));
set_param('PowerController/Dc2Dc_Battery','imin',...
    num2str(-1*handles.SysParamSet.ConBCurLmt));
set_param('PowerController/Dc2Dc_Battery','Ls',...
    num2str(handles.SysParamSet.ConBLs));
%==============Dc2Dc_SC======================
set_param('PowerController/Dc2Dc_SC','Tsconv',...
    num2str(handles.SysParamCal.Tsconv));
set_param('PowerController/Dc2Dc_SC','imax',...
    num2str(handles.SysParamSet.ConSCCurLmt));
set_param('PowerController/Dc2Dc_SC','imin',...
    num2str(-1*handles.SysParamSet.ConSCCurLmt));
set_param('PowerController/Dc2Dc_SC','Ls',...
    num2str(handles.SysParamSet.ConSCLs));
%=============DCBus_Controller=================
set_param('PowerController/DCBus_Controller','Kpdc',...
    num2str(handles.DCController.Kp));
set_param('PowerController/DCBus_Controller','Kidc',...
    num2str(handles.DCController.Ki));
%==============PowerOp_Controller==============
set_param('PowerController/PowerOp_Controller','DelayNum',...
    num2str(handles.OpController.DelayNum));
set_param('PowerController/PowerOp_Controller','OmegaLP',...
    num2str(handles.OpController.OmegaLP));
set_param('PowerController/PowerOp_Controller','Ts',...
    num2str(handles.SysParamCal.DCTs));
set_param('PowerController/PowerOp_Controller','T',...
    num2str(handles.SysParamSet.CurOptTime));
%==============Battery_Controller==============
set_param('PowerController/Battery_Controller','Kp',...
    num2str(handles.BatteryController.Kp));
set_param('PowerController/Battery_Controller','Ki',...
    num2str(handles.BatteryController.Ki));
set_param('PowerController/Battery_Controller','imax',...
    num2str(handles.SysParamSet.ConBCurLmt));
set_param('PowerController/Battery_Controller','imin',...
    num2str(-1*handles.SysParamSet.ConBCurLmt));
%==============SC_Controller==============
set_param('PowerController/SC_Controller','Kp',...
    num2str(handles.SCController.Kp));
set_param('PowerController/SC_Controller','Ki',...
    num2str(handles.SCController.Ki));
set_param('PowerController/SC_Controller','imax',...
    num2str(handles.SysParamSet.ConSCCurLmt));
set_param('PowerController/SC_Controller','imin',...
    num2str(-1*handles.SysParamSet.ConSCCurLmt));

%=====================disturb Setting==========================
function enableStep(handles)
    %set Step Enabled
    set(handles.edStepInitP,'Enable','on');
    set(handles.edStepFP,'Enable','on');
    set(handles.edStepST,'Enable','on');
    
    
function enablePluse(handles)
    set(handles.edPluseMaxP,'Enable','on');
    set(handles.edPluseMinP,'Enable','on');
    set(handles.edPluseTs,'Enable','on');
    
    
function enableCustom(handles)
    set(handles.edCustom,'Enable','on');
    set(handles.edCustomTs,'Enable','on');
    
function disableStep(handles)
    set(handles.edStepInitP,'Enable','off');
    set(handles.edStepFP,'Enable','off');
    set(handles.edStepST,'Enable','off');
    set(handles.rbStep,'Value',0);
    
function disablePluse(handles)
    set(handles.edPluseMaxP,'Enable','off');
    set(handles.edPluseMinP,'Enable','off');
    set(handles.edPluseTs,'Enable','off');
    set(handles.rbPluse,'Value',0);
    
function disableCustom(handles)
    set(handles.edCustom,'Enable','off');
    set(handles.edCustomTs,'Enable','off');
    set(handles.rbCustom,'Value',0);
    
    
function setStepEnable(handles)
    enableStep(handles);
    disablePluse(handles);
    disableCustom(handles);
    set(handles.rbStep,'Value',1);
    
function setPluseEnable(handles)
    enablePluse(handles);
    disableStep(handles);
    disableCustom(handles);
    set(handles.rbPluse,'Value',1);
    
function setCustomEnable(handles)
    enableCustom(handles);
    disablePluse(handles);
    disableStep(handles);
    set(handles.rbCustom,'Value',1);
        
function RsNum = parseCustomStr(StrIn)
    %parseCustom, check if it is valid
    %typical form is num,num,num,num
    %return a Num Array
    RsNumCell = textscan(StrIn,'%f','Delimiter',',');
    RsNum = RsNumCell{1};
    
function StrOut = genDisturbStr(handles)
    %first get disturbance Type
    DisturbType = '';
    if get(handles.rbStep,'Value') == 1
        DisturbType = 'Step';
    elseif get(handles.rbPluse,'Value') == 1
        DisturbType = 'Pluse';
    elseif get(handles.rbCustom,'Value') == 1
        DisturbType = 'Custom';
    end
    
    switch lower(DisturbType)
        case 'step'
            StrOut = 'Step' ;
            temp = str2double(get(handles.edStepInitP,'String')) ;
            StrOut = strcat(StrOut,';','InitP=',num2str(temp,6),'kw');
            temp = str2double(get(handles.edStepFP,'String')) ;
            StrOut = strcat(StrOut,';','FinalP=',num2str(temp,6),'kw');
            temp = str2double(get(handles.edStepST,'String')) ;
            StrOut = strcat(StrOut,';','Time=',num2str(temp,6),'s');
        case 'pluse'
            StrOut = 'Pluse' ;
            temp = str2double(get(handles.edPluseMaxP,'String')) ;
            StrOut = strcat(StrOut,';','MaxP=',num2str(temp,6),'kw');
            temp = str2double(get(handles.edPluseMinP,'String')) ;
            StrOut = strcat(StrOut,';','MinP=',num2str(temp,6),'kw');
            temp = str2double(get(handles.edPluseTs,'String')) ;
            StrOut = strcat(StrOut,';','Ts=',num2str(temp,6),'s');
        case 'custom'
            StrOut = 'Custom ' ;
            temp = str2double(get(handles.edCustomTs,'String')) ;
            StrOut = strcat(StrOut,';','Ts=',num2str(temp,6),'s');
            
            SetNum = parseCustomStr(get(handles.edCustom,'String'));
            if isempty(SetNum)
                error('Input Error');
            end
            
            CustomStr = num2str(SetNum(1),32);
            for i =2:length(SetNum)
                CustomStr = strcat(CustomStr,',',num2str(SetNum(i),6));
            end
                CustomStr = strcat(CustomStr,'kw');
            StrOut = strcat(StrOut,';','Value =',CustomStr);
    end

function rs = checkInputValid(handles)
        %first get disturbance Type
    DisturbType = '';
    if get(handles.rbStep,'Value') == 1
        DisturbType = 'Step';
    elseif get(handles.rbPluse,'Value') == 1
        DisturbType = 'Pluse';
    elseif get(handles.rbCustom,'Value') == 1
        DisturbType = 'Custom';
    end
    
    rs = true;
    
    switch lower(DisturbType)
        case 'step'
            temp1 = get(handles.edStepInitP,'String') ;
            temp2 = get(handles.edStepFP,'String') ;
            temp3 = get(handles.edStepST,'String') ;           
        case 'pluse'
            temp1 = get(handles.edPluseMaxP,'String') ;
            temp2 = get(handles.edPluseMinP,'String') ;
            temp3 = get(handles.edPluseTs,'String') ;
        case 'custom'
            temp1 = get(handles.edCustom,'String') ;
            temp2 = '1';
            temp3 = '1';
    end
    
    if isempty(temp1) || isempty(temp2)|| isempty(temp3)
        rs = false;
    end

    
function rs = popDisturbList(handles)
    
    ListIndex = get(handles.lbDisturb,'Value');
    StrLb = get(handles.lbDisturb,'String') ;
    if ~isempty(StrLb)
        MaxIndex = max(ListIndex);
        ListNum = length(StrLb);
        IndexNum = length(ListIndex);

        if MaxIndex > ListNum
            error('Out of index');
        end

        rs = cell(IndexNum,1);
        for i=1:IndexNum
            rs{i,:} = StrLb{i,:};
        end

        StrLb(ListIndex) = [];
        set(handles.lbDisturb,'Value',1,'String',StrLb);
    end

function StrRs = genOutputList(handles)
    ListRs = get(handles.lbDisturb,'String');
    StrRs = '';
    NumCnt = length(ListRs);
    if(~isempty(ListRs))
        for i=1:NumCnt-1
        StrRs = strcat(StrRs,ListRs(i),char('\n'));
        end
        StrRs = strcat(StrRs,ListRs(NumCnt));
    end

    function Rs = ParseDisturbText(handles)
        ParseText = get(handles.lbDisturb,'String');
        Rs = '';
        if ~isempty(ParseText)
            NumCnt = length(ParseText);
            Rs = cell(NumCnt,1);
            for i=1:NumCnt
                %Cur cell
                CurText = ParseText{i};
                %get Name Part by ;
                [Name,Remain] = strtok(CurText,';');
                %get Name
                switch lower(Name)
                    case 'step'
                        temp = struct('Name',[],'InitP',[],'FinalP',[],'StepT',[]);
                        temp.Name = Name;
                        %next get InitP
                        [InitP,Remain] = strtok(Remain,';');
                        temp.InitP = getValue(InitP);
                        [FinalP,Remain] = strtok(Remain,';');
                        temp.FinalP = getValue(FinalP);
                        [StepT,Remain] = strtok(Remain,';');
                        temp.StepT = getValue(StepT);
                        Rs{i} = temp ;
                    case 'pluse'
                        temp = struct('Name',[],'MaxP',[],'MinP',[],'Ts',[]);
                        temp.Name = Name;
                        
                        [MaxP,Remain] = strtok(Remain,';');
                        temp.MaxP = getValue(MaxP);
                        [MinP,Remain] = strtok(Remain,';');
                        temp.MinP = getValue(MinP);
                        [Ts,Remain] = strtok(Remain,';');
                        temp.Ts = getValue(Ts);
                        Rs{i} = temp ;
                    case 'custom'
                        temp = struct('Name',[],'Ts',[],'Value',[]);
                        temp.Name = Name;
                        
                        [Ts,Remain] = strtok(Remain,';');
                        temp.Ts = getValue(Ts);
                        
                        [Value,Remain] = strtok(Remain,';');
                        temp.Value = getValue(Value);
                        Rs{i} = temp ;
                end
            end
        end
        
function Rs = getValue(StrIn)
    Remain = StrIn;
    while ~isempty(Remain)
    [Rs,Remain] = strtok(Remain,'=');
    end
    expr = '(-?\d*.?\d*,?)+[^a-zA-Z]';
    Rs = regexp(Rs,expr,'match');
    Rs = Rs{1};
    
function setinitSimDisturbStruct(handles)
        %based on the struct
        %case 'step'
        Power = handles.SysParamSet.BESSMaxPower/1000;
        set(handles.edStepInitP,'String','0');
        set(handles.edStepFP,'String',Power);
        set(handles.edStepST,'String','0');
        %case 'pluse'
        set(handles.edPluseMaxP,'String',Power) ;
        set(handles.edPluseMinP,'String',-1*Power) ;
        set(handles.edPluseTs,'String','1') ;
        %case 'custom'
        StrTemp = num2str(Power);
        StrTemp = strcat(StrTemp,',','-',StrTemp);
        set(handles.edCustom,'String',StrTemp);
        set(handles.edCustomTs,'String','1');
            
            
    function setSimDisturbStruct(handles,DisturbS)
        %based on the struct
        switch lower(DisturbS.Name)
            case 'step'
                %first set type
                set_param('PowerController/Disturb/Type','Value',...
                    '1');
                set_param('PowerController/Disturb/Step','InitP',...
                    DisturbS.InitP);
                set_param('PowerController/Disturb/Step','FinalP',...
                    DisturbS.FinalP);
                set_param('PowerController/Disturb/Step','StepT',...
                    DisturbS.StepT);
            case 'pluse'
                set_param('PowerController/Disturb/Type','Value',...
                    '2');
                set_param('PowerController/Disturb/Pluse','MaxP',...
                    DisturbS.MaxP);
                set_param('PowerController/Disturb/Pluse','MinP',...
                    DisturbS.MinP);
                set_param('PowerController/Disturb/Pluse','PluseTs',...
                    DisturbS.Ts);
            case 'custom'
                set_param('PowerController/Disturb/Type','Value',...
                    '3');
                temp = DisturbS.Value;
                temp = strcat('[',temp,']');
                set_param('PowerController/Disturb/Custom','Value',...
                    temp);
                set_param('PowerController/Disturb/Custom','TsCustom',...
                    DisturbS.Ts);
                
        end

function setSimDisturbStructByCurSelect(handles)
    DisturbCell = ParseDisturbText(handles);
    %get the value by the minimum value;
    if ~isempty(DisturbCell)
        CurIndex = get(handles.lbDisturb,'Value');
        Index = min(CurIndex);
        setSimDisturbStruct(handles,DisturbCell{Index});
    end

function updateSimdis(handles,Total,Cur)
    DisStr = '';
    if Cur==0
        DisStr = 'Simulation is idle now.';
    else
        DisStr = strcat('Now, Set',num2str(Cur),'of',num2str(Total),' is in progress');
    end
    set(handles.edSimProcess,'String',DisStr);
 
    function rs = getToggledTb(handles)
        rs = [];
    cnt = 1 ;
    if get(handles.tb1,'Value') == 1
        rs(cnt) = 1;
        cnt = cnt +1 ;
    end
    if get(handles.tb2,'Value') == 1
        rs(cnt) = 2;
        cnt = cnt +1 ;
    end
    if get(handles.tb3,'Value') == 1
        rs(cnt) = 3;
        cnt = cnt +1 ;
    end
    if get(handles.tb4,'Value') == 1
        rs(cnt) = 4;
        cnt = cnt +1 ;
    end
    if get(handles.tb5,'Value') == 1
        rs(cnt) = 5;
        cnt = cnt +1 ;
    end
    if get(handles.tb6,'Value') == 1
        rs(cnt) = 6;
        cnt = cnt +1 ;
    end
    
    function rs = getToggledTbStr(handles,Index)
    Temprs = cell(6,1);
    Temprs{1} = get(handles.tb1,'String') ;
    Temprs{2} = get(handles.tb2,'String') ;
    Temprs{3} = get(handles.tb3,'String') ;
    Temprs{4} = get(handles.tb4,'String') ;
    Temprs{5} = get(handles.tb5,'String') ;
    Temprs{6} = get(handles.tb6,'String') ;
    rs = Temprs(Index);
    
function EditDCCap_Callback(hObject, eventdata, handles)
% hObject    handle to EditDCCap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDCCap as text
%        str2double(get(hObject,'String')) returns contents of EditDCCap as a double
handles.SysParamSet.DCCap = ...
    str2double(get(handles.EditDCCap,'String'))*1e-6;
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function EditDCCap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDCCap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDCVref_Callback(hObject, eventdata, handles)
% hObject    handle to EditDCVref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDCVref as text
%        str2double(get(hObject,'String')) returns contents of EditDCVref as a double
handles.SysParamSet.DCVref = ...
    str2double(get(handles.EditDCVref,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditDCVref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDCVref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditBESSMaxPower_Callback(hObject, eventdata, handles)
% hObject    handle to EditBESSMaxPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditBESSMaxPower as text
%        str2double(get(hObject,'String')) returns contents of EditBESSMaxPower as a double
%change BESSMaxPower Setting
handles.SysParamSet.BESSMaxPower = ...
    str2double(get(handles.EditBESSMaxPower,'String'))*1e3;
updateCurLmt(handles);
handles = updateSCCap(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditBESSMaxPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditBESSMaxPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditCurOptTime_Callback(hObject, eventdata, handles)
% hObject    handle to EditCurOptTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCurOptTime as text
%        str2double(get(hObject,'String')) returns contents of EditCurOptTime as a double
handles.SysParamSet.CurOptTime = ...
    str2double(get(handles.EditCurOptTime,'String'));
handles = updateSCCap(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditCurOptTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCurOptTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDCfreq_Callback(hObject, eventdata, handles)
% hObject    handle to EditDCfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDCfreq as text
%        str2double(get(hObject,'String')) returns contents of EditDCfreq as a double
handles.SysParamSet.DCfreq = ...
    str2double(get(handles.EditDCfreq,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditDCfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDCfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditESEBatteryV_Callback(hObject, eventdata, handles)
% hObject    handle to EditESEBatteryV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditESEBatteryV as text
%        str2double(get(hObject,'String')) returns contents of EditESEBatteryV as a double
handles.SysParamSet.ESEBatteryV = ...
    str2double(get(handles.EditESEBatteryV,'String'));
updateCurLmt(handles) ;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function EditESEBatteryV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditESEBatteryV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditESESCUV_Callback(hObject, eventdata, handles)
% hObject    handle to EditESESCUV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditESESCUV as text
%        str2double(get(hObject,'String')) returns contents of EditESESCUV as a double
handles.SysParamSet.ESESCUV = ...
    str2double(get(handles.EditESESCUV,'String'));
handles = updateSCCap(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditESESCUV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditESESCUV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditESESCLV_Callback(hObject, eventdata, handles)
% hObject    handle to EditESESCLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditESESCLV as text
%        str2double(get(hObject,'String')) returns contents of EditESESCLV as a double
handles.SysParamSet.ESESCLV = ...
    str2double(get(handles.EditESESCLV,'String'));
handles = updateSCCap(handles);
updateCurLmt(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditESESCLV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditESESCLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditESESCMargin_Callback(hObject, eventdata, handles)
% hObject    handle to EditESESCMargin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditESESCMargin as text
%        str2double(get(hObject,'String')) returns contents of EditESESCMargin as a double
handles.SysParamSet.ESESCMargin = ...
    str2double(get(handles.EditESESCMargin,'String'))/100;
handles = updateSCCap(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditESESCMargin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditESESCMargin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSCCap_Callback(hObject, eventdata, handles)
% hObject    handle to EditSCCap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSCCap as text
%        str2double(get(hObject,'String')) returns contents of EditSCCap as a double


% --- Executes during object creation, after setting all properties.
function EditSCCap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSCCap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditConFs_Callback(hObject, eventdata, handles)
% hObject    handle to EditConFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditConFs as text
%        str2double(get(hObject,'String')) returns contents of EditConFs as a double
handles.SysParamSet.ConFs = ...
    str2double(get(handles.EditConFs,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditConFs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditConFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditConSCLs_Callback(hObject, eventdata, handles)
% hObject    handle to EditConSCLs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditConSCLs as text
%        str2double(get(hObject,'String')) returns contents of EditConSCLs as a double
handles.SysParamSet.ConSCLs = ...
    str2double(get(handles.EditConSCLs,'String'))*1e-3;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditConSCLs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditConSCLs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditConSCCurLmt_Callback(hObject, eventdata, handles)
% hObject    handle to EditConSCCurLmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditConSCCurLmt as text
%        str2double(get(hObject,'String')) returns contents of EditConSCCurLmt as a double
handles.SysParamSet.ConSCCurLmt = ...
    str2double(get(handles.EditConSCCurLmt,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditConSCCurLmt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditConSCCurLmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditConBLs_Callback(hObject, eventdata, handles)
% hObject    handle to EditConBLs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditConBLs as text
%        str2double(get(hObject,'String')) returns contents of EditConBLs as a double
handles.SysParamSet.ConBLs = ...
    str2double(get(handles.EditConBLs,'String'))*1e-3;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditConBLs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditConBLs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditConBCurLmt_Callback(hObject, eventdata, handles)
% hObject    handle to EditConBCurLmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditConBCurLmt as text
%        str2double(get(hObject,'String')) returns contents of EditConBCurLmt as a double
handles.SysParamSet.ConBCurLmt = ...
    str2double(get(handles.EditConBCurLmt,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditConBCurLmt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditConBCurLmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDCfs_Callback(hObject, eventdata, handles)
% hObject    handle to EditDCfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDCfs as text
%        str2double(get(hObject,'String')) returns contents of EditDCfs as a double
handles.SysParamSet.DCfs = ...
    str2double(get(handles.EditDCfs,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EditDCfs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDCfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%recalculate Paramater;
handles = updateCalParam(handles);
handles   = updateController(handles);
setSimParam(handles);
setSimDisturbStructByCurSelect(handles);
sim('PowerController',handles.SysParamSet.StopTime);


function EditVSCInit_Callback(hObject, eventdata, handles)
% hObject    handle to EditVSCInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditVSCInit as text
%        str2double(get(hObject,'String')) returns contents of EditVSCInit as a double


% --- Executes during object creation, after setting all properties.
function EditVSCInit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditVSCInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateCalParam(handles);
handles = updateController(handles);
setSimParam(handles);
setSimDisturbStructByCurSelect(handles);



function EditSCCurLmtRmd_Callback(hObject, eventdata, handles)
% hObject    handle to EditSCCurLmtRmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSCCurLmtRmd as text
%        str2double(get(hObject,'String')) returns contents of EditSCCurLmtRmd as a double


% --- Executes during object creation, after setting all properties.
function EditSCCurLmtRmd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSCCurLmtRmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditBCurLmtRmd_Callback(hObject, eventdata, handles)
% hObject    handle to EditBCurLmtRmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditBCurLmtRmd as text
%        str2double(get(hObject,'String')) returns contents of EditBCurLmtRmd as a double


% --- Executes during object creation, after setting all properties.
function EditBCurLmtRmd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditBCurLmtRmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadParam.
function LoadParam_Callback(hObject, eventdata, handles)
% hObject    handle to LoadParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = Savedlg(handles.SysParamSet,handles.SysParamSetArray,'Type','Load');
if ~isempty(user_response)
    if user_response{1}
        handles.SysParamSet = user_response{2};
        handles = updateUi(handles);
    end
end
guidata(hObject,handles);
    
% --- Executes on button press in LoadDefault.
function LoadDefault_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = modaldlg('Title','Confirm Close','String',...
    'Are You Sure to load Default Parameters?');
if user_response
    handles.SysParamSet = handles.SysParamSetArray(1);
    handles = updateUi(handles);
end
guidata(hObject,handles);

% --- Executes on button press in SaveChanges.
function SaveChanges_Callback(hObject, eventdata, handles)
% hObject    handle to SaveChanges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = Savedlg(handles.SysParamSet,handles.SysParamSetArray,'Type','SaveChanges');
if ~isempty(user_response)
    if user_response{1}
        SysParamSetArray = user_response{2};
        handles.SysParamSetArray = user_response{2};
        saveSysParam2Xml(SysParamSetArray,handles.SaveFileName);
    end
end
guidata(hObject,handles);


% --- Executes on button press in SaveAsDefault.
function SaveAsDefault_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = modaldlg('Title','Confirm Close','String',...
    'Are You Sure to Overwirte the Default Parameters?');
if user_response
    SysParamSetArray = handles.SysParamSetArray ;
    SysParamSetArray(1) = handles.SysParamSet;
    handles.SysParamSetArray = SysParamSetArray ;
    saveSysParam2Xml(SysParamSetArray,handles.SaveFileName);
end
guidata(hObject,handles);


% --- Executes on button press in DeleteParam.
function DeleteParam_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = Savedlg(handles.SysParamSet,handles.SysParamSetArray,'Type','Delete');
if ~isempty(user_response)
    if user_response{1}
                SysParamSetArray = user_response{2};
        handles.SysParamSetArray = user_response{2};
        saveSysParam2Xml(SysParamSetArray,handles.SaveFileName);
    end
end
guidata(hObject,handles);


% --- Executes on selection change in lbSimRs.
function lbSimRs_Callback(hObject, eventdata, handles)
% hObject    handle to lbSimRs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbSimRs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbSimRs


% --- Executes during object creation, after setting all properties.
function lbSimRs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbSimRs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lbDisturb.
function lbDisturb_Callback(hObject, eventdata, handles)
% hObject    handle to lbDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbDisturb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbDisturb


% --- Executes during object creation, after setting all properties.
function lbDisturb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbStep.
function rbStep_Callback(hObject, eventdata, handles)
% hObject    handle to rbStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbStep
setStepEnable(handles);


function edStepInitP_Callback(hObject, eventdata, handles)
% hObject    handle to edStepInitP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStepInitP as text
%        str2double(get(hObject,'String')) returns contents of edStepInitP as a double


% --- Executes during object creation, after setting all properties.
function edStepInitP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStepInitP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edStepFP_Callback(hObject, eventdata, handles)
% hObject    handle to edStepFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStepFP as text
%        str2double(get(hObject,'String')) returns contents of edStepFP as a double


% --- Executes during object creation, after setting all properties.
function edStepFP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStepFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edStepST_Callback(hObject, eventdata, handles)
% hObject    handle to edStepST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStepST as text
%        str2double(get(hObject,'String')) returns contents of edStepST as a double


% --- Executes during object creation, after setting all properties.
function edStepST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStepST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbPluse.
function rbPluse_Callback(hObject, eventdata, handles)
% hObject    handle to rbPluse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbPluse
setPluseEnable(handles);



function edPluseMaxP_Callback(hObject, eventdata, handles)
% hObject    handle to edPluseMaxP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edPluseMaxP as text
%        str2double(get(hObject,'String')) returns contents of edPluseMaxP as a double


% --- Executes during object creation, after setting all properties.
function edPluseMaxP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edPluseMaxP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edPluseMinP_Callback(hObject, eventdata, handles)
% hObject    handle to edPluseMinP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edPluseMinP as text
%        str2double(get(hObject,'String')) returns contents of edPluseMinP as a double


% --- Executes during object creation, after setting all properties.
function edPluseMinP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edPluseMinP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edPluseTs_Callback(hObject, eventdata, handles)
% hObject    handle to edPluseTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edPluseTs as text
%        str2double(get(hObject,'String')) returns contents of edPluseTs as a double


% --- Executes during object creation, after setting all properties.
function edPluseTs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edPluseTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbCustom.
function rbCustom_Callback(hObject, eventdata, handles)
% hObject    handle to rbCustom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbCustom
setCustomEnable(handles);



function edCustom_Callback(hObject, eventdata, handles)
% hObject    handle to edCustom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edCustom as text
%        str2double(get(hObject,'String')) returns contents of edCustom as a double


% --- Executes during object creation, after setting all properties.
function edCustom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edCustom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAddDisturb.
function pbAddDisturb_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if checkInputValid(handles)
    AddStr =  genDisturbStr(handles);
    HStr = get(handles.lbDisturb,'String');
    Num = length(HStr)+1 ;
    HStrNew = cell(Num,1);
    for i=1:Num-1
        HStrNew{i,:} = HStr{i,:};
    end
    HStrNew{Num,:} = AddStr;
    set(handles.lbDisturb,'String',HStrNew);
end


% --- Executes on button press in pbSaveDisturb.
function pbSaveDisturb_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StrW = genOutputList(handles) ;
if ~isempty(StrW)
    [file,path] = uiputfile('*.txt','Save List As');
    if(file~=0)
        fid = fopen(fullfile(path,file), 'w');
        fprintf(fid,StrW{1});
        fclose(fid);
    end
end
%dlmwrite('ListText.txt', get(handles.lbDisturb));


% --- Executes on button press in pbLoadDisturb.
function pbLoadDisturb_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.txt','Select the MATLAB code file');
if(FileName~=0)
    fid = fopen(fullfile(PathName,FileName), 'r');
    %textIn = fileread(fullfile(PathName,FileName));
    TextStr = textscan(fid,'%s','delimiter','\n');
    fclose(fid);
    %fullfill the list box
    set(handles.lbDisturb,'Value',1,'String',TextStr{1});
end


% --- Executes on button press in pbDelDisturb.
function pbDelDisturb_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popDisturbList(handles);


% --- Executes on button press in tb1.
function tb1_Callback(hObject, eventdata, handles)
% hObject    handle to tb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb1


% --- Executes on button press in PBPlot.
function PBPlot_Callback(hObject, eventdata, handles)
% hObject    handle to PBPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  currentVal = get(handles.lbSimRs,'Value');

  % Get data to plot
  legendStr = cell(length(currentVal),1);
  plotColor = {'b','g','r','c','m','y','k'};
  ColorNum = length(plotColor) ;
  ToggleValue = getToggledTb(handles);
  %make sure index not exceed
  try
    [Trival MaxIndexNum]  = size(handles.SimRsData(1).Output) ;
    cnt = 0 ;
    for i=1:length(ToggleValue)
        if ToggleValue(i-cnt) > MaxIndexNum 
            ToggleValue(i-cnt) = [];
            cnt = cnt+1;
        end
    end
  catch
      ToggleValue = [];
  end
  SimName = get(handles.lbSimRs,'String');
  if ~isempty(ToggleValue)
      %if two or more rs is selected then use color for one set
      if length(currentVal)>1
          for ctVal = 1:length(currentVal);
            PlotData{(ctVal*3)-2} = handles.SimRsData(currentVal(ctVal)).time;
            PlotData{(ctVal*3)-1} = handles.SimRsData(currentVal(ctVal)).Output(:,ToggleValue);	
            numColor = ctVal - ColorNum*( floor((ctVal-1)/ColorNum) );
            PlotData{ctVal*3} = plotColor{numColor};
            %get Name

            %legendStr{ctVal} = ['rS',num2str(ctVal)];
            legendStr{ctVal} = SimName{currentVal(ctVal)} ;
          end
          Interval = length(ToggleValue) ;
      else
          NameTemp = getToggledTbStr(handles,ToggleValue) ;
          for ctVal = 1:length(ToggleValue);
            PlotData{(ctVal*3)-2} = handles.SimRsData(currentVal(1)).time;
            PlotData{(ctVal*3)-1} = handles.SimRsData(currentVal(1)).Output(:,ToggleValue(ctVal));	
            numColor = ctVal - ColorNum*( floor((ctVal-1)/ColorNum) );
            PlotData{ctVal*3} = plotColor{numColor};
            %get Name

            %legendStr{ctVal} = ['rS',num2str(ctVal)];
            legendStr{ctVal} = NameTemp{ctVal} ;
          end
          Interval = 1;
      end
      % If necessary, create the plot figure and store in handles structure
      if ~isfield(handles,'PlotFigure') || ~ishandle(handles.PlotFigure),
        handles.PlotFigure = figure('Name','BESS Simulation Output','Visible','off',...
                                    'NumberTitle','off','HandleVisibility','off','IntegerHandle','off');
        handles.PlotAxes = axes('Parent',handles.PlotFigure);
        guidata(hObject,handles)
      end 

      % Plot data
      pHandles = plot(PlotData{:},'Parent',handles.PlotAxes);
      
      set(pHandles,'LineWidth',2);
      set(handles.PlotAxes,'XGrid','on','YGrid','on')
      %legend(pHandles(1:2:end),legendStr{:});
      legend(pHandles(1:Interval:end),legendStr{:});
      figure(handles.PlotFigure);
  end

  % Add a legend, and bring figure to the front
  %legend(pHandles(1:2:end),legendStr{:})
  % Make the figure visible and bring it forward



% --- Executes on button press in pbSimDisturb.
function pbSimDisturb_Callback(hObject, eventdata, handles)
% hObject    handle to pbSimDisturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DisturbCell = ParseDisturbText(handles);
%setSimDisturbStruct(handles,handles.DisturbCell{1});
%Start Simluation here
if~isempty(handles.DisturbCell)
    TotalSim = length(handles.DisturbCell);
    %param set
    handles = updateCalParam(handles);
    handles   = updateController(handles);
    setSimParam(handles);
    SimRs = get(handles.lbSimRs,'String');
    if ~iscell(SimRs)
        temp = SimRs ;
        SimRs = cell(1);
        SimRs{1} = temp;
    end
    %set Simulation result;
    if ~isfield(handles,'SimRsData') || isRsListEmpty(handles)
        SimRsData = struct('time',[],'Output',[]);
        Cnt = 0 ;
    else
        SimRsData = handles.SimRsData;
        Cnt = length(SimRs);
    end
    
    for i=1:TotalSim
        %update display
        updateSimdis(handles,TotalSim,i);
        %set param
        setSimDisturbStruct(handles,handles.DisturbCell{1});
        %Start Simulation
        [timeVector,stateVector,outputVector] = sim('PowerController',handles.SysParamSet.StopTime);
        SimRsData(Cnt+i).Output = outputVector ;
        SimRsData(Cnt+i).time = timeVector;
        %handles data
        handles.DisturbCell(1) = [] ;
        %update listbox display
        temp = get(handles.lbDisturb,'String');
        SimRs{Cnt+i} = temp{1};
        temp(1) = [];
        set(handles.lbDisturb,'String',temp);
        set(handles.lbSimRs,'String',SimRs);
    end
    
    handles.SimRsData = SimRsData ;
end
updateSimdis(handles,0,0);
guidata(hObject,handles);


function rs = isRsListEmpty(handles)
    % get Rs list str
    rs = false;
    RsListStr = get(handles.lbSimRs,'String');
    if ~iscell(RsListStr)
        if strcmpi(RsListStr,'<empty>')
            rs = true;
        end
    elseif isempty(RsListStr)
        rs = true;
    end
        

% --- Executes on button press in tb4.
function tb4_Callback(hObject, eventdata, handles)
% hObject    handle to tb4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb4


% --- Executes on button press in tb2.
function tb2_Callback(hObject, eventdata, handles)
% hObject    handle to tb2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb2


% --- Executes on button press in tb3.
function tb3_Callback(hObject, eventdata, handles)
% hObject    handle to tb3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb3


% --- Executes on button press in tb5.
function tb5_Callback(hObject, eventdata, handles)
% hObject    handle to tb5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb5


% --- Executes on button press in tb6.
function tb6_Callback(hObject, eventdata, handles)
% hObject    handle to tb6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb6



function edCustomTs_Callback(hObject, eventdata, handles)
% hObject    handle to edCustomTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edCustomTs as text
%        str2double(get(hObject,'String')) returns contents of edCustomTs as a double


% --- Executes during object creation, after setting all properties.
function edCustomTs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edCustomTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edSimProcess_Callback(hObject, eventdata, handles)
% hObject    handle to edSimProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSimProcess as text
%        str2double(get(hObject,'String')) returns contents of edSimProcess as a double


% --- Executes during object creation, after setting all properties.
function edSimProcess_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSimProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edRsReomve.
function edRsReomve_Callback(hObject, eventdata, handles)
% hObject    handle to edRsReomve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fist check empty
if isRsListEmpty(handles)
    if isfield(handles,'SimRsData') && ~isempty(handles.SimRsData)
        handles.SimRsData = [];
    end
else
    %get select value
    select = get(handles.lbSimRs,'Value');
    selectNum = length(select);
    ItemStr = get(handles.lbSimRs,'String');
    ItemNum = length(ItemStr);
    if(selectNum==ItemNum)
        %remove all, set list to empty;
        handles.SimRsData = [];
        ItemStr = '<empty>';
    else
        ItemStr(select) = [];
        handles.SimRsData(select) = [];
    end
        set(handles.lbSimRs,'Value',1);
        set(handles.lbSimRs,'String',ItemStr);
end
guidata(hObject,handles);
        


% --- Executes on button press in pbLoadSimRs.
function pbLoadSimRs_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadSimRs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat','Select Simulation Result');
if(FileName~=0)
    fName = fullfile(PathName,FileName);
    TempSimRsStr = load(fName,'SimRsStr');
    SimRsStr = TempSimRsStr.SimRsStr;
    TempSimRsData = load(fName,'SimRsData');
    SimRsData =TempSimRsData.SimRsData;
    %set display
    set(handles.lbSimRs,'Value',1);
    set(handles.lbSimRs,'String',SimRsStr);
    handles.SimRsData = SimRsData;
    guidata(hObject,handles);
end



% --- Executes on button press in pbSaveSimRs.
function pbSaveSimRs_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveSimRs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%first check if the lbSimRs is empty or not
if ~isRsListEmpty(handles)
    %grab the the data to save
    %String of the list Box
    [file,path] = uiputfile('*.mat','Save Simulation Result');
    if(file~=0)
        fName = fullfile(path,file);
        %display string
        SimRsStr = get(handles.lbSimRs,'String');
        %Data
        SimRsData = handles.SimRsData ;
        %try 5 times maximum;
        tryCnt = 5 ;
        while tryCnt >0
            try
                save(fName,'SimRsStr','SimRsData');
                tryCnt = -1 ;
            catch
                tryCnt = tryCnt-1;
            end
            if tryCnt ==0
                error('Write File fails!');
            end
        end
    end
end



function edStopTime_Callback(hObject, eventdata, handles)
% hObject    handle to edStopTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStopTime as text
%        str2double(get(hObject,'String')) returns contents of edStopTime as a double
handles.SysParamSet.StopTime = ...
    str2double(get(handles.edStopTime,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edStopTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStopTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
