FOR /L %%A IN (1,1,6) DO (
	START /W TSN_HeuristicScheduler.exe %%A STHS_input.txt 3
	matlab -wait -nosplash -nodesktop -r "AVB_analysis_input_generator(%%A); quit();"
	START /W AVB_analysis.exe %%A
)