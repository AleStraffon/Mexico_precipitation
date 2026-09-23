%% =========================================================
% FIGURES AND SIGNIFICANCE ANALYSIS
% KRUSKAL–WALLIS ENSO vs PRECIPITATION
% =========================================================

clearvars -except KW_results data_groups %From ENSO_preprocessing.m
close all
clc

%% =========================================================
% FIGURE SAVING CONFIGURATION
% =========================================================

ruta_figuras = '/home/X/X/FiguresENSO';

if ~exist(ruta_figuras,'dir')
    mkdir(ruta_figuras)
end

alpha = 0.05;

[nq,nr] = size(KW_results);   % 24 x 37
%% =========================================================
% GLOBAL ENSO SUMMARY
% =========================================================

max_phase_map = NaN(nq,nr);
min_phase_map = NaN(nq,nr);

sig_dunn_map = false(nq,nr);
sig_kw_map   = false(nq,nr);

for q = 1:nq
for r = 1:nr

    EN_mean  = mean(squeeze(data_groups(q,r,1,:)),'omitnan');
    NEU_mean = mean(squeeze(data_groups(q,r,2,:)),'omitnan');
    LN_mean  = mean(squeeze(data_groups(q,r,3,:)),'omitnan');

    means = [EN_mean NEU_mean LN_mean];

    [~,max_phase_map(q,r)] = max(means);
    [~,min_phase_map(q,r)] = min(means);

    % ---------------------------------------
    % Significance
    % ---------------------------------------
    p_kw = KW_results(q,r).p;

    if ~isempty(p_kw) && p_kw < alpha

        sig_kw_map(q,r) = true;

        p_dunn = KW_results(q,r).Dunn_p;

        if ~isempty(p_dunn)

            if any(p_dunn < alpha)

                sig_dunn_map(q,r) = true;

            end

        end

    end

end
end

%% =========================================================
% GLOBAL STATISTICS
% =========================================================

Ntotal = nq*nr;   % 24 x 37 = 888

fprintf('\n====================================\n')
fprintf('RESUMEN ENSO\n')
fprintf('====================================\n')

fases = {'El Niño','Neutral','La Niña'};

for f = 1:3

    nmax = sum(max_phase_map(:)==f);
    nmin = sum(min_phase_map(:)==f);

    fprintf('\n%s\n',fases{f})

    fprintf('Highest precipitation' : %4d (%.1f%%)\n',...
        nmax,100*nmax/Ntotal)

    fprintf('Lowest precipitation' : %4d (%.1f%%)\n',...
        nmin,100*nmin/Ntotal)

end

%% =========================================================
% SIGNIFICANCIA
% =========================================================

Nkw   = sum(sig_kw_map(:));
Ndunn = sum(sig_dunn_map(:));

fprintf('\n------------------------------------\n')

fprintf('KW significativo      = %4d (%.1f%%)\n',...
    Nkw,100*Nkw/Ntotal)

fprintf('Dunn significativo    = %4d (%.1f%%)\n',...
    Ndunn,100*Ndunn/Ntotal)

fprintf('Dunn/KW              = %.1f%%\n',...
    100*Ndunn/max(Nkw,1))

fprintf('------------------------------------\n')

%% =========================================================
% ENSO BY SEASON
% =========================================================

season_names = { ...
    'Jan-May', ...
    'Jun-Sep', ...
    'Oct-Dec'};

season_idx = { ...
    1:10,...
    11:18,...
    19:24};

fprintf('\n')
fprintf('=====================================================\n')
fprintf('ENSO PHASE FREQUENCY BY SEASON\n')
fprintf('=====================================================\n')

for s = 1:length(season_names)

    qsel = season_idx{s};

    max_season = max_phase_map(qsel,:);
    min_season = min_phase_map(qsel,:);

    sig_season = sig_dunn_map(qsel,:);

    Nseason = numel(max_season);
    Nsig    = sum(sig_season(:));

    fprintf('\n')
    fprintf('=====================================================\n')
    fprintf('%s\n',season_names{s})
    fprintf('=====================================================\n')

    fprintf('\nWettest phase\n')

    for f = 1:3

        Nf = sum(max_season(:)==f);

        fprintf('%-8s : %4d (%5.1f%%)\n',...
            fases{f},...
            Nf,...
            100*Nf/Nseason);

    end

    fprintf('\nDriest phase\n')

    for f = 1:3

        Nf = sum(min_season(:)==f);

        fprintf('%-8s : %4d (%5.1f%%)\n',...
            fases{f},...
            Nf,...
            100*Nf/Nseason);

    end

    fprintf('\nSignificant cells (Dunn)\n')
    fprintf('%4d of %4d (%5.1f%%)\n',...
        Nsig,...
        Nseason,...
        100*Nsig/Nseason);

end

%% =========================================================
% 1. EXTRACT P-VALUE MATRIX
% =========================================================

KW_p = NaN(nq,nr);

for q = 1:nq
for r = 1:nr
    KW_p(q,r) = KW_results(q,r).p;
end
end

%% =========================================================
% 2. SIGNIFICANCE MATRIX
% =========================================================

KW_sig = KW_p < alpha;

