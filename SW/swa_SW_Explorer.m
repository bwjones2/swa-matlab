%% GUI for Exploring Travelling Waves

function swa_SW_Explorer(varargin)
DefineInterface

function DefineInterface
%% Create Figure
handles.Figure = figure(...
    'Name',         'Travelling Waves:',...
    'NumberTitle',  'off',...
    'Color',        'w',...
    'MenuBar',      'none',...
    'Units',        'normalized',...
    'Outerposition',[0 0.04 1 0.96]);

%% Menus
handles.menu.File = uimenu(handles.Figure, 'Label', 'File');
handles.menu.LoadData = uimenu(handles.menu.File,...
    'Label', 'Load Data',...
    'Accelerator', 'L');
set(handles.menu.LoadData, 'Callback', {@menu_LoadData});

handles.menu.SaveData = uimenu(handles.menu.File,...
    'Label', 'Save Data',...
    'Accelerator', 'S');
set(handles.menu.SaveData, 'Callback', {@menu_SaveData});

%% Status Bar
handles.StatusBar = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Status Updates',...
    'Units',    'normalized',...
    'Position', [0 0 1 0.03],...
    'FontName', 'Century Gothic',...
    'FontSize', 10);

handles.java.StatusBar = findjobj(handles.StatusBar);
handles.java.StatusBar.setVerticalAlignment(javax.swing.SwingConstants.CENTER);
handles.java.StatusBar.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);

%% Slider Spinner and Delete Button
[handles.java.Slider,handles.Slider] = javacomponent(javax.swing.JSlider);
set(handles.Slider,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.05 0.72 0.32 0.05]);
% >> handles.java.Slider.set [then tab complete to find available methods]
handles.java.Slider.setBackground(javax.swing.plaf.ColorUIResource(1,1,1))
set(handles.java.Slider, 'MouseReleasedCallback',{@SliderUpdate, handles.Figure});

[handles.java.Spinner,handles.Spinner] = javacomponent(javax.swing.JSpinner);
set(handles.Spinner,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.38 0.72 0.05 0.05]);
% Set the font and size (Found through >>handles.java.Slider.Font)
handles.java.Spinner.setFont(javax.swing.plaf.FontUIResource('Century Gothic', 0, 25))
handles.java.Spinner.getEditor().getTextField().setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
set(handles.java.Spinner, 'StateChangedCallback', {@SpinnerUpdate, handles.Figure});

handles.pb_Delete = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   'X',...
    'Units',    'normalized',...
    'Position', [0.43 .72 0.02 0.05],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.pb_Delete, 'Callback', {@pb_Delete_Callback});

%% Plot Titles and Export Button
handles.Title_SWPlot = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Individual Wave',...
    'Units',    'normalized',...
    'Position', [0.05 .68 0.4 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_SWPlot = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.43 .68 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_SWPlot, 'Callback', @edit_SWPlot)

handles.Title_Origins = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Origins Map',...
    'Units',    'normalized',...
    'Position', [0.05 .38 0.2 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_Origins = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.23 .38 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_Origins, 'Callback', @pb_XOrigins_Callback)


handles.Title_Density = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Density Map',...
    'Units',    'normalized',...
    'Position', [0.25 .38 0.2 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_Density = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.43 .38 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_Density, 'Callback', @pb_XDensity_Callback)


handles.Title_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Delay Map',...
    'Units',    'normalized',...
    'Position', [0.5 .73 0.45 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.93 .73 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_Delay, 'Callback', @pb_XDelay_Callback)

%% Checkboxes for Delay
handles.Surface_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',...
    'BackgroundColor', 'w',...
    'String',   'Surface',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.5 .1 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Surface_Delay, 'Callback', @UpdateDelay2);

handles.Channels_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',...    
    'BackgroundColor', 'w',...
    'String',   'Channels',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.6 .1 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Channels_Delay, 'Callback',  @UpdateDelay2);

handles.Origins_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',... 
    'BackgroundColor', 'w',...
    'String',   'Origins',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.7 .1 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Origins_Delay, 'Callback',  @UpdateDelay2);

handles.Streams_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',... 
    'BackgroundColor', 'w',...
    'String',   'Streams',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.8 .1 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Streams_Delay, 'Callback',  @UpdateDelay2);


%% Create Axes
handles.ax_Butterfly = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.8 0.9 0.15],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Ytick', []);

handles.ax_SWPlot = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.4 0.4 0.3],...
    'FontName', 'Century Gothic',...
    'NextPlot', 'add',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

