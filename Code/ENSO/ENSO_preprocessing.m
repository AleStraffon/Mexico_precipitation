%load PPT_SMN_81_24.mat   
%load PPT_ERA_81_24.mat 
load PPT_CHIRPS_81_24_detrended.mat

%% =========================================================
% 1. LOAD ENSO (RONI) from: https://www.cpc.ncep.noaa.gov/data/indices/RONI.ascii.txt
% =========================================================

ruta_datos = '/home/X/X';

oni_mat = readmatrix(fullfile(ruta_datos,'RONI_81_24.csv'));
[n_yrs,~] = size(oni_mat);

ONI_val = reshape(oni_mat(:,2:13)',[],1);
ONI_yrs = repelem(oni_mat(:,1),12);
ONI_mos = repmat((1:12)',n_yrs,1);

idx = ONI_yrs>=1981 & ONI_yrs<=2024;

ONI_val = ONI_val(idx);
ONI_yrs = ONI_yrs(idx);

%% =========================================================
% 2. MONTHLY ONI → FORTNIGHTLY
% =========================================================
years   = unique(ONI_yrs);
n_years = length(years);

assert(n_years==44,'Incorrect period');

oni_mensual   = reshape(ONI_val,12,n_years);
oni_quincenal = repelem(oni_mensual,2,1);   % 24x44

%% =========================================================
% 3. ENSO CLASSIFICATION
% =========================================================
enso_quincenal = ones(size(oni_quincenal))*2;

enso_quincenal(oni_quincenal >= 0.5)  = 1; % EN
enso_quincenal(oni_quincenal <= -0.5) = 3; % LN

conteo = accumarray(enso_quincenal(:),1,[3 1]);

disp('Conteo quincenas ENSO:')
disp(conteo)

%% =========================================================
% 4. SEPARATE PRECIPITATION BY ENSO
% =========================================================
PPT = PPT_CHIRPS_81_24_detrended(1:24,1:44,:);
%PPT = PPT_SMN_81_24(1:24,1:44,:);
%PPT = PPT_ERA_81_24_corr(1:24,1:44,:);

[nq,ny,nr] = size(PPT);

PPT_EN     = NaN(size(PPT));
PPT_Neutro = NaN(size(PPT));
PPT_LN     = NaN(size(PPT));

% --- máscaras ENSO ---
mask_EN     = (enso_quincenal==1);
mask_Neutro = (enso_quincenal==2);
mask_LN     = (enso_quincenal==3);

% expand to 3D
mask_EN     = mask_EN(:,:,ones(1,nr));
mask_Neutro = mask_Neutro(:,:,ones(1,nr));
mask_LN     = mask_LN(:,:,ones(1,nr));

% apply masks
PPT_EN(mask_EN)         = PPT(mask_EN);
PPT_Neutro(mask_Neutro) = PPT(mask_Neutro);
PPT_LN(mask_LN)         = PPT(mask_LN);

%% =========================================================
% 5. ADD MEAN AND STD
% =========================================================
PPT_EN     = agregar_stats(PPT_EN);
PPT_Neutro = agregar_stats(PPT_Neutro);
PPT_LN     = agregar_stats(PPT_LN);

%% =========================================================
% 5.1 ORGANIZE DATA FOR KRUSKAL-WALLIS
% DATA ONLY (columns 1–44)
% =========================================================
data_groups = NaN(24,37,3,44);
%data_groups = NaN(nq,nr,3,44);

for q = 1:nq
for r = 1:nr

    data_groups(q,r,1,:) = PPT_EN(q,1:44,r);
    data_groups(q,r,2,:) = PPT_Neutro(q,1:44,r);
    data_groups(q,r,3,:) = PPT_LN(q,1:44,r);

end
end
%% =========================================================
% 6. KRUSKAL–WALLIS + DUNN–BONFERRONI
% =========================================================

alpha = 0.05;

[nq, nr, ng, ~] = size(data_groups);  
% data_groups(q,r,g,:)  → data by group

KW_results(nq,nr) = struct( ...
    'p', [], ...
    'H', [], ...
    'meanranks', [], ...
    'n', [], ...
    'Dunn_p', [], ...
    'group_names', []);

for q = 1:nq
for r = 1:nr

    all_values = [];
    group_labels = [];
    n_groups = zeros(1,ng);

    %% ===============================
    % Build vector for KW
    % ===============================
    for g = 1:ng

        x = squeeze(data_groups(q,r,g,:));

        % ONLY remove NaN (NOT zeros)
        x = x(~isnan(x));

        n_groups(g) = length(x);

        all_values   = [all_values; x];
        group_labels = [group_labels; ...
                        g*ones(length(x),1)];
    end

    %% ===============================
    % Check sufficient data
    % ===============================
    if length(unique(group_labels)) < 2
        continue
    end

    %% ===============================
    % Kruskal-Wallis
    % ===============================
    [p,tbl,stats] = kruskalwallis( ...
        all_values, ...
        group_labels, ...
        'off');

    KW_results(q,r).p = p;
    KW_results(q,r).H = tbl{2,5};
    KW_results(q,r).meanranks = stats.meanranks;
    KW_results(q,r).n = n_groups;
    KW_results(q,r).group_names = unique(group_labels);

    %% ===============================
    % POST-HOC (only if KW is significant)
    % ===============================
    if p < alpha

        try
            c = multcompare(stats, ...
                'ctype','dunn-sidak', ...
                'display','off');

            % ===== included recommendation =====
            if isempty(c)
                warning('Empty post-hoc: q=%d r=%d',q,r)
                KW_results(q,r).Dunn_p = [];
            else
                KW_results(q,r).Dunn_p = c(:,6);
            end

        catch
            warning('Post-hoc error: q=%d r=%d',q,r)
            KW_results(q,r).Dunn_p = [];
        end

    else
        KW_results(q,r).Dunn_p = [];
    end

end
end
%% == KW ERROR CHECK ===
errores = 0;

for q = 1:24
for r = 1:37

    real_EN = enso_quincenal(q,:)==1;
    real_NE = enso_quincenal(q,:)==2;
    real_LN = enso_quincenal(q,:)==3;

    data_EN = ~isnan(PPT_EN(q,1:44,r));
    data_NE = ~isnan(PPT_Neutro(q,1:44,r));
    data_LN = ~isnan(PPT_LN(q,1:44,r));

    errores = errores + ...
        sum(data_EN & ~real_EN) + ...
        sum(data_NE & ~real_NE) + ...
        sum(data_LN & ~real_LN);

end
end

fprintf('Total errors = %d\n',errores)

fprintf('\n===== KW vs ENSO VERIFICATION =====\n')

errores = 0;

for q = 1:24
for r = 1:37

    % --- Actual ENSO count ---
    n_EN_real = sum(enso_quincenal(q,:) == 1);
    n_NE_real = sum(enso_quincenal(q,:) == 2);
    n_LN_real = sum(enso_quincenal(q,:) == 3);

    % --- Count used in KW ---
    n_kw = KW_results(q,r).n;

    if isempty(n_kw)
        continue
    end

    % --- comparison ---
    if n_kw(1) > n_EN_real || ...
       n_kw(2) > n_NE_real || ...
       n_kw(3) > n_LN_real

        fprintf('ERROR q=%d r=%d\n',q,r)
        errores = errores + 1;
    end

end
end

fprintf('Total inconsistencies = %d\n',errores)