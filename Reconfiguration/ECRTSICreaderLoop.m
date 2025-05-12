function [] = ECRTSICreaderLoop()
    clear;
    clc;
    faultyLink = [-1 -2;-1 -3;-1 -4;-1 -5;-2 -3;-2 -5;-3 -4;-4 -5];
    for i = 1:size(faultyLink, 1)
        ECRTSICreader(faultyLink(i, :),i);
    end
end

function [] = ECRTSICreader(faultyLink, ID)

inputFile = 'TSN_Streams.txt';
fid = fopen(inputFile, 'r');
if fid == -1
    error('Couldn´t open input file.');
end

streams = struct();
currentStream = '';

while ~feof(fid)
    line = strtrim(fgets(fid));

    if startsWith(line, 'TSN_Stream')
        parts = split(line);
        currentStream = parts{2};
        streams.(currentStream) = struct();

    elseif contains(line, '=')
        parts = split(line, '=');
        field = strtrim(parts{1});
        value = strtrim(parts{2});

        fieldParts = split(field, '.');
        if length(fieldParts) == 2
            param = fieldParts{2};
            streams.(currentStream).(param) = value;
        end
    end
end

fclose(fid);

% Crear listas para los distintos tipos
BE = [];
AVB = [];
TT = [];

% Para construir Architecture
allLinks = [];
pathList = {};

streamNames = fieldnames(streams);

numTT1 = 0;
numTT2 = 0;
numTT3 = 0;
numTT4 = 0;
minT = 3200000;
maxT = 0;
minS = 2000;
maxS = 0;

for i = 1:length(streamNames)
    s = streams.(streamNames{i});
    
    % Extraer datos
    period = str2double(s.period)/100;
    maxFrameSize = str2double(s.maxFrameSize);
    source = extractAfter(s.source, 'ES');
    pathNodes = split(s.path);
    destNode = extractAfter(pathNodes{end}, 'ES');
    
    
    if (period > maxT)
        maxT = period;
    end
    if (period < minT)
        minT = period;
    end
    if (maxFrameSize > maxS)
        maxS = maxFrameSize;
    end
    if (maxFrameSize < minS)
        minS = maxFrameSize;
    end
    

    % Determinar trafficClass
    tcNum = str2double(extractAfter(s.trafficClass, 'TC'));

    % Crear path numérico
    pathNumeric = [];
    for p = 1:length(pathNodes)
        node = pathNodes{p};
        if startsWith(node, 'ES')
            pathNumeric(end+1) = str2double(extractAfter(node, 'ES'));
        elseif startsWith(node, 'SW')
            pathNumeric(end+1) = -str2double(extractAfter(node, 'SW'));
        end
    end

    % Guardar este path
    pathList{end+1} = pathNumeric;

    % Añadir enlaces para arquitectura
    for p = 1:(length(pathNumeric)-1)
        if ~(pathNumeric(p) == faultyLink(1) && pathNumeric(p+1) == faultyLink(2))
            if ~(pathNumeric(p) == faultyLink(2) && pathNumeric(p+1) == faultyLink(1))
                allLinks = [allLinks; pathNumeric(p) pathNumeric(p+1)];
            end
        end
    end

    % Asignar deadline
    if tcNum == 7
        deadline = period / 2;
        numTT1 = numTT1 + 1;
    elseif ismember(tcNum, [5,6])
        deadline = period;
        numTT2 = numTT2 + 1;
    elseif ismember(tcNum, [2,3,4])
        deadline = 2*period;
        numTT3 = numTT3 + 1;
    else
        deadline = 0;
        numTT4 = numTT4 + 1;
    end

    % Fila base
    row = {period, 0, 0, 0, 0, 0, maxFrameSize, deadline, str2double(source), str2double(destNode), 0, 7 - tcNum};

    % Clasificar
    %if ismember(tcNum, [5,6,7])
    %if tcNum == 7 || (deadline >= 2000 && deadline <= 4000)
    %if tcNum == 7
    if tcNum == 7 || (deadline >= 2000 && deadline <= 4000)
        TT = [TT; row];
    elseif ismember(tcNum, [2,3,4,5,6])
        AVB = [AVB; row];
    elseif ismember(tcNum, [0,1])
        BE = [BE; row];
    end
end


% Calcular el total
total = numTT1 + numTT2 + numTT3 + numTT4;

