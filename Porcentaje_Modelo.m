

% Cargar los archivos
carpeta_datos = 'C:\\Users\\danar\\Documents\\MATLAB\\SujetosTEA\\';
archivos = dir([carpeta_datos, '*.set']);

% Obtener el número total de archivos
num_archivos = length(archivos);

% Inicializa una celda para almacenar los datos EEGlab cargados
datos_EEG = cell(1, num_archivos);

% Itera sobre cada archivo y cárgalo
for i = 1:num_archivos
    % Construye el nombre completo del archivo
    nombre_archivo = [carpeta_datos, archivos(i).name];
    
    % Carga el archivo utilizando EEGlab
    datos_EEG{i} = pop_loadset(nombre_archivo)
end

% Obtener el número total de canales
num_canales = size(datos_EEG{1}.data, 1); % Suponiendo que todos los conjuntos de datos tienen la misma cantidad de canales

% Inicializar matrices para almacenar el PSD promedio de cada canal
psd_promedio_NT_theta = zeros(1, num_canales);
psd_promedio_NT_alpha = zeros(1, num_canales);
psd_promedio_NT_beta = zeros(1, num_canales);
eng_index = zeros(1,num_canales);
conc_index = zeros (1,num_canales);
inm_index = zeros (1,num_canales);

% Calcular el PSD promedio de cada canal para cada sujeto y acumular los resultados
for i = 1:num_archivos

    % Calcular el PSD para el sujeto actual
    [theta_band, alpha_band,beta_band, f] = calcular_PSD(datos_EEG{i});
    
    % Sumar el PSD calculado al PSD promedio de cada canal
    psd_promedio_NT_theta = psd_promedio_NT_theta + theta_band;
    psd_promedio_NT_alpha = psd_promedio_NT_alpha + alpha_band;
    psd_promedio_NT_beta = psd_promedio_NT_beta + beta_band;
    
end

% Calcular el promedio del PSD para cada canal sobre todos los sujetos
psd_promedio_NT_alpha = (psd_promedio_NT_alpha / num_archivos);
psd_promedio_NT_beta = (psd_promedio_NT_beta / num_archivos);
psd_promedio_NT_theta = (psd_promedio_NT_theta / num_archivos);

% Calculo de Engagement index
eng_index = [psd_promedio_NT_beta./(psd_promedio_NT_theta + psd_promedio_NT_alpha)];
eng_index = eng_index';

%Cálculo de indice de concentracion(beta/alfa)
conc_index = [psd_promedio_NT_beta./psd_promedio_NT_alpha];
conc_index = conc_index';

%Cálculo de indice de inmersión (theta/alpha)
inm_index= [psd_promedio_NT_theta./psd_promedio_NT_alpha];
inm_index = inm_index';

%% RESULTADO SUJETO DE PRUEBA
%%TEA1 = pop_loadset('filename','T4_RS_CLEAN.set','filepath','C:\\Users\\danar\\Documents\\MATLAB\\SujetosTEA\\');
TEA1 = pop_loadset('filename','N6_CLEAN.set','filepath','C:\\Users\\danar\\Documents\\MATLAB\\Neurotipicxs\\');
TEA1 = TEA1.data;
[n m] = size(TEA1);

% Set parameters
fs = 256;          % Sampling rate in Hz
win_length = fs;   % Window length in samples
overlap = win_length/2; % Overlap between adjacent windows in samples
tiempo_inicio = 1; % En segundos
tiempo_fin = 80; % En segundos

% INDICES Y PSD DE TEA 1 
psd_matrix_TEA1 = zeros(n, 3);
eng_index_TEA1 = zeros(n,1);
conc_index_TEA1 = zeros (n,1);
inm_index_TEA1 = zeros (n,1);

