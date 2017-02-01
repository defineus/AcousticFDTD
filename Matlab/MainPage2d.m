function varargout = MainPage2d(varargin)
%MAINPAGE2D MATLAB code file for MainPage2d.fig
%      MAINPAGE2D, by itself, creates a new MAINPAGE2D or raises the existing
%      singleton*.
%
%      H = MAINPAGE2D returns the handle to a new MAINPAGE2D or the handle to
%      the existing singleton*.
%
%      MAINPAGE2D('Property','Value',...) creates a new MAINPAGE2D using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to MainPage2d_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MAINPAGE2D('CALLBACK') and MAINPAGE2D('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MAINPAGE2D.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainPage2d

% Last Modified by GUIDE v2.5 01-Feb-2017 21:34:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainPage2d_OpeningFcn, ...
                   'gui_OutputFcn',  @MainPage2d_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before MainPage2d is made visible.
function MainPage2d_OpeningFcn(hObject, eventdata, handles, varargin)
%define FS
handles.fs = 1000;

%define density
handles.rho = 1.21;

%define speed of sound
handles.c = 343;

%define total time
handles.T = 10.0;

%define grid width in meters
handles.gridWidth = 10;

%define timestep
handles.dt = 1/(2*handles.fs);
%dfine grid spacing
handles.dx = 2 * handles.dt * handles.c;
%calculate pconst
handles.pconst = handles.rho * handles.c^2 * (handles.dt/handles.dx) * handles.dt * handles.c;
%calculate uconst
handles.uconst = (1/handles.rho)*(handles.dt/handles.dx)*handles.dt*handles.c;
% define pml depth
% handles.PMLdepth = 10;
% handles.PMLdepth = 30;
%calc PML depth
handles.PMLdepth = ceil((abs(handles.gridWidth/handles.dx)/10)/2);
%calc time steps
handles.timestep = abs(handles.T/handles.dt);
%calc grid size
handles.N = ceil(abs(handles.gridWidth/handles.dx)+2*handles.PMLdepth);

%calculate differentiation matrix
handles.tempdiffmatrix = zeros(1,handles.N);
handles.tempdiffmatriy = zeros(handles.N,1);
handles.diffmatrix = zeros(handles.N,handles.N);
handles.diffamalgamx = zeros(handles.N,handles.N);
handles.diffamalgamy = zeros(handles.N,handles.N);
handles.diffamalgam = zeros(handles.N,handles.N);
handles.temp = zeros(handles.N, handles.N);
%Calc source
handles.src = ones(7,ceil(handles.T/handles.dt)+10);
handles.src(1,10:610) = 1 - ((50*10^-10).*sin((2*pi/600)*(1:601)));
handles.src(2,10:610) = 1 -((70*10^-10).*sin((2*pi/600)*(1:601)));
handles.src(3,10:610) = 1 -((90*10^-10).*sin((2*pi/600)*(1:601)));
handles.src(4,10:610) = 1 -((120*10^-10).*sin((2*pi/600)*(1:601)));
handles.src(5,10:610) = 1 -((90*10^-10).*sin((2*pi/600)*(1:601)));
handles.src(6,10:610) = 1 -((70*10^-10).*sin((2*pi/600)*(1:601)));
handles.src(7,10:610) = 1 -((50*10^-10).*sin((2*pi/600)*(1:601)));

%Create visualisation data storage matrix
handles.pdstore = zeros(handles.N, handles.N, ceil((handles.T/handles.dt)/100)+1);

%create alpha for PML region
handles.alpha = 0;
%celculate geometry matricies
handles.phat = zeros(handles.N,handles.N);
handles.uhat = zeros(handles.N,handles.N);
handles.pdiffhat = zeros(handles.N,handles.N);
handles.udiffhat = zeros(handles.N,handles.N);
handles.pd = zeros(handles.N,handles.N);
handles.ud = zeros(handles.N,handles.N);
%Create the differentiator
for i2 = 1 : handles.N
    if i2 <  ceil(handles.N+1/2)
        handles.tempdiffmatrix(i2) =  (i2-1);
        handles.tempdiffmatriy(i2,1) =  (i2-1);
    end
    if i2 ==  ceil((handles.N+1)/2)
        handles.tempdiffmatrix(i2) = 0;
        handles.tempdiffmatriy(i2,1) = 0;
    end
    if i2 >  ceil((handles.N+1)/2)
        handles.tempdiffmatrix(i2) = (i2 - (handles.N+1));
        handles.tempdiffmatriy(i2,1) =  (i2 - (handles.N+1));
    end
end

for i1 = 1 : handles.N
handles.diffamalgamx(:,i1) = handles.tempdiffmatrix;
handles.diffamalgamy(i1,:) = handles.tempdiffmatriy;
end
handles.diffamalgam = handles.diffamalgamx + handles.diffamalgamy;
handles.diffamalgam = handles.diffamalgam ./2;
% handles.diffmatrix = 1i * handles.tempdiffmatrix;
% handles.diffmatriy = 1i * handles.tempdiffmatriy;
handles.diffmatrix = 1i * handles.diffamalgam;
handles.hanger = 0;
handles.cntr = 1;

% Choose default command line output for MainPage
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainPage wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainPage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pause_button,'Visible','On');
set(handles.resume_button,'Visible','Off');
set(handles.stop_button,'Visible','On');
set(handles.run_button,'Visible','Off');
axes(handles.axes1);
for i = 0 : handles.dt : handles.T
    pause(0.000001) ;
    if handles.hanger == 1
        pause(0.000001) ;
        return
    end
    pause(0.000001) ;
handles = spectral_function2d(handles);
pause(0.000001) ;
        if mod(handles.cntr,10)==1
          surf(handles.pd);
%           shading interp;
%         view(2);
        title(sprintf('Time = %.6f s Max = %.6f dB',i ,(20 * log10(max(max(abs(handles.pd))/(10^-12))))));
        drawnow();
        end
        pause(0.000001) ;
end
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
% Choose default command line output for MainPage
handles.output = hObject;
set(handles.pause_button,'Visible','Off');
set(handles.resume_button,'Visible','On');
pause(0.000001);
uiwait(gcf);
pause(0.000001);
% Update handles structure
guidata(hObject, handles);
% hObject    handle to pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in resume_button.
function resume_button_Callback(hObject, eventdata, handles)
% hObject    handle to resume_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Choose default command line output for MainPage
handles.output = hObject;
set(handles.pause_button,'Visible','On');
set(handles.resume_button,'Visible','Off');
pause(0.000001) ;
uiresume(gcf);
pause(0.000001) ;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
handles.hanger = 1;
set(handles.pause_button,'Visible','On');
set(handles.resume_button,'Visible','Off');
set(handles.stop_button, 'Visible','Off');
set(handles.run_button,'Visible','On');
pause(0.000001) ;
% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%PLOTTING FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotter_Callback(hObject, eventdata, handles)
axes(handles.axes1), set(handles.axes1, 'Visible', 'On');
cla(handles.axes1),reset(handles.axes1), hold off;
% plot(get(handles.SLX, 'Value'), get(handles.SLY, 'Value'), ...
%     'k', 'Marker', 'o', 'MarkerSize', 10), hold on;
% plot(get(handles.LLX, 'Value'), get(handles.LLY, 'Value'), ...
%     'k', 'Marker', 'x', 'MarkerSize', 10), hold off;
% grid on, axis([0 get(handles.LLX, 'Value') 0 get(handles.LLY, 'Value')]);

% title(' o = source, x = listener');
