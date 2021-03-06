function [Info, SW] = swa_FindSWTravelling(Info, SW, indSW)
% Calculate the streamlines for each slow wave

if ~isfield(Info.Parameters, 'Stream_GS');
    Info.Parameters.Stream_GS = 20; % size of interpolation grid
    fprintf(1,'Information: Interpolation grid set at 20x20 by default. \n');
    Info.Parameters.Stream_MinDelay = 40; % minimum travel time (ms)
end

%% Check Electrodes for 2D locations (match to grid)
Info.Electrodes = swa_add2dlocations(Info.Electrodes, Info.Parameters.Stream_GS);
fprintf(1,'Calculation: 2D electrode projections (Info.Electrodes). \n');

xloc = [Info.Electrodes.x]; xloc=xloc(:);
yloc = [Info.Electrodes.y]; yloc=yloc(:);

%% Create the plotting mesh
GS = Info.Parameters.Stream_GS; 
XYrange = linspace(1, GS, GS);
XYmesh = XYrange(ones(GS,1),:);
F = TriScatteredInterp(xloc,yloc,SW(1).Travelling_Delays(:), 'natural');      % No speed difference in methods...

%% Loop for each SW
if nargin == 3
    loopRange = indSW;    
else
    loopRange = 1:length(SW);
    h = waitbar(0,'Please wait...', 'Name', 'Finding Streams...');
end

for nSW = loopRange
    
    Delays      = SW(nSW).Travelling_Delays;
    
    % Check for minimum travel time...
    if max(Delays) < Info.Parameters.Stream_MinDelay * Info.Recording.sRate/1000
        continue
    end
    
    %% Interpolate delay map [zeros or nans above...]
    Delays = Delays(:);            % Ensure data is in column format
    F.V = Delays;                  % Put new data into the interpolant
    SW(nSW).Travelling_DelayMap = F(XYmesh, XYmesh'); % Delay map (with zeros)
    [u,v] = gradient(SW(nSW).Travelling_DelayMap);

    %% Define Starting Point(s) on the GSxGS grid...
    sx = xloc(SW(nSW).Channels_Active);
    sy = yloc(SW(nSW).Channels_Active);
      
    %% Find Streamline(s)

    % Use adstream2 (should optimise by coding entirely in c)
    Streams         = cell(1,length(sx));
    Distances       = cell(1,length(sx));
    for i = 1:length(sx)
        [StreamsBack, DistancesBack,~] = adstream2b(XYrange,XYrange,-u,-v,sx(i),sy(i), cosd(45), 0.1, 1000);
        [StreamsForw, DistancesForw,~] = adstream2b(XYrange,XYrange,u,v,sx(i),sy(i), cosd(45), 0.1, 1000);
        Streams{i}      = [fliplr(StreamsBack), StreamsForw];
        Distances{i}    = [fliplr(DistancesBack), DistancesForw];
    end
       
    %% Process and save streamlines...
    Streams(cellfun(@isempty, Streams)) = []; %Remove empty streams
    Distances(cellfun(@isempty, Distances)) = []; %Remove empty streams
    
    if isempty(Streams) % continue if there were no streams found
        continue
    end
    
    % Minimum Distance Threshold (25% of longest path)
    tDist = cellfun(@(x) sum(x), Distances);    %% Plot Functions
    Streams(tDist < max(tDist)/4) = [];
    Distances(tDist < max(tDist)/4) = [];
   
    % Longest displacement
    tDisp = cellfun(@(x) (sum((x(:,1)-x(:,end)).^2))^0.5, Streams); % total displacement
    [~,maxDispId] = max(tDisp);
    SW(nSW).Travelling_Streams{1} = Streams{maxDispId};
    
    % Longest distance travelled (if different from displacement)
    tDist = cellfun(@(x) sum(x), Distances);    %% Plot Functions
    [~,maxDistId] = max(tDist);
    if maxDistId ~= maxDispId
        SW(nSW).Travelling_Streams{end+1} = Streams{maxDistId};
    end  
        
    % Most different displacement angle compared to longest stream (at least 45 degrees)
    streamAngle = cellfun(@(x) atan2d(x(1,end)- x(1,1),x(2,end)-x(2,1)), Streams);
    [maxAngle,maxAngleId] = max(streamAngle - streamAngle(maxDispId));
    if maxAngle > 45 || maxAngleId ~= maxDispId || maxAngleId ~= maxDistId
        SW(nSW).Travelling_Streams{end+1} = Streams{maxAngleId};
    end
    
    % Update waitbar (if there is one)
    if exist('h', 'var')
        waitbar(nSW/length(SW),h,sprintf('Slow Wave %d of %d',nSW, length(SW)))
    end
    
end

if exist('h', 'var')
    delete(h)       % DELETE the waitbar; don't try to CLOSE it.
end
