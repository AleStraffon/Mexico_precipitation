%% CODE TO GENERATE PRECIPITATION TREND MAPS for 3 datasets and all fortnights

% clear all
% 
load PPT_CHIRPS_81_24.mat
load PPT_ERA_81_24.mat 
load PPT_SMN_81_24.mat
load p_value_PPT_SMN_81_24.mat
load p_value_PPT_ERA_81_24.mat
load p_value_PPT_CHIRPS_81_24.mat
S=shaperead('Regiones.shp');

%Combine p-value arrays for the 3 datasets
p_value = zeros(3,37,25); % with the 44-year slopes
p_value(1,:,:) = p_value_PPT_81_24(:,:); %SMN
p_value(2,:,:) = p_value_PPT_CHIRPS_81_24(:,:); %CHIRPS
p_value(3,:,:) = p_value_PPT_ERA_81_24(:,:); %ERA


names = {'SMN', 'CHIRPPS', 'ERA5'};


R = 15;% max(max(abs(Mqq))); %The maximum absolute value for a fortnight is determined
%% DETAILS OF THE SYMMETRIC PRECIPITATION COLORBAR 

n = 100;

% Define the base colors
red_dark   = [0.55 0.1 0.1];
white      = [1 1 1];
green_dark = [0 0.5 0]; % (0,128,0)

% --- PARÁMETRO AJUSTABLE ---
white_frac = 0.05;%R/5; % Central white fraction (e.g., 0.2 = 20%)
% You can change this value between 0 (no white) and ~0.5 (very wide white band)
% ----------------------------

% Calculate how many colors correspond to the white range
n_white = round(n * white_frac / 2);
n_half = (n/2) - n_white;

% Interpolate from dark red → white
reds_to_white = [linspace(red_dark(1), white(1), n_half)' ...
                 linspace(red_dark(2), white(2), n_half)' ...
                 linspace(red_dark(3), white(3), n_half)'];

% Maintain a wider central white band
white_band = repmat(white, 2*n_white, 1);

% Interpolate from white → dark green
white_to_greens = [linspace(white(1), green_dark(1), n_half)' ...
                   linspace(white(2), green_dark(2), n_half)' ...
                   linspace(white(3), green_dark(3), n_half)'];

% Combine all parts
cmap = [reds_to_white; white_band; white_to_greens];

% Apply colormap
colormap(cmap);
colorbar;


%n = size(cmap,1);%Number of color intervals in the map



%% Create a folder to save the figures 
%output_folder = 'Figuras';

% 1️. Create a global grid of evenly spaced points
allX = [S.X];
allY = [S.Y];
xlim_global = [min(allX) max(allX)];
ylim_global = [min(allY) max(allY)];

% Define the uniform spacing
dx = (xlim_global(2)-xlim_global(1)) / 70; % you can adjust the 200
dy = (ylim_global(2)-ylim_global(1)) / 70;
[xp_global, yp_global] = meshgrid(xlim_global(1):dx:xlim_global(2), ...
                                  ylim_global(1):dy:ylim_global(2));

%% Test with a for loop for multiple fortnights

for qq=25:25 %fortnight number

Mqq = zeros(3,37); % with the 44-year slopes
Mqq(1,:)=PPT_SMN_81_24(qq,45,:);%SMN 2
Mqq(3,:)=PPT_ERA_81_24_corr(qq,45,:);%ERA
Mqq(2,:)=PPT_CHIRPS_81_24(qq,45,:);%CHIRPS



figure()
set(gcf,'Units','pixels','Position',[100 100 2400 700])
set(gcf,'Color','w') %white background
% --- Layout with 3 maps (one dataset per map) ---
tiledlayout(1,3,'TileSpacing','none','Padding','compact')

names = {'SMN', 'CHIRPS', 'ERA5'};
nbases = numel(names);

for b = 1:nbases   % dataset index

    nexttile
    ax = gca;
    ax.Color = 'w';
    hold on

    for k = 1:length(S)

        X = S(k).X;
        Y = S(k).Y;

        % Find separators (NaN)
        nan_idx = [0 find(isnan(X)) length(X)+1];

        for i = 1:length(nan_idx)-1

            seg = (nan_idx(i)+1):(nan_idx(i+1)-1);
            if numel(seg) < 3
                continue
            end

            % Value to be colored (by dataset)
            j = Mqq(b,k);

            % Convert value to colormap index
            idx = round(((j + R) / (2*R)) * (n-1)) + 1;
            idx = max(1, min(n, idx));
            color = cmap(idx, :);

            % Draw polygon
            hPatch = patch(X(seg), Y(seg), color, ...
                'EdgeColor','k', 'LineWidth',0.5);

            if p_value(b,k,qq) < 0.05

                xv = X(seg);
                yv = Y(seg);

                % Use global grid (consistent throughout the map)
                in = inpolygon(xp_global, yp_global, xv, yv);

                % Draw points ONLY inside the polygon
                scatter(xp_global(in), yp_global(in), 3, ...
                    'MarkerFaceColor',[0.1 0.1 0.1], ...
                    'MarkerEdgeColor','none');
            end
        end
    end

    % --- Map settings ---
    clim([-R R]);
    colormap(cmap);
    ylim([14 33])
    %axis image
    axis equal
    axis tight
   

    xticks(-115:5:-90)
    %xlabel('Longitude (°)', ...
    xlabel('Longitud (°)', ...
       'FontSize',16)

    if b == 1

    yticks(15:5:30)

    %ylabel('Latitude (°)', ...
    ylabel('Latitud (°)', ...
           'FontSize',16)

    else

    set(gca,'YTick',[])

    end
    set(gca,'LooseInset',...
        get(gca,'TightInset'))
    %title(names{b}, 'FontSize', 14)
    set(gca,...
    'FontSize',14,...
    'LineWidth',1,...
    'TickDir','out')
    panel_labels = {'(a) SMN','(b) CHIRPS','(c) ERA5'};

    title(panel_labels{b}, ...
      'FontSize',18,...
      'FontWeight','bold')

    hold off
end

% --- Single colorbar ---
cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = '(mm year^{-1})';
cb.FontSize = 16;
cb.Ticks = -15:5:15;
cb.TickLabels = {'-15','-10','-5','0','5','10','15'};

% -----------------------------------------------------
% Figure capture (keep this)
% -----------------------------------------------------
set(gcf,...
    'Units','pixels',...
    'Position',[100 100 2200 850])
set(gcf,'Renderer','opengl')
drawnow
pause(0.5)

exportgraphics(gcf,...
    'MapaT_3D_q25_PATCH_R15.png',...
    'Resolution',600,...
    'BackgroundColor','white')

