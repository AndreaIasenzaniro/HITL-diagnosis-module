clear; clc;

%% 1. Definizione della lista dei file e dei corrispondenti codici di guasto
fileList = { 
    'Logs/LogTraiettoria1/LogBuono0.ulg',
    'Logs/LogTraiettoria1/LogBuono1.ulg', 
    'Logs/LogTraiettoria1/LogBuono2.ulg',
    'Logs/LogTraiettoria1/LogBuono3.ulg',
    'Logs/LogTraiettoria1/LogBuono4.ulg',
    'Logs/LogTraiettoria1/LogBuono5.ulg',
    'Logs/LogTraiettoria1/LogBuono6.ulg',
    'Logs/LogTraiettoria1/LogBuono7.ulg',
    'Logs/LogTraiettoria1/LogBuono8.ulg',
    'Logs/LogTraiettoria2/LogBuono0.ulg',
    'Logs/LogTraiettoria2/LogBuono1.ulg', 
    'Logs/LogTraiettoria2/LogBuono2.ulg',
    'Logs/LogTraiettoria2/LogBuono3.ulg',
    'Logs/LogTraiettoria2/LogBuono4.ulg',
    'Logs/LogTraiettoria2/LogBuono5.ulg',
    'Logs/LogTraiettoria2/LogBuono6.ulg',
    'Logs/LogTraiettoria2/LogBuono7.ulg',
    'Logs/LogTraiettoria2/LogBuono8.ulg',
    'Logs/LogTraiettoria3/LogBuono0.ulg',
    'Logs/LogTraiettoria3/LogBuono1.ulg', 
    'Logs/LogTraiettoria3/LogBuono2.ulg',
    'Logs/LogTraiettoria3/LogBuono3.ulg',
    'Logs/LogTraiettoria3/LogBuono4.ulg',
    'Logs/LogTraiettoria3/LogBuono5.ulg',
    'Logs/LogTraiettoria3/LogBuono6.ulg',
    'Logs/LogTraiettoria3/LogBuono7.ulg',
    'Logs/LogTraiettoria3/LogBuono8.ulg',
    'Logs/LogTraiettoria1/LogConGuasto0_M1_05.ulg',
    'Logs/LogTraiettoria1/LogConGuasto1_M1_05.ulg',
    'Logs/LogTraiettoria1/LogConGuasto2_M1_05.ulg',
    'Logs/LogTraiettoria2/LogConGuasto0_M1_05.ulg',
    'Logs/LogTraiettoria2/LogConGuasto1_M1_05.ulg',
    'Logs/LogTraiettoria2/LogConGuasto2_M1_05.ulg',
    'Logs/LogTraiettoria3/LogConGuasto0_M1_05.ulg',
    'Logs/LogTraiettoria3/LogConGuasto1_M1_05.ulg',
    'Logs/LogTraiettoria3/LogConGuasto2_M1_05.ulg',
    'Logs/LogTraiettoria1/LogConGuasto0_M1_10.ulg',
    'Logs/LogTraiettoria1/LogConGuasto1_M1_10.ulg',
    'Logs/LogTraiettoria1/LogConGuasto2_M1_10.ulg', 
    'Logs/LogTraiettoria2/LogConGuasto0_M1_10.ulg',
    'Logs/LogTraiettoria2/LogConGuasto1_M1_10.ulg',
    'Logs/LogTraiettoria2/LogConGuasto2_M1_10.ulg', 
    'Logs/LogTraiettoria3/LogConGuasto0_M1_10.ulg',
    'Logs/LogTraiettoria3/LogConGuasto1_M1_10.ulg',
    'Logs/LogTraiettoria3/LogConGuasto2_M1_10.ulg',
    'Logs/LogTraiettoria1/LogConGuasto0_M1_15.ulg',
    'Logs/LogTraiettoria1/LogConGuasto1_M1_15.ulg',
    'Logs/LogTraiettoria1/LogConGuasto2_M1_15.ulg',
    'Logs/LogTraiettoria2/LogConGuasto0_M1_15.ulg',
    'Logs/LogTraiettoria2/LogConGuasto1_M1_15.ulg',
    'Logs/LogTraiettoria2/LogConGuasto2_M1_15.ulg',
    'Logs/LogTraiettoria3/LogConGuasto0_M1_15.ulg',
    'Logs/LogTraiettoria3/LogConGuasto1_M1_15.ulg',
    'Logs/LogTraiettoria3/LogConGuasto2_M1_15.ulg'
};  
faultLabels = [zeros(1,27), ones(1,27)];
matFileName = 'final_dataset_100HZ_binario.mat';  % Nome del file finale

