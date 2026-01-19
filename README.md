# EEG_Processing_Pipeline

**Author:** Ria Borger  
**Project:** EEG Processing Pipeline
**Updated On:** 01/19/2026

---

## Overview

This repository contains a MATLAB-based EEG processing pipeline using **EEGLAB**. The pipeline includes:

- Loading EEG datasets in `.set` format  
- ERP extraction and visualization  
- Frequency band power computation (delta, theta, alpha, beta, gamma)  
- Time-frequency analysis (optional)  
- Shannon entropy calculation per channel  
- Visualization of band power and entropy  
- Saving processed results and figures  

The code is intended for reproducible EEG data analysis and interim reporting.

---

## Requirements

- **MATLAB** (R2019b or later recommended)  
- **EEGLAB** (v2023 or later recommended)  
- Optional: EEGLAB plugins such as **ERPLAB** for extended ERP analysis  

> Note: This repository does not include raw EEG `.set` files. Please place your EEG dataset in a local folder and update the `data_path` variable in the script.

---

## Usage

1. **Set the paths in the script**

```matlab
addpath(genpath('C:\Users\---\Desktop\BME499_EEGProcessing\eeglab_current')); % EEGLAB path 
data_path = 'C:\Users\---\Desktop\BME499_EEGProcessing\ses_001_sub_02';        % EEG dataset path (changed for each dataset)

2. **Run the main script**

```matlab
eeg_processing.m


3. **Outputs** will be saved in a folder named EEG_results inside data_path, including:
- ERP.mat – Event-related potentials
- BandPower.mat – Average power for delta/theta/alpha/beta/gamma bands
- Entropy.mat – Shannon entropy per channel
- Figures: BandPower_Figure.png, Entropy_Figure.png, ERP plots

4. **Visualizations**
- ERP plots per channel
- Bar plots of mean band power across channels
- Channel-wise entropy plots
