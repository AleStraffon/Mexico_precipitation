% Program that generates comparative boxplot figures for 3 datasets of
% precipitation

load PPT_CHIRPS_81_24.mat
load PPT_ERA_81_24.mat 
load PPT_SMN_81_24.mat

%% Boxplot for multiple HRs in the same figure
names = {'SMN', 'CHIRPS', 'ERA5'};

qq = 25;          % fortnight
nRH = 37;         % number of regions
ny = 44;          % years

% -------------------------------------------------
% BUILD MATRIX FOR BOXPLOT
% -------------------------------------------------
bd_all = nan(ny, 3*nRH);

for RH = 1:nRH

    SMN    = PPT_SMN_81_24(qq,1:ny,RH)';
    CHIRPS = PPT_CHIRPS_81_24(qq,1:ny,RH)';
    ERA    = PPT_ERA_81_24_corr(qq,1:ny,RH)';

    cols = (RH-1)*3 + (1:3);

    bd_all(:,cols) = [SMN, CHIRPS, ERA];

end

% -------------------------------------------------
% POSITIONS FOR GROUPING THE BOXES
% -------------------------------------------------
pos = [];

for RH = 1:nRH
    base = (RH-1)*4;      % leaves space between regions
    pos  = [pos base + (1:3)];
end

% -------------------------------------------------
% FIGURE
% -------------------------------------------------
figure
boxplot(bd_all, ...
    'Positions', pos, ...
    'Widths', 0.6, ...
    'Symbol','k.');

ylabel('mm')
%title(sprintf('Annual accumulated precipitation 1981-2024'))
set(gca,'FontSize',16)

% -------------------------------------------------
% X-AXIS LABELS = HR
% -------------------------------------------------
xticks( mean(reshape(pos,3,[]) ) )
xticklabels(1:nRH)
xlabel('Hydrological Regions')

% -------------------------------------------------
% CUSTOM COLORS
% -------------------------------------------------
colors = [
    0 0 0      % SMN
    1 0 0      % CHIRPS
    0 0 1      % ERA5
];

boxes = findobj(gca,'Tag','Box');
boxes = flipud(boxes);

for i = 1:length(boxes)

    c = colors( mod(i-1,3)+1 , : );

    patch( ...
        get(boxes(i),'XData'), ...
        get(boxes(i),'YData'), ...
        c, ...
        'FaceAlpha',0.7, ...
        'EdgeColor','k', ...
        'LineWidth',1.2);

end

% -------------------------------------------------
% MEDIANS IN MAGENTA
% -------------------------------------------------
medians = findobj(gca,'Tag','Median');

for i = 1:length(medians)
    set(medians(i), ...
        'Color',[0 0 0], ...
        'LineWidth',2);
end

% -------------------------------------------------
% LEGEND
% -------------------------------------------------
hold on

h = zeros(3,1);
for i = 1:3
    h(i) = plot(nan,nan,'s', ...
        'MarkerFaceColor',colors(i,:), ...
        'MarkerEdgeColor','k');
end

legend(h, names, 'Location','best')

hold off
%Save
nombre_archivo = sprintf( ...
    'Boxplot_Precip.png');

exportgraphics(gcf, nombre_archivo, ...
    'Resolution',600, ...
    'BackgroundColor','white');