for i = 1:n
    dato_recortado = TEA1(:, tiempo_inicio*fs:tiempo_fin*fs);
    channel_data = dato_recortado(i,:);
    %Calculo del PSD
    [pxx, f] = pwelch(channel_data, hamming(win_length), overlap, [], fs);

    % Separación por bandas de interés
    theta_band = bandpower (pxx,f, [4 8],'psd');
    alpha_band = bandpower(pxx, f, [8 13], 'psd');
    beta_band = bandpower(pxx, f, [13 30], 'psd');

    %Matriz de psd por bandas, utilizada para calcular los ratios
    psd_matrix_TEA1(i,:) = [theta_band alpha_band beta_band];

    % Calculo de Engagement index
    eng_index_TEA1(i,:) = [beta_band/(theta_band + alpha_band)];
    %Cálculo de indice de concentracion(beta/alfa)
    conc_index_TEA1(i,:) = [beta_band/alpha_band];
    %Cálculo de indice de inmersión (theta/alpha)
    inm_index_TEA1(i,:) = [theta_band/alpha_band];

end

%% Porcentajes de similitud

similitud_inm = zeros(1, length(inm_index));
similitud_conc = zeros(1, length(conc_index));
similitud_eng= zeros(1, length(eng_index));

% Calcular la similitud para inmersion
for i = 1:length(inm_index)
        % Calcular la diferencia relativa directa
        diferencia_inm = abs(inm_index(i) - inm_index_TEA1(i)) / max(abs(inm_index(i)), abs(inm_index_TEA1(i))) * 100;
        % Calcular el porcentaje de similitud
        similitud_inm(i) = 100 - diferencia_inm;

end

% Calcular la similitud para concentracion
for i = 1:length(conc_index)
        % Calcular la diferencia relativa directa
        diferencia_conc = abs(conc_index(i) - conc_index_TEA1(i)) / max(abs(conc_index(i)), abs(conc_index_TEA1(i))) * 100;
        % Calcular el porcentaje de similitud
        similitud_conc(i) = 100 - diferencia_conc;

end

% Calcular la similitud para engagement
for i = 1:length(eng_index)
        % Calcular la diferencia relativa directa
        diferencia_eng = abs(eng_index(i) - eng_index_TEA1(i)) / max(abs(eng_index(i)), abs(eng_index_TEA1(i))) * 100;
        % Calcular el porcentaje de similitud
        similitud_eng(i) = 100 - diferencia_eng;

end

porcentaje_similitud_eng = mean (similitud_eng);
porcentaje_similitud_inm = mean (similitud_inm);
porcentaje_similitud_conc = mean (similitud_conc);
similitud_total = ((porcentaje_similitud_conc + porcentaje_similitud_inm + porcentaje_similitud_eng)/3)


%% Graficar resultados

canales = {'Fp1','F3','F7','C3','T7','P3','P7','O1','POz','Pz','CPz','Fp2','Afz','Fz','F4','F8','Cz','C4','T8','P4','P8','O2'};

min_conc = min([min(double(conc_index(:))), ...
               min(double(conc_index_TEA1(:)))]);

max_conc = max([max(double(conc_index(:))), ...
               max(double(conc_index_TEA1(:)))]);


min_inm = min([min(double(inm_index(:))), ...
               min(double(inm_index_TEA1(:)))]);

max_inm = max([max(double(inm_index(:))), ...
               max(double(inm_index_TEA1(:)))]);

min_eng = min([min(double(eng_index(:))), ...
               min(double(eng_index_TEA1(:)))]);

max_eng = max([max(double(eng_index(:))), ...
               max(double(eng_index_TEA1(:)))]);
figure(1)
subplot(1,3,1)
plot_topography(canales, double(inm_index_TEA1), false, '10-20', false, true, 1000)
title('Índice de Inmersión del Sujeto de Prueba')
fontsize(12,"points")
caxis([min_inm max_inm]); % Set color axis limits

subplot(1,3,2)
plot_topography(canales, double(conc_index_TEA1), false, '10-20', false, true, 1000)
title('Índice de Concentración del Sujeto de Prueba')
fontsize(12,"points")
caxis([min_inm max_inm]); % Set color axis limits

subplot(1,3,3)
plot_topography(canales, double(eng_index_TEA1), false, '10-20', false, true, 1000)
title('Índice de Involucramiento del Sujeto de Prueba')
fontsize(12,"points")
caxis([min_inm max_inm]); % Set color axis limits