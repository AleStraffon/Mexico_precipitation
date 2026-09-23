%% Figure identifying the lag of maximum correlation between two variables

%% ================================================================
% PRECIPITATION - RONI CORRELATION
% SECTION 1: Analysis preparation
%
% Precipitation: PPT_50_24
% Available period: 1950-2024
%
% Analysis period: 1961-2024
%
% States of Mexico:
%   CVE_ENT = official state/entity code (01-32)
%   NOM_ENT = state/entity name
%
% The ID for each state will be CVE_ENT.
% ================================================================
%% ================================================================
% RONI - CPC/NOAA
% Direct download from the Internet and extraction 1961-2024
%
% Font:
% https://www.cpc.ncep.noaa.gov/data/indices/RONI.ascii.txt
%
% File format:
%   Columna 1 = season
%   Columna 2 = year
%   Columna 3 = RONI
%
% Each value corresponds to a 3-month rolling season:
%   DJF -> January
%   JFM -> February
%   FMA -> March
%   ...
%   NDJ -> December
%
% Analysis period:
%   January 1961 - December 2024
%
% Results:
%   RONI_ANIO_MES = 64 x 12
%   RONI          = 768 x 1
%   fecha_RONI    = 768 x 1
% ================================================================

clear;
clc;


%% Download file directly from CPC/NOAA

url_RONI = ...
    'https://www.cpc.ncep.noaa.gov/data/indices/RONI.ascii.txt';

archivo_temporal = [tempname '.txt'];

websave(archivo_temporal,url_RONI);


%% Read file

fid = fopen(archivo_temporal,'r');

% Skip header
fgetl(fid);

% Leer:
% season | year | RONI
datos_RONI = textscan(fid,'%s %f %f');

fclose(fid);

% Delete temporary file
delete(archivo_temporal);


%% Extract columns

temporada_RONI = datos_RONI{1};
anio_RONI      = datos_RONI{2};
valor_RONI     = datos_RONI{3};


%% Select period 1961-2024

idx_RONI = anio_RONI >= 1981 & anio_RONI <= 2024;

temporada_RONI = temporada_RONI(idx_RONI);
anio_RONI      = anio_RONI(idx_RONI);
valor_RONI     = valor_RONI(idx_RONI);


%% Withvert seasons to central month

% DJF -> January
% JFM -> February
% FMA -> March
% MAM -> April
% AMJ -> May
% MJJ -> June
% JJA -> July
% JAS -> August
% ASO -> September
% SON -> October
% OND -> November
% NDJ -> December

mes_RONI = nan(size(temporada_RONI));

for i = 1:length(temporada_RONI)

    switch temporada_RONI{i}

        case 'DJF'
            mes_RONI(i) = 1;

        case 'JFM'
            mes_RONI(i) = 2;

        case 'FMA'
            mes_RONI(i) = 3;

        case 'MAM'
            mes_RONI(i) = 4;

        case 'AMJ'
            mes_RONI(i) = 5;

        case 'MJJ'
            mes_RONI(i) = 6;

        case 'JJA'
            mes_RONI(i) = 7;

        case 'JAS'
            mes_RONI(i) = 8;

        case 'ASO'
            mes_RONI(i) = 9;

        case 'SON'
            mes_RONI(i) = 10;

        case 'OND'
            mes_RONI(i) = 11;

        case 'NDJ'
            mes_RONI(i) = 12;

        otherwise
            error('Unrecognized RONI season: %s', ...
                temporada_RONI{i});

    end

end


%% Build year x month matrix

anios_RONI_analisis = (1981:2024)';

RONI_ANIO_MES = nan(length(anios_RONI_analisis),12);

for i = 1:length(valor_RONI)

    fila = find(anios_RONI_analisis == anio_RONI(i));
    columna = mes_RONI(i);

    RONI_ANIO_MES(fila,columna) = valor_RONI(i);

end


%% Withvert to continuous monthly series

% Order:
% Enero 1961
% Febrero 1961
% ...
% Diciembre 2024

