function WCRTGraph()

% Leer el archivo de texto
filename = './final_new_new_results.txt'; % Cambia por el nombre real de tu archivo
data = readmatrix(filename, 'Delimiter', ';');

% Extraer columnas
col3 = data(:, 3) ./10000; % Tercera columna
col4 = data(:, 4) ./10000; % Cuarta columna

% Calcular el ratio
ratio = (col4 ./ col3) * 100;

% Encontrar los valores únicos de la tercera columna (como categorías)
[unique_vals, ~, group_idx] = unique(col3);

% Crear la gráfica de caja (boxplot)
figure;
boxplot(ratio, group_idx, 'Labels', string(unique_vals));
xlabel('Deadlines (ns)');
ylabel('WCRT (% of Deadline)');
grid on;
hold on;
threshold = 75;
yline(threshold, '--r', '75% Threshold', 'LabelHorizontalAlignment', 'left');
hold off;

set(gca, 'YTickLabelMode', 'auto')
set(gca, 'Color', 'none')     % Fondo transparente de los ejes
set(gcf, 'Color', 'none')     % Fondo transparente de la figura

% Ajustar tamaño del PDF al contenido de la figura
set(gcf, 'Units', 'inches');
figPosition = get(gcf, 'Position');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [figPosition(3) figPosition(4)]);
set(gcf, 'PaperPosition', [0 0 figPosition(3) figPosition(4)]);
set(gcf, 'InvertHardcopy', 'off');  % Mantener fondo transparente al guardar

% Guardar como PDF sin márgenes y con fondo transparente
print(gcf, 'WCRTGraph3', '-dpdf', '-r300')

end