handles.ax_Origins = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.1 0.2 0.3],...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

handles.ax_Density = axes(...
    'Parent', handles.Figure,...
    'Position', [0.25 0.1 0.2 0.3],...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

handles.ax_Delay = axes(...
    'Parent', handles.Figure,...
    'Position', [0.5 0.1 0.45 0.65],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

%% Context Menus
handles.menu.ButterflyContext = uicontextmenu;
handles.menu.UIContext_YReverse = uimenu(handles.menu.ButterflyContext,...
    'Label',    'Negative Down',...
    'Callback', {@Butterfly_Context, 'normal'});
handles.menu.UIContext_YReverse = uimenu(handles.menu.ButterflyContext,...
    'Label',    'Negative Up',...
    'Callback', {@Butterfly_Context, 'reverse'});
set(handles.ax_Butterfly, 'uicontextmenu', handles.menu.ButterflyContext);
set(handles.ax_SWPlot, 'uicontextmenu', handles.menu.ButterflyContext);

%% Make Figure Visible and Maximise
set(handles.Figure, 'Visible', 'on');
drawnow; pause(0.001)
jFrame = get(handle(handles.Figure),'JavaFrame');
jFrame.setMaximized(true);   % to maximize the figure

guidata(handles.Figure, handles);

function menu_LoadData(hObject, eventdata)
handles = guidata(hObject);

[swaFile, swaPath] = uigetfile('*.mat', 'Please Select the Results File');
if swaFile == 0
    set(handles.StatusBar, 'String', 'Information: No File Selected');
    return;
end

set(handles.StatusBar, 'String', 'Busy: Loading Data');
load ([swaPath,swaFile], 'Data', 'Info', 'SW');

set(handles.Figure, 'Name', ['Travelling Waves: ', swaFile]);

%% Check for data present or external file
if ischar(Data.Raw)
    set(handles.StatusBar, 'String', 'Busy: Loading Data');
    fid = fopen(Data.Raw);
    Data.Raw = fread(fid, Info.Recording.dataDim, 'single');
    fclose(fid);
end

%% Set the handles
handles.Info    = Info;
handles.SW      = SW;
handles.Data    = Data;

%% Set Slider and Spinner Values
handles.java.Slider.setValue(1);
handles.java.Slider.setMinimum(1);
handles.java.Slider.setMaximum(length(SW));
handles.java.Slider.setMinorTickSpacing(5);
handles.java.Slider.setMajorTickSpacing(20);
handles.java.Slider.setPaintTicks(true);
% handles.java.Slider.setPaintLabels(false);
% handles.java.Slider.setPaintLabels(true);

handles.java.Spinner.setValue(1);

%% Draw Initial Plots
 
% Origins & Delay Plot
handles = update_SWOriginsMap(handles);

% Colormap
colormap(flipud(hot))

set(handles.StatusBar, 'String', 'Idle');
% Update handles structure
guidata(hObject, handles);

function menu_SaveData(hObject, eventdata)
handles = guidata(hObject);

[saveName,savePath] = uiputfile('*.mat');

if saveName == 0; return; end

Data = handles.Data;
Info = handles.Info;
SW   = handles.SW;

save([savePath, saveName], 'Data', 'Info', 'SW', '-mat');


%% Update Controls
function SpinnerUpdate(~,~,hObject)
handles = guidata(hObject); % Needs to be like this because slider is a java object

handles.java.Slider.setValue(handles.java.Spinner.getValue())

handles = update_ButterflyPlot(handles);
% handles = update_SWOriginsMap(handles);
handles = update_SWPlot(handles);
handles = update_SWDelay(handles, 0);

guidata(hObject, handles);

function SliderUpdate(~,~,Figure)
handles = guidata(Figure); % Needs to be like this because slider is a java object

handles.java.Spinner.setValue(handles.java.Slider.getValue())

handles = update_ButterflyPlot(handles);
% handles = update_SWOriginsMap(handles);
handles = update_SWPlot(handles);
handles = update_SWDelay(handles, 0);

guidata(handles.Figure, handles);


%% Plot Controls
function handles = update_ButterflyPlot(handles)
% initial plot then update the yData in a loop (faster than replot)
nSW = handles.java.Spinner.getValue();
win = round(10*handles.Info.Recording.sRate); % ten seconds on each side of the wave

range = round((handles.SW(nSW).Ref_PeakInd-win):(handles.SW(nSW).Ref_PeakInd+win));
range(range<1)=[]; %eliminate negative values in case SW is early in the data
xaxis = range./handles.Info.Recording.sRate;

if ~isfield(handles, 'lines_Butterfly') %50 times takes 1.67s
    cla(handles.ax_Butterfly);
    handles.lines_Butterfly = plot(handles.ax_Butterfly, xaxis, handles.Data.Raw(:,range)', 'k');
    set(handles.ax_Butterfly,...
        'YLim', [-120,80],...
        'XLim', [xaxis(1), xaxis(end)]);
    
    handles.zoomline(1) = line([handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate-0.4, handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate-0.4],[-200, 200], 'color', [0.4 0.4 0.4], 'linewidth', 2, 'Parent', handles.ax_Butterfly);
    handles.zoomline(2) = line([handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate+.6, handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate+0.6],[-200, 200], 'color', [0.4 0.4 0.4], 'linewidth', 2, 'Parent', handles.ax_Butterfly);

else %50 times takes 0.3s
    set(handles.lines_Butterfly, 'xData', xaxis);
    for j = 1:size(handles.Data.Raw, 1)
        set(handles.lines_Butterfly(j), 'yData', handles.Data.Raw(j,range)');
    end 
    set(handles.ax_Butterfly,...
        'XLim', [xaxis(1), xaxis(end)]);
    
    set(handles.zoomline(1), 'xData', [handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate-0.4, handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate-0.4]);
    set(handles.zoomline(2), 'xData', [handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate+0.6, handles.SW(nSW).Ref_PeakInd/handles.Info.Recording.sRate+0.6]);
end

function handles = update_SWPlot(handles)
nSW = handles.java.Spinner.getValue();
win = round(0.5*handles.Info.Recording.sRate);

if ~isfield(handles, 'SWPlot') % in case plot doesn't already exist
    cla(handles.ax_SWPlot);
    
    handles.SWPlot.All = plot(handles.ax_SWPlot, handles.Data.Raw(:,handles.SW(nSW).Ref_PeakInd-win:handles.SW(nSW).Ref_PeakInd+win)',...
        'color',        [0.7 0.7 0.7],...
        'linewidth',    0.5,...
        'visible',      'off');
    set(handles.SWPlot.All(handles.SW(nSW).Channels_Active),...
        'color',        'k',...
        'linewidth',    1,...
        'visible',      'on');
    set(handles.SWPlot.All(handles.SW(nSW).Travelling_Delays<1),...
        'color', 'g',...
        'linewidth', 2);
    
    handles.SWPlot.Ref = plot(handles.ax_SWPlot, handles.Data.SWRef(1,handles.SW(nSW).Ref_PeakInd-win:handles.SW(nSW).Ref_PeakInd+win)',...
        'color',        'r',...
        'linewidth',    3);

    set(handles.ax_SWPlot, 'XLim', [1, win*2+1])
    
else
    for i = 1:size(handles.Data.Raw,1) % faster than total replot...
         set(handles.SWPlot.All(i),...
             'yData', handles.Data.Raw(i,handles.SW(nSW).Ref_PeakInd-win:handles.SW(nSW).Ref_PeakInd+win),...
             'Color', [0.6 0.6 0.6], 'linewidth', 0.5, 'visible', 'off');
    end
    set(handles.SWPlot.All(handles.SW(nSW).Channels_Active), 'Color', 'k', 'LineWidth', 1, 'visible', 'on');
    set(handles.SWPlot.All(handles.SW(nSW).Travelling_Delays < 1), 'Color', 'g', 'LineWidth', 2);
    set(handles.SWPlot.Ref, 'yData', handles.Data.SWRef(1,handles.SW(nSW).Ref_PeakInd-win:handles.SW(nSW).Ref_PeakInd+win));
    
    set(handles.ax_SWPlot, 'YLim', [handles.SW(nSW).Channels_NegAmp-20, -handles.SW(nSW).Channels_NegAmp-20])

end

function handles = update_SWDelay(handles, nFigure)
nSW = handles.java.Spinner.getValue();

if nFigure ~= 1; cla(handles.ax_Delay); end

if ~isempty(handles.SW(nSW).Travelling_DelayMap)
    H = swa_Topoplot...
        (handles.SW(nSW).Travelling_DelayMap, handles.Info.Electrodes,...
        'NewFigure',        nFigure                             ,...
        'Axes',             handles.ax_Delay                    ,...
        'NumContours',      10                                  ,...
        'PlotContour',      1                                   ,...
        'PlotSurface',      get(handles.Surface_Delay,  'value'),...
        'PlotChannels',     get(handles.Channels_Delay, 'value'),...
        'PlotStreams',      get(handles.Streams_Delay,  'value'),...
        'Streams',          handles.SW(nSW).Travelling_Streams);
else % if there is no delay map make one!
    ept_Topoplot(handles.SW(nSW).Travelling_Delays,handles.Info.Electrodes,...
        'NewFigure',        nFigure,...
        'PlotContour',      1,...
        'NumContours',      10,...
        'PlotSurface',      get(handles.Surface_Delay,   'value'),...
        'PlotChannels',     get(handles.Channels_Delay,  'value'));
    colormap(flipud(hot));
end
  
if get(handles.Origins_Delay, 'Value') == 1 && exist('H', 'var')
    if isfield(H, 'Channels')
        set(H.Channels(handles.SW(nSW).Travelling_Delays<2),...
            'String',           'o'         ,...
            'FontSize',         12          );
    end
end

function handles = update_SWOriginsMap(handles, nFigure)

handles.Origins = zeros(size(handles.Data.Raw,1),1);
handles.Totals  = zeros(size(handles.Data.Raw,1),1);
for i = 1:length(handles.SW)
    handles.Origins(handles.SW(i).Travelling_Delays<1) = handles.Origins(handles.SW(i).Travelling_Delays<1) + 1;
    handles.Totals(handles.SW(i).Channels_Active)  = handles.Totals(handles.SW(i).Channels_Active) +1;
end

set(gcf,'CurrentAxes',handles.ax_Origins)
ept_Topoplot(handles.Origins,handles.Info.Electrodes, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);

set(gcf,'CurrentAxes',handles.ax_Density)
ept_Topoplot(handles.Totals,handles.Info.Electrodes, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);


%% Push Buttons
function pb_XOrigins_Callback(hObject, eventdata)
handles = guidata(hObject);
ept_Topoplot(handles.Origins,handles.Info.Electrodes, 'NewFigure', 1, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);

function pb_XDensity_Callback(hObject, eventdata)
handles = guidata(hObject);
ept_Topoplot(handles.Totals,handles.Info.Electrodes, 'NewFigure', 1, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);

function pb_XDelay_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
update_SWDelay(handles, 1);


function pb_Delete_Callback(hObject, eventdata)
handles = guidata(hObject);

handles.SW(handles.java.Spinner.getValue())=[];

handles.java.Slider.setMaximum(length(handles.SW));

% Update the Origins and Density Maps with new values
handles = update_SWOriginsMap(handles, 0);
colormap(flipud(hot));

guidata(hObject, handles);
SpinnerUpdate([],[], hObject);


function edit_SWPlot(hObject, eventdata)
handles = guidata(hObject);
nSW = handles.java.Spinner.getValue();
win = round(0.5*handles.Info.Recording.sRate);

SW_Handles.Figure = figure(...
    'Name',         'Edit Detected Slow Wave',...
    'NumberTitle',  'off',...
    'Color',        'w',...
    'MenuBar',      'none',...
    'Units',        'normalized',...
    'Outerposition',[0 0.04 1 0.96]);

SW_Handles.Axes = axes(...
    'Parent', SW_Handles.Figure,...
    'Position', [0.05 0.05 0.9 0.9],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'XLim', [1, win*2+1]);

% add javacomponent buttons
% `````````````````````````
% get icons
iconZoom = fullfile(matlabroot,'/toolbox/matlab/icons/tool_zoom_in.png');
iconArrow = fullfile(matlabroot,'/toolbox/matlab/icons/tool_pointer.png'); 
iconTravel = fullfile(matlabroot,'/toolbox/matlab/icons/tool_text_arrow.png'); 

[j_pbArrow,SW_Handles.pb_Arrow] = javacomponent(javax.swing.JButton);
set(SW_Handles.pb_Arrow,...
    'Parent',   SW_Handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.80 0.05 0.05 0.07]);
% >> j_pbZoom.set [then tab complete to find available methods]
j_pbArrow.setIcon(javax.swing.ImageIcon(iconArrow))
set(j_pbArrow, 'ToolTipText', 'Select Channel'); 
set(j_pbArrow, 'MouseReleasedCallback', 'zoom off');

[j_pbZoom,SW_Handles.pb_Zoom] = javacomponent(javax.swing.JButton);
set(SW_Handles.pb_Zoom,...
    'Parent',   SW_Handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.85 0.05 0.05 0.07]);
% >> j_pbZoom.set [then tab complete to find available methods]
j_pbZoom.setIcon(javax.swing.ImageIcon(iconZoom))
set(j_pbZoom, 'ToolTipText', 'Zoom Mode'); 
set(j_pbZoom, 'MouseReleasedCallback', 'zoom on');

[j_pbTravel,SW_Handles.pb_Travel] = javacomponent(javax.swing.JButton);
set(SW_Handles.pb_Travel,...
    'Parent',   SW_Handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.92 0.05 0.05 0.07]);
% >> j_pbZoom.set [then tab complete to find available methods]
j_pbTravel.setIcon(javax.swing.ImageIcon(iconTravel))
set(j_pbTravel, 'ToolTipText', 'Recalculate Travelling'); 
set(j_pbTravel, 'MouseReleasedCallback', {@UpdateTravelling, handles.Figure});

% plot the channels
% `````````````````
SW_Handles.Plot_Ch = plot(SW_Handles.Axes, handles.Data.Raw(:,handles.SW(nSW).Ref_PeakInd-win:handles.SW(nSW).Ref_PeakInd+win)',...
    'Color', [0.6 0.6 0.6],...
    'LineWidth', 0.5);
set(SW_Handles.Plot_Ch, 'ButtonDownFcn', {@Channel_Selected, handles.Figure, SW_Handles});
set(SW_Handles.Plot_Ch(handles.SW(nSW).Channels_Active), 'Color', 'k', 'LineWidth', 1);
set(SW_Handles.Plot_Ch(handles.SW(nSW).Travelling_Delays<1), 'Color', 'b', 'LineWidth', 2);

handles.SWPlot.Ref = plot(SW_Handles.Axes, handles.Data.SWRef(1,handles.SW(nSW).Ref_PeakInd-win:handles.SW(nSW).Ref_PeakInd+win)','Color', 'r', 'linewidth', 3);

function UpdateTravelling(hObject, ~ , FigureHandle)
handles = guidata(FigureHandle);

nSW = handles.java.Spinner.getValue();

% Recalculate the Travelling_Delays parameter before running since we 
% do not know what their delay is
window  = round(handles.Info.Parameters.Channels_WinSize*handles.Info.Recording.sRate);
% double the window length for the raw data (for better correlation and filtering)
rangeRaw   = (handles.SW(nSW).Ref_PeakInd-window*2):(handles.SW(nSW).Ref_PeakInd+window*2);  
rangeRef   = (handles.SW(nSW).Ref_PeakInd-window):(handles.SW(nSW).Ref_PeakInd+window);  

% filter the data
rawData     = handles.Data.Raw(handles.SW(nSW).Channels_Active, rangeRaw);
filtData    = swa_filter_data(rawData, handles.Info);

refData     = handles.Data.SWRef(handles.SW(nSW).Ref_Region(1), rangeRef);

if strcmp(handles.Info.Parameters.Ref_Method, 'Envelope')
    % calculate the correlations
    cc = swa_xcorr(refData, filtData, window);
    [~, maxID]      = max(cc,[],2);
else
%     TODO: Recalculation of travelling parameters for non-envelope measures
    fprintf(1, 'Warning: Recalculation of travelling not yet available for non-envelope methods');
    return;
end

% delay calculation
SW(nSW).Travelling_Delays = nan(length(handles.Info.Electrodes),1);
SW(nSW).Travelling_Delays(handles.SW(nSW).Channels_Active)...
    = maxID- min(maxID);

% find the travelling parameters
[handles.Info, handles.SW] = swa_FindSWTravelling(handles.Info, handles.SW, nSW);

% update the handles structure
handles = update_SWDelay(handles, 0);
guidata(handles.Figure, handles);


function Channel_Selected(hObject, eventdata, FigureHandle, SW_Handles)
handles = guidata(FigureHandle);

nSW = handles.java.Spinner.getValue();
nCh = find(SW_Handles.Plot_Ch == hObject);

if ~handles.SW(nSW).Channels_Active(nCh)
    handles.SW(nSW).Channels_Active(nCh) = true;
    set(SW_Handles.Plot_Ch(nCh), 'Color', 'k', 'LineWidth', 1)
    set(handles.SWPlot.All(nCh), 'Color', 'k', 'LineWidth', 1)
else
    handles.SW(nSW).Channels_Active(nCh) = false;
    set(SW_Handles.Plot_Ch(nCh), 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5)
    set(handles.SWPlot.All(nCh), 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5)
end

guidata(handles.Figure, handles);


%% Check Boxes
function UpdateDelay2(hObject, eventdata)
handles = guidata(hObject);
update_SWDelay(handles, 0);
