
%%
%Primero corre esta sección, ten en cuenta que debes cambiar el nombre del
%archivo y la ruta de acceso (o sea cambia "T1_RS" por "T1 y asi segun
%toque)

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%carga archivo
EEG = pop_loadset('filename','T21_RS.set','filepath','/Users/valeleija/Desktop/Datos TEA/High ASRS');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG=pop_chanedit(EEG, {'lookup','/Users/valeleija/Desktop/Datos TEA/High ASRS/channels_mod.txt'},'load',{'/Users/valeleija/Desktop/Datos TEA/High ASRS/channels_mod.txt','filetype','besa'});
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_reref(EEG, [23 24]);
EEG = pop_rmbase( EEG, [],[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

% Crear un vector de tiempo
[num_channels, num_samples] = size(EEG.data);
t = (0:num_samples-1) / EEG.srate;

% Crear una figura
figure;

% Plotear todos los canales
for ch = 1:num_channels
    subplot(num_channels, 1, ch);
    plot(t, EEG.data(ch, :));
    set(gca, 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none'); % Eliminar las marcas y etiquetas de los ejes
    grid on;
end

% Añadir un título general
sgtitle('Señal cruda de EEG para todos los canales');

% Añadir ejes generales para todos los subplots
han = axes('visible', 'off', 'Position', [0.1 0.1 0.9 0.9]);  
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlabel(han, 'Tiempo (s)');
ylabel(han, 'Amplitud');


%%

pop_eegplot( EEG, 1, 1, 1);

% FIR de 0.1 a 30 que son las bandas de interés
EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','T1_RS_FIR','gui','off'); 
%pop_eegplot( EEG, 1, 1, 1);
%EEG = pop_saveset( EEG, 'filename','T10_FIR.set','filepath','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

%
%ASR a como quedamos que se haría
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass',[0.25 0.75] ,'BurstCriterion',20,'WindowCriterion','off','BurstRejection','on','Distance','Euclidian');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','T1_RS_ASR','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_ASR.set','gui','off'); 

%Filtro de 1 HZ para el ICA
EEG = pop_eegfiltnew(EEG, 'locutoff',1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','T1_RS_1HZ','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_1HZ.set','gui','off'); 

%ICA
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'rndreset','yes','interrupt','on');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'retrieve',4,'study',0); 
EEG = pop_editset(EEG, 'icaweights', 'ALLEEG(5).icaweights', 'icasphere', 'ALLEEG(5).icasphere', 'icachansind', 'ALLEEG(5).icachansind');

[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_iclabel(EEG, 'default');
eeglab redraw;

%ELIMINAR COMPONENTES

matriz = EEG.etc.ic_classification.ICLabel.classifications;
[rows, cols] = size(matriz);
brain = matriz(:, 1);

% Encontrar los índices de componentes cerebrales menores de 0.30
x = find(brain < 0.70);
y = [];

% Iterar sobre los índices encontrados y aplicar la condición
for i = 1:length(x)
    idx = x(i);
    if sum(matriz(idx, 2:6)) > brain(idx)
        y = [y, idx];
    end
end

% Asegurarse de que los índices no estén fuera del rango
if ~isempty(y)
    y = unique(y); % Elimina

    %% K
    if all(y <= size(EEG.icaweights, 1))
        EEG = pop_subcomp(EEG, y, 0);
    else
        error('Componentes fuera de rango');
    end
else
    disp('No se eliminarán componentes');
end

%Señal ya limpia sin los componentes
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','T1_RS_CLEAN','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_CLEAN.set','gui','off'); 
pop_eegplot( EEG, 1, 1, 1);

%DELTA
EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',4);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'setname','T1_RS_DELTA','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_RS_DELTA.set','gui','off'); 
%pop_eegplot( EEG, 1, 1, 1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'retrieve',6,'study',0); 
%THETA
EEG = pop_eegfiltnew(EEG, 'locutoff',4,'hicutoff',8);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'setname','T1_RS_THETA','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_RS_THETA.set','gui','off'); 
%pop_eegplot( EEG, 1, 1, 1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'retrieve',6,'study',0); 
%ALPHA
EEG = pop_eegfiltnew(EEG, 'locutoff',8,'hicutoff',13);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'setname','T1_RS_ALPHA','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_RS_ALPHA.set','gui','off'); 
%pop_eegplot( EEG, 1, 1, 1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 9,'retrieve',6,'study',0); 
%BETA
EEG = pop_eegfiltnew(EEG, 'locutoff',13,'hicutoff',30);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'setname','T1_RS_BETA','savenew','C:\\Users\\danar\\Documents\\MATLAB\\TEA\\T1_RS_BETA.set','gui','off'); 
%pop_eegplot( EEG, 1, 1, 1);

eeglab redraw;