fprintf('\n===== RESUMEN GLOBAL =====\n')
fprintf('Pruebas significativas = %d\n',sum(KW_sig(:)))
fprintf('Total pruebas          = %d\n',numel(KW_sig))
fprintf('Porcentaje             = %.2f %%\n',...
        100*sum(KW_sig(:))/numel(KW_sig))

%% =========================================================
% 3. DIAGNOSTIC METRICS
% =========================================================

sig_por_quincena = sum(KW_sig,2);
sig_por_region   = sum(KW_sig,1);
pmin_quincena    = min(KW_p,[],2,'omitnan');

% %% =========================================================
% % 4.ENSO FIGURE HEATMAP OF DOMINANT PHASE + PRECIPITATION
% % =========================================================

figure('Color','w',...
       'Units','pixels',...
       'Position',[100 50 1100 1250]);

tiledlayout(2,1,...
    'TileSpacing','compact',...
    'Padding','loose');

cmap = [
0.88 0.18 0.18   % El Niño
1.00 1.00 1.00   % Neutral
0.23 0.36 0.84   % La Niña
];


titles_fig = { ...
'(a) ENSO phase associated with the highest precipitation', ...
'(b) ENSO phase associated with the lowest precipitation'};

for panel = 1:2

    nexttile

    if panel == 1
        phase_map = max_phase_map;
    else
        phase_map = min_phase_map;
    end

    imagesc(phase_map')

    axis tight
    hold on

    set(gca,...
        'FontSize',16,...
        'LineWidth',1.2,...
        'TickDir','in',...
        'TickLength',[0.006 0.006])

    hold on

    ylim_actual = ylim;

    L = 0.8;

    for x = 0.5:2:24.5

        plot([x x],...
            [ylim_actual(2) ylim_actual(2)-L],...
            'k','LineWidth',2.5)

        plot([x x],...
            [ylim_actual(1) ylim_actual(1)+L],...
            'k','LineWidth',2.5)

    end

xticks(1.5:2:24)

xticklabels({'Jan','Feb','Mar','Apr',...
             'May','Jun','Jul','Aug',...
             'Sep','Oct','Nov','Dec'})

ylabel('Hydrological Regions',...
       'FontSize',18)


set(gca,...
    'FontSize',16,...
    'LineWidth',1.5,...
    'TickLength',[0.01 0.01],...
    'Layer','top')


    t = title(titles_fig{panel},...
          'FontSize',18,...
          'FontWeight','bold');

t.Units = 'normalized';
t.Position(1) = 0.0;      % izquierda
t.HorizontalAlignment = 'left';

    colormap(cmap)
    caxis([1 3])

    for m = 2:2:24
        xline(m+0.5,'k:','LineWidth',0.8)
    end

    yline(9.5,'--k','LineWidth',1.8)
    yline(23.5,'--k','LineWidth',1.8)
    yline(33.5,'--k','LineWidth',1.8)

    % Significance

    for q = 1:nq
    for r = 1:nr

        if sig_dunn_map(q,r)

            text(q,r,'•',...
                'HorizontalAlignment','center',...
                'FontSize',12,...
                'FontWeight','bold',...
                'Color','k');

        end

    end
    end

    hold off

end
%% =========================================================
% MANUAL LEGEND
% =========================================================

ybox = 0.028;   % rectángulos
ytxt = 0.020;   % texto

%% El Niño
annotation('rectangle',...
    [0.40 ybox 0.020 0.020],...
    'FaceColor',[0.88 0.18 0.18],...
    'EdgeColor','k');

annotation('textbox',...
    [0.427 ytxt 0.09 0.03],...
    'String','El Niño',...
    'FontSize',15,...
    'LineStyle','none',...
    'HorizontalAlignment','left');

%% Neutral
annotation('rectangle',...
    [0.51 ybox 0.020 0.020],...
    'FaceColor',[1 1 1],...
    'EdgeColor',[0.6 0.6 0.6]);

annotation('textbox',...
    [0.537 ytxt 0.09 0.03],...
    'String','Neutral',...
    'FontSize',15,...
    'LineStyle','none',...
    'HorizontalAlignment','left');

%% La Niña
annotation('rectangle',...
    [0.64 ybox 0.020 0.020],...
    'FaceColor',[0.23 0.36 0.84],...
    'EdgeColor','k');

annotation('textbox',...
    [0.667 ytxt 0.10 0.03],...
    'String','La Niña',...
    'FontSize',15,...
    'LineStyle','none',...
    'HorizontalAlignment','left');
%% =========================================================
% SIGNIFICANCE NOTES
% =========================================================

% annotation('textbox',...
%     [0.12 0.025 0.76 0.025],...
%     'String',...
%     {'• Significant difference between wettest and driest ENSO phases (Dunn''s test, p < 0.05)'},...
%     'FontSize',13,...
%     'HorizontalAlignment','center',...
%     'LineStyle','none');
% 
% annotation('textbox',...
%     [0.08 0.000 0.84 0.025],...
%     'String',...
%     {'× Significant difference among ENSO phases (Kruskal–Wallis test, p < 0.05), but not confirmed by Dunn''s pairwise test'},...
%     'FontSize',13,...
%     'HorizontalAlignment','center',...
%     'LineStyle','none');
% %% =========================================================
% SAVE
% =========================================================

exportgraphics(gcf,...
    fullfile(ruta_figuras,...
    'ENSO_final.png'),...
    'Resolution',600);