% Parametri per rimuovere decollo e atterraggio
takeoff_duration = seconds(5);  % Tempo da escludere all'inizio
landing_duration = seconds(5);  % Tempo da escludere alla fine

%% 2. Se il file esiste già, lo elimina per sovrascrivere il dataset
if isfile(matFileName)
    delete(matFileName);
end
allTTs = table();

%% 3. Loop su tutti i file ULog
for idx = 1:length(fileList)
    filePath = fileList{idx};  
    faultLabel = faultLabels(idx);  

    fprintf('🔄 Elaborazione file: %s con Fault Code: %d\n', filePath, faultLabel);
    
    % Lettura del file ULog
    ulogOBJ = ulogreader(filePath);

    % Selezione dei topic di interesse
    topicsOfInterest = {'vehicle_acceleration', 'vehicle_angular_velocity', 'actuator_outputs', 'trajectory_setpoint', 'vehicle_local_position'};
    msgTable = readTopicMsgs(ulogOBJ, 'TopicNames', topicsOfInterest);

    %% 🚀 **Estrazione e processamento dei dati**
    
    % **ACCELERAZIONI**
    accData = msgTable.TopicMessages{strcmp(msgTable.TopicNames, 'vehicle_acceleration')};
    accData = accData(:, {'xyz'});  
    t_start = accData.Properties.RowTimes(1);
    t_end   = accData.Properties.RowTimes(end);
    commonTime = (t_start : seconds(0.01) : t_end)';  
    accDataResampled = retime(accData, commonTime, 'linear');
    
    % **VELOCITÀ ANGOLARE**
    angVelData = msgTable.TopicMessages{strcmp(msgTable.TopicNames, 'vehicle_angular_velocity')};
    angVelData = angVelData(:, {'xyz'});  
    angVelDataResampled = retime(angVelData, commonTime, 'linear');

    % **ACTUATOR OUTPUTS**
    actuatorData = msgTable.TopicMessages{strcmp(msgTable.TopicNames, 'actuator_outputs')};
    actuatorData = actuatorData(:, {'output'});  
    %actuatorData.output = actuatorData.output(:, 1:4);  
    actuatorDataResampled = retime(actuatorData, commonTime, 'linear');

    % **TRAJECTORY SETPOINT**
    trajectorySetP = msgTable.TopicMessages{strcmp(msgTable.TopicNames, 'trajectory_setpoint')};
    trajectorySetA = msgTable.TopicMessages{strcmp(msgTable.TopicNames, 'trajectory_setpoint')};
    trajectorySetP = trajectorySetP(:, {'position'});
    trajectorySetA = trajectorySetA(:, {'acceleration'});
    %actuatorData.output = actuatorData.output(:, 1:3);  
    trajectorySetPResempled = retime(trajectorySetP, commonTime, 'linear');
    trajectorySetAResempled = retime(trajectorySetA, commonTime, 'linear');

    % **VEHICLE LOCAL POSITION**
    localPosition = msgTable.TopicMessages{strcmp(msgTable.TopicNames, 'vehicle_local_position')};
    localPosition_x = localPosition(:,{'x'});
    localPosition_y = localPosition(:,{'y'});
    localPosition_z = localPosition(:,{'z'});
    localPosition_x_Resampled = retime(localPosition_x, commonTime, 'linear');
    localPosition_y_Resampled = retime(localPosition_y, commonTime, 'linear');
    localPosition_z_Resampled = retime(localPosition_z, commonTime, 'linear');

    %% **✂️ RIMOZIONE DI DECOLLO E ATTERRAGGIO**
    flight_start = commonTime(1) + takeoff_duration;  % Inizio della fase di volo stabile
    flight_end = commonTime(end) - landing_duration;  % Fine della fase di volo stabile

    % Filtra solo la parte centrale del volo
    idxMask = (commonTime >= flight_start & commonTime <= flight_end);
    
    accDataResampled = accDataResampled(idxMask, :);
    angVelDataResampled = angVelDataResampled(idxMask, :);
    actuatorDataResampled = actuatorDataResampled(idxMask, :);
    trajectorySetPResempled = trajectorySetPResempled(idxMask, :);
    localPosition_x_Resampled = localPosition_x_Resampled(idxMask, :);
    localPosition_y_Resampled = localPosition_y_Resampled(idxMask, :);
    localPosition_z_Resampled = localPosition_z_Resampled(idxMask, :);
    trajectorySetAResempled = trajectorySetAResempled(idxMask, :);

    % Aggiorna il tempo relativo
    commonTime = commonTime(commonTime >= flight_start & commonTime <= flight_end);
    timeSec = commonTime - commonTime(1);


    %% 🛠 **Creazione delle `timetable` finali**
    
    res_acc_x = abs(accDataResampled.xyz(:,1) - trajectorySetAResempled.acceleration(:,1));
    res_acc_y = abs(accDataResampled.xyz(:,2) - trajectorySetAResempled.acceleration(:,2));
    res_acc_z = abs(accDataResampled.xyz(:,3) - trajectorySetAResempled.acceleration(:,3));

    res_acc_x = timetable(timeSec, res_acc_x, 'VariableNames', {'res_acc_x'});
    res_acc_y = timetable(timeSec, res_acc_y, 'VariableNames', {'res_acc_y'});
    res_acc_z = timetable(timeSec, res_acc_z, 'VariableNames', {'res_acc_z'});

    % **Timetable accelerazioni reali**
    acc_x_TT = timetable(timeSec, accDataResampled.xyz(:,1), 'VariableNames', {'acc_x_reale'});
    acc_y_TT = timetable(timeSec, accDataResampled.xyz(:,2), 'VariableNames', {'acc_y_reale'});
    acc_z_TT = timetable(timeSec, accDataResampled.xyz(:,3), 'VariableNames', {'acc_z_reale'});
    
    % **Timetable accelerazioni desiderate**
    acc_x_des_TT = timetable(timeSec, trajectorySetAResempled.acceleration(:,1), 'VariableNames', {'acc_x_desiderata'});
    acc_y_des_TT = timetable(timeSec, trajectorySetAResempled.acceleration(:,2), 'VariableNames', {'acc_y_desiderata'});
    acc_z_des_TT = timetable(timeSec, trajectorySetAResempled.acceleration(:,3), 'VariableNames', {'acc_z_desiderata'});

    % **Timetable velocità angolari**
    angVel_x_TT = timetable(timeSec, angVelDataResampled.xyz(:,1), 'VariableNames', {'angVel_x'});
    angVel_y_TT = timetable(timeSec, angVelDataResampled.xyz(:,2), 'VariableNames', {'angVel_y'});
    angVel_z_TT = timetable(timeSec, angVelDataResampled.xyz(:,3), 'VariableNames', {'angVel_z'});

    % **Timetable attuatori**
    actuator_1_TT = timetable(timeSec, actuatorDataResampled.output(:,1), 'VariableNames', {'actuator_1'});
    actuator_2_TT = timetable(timeSec, actuatorDataResampled.output(:,2), 'VariableNames', {'actuator_2'});
    actuator_3_TT = timetable(timeSec, actuatorDataResampled.output(:,3), 'VariableNames', {'actuator_3'});
    actuator_4_TT = timetable(timeSec, actuatorDataResampled.output(:,4), 'VariableNames', {'actuator_4'});

    % ** Calcolo residui posizione**
    res_x = abs(trajectorySetPResempled.position(:,1) - localPosition_x_Resampled.x);
    res_y = abs(trajectorySetPResempled.position(:,2) - localPosition_y_Resampled.y);
    res_z = abs(trajectorySetPResempled.position(:,3) - localPosition_z_Resampled.z);

    % **Timetable Posizione Desiderata**
    x_des_TT = timetable(timeSec, trajectorySetPResempled.position(:,1), 'VariableNames', {'x_desiderata'});
    y_des_TT = timetable(timeSec, trajectorySetPResempled.position(:,2), 'VariableNames', {'y_desiderata'});
    z_des_TT = timetable(timeSec, trajectorySetPResempled.position(:,3), 'VariableNames', {'z_desiderata'});

    % **Timetable Posizione Reale**
    x_real_TT = timetable(timeSec, localPosition_x_Resampled.x, 'VariableNames', {'x_reale'});
    y_real_TT = timetable(timeSec, localPosition_y_Resampled.y, 'VariableNames', {'y_reale'});
    z_real_TT = timetable(timeSec, localPosition_z_Resampled.z, 'VariableNames', {'z_reale'});

    res_x = timetable(timeSec, res_x, 'VariableNames', {'res_x'});
    res_y = timetable(timeSec, res_y, 'VariableNames', {'res_y'});
    res_z = timetable(timeSec, res_z, 'VariableNames', {'res_z'});


    %% 📌 **Creiamo la tabella con `timetable` nelle colonne**
    newEntry = table({acc_x_TT}, {acc_y_TT}, {acc_z_TT}, ...
                 {angVel_x_TT}, {angVel_y_TT}, {angVel_z_TT}, ...
                 {actuator_1_TT}, {actuator_2_TT}, {actuator_3_TT}, {actuator_4_TT}, ...
                 {res_x}, {res_y}, {res_z},...
                 {res_acc_x}, {res_acc_y}, {res_acc_z},...
                 faultLabel, ...
                 'VariableNames', {'acc_x_reale', 'acc_y_reale', 'acc_z_reale', ...
                                   'angVel_x', 'angVel_y', 'angVel_z', ...
                                   'actuator_1', 'actuator_2', 'actuator_3', 'actuator_4', ...
                                   'res_x', 'res_y', 'res_z', ...
                                   'res_acc_x', 'res_acc_y', 'res_acc_z', ...
                                   'Fault'});

    %% **Concatenazione con la tabella principale**
    allTTs = [allTTs; newEntry];
end

%% 4. Normalizzazione della lunghezza delle `timetable`
numRows = height(allTTs);
numVars = width(allTTs) - 1; % Escludendo la colonna 'Fault'

% Trova la lunghezza minima tra tutte le timetable
timetableLengths = zeros(numRows, numVars);
for i = 1:numRows
    for j = 1:numVars
        timetableLengths(i, j) = height(allTTs{i, j}{1});
    end
end
minLength = min(timetableLengths(:));
fprintf("📏 Lunghezza minima trovata: %d campioni\n", minLength);

% Tronchiamo tutte le timetable alla stessa lunghezza
for i = 1:numRows
    for j = 1:numVars
        currentTT = allTTs{i, j}{1};
        if height(currentTT) > minLength
            allTTs{i, j}{1} = currentTT(1:minLength, :);
        end
    end
end

%% 5. Salvataggio del dataset aggiornato
save(matFileName, 'allTTs');

disp("Tutti i file ULog sono stati elaborati e i dati sono stati salvati!");
