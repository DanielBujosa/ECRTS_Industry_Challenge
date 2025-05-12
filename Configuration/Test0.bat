matlab -wait -nosplash -nodesktop -r "ECRTSICreader(); quit();"
START /W TSN_HeuristicScheduler.exe 0 STHS_input.txt 3
matlab -wait -nosplash -nodesktop -r "AVB_analysis_input_generator(0); quit();"
START /W AVB_analysis.exe 0