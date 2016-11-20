function varargout = MainPage(varargin)
% MAINPAGE MATLAB code for MainPage.fig
%      MAINPAGE, by itself, creates a new MAINPAGE or raises the existing
%      singleton*.
%
%      H = MAINPAGE returns the handle to a new MAINPAGE or the handle to
%      the existing singleton*.
%
%      MAINPAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPAGE.M with the given input arguments.
%
%      MAINPAGE('Property','Value',...) creates a new MAINPAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainPage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainPage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainPage

% Last Modified by GUIDE v2.5 20-Nov-2016 11:33:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainPage_OpeningFcn, ...
                   'gui_OutputFcn',  @MainPage_OutputFcn, ...
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

%%
%opening functions

% --- Executes just before MainPage is made visible.
function MainPage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
%define FS
handles.fs = 1000;

%define density
handles.rho = 1.21;

%define speed of sound
handles.c = 343;

%define total time
handles.T = 10.0;

%define grid width in meters
handles.gridWidth = 120;

%define timestep
handles.dt = 1/(2*handles.fs);
%dfine grid spacing
handles.dx = 2 * handles.dt * handles.c;
%calculate pconst
handles.pconst = handles.rho * handles.c^2 * (handles.dt/handles.dx) * handles.dt * handles.c;
%calculate uconst
handles.uconst = (1/handles.rho)*(handles.dt/handles.dx)*handles.dt*handles.c;
% define pml depth
handles.PMLdepth = 10;
%calc time steps
handles.timestep = abs(handles.T/handles.dt);
%calc grid size
handles.N = ceil(abs(handles.gridWidth/handles.dx)+2*handles.PMLdepth);
%calculate differentiation matrix
handles.tempdiffmatrix = zeros(1,handles.N);
handles.diffmatrix = zeros(1,handles.N);
handles.temp = zeros(handles.N, handles.N);
%Calc source
handles.src = ones(7,ceil(handles.T/handles.dt)+10);
handles.src(1,10:610) = 1 - ((50*10^-10).*sin((2*pi/1200)*(1:601)));
handles.src(2,10:610) = 1 -((70*10^-10).*sin((2*pi/1200)*(1:601)));
handles.src(3,10:610) = 1 -((90*10^-10).*sin((2*pi/1200)*(1:601)));
handles.src(4,10:610) = 1 -((120*10^-10).*sin((2*pi/1200)*(1:601)));
handles.src(5,10:610) = 1 -((90*10^-10).*sin((2*pi/1200)*(1:601)));
handles.src(6,10:610) = 1 -((70*10^-10).*sin((2*pi/1200)*(1:601)));
handles.src(7,10:610) = 1 -((50*10^-10).*sin((2*pi/1200)*(1:601)));

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
    end
    if i2 ==  ceil((handles.N+1)/2)
        handles.tempdiffmatrix(i2) = 0;
    end
    if i2 >  ceil((handles.N+1)/2)
        handles.tempdiffmatrix(i2) = (i2 - (handles.N+1));
    end
end

for i = 1 : length(handles.diffmatrix)
    handles.diffmatrix = 1i * handles.tempdiffmatrix;
end

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
axes(handles.axes1);
for i = 0 : handles.dt : handles.T
handles = spectral_function(handles);
        if mod(handles.cntr,10)==1
          surf(real(handles.pd(100:300,100:300)));
          shading interp;
        view(2);
        title(sprintf('Time = %.6f s',i));
        drawnow();
        end
        i
end
guidata(hObject, handles);


% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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