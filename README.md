# TSN Configuration and Reconfiguration Tools – Industry Challenge

This repository contains the tools, scripts, and experimental results developed for the Industry Challenge case study. It focuses on the configuration and reconfiguration of a Time-Sensitive Networking (TSN) system under both normal and fault conditions.

## 📁 Repository Structure

The repository is organized into two main folders:

### 🔧 Configuration

This folder includes the tools used to perform the initial configuration of the network, as well as the results of each analysis and iteration.

Contents:
- **Experiment0.X** (4 folders): Analysis of the initial configuration provided in the Industry Challenge.
- **Experiment1.X** (3 folders): Results of the three iterations used to determine AVB traffic priority mapping.
- **TSN_Streams.txt**: Stream definitions for the case study.
- **ECRTSICreader.m**: MATLAB script that parses `TSN_Streams.txt`, classifies the traffic, and generates the input for the ST scheduler.
- **TSN_HeuristicScheduler.exe**: Executable for generating the ST schedule.
- **AVB_analysis_input_generator.m**: MATLAB script to generate the input for the AVB WCRTA analysis.
- **AVB_analysis.exe**: WCRTA analysis executable.
- **test0.bat**: Windows batch script to run the full configuration process.

### 🔁 Reconfiguration

This folder contains the tools and results related to evaluating the system under link failure scenarios.

Contents:
- **Experiment1** to **Experiment8**: Each folder corresponds to a different link failure.
- **TSN_Streams.txt**: Same stream definition file used in configuration.
- **ECRTSICreaderLoop.m**: MATLAB script that generates all eight failure scenarios, calculates alternative paths, maps traffic classes, and creates inputs for the ST scheduler.
- **TSN_HeuristicScheduler.exe**, **AVB_analysis_input_generator.m**, and **AVB_analysis.exe**: Same tools as in the configuration phase.
- **test.bat**: Windows batch script to execute all reconfiguration experiments.

## ⚙️ Requirements

- MATLAB R2019a or later
- Windows OS (for `.bat` script execution)

## 🧑‍💻 Authors

Developed by Daniel Bujosa Mateu, Mohammad Ashjaei and Saad Mubeen.

---