% Calcular porcentajes
porcentajes = [numTT1, numTT2, numTT3, numTT4] / total * 100;

% Crear etiquetas para la gráfica
etiquetas = {'S1', 'S2', 'S3', 'S4'};

% Crear la gráfica de barras
%figure;
%bar(porcentajes);
%set(gca, 'XTickLabel', etiquetas);
%ylabel('Percentage (%)');
%ylim([0 40]);
%title('Percentage of streams for each type of timing requirement');

% Opcional: agregar los valores encima de cada barra
%for i = 1:length(porcentajes)
%text(i, porcentajes(i)+1, sprintf('%.1f%%', porcentajes(i)), 'HorizontalAlignment', 'center');
%end

% Ajustar figura para quitar márgenes
%set(gca, 'LooseInset', get(gca, 'TightInset'));
%set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 4]); 
%set(gcf, 'PaperPositionMode', 'auto');
%set(gcf, 'PaperUnits', 'Inches');
%set(gcf, 'PaperSize', [6 4]);
%set(gcf, 'PaperPosition', [0 0 6 4]); % Posicionar la gráfica ocupando toda la hoja

% Guardar la figura como PDF sin bordes
%print(gcf, 'percentages', '-dpdf');


% Eliminar enlaces duplicados para Architecture
Architecture = unique(allLinks, 'rows');

% Crear Routes
sources = unique(cellfun(@(x) x(1), pathList));
dests = unique(cellfun(@(x) x(end), pathList));

%Routes = cell(max(dests), max(sources));

%for i = 1:length(pathList)
%    path = pathList{i};
%    src = path(1);
%    dst = path(end);
%    
%    if isempty(Routes{dst,src})
%        Routes{dst,src}{1} = path;
%    else
%        Routes{dst,src}{end+1} = path;
%    end
%end

edges = Architecture;

% 2. Identificar nodos positivos únicos
positive_nodes = unique(edges(edges > 0));
n_pos = length(positive_nodes);

% 3. Crear mapa de nodo ? índice para celdas
node_to_idx = containers.Map(positive_nodes, 1:n_pos);

% 4. Inicializar celda de paths
global Routes  % Routes{dest, orig}
Routes = cell(n_pos, n_pos);

% 6. Explorar desde cada nodo positivo
for i = 1:length(positive_nodes)
    orig = positive_nodes(i);
    candidates = edges(edges(:,1) == orig, :);
    for j = 1:size(candidates,1)
        next = candidates(j,2);
        if next > 0
            idx_dest = node_to_idx(next);
            idx_orig = node_to_idx(orig);
            Routes{idx_dest, idx_orig}{end+1} = [orig, next];
        elseif next < 0
            recurse([orig, next], next, node_to_idx, edges, Routes);
        end
    end
end

% 7. Ordenar paths en cada celda de menor a mayor longitud
for i = 1:n_pos
    for j = 1:n_pos
        if ~isempty(Routes{i, j})
            lengths = cellfun(@length, Routes{i, j});
            [~, idx] = sort(lengths);
            Routes{i, j} = Routes{i, j}(idx);
        end
    end
end

% Ahora asignamos indices de rutas a BE, AVB y TT
pathCounters = containers.Map;
indexTT = 1;
indexBE = 1;
indexAVB = 1;

for i = 1:length(streamNames)
    s = streams.(streamNames{i});
    period = str2double(s.period)/100;
    maxFrameSize = str2double(s.maxFrameSize);
    source = extractAfter(s.source, 'ES');
    pathNodes = split(s.path);
    destNode = extractAfter(pathNodes{end}, 'ES');

    tcNum = str2double(extractAfter(s.trafficClass, 'TC'));
    
    % Asignar deadline
    if tcNum == 7
        deadline = period / 2;
    elseif ismember(tcNum, [5,6])
        deadline = period;
    elseif ismember(tcNum, [2,3,4])
        deadline = 2*period;
    else
        deadline = 0;
    end

    % Construir path numérico
    pathNumeric = [];
    for p = 1:length(pathNodes)
        node = pathNodes{p};
        if startsWith(node, 'ES')
            pathNumeric(end+1) = str2double(extractAfter(node, 'ES'));
        elseif startsWith(node, 'SW')
            pathNumeric(end+1) = -str2double(extractAfter(node, 'SW'));
        end
    end

    src = pathNumeric(1);
    dst = pathNumeric(end);

    pathsHere = Routes{dst,src};

    % Buscar coincidencia de path
    pathMatch = 0;
    for k = 1:size(pathsHere,2)
        if isequal(pathsHere{k}, pathNumeric)
            pathMatch = k;
            break;
        end
        if k == size(pathsHere,2)
            pathMatch = 1;
        end
    end

    % Asignar el número de path
    %if ismember(tcNum, [5,6,7])
    %if tcNum == 7 || (deadline >= 2000 && deadline <= 4000)
    %if tcNum == 7
    if tcNum == 7 || (deadline >= 2000 && deadline <= 4000)
        TT{indexTT,11} = pathMatch;
        indexTT = indexTT + 1;
    elseif ismember(tcNum, [2,3,4,5,6])
        AVB{indexAVB,11} = pathMatch;
        indexAVB = indexAVB + 1;
    elseif ismember(tcNum, [0,1])
        BE{indexBE,11} = pathMatch;
        indexBE = indexBE + 1;
    end
