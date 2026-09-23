%% =========================================================
% COMPARATIVE PERFORMANCE FIGURE
% CHIRPS vs ERA5
% RMSE, BIAS, AND CORRELATION
%% =========================================================

load PPT_CHIRPS_81_24.mat
load PPT_ERA_81_24.mat
load PPT_SMN_81_24.mat

%% =========================================================
% CONFIGURATION
%% =========================================================

nq  = 25;
nRH = 37;
ny  = 44;

cCH = [0.85 0.20 0.20];   % CHIRPS
cER = [0.20 0.35 0.85];   % ERA5

%% =========================================================
% CALCULATION OF STATISTICS
%% =========================================================

RMSE_CHIRPS = nan(nq,nRH);
RMSE_ERA5   = nan(nq,nRH);

BIAS_CHIRPS = nan(nq,nRH);
BIAS_ERA5   = nan(nq,nRH);

CORR_CHIRPS = nan(nq,nRH);
CORR_ERA5   = nan(nq,nRH);

for qq = 1:nq
for RH = 1:nRH

    SMN    = PPT_SMN_81_24(qq,1:ny,RH);
    CHIRPS = PPT_CHIRPS_81_24(qq,1:ny,RH);
    ERA5   = PPT_ERA_81_24(qq,1:ny,RH);

    RMSE_CHIRPS(qq,RH) = sqrt(mean((CHIRPS-SMN).^2,'omitnan'));
    RMSE_ERA5(qq,RH)   = sqrt(mean((ERA5-SMN).^2,'omitnan'));

    BIAS_CHIRPS(qq,RH) = mean(CHIRPS-SMN,'omitnan');
    BIAS_ERA5(qq,RH)   = mean(ERA5-SMN,'omitnan');

    CORR_CHIRPS(qq,RH) = corr(CHIRPS',SMN','rows','pairwise');
    CORR_ERA5(qq,RH)   = corr(ERA5',SMN','rows','pairwise');

end
end

%% =========================================================
% SPATIAL AVERAGES
%% =========================================================

RMSE_mean_CHIRPS = mean(RMSE_CHIRPS,2,'omitnan');
RMSE_mean_ERA5   = mean(RMSE_ERA5,2,'omitnan');

BIAS_mean_CHIRPS = mean(BIAS_CHIRPS,2,'omitnan');
BIAS_mean_ERA5   = mean(BIAS_ERA5,2,'omitnan');

CORR_mean_CHIRPS = mean(CORR_CHIRPS,2,'omitnan');
CORR_mean_ERA5   = mean(CORR_ERA5,2,'omitnan');

%% =========================================================
% FIGURE
%% =========================================================

figure('Color','w',...
       'Position',[100 50 1200 1200])

t = tiledlayout(4,1,...
    'TileSpacing','compact',...
    'Padding','compact');

% =========================================================
% COLORS
% =========================================================
cCH = [0.85 0.20 0.20];   % CHIRPS (red)
cER = [0.20 0.35 0.85];   % ERA5 (blue)

% =========================================================
% HORIZONTAL OFFSET
% =========================================================
offset = 0.10;

%% =========================================================
% (a) RMSE ANNUAL BY HR
%% =========================================================

ax1 = nexttile;
hold on

xRH = 1:nRH;

h1 = stem(xRH-offset,...
          RMSE_CHIRPS(25,:),...
          'filled',...
          'Color',cCH,...
          'MarkerFaceColor',cCH,...
          'LineWidth',1.2);

h2 = stem(xRH+offset,...
          RMSE_ERA5(25,:),...
          'filled',...
          'Color',cER,...
          'MarkerFaceColor',cER,...
          'LineWidth',1.2);

h1.ShowBaseLine = 'off';
h2.ShowBaseLine = 'off';

ylabel('RMSE (mm)','FontSize',16)
%ylabel('RECM (mm)','FontSize',16)

% 
set(gca,'YScale','log')

yticks([30 100 300 1000])
yticklabels({'30','100','300','1000'})

xticks(1:3:nRH)
xticklabels(1:3:nRH)

xlabel('Hydrological Region','FontSize',16)
%xlabel('Hydrological Regions','FontSize',16)

set(gca,...
    'FontSize',16,...
    'TickDir','out',...
    'LineWidth',1)

grid on
box on

text(0.01,0.88,'(a)',...
    'Units','normalized',...
    'FontSize',18,...
    'FontWeight','bold')