RONI = reshape(RONI_ANIO_MES',[],1);


%% Create date vector

fecha_RONI = datetime(1981,1,1) + ...
             calmonths(0:length(RONI)-1);

fecha_RONI = fecha_RONI(:);


%% Checks

fprintf('\n=============================================\n');
fprintf(' RONI - CPC/NOAA\n');
fprintf('=============================================\n');

fprintf('Number of downloaded records: %d\n', ...
    length(valor_RONI));

fprintf('Selected period: 1961-2024\n');

fprintf('RONI_ANIO_MES dimensions: %d x %d\n', ...
    size(RONI_ANIO_MES,1), ...
    size(RONI_ANIO_MES,2));

fprintf('RONI dimensions: %d x %d\n', ...
    size(RONI,1), ...
    size(RONI,2));

fprintf('Start date: %s\n', ...
    datestr(fecha_RONI(1)));

fprintf('End date:   %s\n', ...
    datestr(fecha_RONI(end)));


%% Display the first and last 12 values

fprintf('\nFirst 12 RONI values (1961):\n');
disp(RONI(1:12));

fprintf('Last 12 RONI values (2024):\n');
disp(RONI(end-11:end));

%% ================================================================
% FORTNIGHTLY TO MONTHLY PRECIPITATION CONVERSION
% ABSOLUTE DATA
%
% Original variable:
%   PPT_CHIRPS_81_24
%
% Structure:
%   rows 1:24   -> 24 quincenas
%   row 25      -> annual accumulation (NOT USED)
%   columns 1:44 -> years 1981-2024
%   columns 45:46 -> additional information (NOT USED)
%   dimension 3  -> 37 regions
%
% Withversion:
%   Q1 + Q2   -> January
%   Q3 + Q4   -> February
%   ...
%   Q23 + Q24 -> December
%
% IMPORTANT:
%   The following are NOT applied here:
%       - moving average
%       - detrending
%       - anomalies
%
% The data remain as ABSOLUTE monthly precipitation.
%
% Resultado:
%   PPT_CHIRPS_MENSUAL_ANIO_MES = 12 x 44 x 37
%   PPT_CHIRPS_MENSUAL            = 528 x 37
%% Load data

load PPT_CHIRPS_81_24.mat


%% Actual dimensions

dim_PPT = size(PPT_CHIRPS_81_24);

fprintf('\n=============================================\n');
fprintf(' PRECIPITACIÓN QUINCENAL -> MENSUAL\n');
fprintf('=============================================\n');

fprintf('Original dimensions: %d x %d x %d\n', ...
    dim_PPT(1),dim_PPT(2),dim_PPT(3));


%% Define only the data that will be used

% Rows 1:24 = 24 quincenas
% Row 25 = annual accumulation -> NOT USED
%
% Columnas 1:44 = years 1981-2024
% Columnas 45:46 = additional information -> NOT USED

PPT_quincenal = PPT_CHIRPS_81_24(1:24,1:44,:);


%% Definir dimensiones

n_quincenas = 24;
n_anios     = 44;
n_regiones  = 37;
n_meses     = 12;


%% Create monthly matrix

% Dimensions:
%   12 meses x 44 years x 37 regions

PPT_CHIRPS_MENSUAL_ANIO_MES = nan( ...
    n_meses,n_anios,n_regiones);


%% Sum fortnight pairs

for r = 1:n_regiones

    for anio = 1:n_anios

        for mes = 1:n_meses

            q1 = 2*mes - 1;
            q2 = 2*mes;

            PPT_CHIRPS_MENSUAL_ANIO_MES(mes,anio,r) = ...
                PPT_quincenal(q1,anio,r) + ...
                PPT_quincenal(q2,anio,r);

        end

    end

end


%% Create year vector

anios_CHIRPS = 1981:2024;


%% Withvert to 37 monthly series

% Filas:
%   consecutive months
%
% Columnas:
%   regions
%
% Order:
%   January 1981
%   February 1981
%   ...
%   December 1981
%   January 1982
%   ...
%   December 2024
%
% Resultado:
%   528 x 37

PPT_CHIRPS_MENSUAL = reshape( ...
    permute(PPT_CHIRPS_MENSUAL_ANIO_MES,[1 2 3]), ...
    n_meses*n_anios, ...
    n_regiones);


%% Create monthly dates

fecha_CHIRPS = datetime(1981,1,1) + ...
               calmonths(0:(n_meses*n_anios-1));

fecha_CHIRPS = fecha_CHIRPS(:);


%% Checks

fprintf('\n=============================================\n');
fprintf(' RESULTS\n');
fprintf('=============================================\n');

fprintf('PPT_CHIRPS_MENSUAL_ANIO_MES: %d x %d x %d\n', ...
    size(PPT_CHIRPS_MENSUAL_ANIO_MES,1), ...
    size(PPT_CHIRPS_MENSUAL_ANIO_MES,2), ...
    size(PPT_CHIRPS_MENSUAL_ANIO_MES,3));

fprintf('PPT_CHIRPS_MENSUAL: %d x %d\n', ...
    size(PPT_CHIRPS_MENSUAL,1), ...
    size(PPT_CHIRPS_MENSUAL,2));

fprintf('Start date: %s\n', ...
    datestr(fecha_CHIRPS(1)));

fprintf('End date: %s\n', ...
    datestr(fecha_CHIRPS(end)));


%% ================================================================
% 1. CENTERED 12-MONTH MOVING AVERAGE
%
% Input variables:
%   PPT_CHIRPS_MENSUAL = 528 x 37
%   RONI               = 528 x 1
%
% Period:
%   January 1981 - December 2024
%
% A centered 12-month moving average is used.
%
% With 'Endpoints','discard':
%   the first 6 months and last 6 months are discarded.
%
% Results:
%   PPT_CHIRPS_12m = 517 x 37
%   RONI_12m       = 517 x 1
% ================================================================

n_meses = size(PPT_CHIRPS_MENSUAL,1);
n_regiones = size(PPT_CHIRPS_MENSUAL,2);



PPT_CHIRPS_12m = movmean( ...
    PPT_CHIRPS_MENSUAL, ...
    12, ...
    'Endpoints','discard');

RONI_12m = movmean( ...
    RONI, ...
    12, ...
    'Endpoints','discard');


%% Create corresponding dates

fecha_12m = datetime(1981,1,1) + ...
            calmonths(6:(n_meses-7));

fecha_12m = fecha_12m(:);


%% Checks

fprintf('\n=============================================\n');
fprintf(' MEDIA MOVIL DE 12 MESES\n');
fprintf('=============================================\n');

fprintf('Original PPT: %d x %d\n', ...
    size(PPT_CHIRPS_MENSUAL,1), ...
    size(PPT_CHIRPS_MENSUAL,2));

fprintf('12-month PPT: %d x %d\n', ...
    size(PPT_CHIRPS_12m,1), ...
    size(PPT_CHIRPS_12m,2));

fprintf('Original RONI: %d x %d\n', ...
    size(RONI,1),size(RONI,2));

fprintf('12-month RONI: %d x %d\n', ...
    size(RONI_12m,1),size(RONI_12m,2));

fprintf('Start date: %s\n', ...
    datestr(fecha_12m(1)));

fprintf('End date:   %s\n', ...
    datestr(fecha_12m(end)));

%% ================================================================
% 2. LINEAR DETRENDING
%
% The linear trend is removed after the
% 12 meses.
%
% Detrending is performed:
%   - independently for each precipitation region
%   - independently for RONI
%
% The values are retained as detrended series.
% ================================================================

% Time axis

x = (1:size(PPT_CHIRPS_12m,1))';


%% Detrend the 37 regions

PPT_CHIRPS_12m_detrended = nan(size(PPT_CHIRPS_12m));

for r = 1:n_regiones

    y = PPT_CHIRPS_12m(:,r);

    % Linear fit
    p = polyfit(x,y,1);

    % Trend
    tendencia = polyval(p,x);

    % Remove trend
    PPT_CHIRPS_12m_detrended(:,r) = y - tendencia;

end


%% Detrend RONI

p_RONI = polyfit(x,RONI_12m,1);

tendencia_RONI = polyval(p_RONI,x);

RONI_12m_detrended = RONI_12m - tendencia_RONI;


%% Checks

fprintf('\n=============================================\n');
fprintf(' LINEAR DETRENDING\n');
fprintf('=============================================\n');

fprintf('Detrended PPT:  %d x %d\n', ...
    size(PPT_CHIRPS_12m_detrended,1), ...
    size(PPT_CHIRPS_12m_detrended,2));

fprintf('Detrended RONI: %d x %d\n', ...
    size(RONI_12m_detrended,1), ...
    size(RONI_12m_detrended,2));


%% Check residual RONI slope

p_check = polyfit(x,RONI_12m_detrended,1);

fprintf('\nResidual RONI slope = %.12f\n',p_check(1));

%% ================================================================
% 3. LEAD-LAG CORRELATION
%
% Lag range:
%   -18 a +18 meses
%
% Withvention:
%
%   lag > 0:
%       RONI leads precipitation
%
%   lag < 0:
%       precipitation leads RONI
%
% The correlation is calculated as:
%
%   x = precipitation
%   y = shifted RONI
%
% The maximum absolute value is then identified |r|.
% ================================================================

lags = -18:18;

n_lags = length(lags);
n = size(PPT_CHIRPS_12m_detrended,1);

% Correlation matrix
%
% rows    = lags
% columns = regions

r_lag_37 = nan(n_lags,n_regiones);


%% Calculate correlations

for r = 1:n_regiones

    PPT_test = PPT_CHIRPS_12m_detrended(:,r);
    RONI_test = RONI_12m_detrended;

    for ilag = 1:n_lags

        L = lags(ilag);

        if L > 0

            % RONI lidera a precipitación
            x = PPT_test(1:n-L);
            y = RONI_test(1+L:n);

        elseif L < 0

            % Precipitation leads RONI
            L_abs = abs(L);

            x = PPT_test(1+L_abs:n);
            y = RONI_test(1:n-L_abs);

        else

            % Zero lag
            x = PPT_test;
            y = RONI_test;

        end

        R = corrcoef(x,y);

        r_lag_37(ilag,r) = R(1,2);

    end

end


fprintf('\n=============================================\n');
fprintf(' LEAD-LAG CORRELATION\n');
fprintf('=============================================\n');

fprintf('Number of regions: %d\n',n_regions);
fprintf('Lag range: %d a %+d meses\n', ...
    min(lags),max(lags));

fprintf('Dimensión r_lag_37: %d x %d\n', ...
    size(r_lag_37,1),size(r_lag_37,2));

%% ================================================================
% 4. TABLE OF THE LAG OF MAXIMUM ABSOLUTE CORRELATION
%
% For each region:
%   identify the lag where |r| is maximum.
%
% Reported:
%   ID
%   Region
%   Lag of maximum |r|
%   Correlation at that lag
%   Correlation as a percentage
% ================================================================

lag_max_37 = nan(n_regiones,1);
r_max_37   = nan(n_regiones,1);


for r = 1:n_regiones

    % Maximum absolute value
    [~,idx_max] = max(abs(r_lag_37(:,r)));

    % Lag correspondiente
    lag_max_37(r) = lags(idx_max);

    % Correlación real
    r_max_37(r) = r_lag_37(idx_max,r);

end


%% Create region IDs

ID_RH = (1:n_regions)';


%% Create table

Resultados_37RH = table( ...
    ID_RH, ...
    lag_max_37, ...
    r_max_37, ...
    100*r_max_37, ...
    'VariableNames', { ...
    'ID_RH', ...
    'Lag_max_abs_r', ...
    'Correlacion', ...
    'Correlacion_porcentaje'});


%% Display table

fprintf('\n=============================================\n');
fprintf(' RESULTS - 37 HYDROLOGICAL REGIONS\n');
fprintf('=============================================\n');

disp(Resultados_37RH);


%% ========================================================================
% LEAD-LAG CORRELATION FOR THE 37 HYDROLOGICAL REGIONS
%
% Data used:
%   lags      -> -24:+24 meses
%   r_lag_37 -> correlaciones para las 37 HR
%
% Figure:
%   X = -18:+18 meses
%   Y = -70:+70 %
%
% Maximum |r|:
%   Identified within -13:+13 months.
%   Marked with a black circle, without a label.
%
% Colores:
%   RH 1-9    -> Northwestern              -> rojo
%   RH 10-23  -> Pacific Coast             -> azul
%   RH 24-33  -> Gulf of Mexico-Caribbean  -> verde
%   RH 34-37  -> North-central             -> magenta
%
% The line + marker combination identifies each HR.
%
% At the end:
%   The figure is captured with getframe,
%   the white borders are cropped
%   and saved as ENSO-lag.png
%% ========================================================================


%% ========================================================================
% 1. REGIONS
% ========================================================================

RH_plot = 1:37;


%% ========================================================================
% 2. COLORS BY DOMAIN
% ========================================================================

rojo    = [0.85 0.00 0.00];
azul    = [0.00 0.25 0.85];
verde   = [0.00 0.55 0.15];
magenta = [0.75 0.00 0.65];

colores = zeros(37,3);

% Northwestern
colores(1:9,:) = repmat(rojo,9,1);

% Pacific Coast
colores(10:23,:) = repmat(azul,14,1);

% Gulf of Mexico-Caribbean
colores(24:33,:) = repmat(verde,10,1);

% North-central
colores(34:37,:) = repmat(magenta,4,1);


%% ========================================================================
% 3. LINE + MARKER COMBINATIONS
%
% 4 line styles x 4 markers = 16 combinations.
%% ========================================================================

lineStyles = { ...
    '-',  '-',  '-',  '-', ...
    '--', '--', '--', '--', ...
    ':',  ':',  ':',  ':', ...
    '-.', '-.', '-.', '-.'};

markers = { ...
    'o', 's', '^', 'd', ...
    'o', 's', '^', 'd', ...
    'o', 's', '^', 'd', ...
    'o', 's', '^', 'd'};


%% ========================================================================
% 4. PATTERN ASSIGNMENT WITHIN EACH DOMAIN
%% ========================================================================

patron_RH = zeros(37,1);

% Northwestern: RH 1-9
patron_RH(1:9) = 1:9;

% Pacific Coast: RH 10-23
patron_RH(10:23) = 1:14;

% Gulf of Mexico-Caribbean: RH 24-33
patron_RH(24:33) = 1:10;

% North-central: RH 34-37
patron_RH(34:37) = 1:4;


%% ========================================================================
% 5. CREATE HIGH-RESOLUTION FIGURE
% ========================================================================

figure('Color','w');

set(gcf,'Units','pixels');

set(gcf,'Position',[100 100 3000 2200]);


%% ========================================================================
% 6. PLOT THE 37 HRs
%% ========================================================================

hold on;

for r = RH_plot

    % Line + marker pattern
    k = patron_RH(r);

    estilo = lineStyles{k};
    marcador = markers{k};

    plot(lags,100*r_lag_37(:,r), ...
        'LineStyle',estilo, ...
        'Marker',marcador, ...
        'Color',colores(r,:), ...
        'LineWidth',1.8, ...
        'MarkerSize',5, ...
        'MarkerIndices',1:3:length(lags), ...
        'DisplayName',sprintf('HR %d',r));

end


%% ========================================================================
% 7. MARK THE MAXIMUM |r|
%
% Search is performed exclusively between -18 and +18 months.
% No label is added.
%% ========================================================================

idx_max_range = lags >= -13 & lags <= 13;

for r = RH_plot

    % Correlations within the selection range
    r_sel = r_lag_37(idx_max_range,r);

    % Corresponding lags
    lag_sel = lags(idx_max_range);

    % Máximo absoluto
    [~,idx_max] = max(abs(r_sel));

    % Lag of the maximum
    lag_max = lag_sel(idx_max);

    % Corresponding correlation
    r_max = r_sel(idx_max);

    % ------------------------------------------------------------
    % Maximum |r| point
    % ------------------------------------------------------------

    plot(lag_max,100*r_max,'o', ...
        'MarkerSize',11, ...
        'MarkerFaceColor',colores(r,:), ...
        'MarkerEdgeColor','k', ...
        'LineWidth',1.3, ...
        'HandleVisibility','off');

end


%% ========================================================================
% 8. REFERENCE LINES
%% ========================================================================

% Correlation = 0
yline(0,'k-', ...
    'LineWidth',1.0, ...
    'HandleVisibility','off');

% Lag = 0
xline(0,'k-', ...
    'LineWidth',1.5, ...
    'HandleVisibility','off');


%% ========================================================================
% 9. LIMITS AND TICKS
%% ========================================================================

xlim([-18 18]);
ylim([-70 70]);

xticks(-18:3:18);
yticks(-70:10:70);


%% ========================================================================
% 10. AXIS LABELS
%% ========================================================================

xlabel('Lag (months)', ...
    'FontSize',21, ...
    'FontWeight','normal');

ylabel('Correlation (%)', ...
    'FontSize',21, ...
    'FontWeight','normal');


%% ========================================================================
% 11. TITLE
%% ========================================================================

% title({'Correlation of HR precipitation with RONI', ...
%        '(12-Month Mean Detrended for 1981-2024)'}, ...
%        'FontSize',23, ...
%        'FontWeight','bold');


%% ========================================================================
% 12. AXIS FORMATTING
%% ========================================================================

set(gca, ...
    'FontName','Arial', ...
    'FontSize',18, ...
    'LineWidth',1.2, ...
    'TickDir','out', ...
    'Box','on');

grid on;


%% ========================================================================
% 13. LEGEND OUTSIDE THE FIGURE
%% ========================================================================

lgd = legend('Location','eastoutside');

% Two columns
lgd.NumColumns = 2;

% Font size
lgd.FontSize = 15;

% Font
lgd.FontName = 'Arial';

% Legend title
lgd.Title.String = 'Hydrological Regions';
lgd.Title.FontSize = 16;
lgd.Title.FontWeight = 'bold';

% Box around the legend
lgd.Box = 'on';


%% ========================================================================
% 14. ADJUST THE FIGURE
%
% drawnow ensures that all graphical elements, including the
% legend, are fully rendered before calling getframe.
%% ========================================================================

drawnow;


%% ========================================================================
% 15. CAPTURE THE FIGURE
%% ========================================================================

F = getframe(gcf);

img = F.cdata;


%% ========================================================================
% 16. CROP UNNECESSARY WHITE BORDERS
%% ========================================================================

mask = any(img < 250,3);

filas = find(any(mask,2));

columnas = find(any(mask,1));


%% ========================================================================
% 17. ADDITIONAL MARGIN
%% ========================================================================

margen = 15;

fila_ini = max(1,filas(1)-margen);
fila_fin = min(size(img,1),filas(end)+margen);

col_ini = max(1,columnas(1)-margen);
col_fin = min(size(img,2),columnas(end)+margen);

img_crop = img( ...
    fila_ini:fila_fin, ...
    col_ini:col_fin, :);


%% ========================================================================
% 18. SAVE FIGURE
%% ========================================================================

imwrite(img_crop,'ENSO-lag.png');


%% ========================================================================
% 19. CONFIRMATION MESSAGE
%% ========================================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('Figure saved as: ENSO-lag.png\n');
fprintf('Original resolution: 3000 x 2200 pixels\n');
fprintf('============================================================\n');
fprintf('\n');


%% ========================================================================
% END
% ========================================================================