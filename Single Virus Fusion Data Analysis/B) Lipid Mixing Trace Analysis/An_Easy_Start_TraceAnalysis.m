% REMEMBER: Always check Setup_Options_Trace_Analysis before you begin!!!


disp('====================================')
disp('   Hey there friend. Lets get started, shall we?')
disp('   First, choose the folder where you want to pick the data...')
disp('   This should be the location of the saved trace data: output of the Extract Traces program.')
    DataLocation_TraceAnalysis = uigetdir();


disp('   Awesome. Sending that to the start program now...')
% If you have already chosen the data location you can simply copy and paste the
% line below for quicker workflow.
Start_Trace_Analysis(DataLocation_TraceAnalysis);