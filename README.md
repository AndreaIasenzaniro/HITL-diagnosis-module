# 💡 Fault Detection in HITL per un Drone Quadricottero

Questo progetto contiene il codice MATLAB e i modelli Simulink utilizzati per la generazione di dataset, l’estrazione di feature e la classificazione di guasti all'interno di una simulazione Hardware-in-the-Loop (HITL) di un drone quadrirotore. L’obiettivo è simulare guasti nel sistema, estrarre feature diagnostiche dai segnali in tempo reale e utilizzare classificatori addestrati per il rilevamento automatico delle anomalie. Il sistema diagnostico è integrato nel controllore di volo e consente il monitoraggio continuo del comportamento del drone, con applicazioni orientate alla **manutenzione predittiva** e al **controllo tollerante ai guasti**.

## 📁 Struttura del repository

```plaintext
project
├── dataset_generate/
│   ├── dataset_binario_generate.m
│   └── dataset_multiclasse_generate.m
│
├── saved_sessions/
│   ├── multiclassClassification_frame1_10features.mat
│   ├── multiclassClassification_frame1&28_10features.mat
├── simulink/
│   ├── Quadcopter_ControllerWithNavigation.slx
│   └── UAV_Dynamics.slx
```

## ⚙️ Descrizione dei componenti

### 1. Generazione Dataset
Gli script in `dataset_generate/` permettono di generare:
- Dataset per classificazione **binaria** del guasto (dataset_binario_generate.m).
- Dataset per classificazione **multiclasse**, considerando diverse tipologie di guasto o condizioni operative (dataset_multiclasse_generate.m).

### 3. Sessioni salvate
Le sessioni in `saved_sessions/` includono:
- File del **Classification Learner** per l’addestramento di classificatori (es. alberi decisionali) con **10 feature nel dominio del tempo** ed una finestra di **128 campioni**.

### 4. Modelli Simulink
I file in `simulink/` comprendono:
- `UAV_Dynamics.slx`: modello della dinamica del drone, aggiornato con **iniezione del guasto**.
- `Quadcopter_ControllerWithNavigation.slx`: controllore aggiornato con **moduli diagnostici integrati** basati su classificatori.

## 🧰 Requisiti

- MATLAB (con Signal Processing, Statistics & Machine Learning Toolbox)
- Simulink
- Diagnostic Feature Designer
- Classification Learner App


## 👥 Autori

|Nome | GitHub |
|-----------|--------|
| 👨 `Balducci Davide` | [Click here](https://github.com/Davide-Balducci) |
| 👨 `Camplese Francesco` | [Click here](https://github.com/FrancescoCamplese00) |
| 👨 `De Ritis Riccardo` | [Click here](https://github.com/RiccardoDR) |
| 👨 `Iasenzaniro Andrea` | [Click here](https://github.com/AndreaIasenzaniro) |