end

% Crear tablas
BE_Messages = table2struct(cell2table(BE, 'VariableNames', {'period','offset','jitter_transmission','jitter_reception','min_inter_arr_time','hard_real_time','length','deadline','source','destination','path','priority'}));
AVB_Messages = table2struct(cell2table(AVB, 'VariableNames', {'period','offset','jitter_transmission','jitter_reception','min_inter_arr_time','hard_real_time','length','deadline','source','destination','path','priority'}));
TT_Messages = table2struct(cell2table(TT, 'VariableNames', {'period','offset','jitter_transmission','jitter_reception','min_inter_arr_time','hard_real_time','length','deadline','source','destination','path','priority'}));

% Guardar .mat
mkdir(sprintf('Experiment%i',ID))
save(sprintf('Experiment%i/BE_Messages.mat',ID), 'BE_Messages');
save(sprintf('Experiment%i/AVB_Messages.mat',ID), 'AVB_Messages');
save(sprintf('Experiment%i/TT_Messages.mat',ID), 'TT_Messages');
save(sprintf('Experiment%i/Architecture.mat',ID), 'Architecture');
save(sprintf('Experiment%i/Routes.mat',ID), 'Routes');

%WRITE ST SCHEDULER INPUT FILE

fid = fopen(sprintf('Experiment%i/STHS_input.txt',ID),'wt');

struct_to_file(TT_Messages, Routes, Architecture, fid);

fclose(fid);

disp('¡Todo generado correctamente!');

end

% 5. Función recursiva para construir los Routes
function recurse(path, used_negatives, node_to_idx, edges, Routes)
    global Routes
    last = path(end);
    candidates = edges(edges(:,1) == last, :);

    for i = 1:size(candidates,1)
        next = candidates(i,2);

        if next < 0
            if ismember(next, used_negatives)
                continue;  % descartar si negativo se repite
            end
            recurse([path, next], [used_negatives, next], node_to_idx, edges, Routes);

        elseif next > 0
            dest = next;
            orig = path(1);
            idx_dest = node_to_idx(dest);
            idx_orig = node_to_idx(orig);
            Routes{idx_dest, idx_orig}{end+1} = [path, dest];
        end
    end
end

function [] = struct_to_file(message_struct, route, architecture, file)

for i = 1:length(message_struct)
    fprintf(file, 'message\n');
    fprintf(file, sprintf('length = %i\n',message_struct(i).length));
    fprintf(file, sprintf('period = %i\n',(message_struct(i).period + message_struct(i).min_inter_arr_time)));
    if message_struct(i).deadline > 0
        fprintf(file, sprintf('deadline = %i\n',message_struct(i).deadline));
    else
        fprintf(file, sprintf('deadline = %i\n',message_struct(i).period));
    end
    %fprintf(file, sprintf('priority = %s\n',type));
    path = route{message_struct(i).destination, message_struct(i).source}{message_struct(i).path}(:);
    num_links = length(path) - 1;
    fprintf(file, sprintf('linkNbr = %i\n',num_links));
    for j = 1:num_links
        fprintf(file, sprintf('link = %i\n',find(architecture(:,1) == path(j) & architecture(:,2) == path(j+1))));
    end
    fprintf(file, sprintf('initOffset = %i\n',message_struct(i).offset));
    %fprintf(file, sprintf('jitterIn = %i\n',message_struct(i).jitter_transmission));
    fprintf(file, '\n');
end
end