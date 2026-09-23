%% Hace el detrend de una matriz

load PPT_CHIRPS_81_24.mat

% ============================================================
% GENERACIÓN DE PRECIPITACIÓN DETRENDED
% ============================================================
%
% PPT_CHIRPS:
%   filas 1:24      -> 24 quincenas
%   fila 25         -> acumulado anual
%   columnas 1:44   -> años 1981-2024
%   columna 45      -> pendiente original (NO SE USA)
%   columna 46      -> ordenada original (NO SE USA)
%   dimensión 3     -> 37 regiones
%
% PPT_CHIRPS_detrended:
%   24 x 44 x 37

% Eje temporal
x = 1:44;

% Crear matriz para los datos detrended
PPT_CHIRPS_detrended = nan(24,44,37);

% Recorrer regiones y quincenas
for r = 1:37
    for q = 1:24
        
        % Serie original de precipitación
        y = squeeze(PPT_CHIRPS_81_24(q,1:44,r));
        
        % Calcular nuevamente la regresión lineal con polyfit
        p = polyfit(x,y,1);
        
        % Constantes obtenidas directamente de polyfit
        m = p(1);
        a = p(2);
        
        % Calcular la tendencia
        tendencia = m .* x + a;
        
        % Eliminar la tendencia
        y_detrended = y - tendencia;
        
        % Guardar la serie detrended
        PPT_CHIRPS_detrended(q,:,r) = y_detrended;
        
    end
end

%% pruebas
q = 1;
r = 1;

% Serie detrended
y_detrended = squeeze(PPT_CHIRPS_detrended(q,:,r));

% Ajustar nuevamente una recta
p_check = polyfit(1:44,y_detrended,1);

fprintf('Pendiente después del detrending = %.12f\n',p_check(1));
fprintf('Ordenada después del detrending  = %.12f\n',p_check(2));
 
%% visualiza
q = 20;
r = 30;

y = squeeze(PPT_CHIRPS_81_24(q,1:44,r));
y_detrended = squeeze(PPT_CHIRPS_detrended(q,:,r));

% Tendencia calculada nuevamente con polyfit
p = polyfit(1:44,y,1);
tendencia = polyval(p,1:44);

figure

plot(1:44,y,'o-','DisplayName','Original')
hold on
plot(1:44,tendencia,'LineWidth',2,'DisplayName','Linear trend')
plot(1:44,y_detrended,'o-','DisplayName','Detrended')

xlabel('Year')
ylabel('Precipitation')
title('Detrending check: Fortnight 1, HR 1')
legend('Location','best')
grid on