%% =========================================================
% (b) RMSE FORTNIGHTLY
%% =========================================================
ax2 = nexttile;
hold on

x = 1:24;

h1 = stem(x-offset,...
          RMSE_mean_CHIRPS(1:24),...
          'filled',...
          'Color',cCH,...
          'MarkerFaceColor',cCH,...
          'LineWidth',1.2);

h2 = stem(x+offset,...
          RMSE_mean_ERA5(1:24),...
          'filled',...
          'Color',cER,...
          'MarkerFaceColor',cER,...
          'LineWidth',1.2);

h1.ShowBaseLine = 'off';
h2.ShowBaseLine = 'off';

ylabel('RMSE (mm)','FontSize',16)


xticks([1.5 3.5 5.5 7.5 9.5 11.5 ...
        13.5 15.5 17.5 19.5 21.5 23.5])

xticklabels({'Jan','Feb','Mar','Apr',...
              'May','Jun','Jul','Aug',...
              'Sep','Oct','Nov','Dec'})

yticks([0 10 20 30 40])
set(gca,...
    'FontSize',16,...
    'TickDir','out',...
    'LineWidth',1)

grid on
box on

text(0.01,0.88,'(b)',...
    'Units','normalized',...
    'FontSize',18,...
    'FontWeight','bold')

%% =========================================================
% (c) BIAS FORTNIGHTLY
%% =========================================================
ax3 = nexttile;
hold on

x = 1:24;

h1 = stem(x-offset,...
          mean(BIAS_CHIRPS(1:24,:),2,'omitnan'),...
          'filled',...
          'Color',cCH,...
          'MarkerFaceColor',cCH,...
          'LineWidth',1.2);

h2 = stem(x+offset,...
          mean(BIAS_ERA5(1:24,:),2,'omitnan'),...
          'filled',...
          'Color',cER,...
          'MarkerFaceColor',cER,...
          'LineWidth',1.2);

h1.ShowBaseLine = 'off';
h2.ShowBaseLine = 'off';

yline(0,'k--','LineWidth',1)

ylabel('Bias (mm)','FontSize',16)


xticks([1.5 3.5 5.5 7.5 9.5 11.5 ...
        13.5 15.5 17.5 19.5 21.5 23.5])

xticklabels({'Jan','Feb','Mar','Apr',...
              'May','Jun','Jul','Aug',...
              'Sep','Oct','Nov','Dec'})

ylim([-1 15.5])
yticks([0 5 10 15])

set(gca,...
    'FontSize',16,...
    'TickDir','out',...
    'LineWidth',1)

grid on
box on

text(0.01,0.88,'(c)',...
    'Units','normalized',...
    'FontSize',18,...
    'FontWeight','bold')

%% =========================================================
% (d) CORRELACIÓN FORTNIGHTLY
%% =========================================================
ax4 = nexttile;
hold on

x = 1:24;

h1 = stem(x-offset,...
          mean(CORR_CHIRPS(1:24,:),2,'omitnan'),...
          'filled',...
          'Color',cCH,...
          'MarkerFaceColor',cCH,...
          'LineWidth',1.2);

h2 = stem(x+offset,...
          mean(CORR_ERA5(1:24,:),2,'omitnan'),...
          'filled',...
          'Color',cER,...
          'MarkerFaceColor',cER,...
          'LineWidth',1.2);

h1.ShowBaseLine = 'off';
h2.ShowBaseLine = 'off';


ylabel('Correlation','FontSize',16)


xticks([1.5 3.5 5.5 7.5 9.5 11.5 ...
        13.5 15.5 17.5 19.5 21.5 23.5])

xticklabels({'Jan','Feb','Mar','Apr',...
              'May','Jun','Jul','Aug',...
              'Sep','Oct','Nov','Dec'})


yticks([0 0.25 0.5 0.75 1])
set(gca,...
    'FontSize',16,...
    'TickDir','out',...
    'LineWidth',1)

grid on
box on

text(0.01,0.88,'(d)',...
    'Units','normalized',...
    'FontSize',18,...
    'FontWeight','bold')
%% =========================================================
% GENERAL LEGEND
%% =========================================================

lgd = legend([h1 h2],...
             {'CHIRPS','ERA5'},...
             'Orientation','horizontal');

lgd.Layout.Tile = 'north';
lgd.Box = 'off';
lgd.FontSize = 16;


%% =========================================================
% EXPORT
%% =========================================================

exportgraphics(gcf,...
    'Performance_CHIRPS_ERA5.png',...
    'Resolution',600)