function [conc_index, inm_index, eng_index] = calcular_PSD_mas_ventanas_modelo(datos_EEG_alfa,datos_EEG_beta, datos_EEG_theta)


fs = 256;          % Sampling rate in Hz
tiempo_inicio = 1; % En segundos
tiempo_fin = 80; % En segundos

    datos_eeg_actual_alfa = double(datos_EEG_alfa.data);
    dato_recortado_alfa = datos_eeg_actual_alfa(:, tiempo_inicio*fs:tiempo_fin*fs);
    channel_data_alfa = dato_recortado_alfa;
    channel_data_alfa = channel_data_alfa([3,5,6,10,11,15,17,20],:);

        datos_eeg_actual_beta = double(datos_EEG_beta.data);
    dato_recortado_beta = datos_eeg_actual_beta(:, tiempo_inicio*fs:tiempo_fin*fs);
    channel_data_beta = dato_recortado_beta;
    channel_data_beta = channel_data_beta([3,5,6,10,11,15,17,20],:);

        datos_eeg_actual_theta = double(datos_EEG_theta.data);
    dato_recortado_theta = datos_eeg_actual_theta(:, tiempo_inicio*fs:tiempo_fin*fs);
    channel_data_theta = dato_recortado_theta;
    channel_data_theta = channel_data_theta([3,5,6,10,11,15,17,20],:);


%Potencia (?)

psd_alfa = channel_data_alfa.^2;
psd_por_ventanas_alfa = [];
psd_theta = channel_data_theta.^2;
psd_por_ventanas_theta = [];
psd_beta = channel_data_beta.^2;
psd_por_ventanas_beta = [];

for canales = 1:8

ventanas_alfa = buffer(psd_alfa(canales,:),4*fs);
ventanas_alfa = mean(ventanas_alfa)';
psd_por_ventanas_alfa = [psd_por_ventanas_alfa, ventanas_alfa];
ventanas_beta = buffer(psd_beta(canales,:),4*fs);
ventanas_beta = mean(ventanas_alfa)';
psd_por_ventanas_beta = [psd_por_ventanas_beta, ventanas_beta];
ventanas_theta = buffer(psd_theta(canales,:),4*fs);
ventanas_theta = mean(ventanas_theta)';
psd_por_ventanas_theta = [psd_por_ventanas_theta, ventanas_theta];

end


% Calculo de Engagement index
eng_index = [psd_por_ventanas_beta./(psd_por_ventanas_theta + psd_por_ventanas_alfa)];
%Cálculo de indice de concentracion(beta/alfa)
conc_index = [psd_por_ventanas_beta./psd_por_ventanas_alfa];
%Cálculo de indice de inmersión (theta/alpha)
inm_index= [psd_por_ventanas_theta./psd_por_ventanas_alfa];