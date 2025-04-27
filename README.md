# 💡 Fault Detection in HIL Simulation of a Quadcopter Drone

Questo progetto contiene il codice MATLAB e i modelli Simulink utilizzati per la generazione di dataset, estrazione di feature e classificazione di guasti all'interno di una simulazione Hardware-in-the-Loop (HIL) di un drone quadrirotore. Il sistema diagnostico è integrato nel controllore di volo e consente il rilevamento in tempo reale di anomalie basate su segnali provenienti dalla simulazione.

## 📁 Struttura del repository

```plaintext
project
├── dataset_generate/
│   ├── dataset_binario_generate.m
│   └── dataset_multiclasse_generate.m
│
├── datasets/
│   ├── final_dataset_100HZ_binario.mat
│   └── final_dataset_100HZ_multiclasse.mat
│
├── saved_sessions/
│   ├── multiclassClassification_frame1_10features.mat
│   ├── multiclassClassification_frame1&28_10features.mat
│   ├── timeDomain_multiclass_wind1.mat
│   └── timeDomain_multiclass_wind1&28.mat
│
├── simulink/
│   ├── Quadcopter_ControllerWithNavigation.slx
│   └── UAV_Dynamics.slx
```
