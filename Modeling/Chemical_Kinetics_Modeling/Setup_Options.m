function [Options] = Setup_Options()

Options.SaveData = 'n';
    % y or n, whether or not to save the data as a .mat file
Options.FileLabel = 'Test';
    % File label for the saved .mat file (be careful you don't overwrite anything)

Options.pHValues = [5.0];
    % pH values you want to scan
  
% Options.ParameterArray = 'Large';
Options.ParameterArray = [0.02];
    % Your scan parameter (this will be pH or a specific rate constant 
    % or something). If you are scanning more than one parameter, have additional 
    % parameters in separate rows. NaN indicates you are not varying
    % anything. 'Large' means you will set up a larger parameter scan in Setup_Large_Parameter_Scan
Options.TotalTime = 300;
    % Total time to evaluate, in seconds
Options.NumberDataPoints = 300;
    % Number data points to evaluate
Options.Time = linspace(0,Options.TotalTime,Options.NumberDataPoints);
    % Time vector. Each time value will be evaluated to find the fraction fused.
 
%-------Equilibration Options------
Options.TotalTime_Eq = 0.01;
    % Total time in equilibration, in sec.
Options.Time_Eq = linspace(0,Options.TotalTime_Eq,15);
    % Time vector for the equilibration
    
%----Other Options----
Options.DisplayFigures = 'y';
    % y or n. Whether or not to display any figures at all.
Options.DisplayNormalizedEfficiencies = 'y';
    % y or n. Normalize theefficiencies of the model to the first pH value
    % in the sequence when displaying the data
Options.Parallel = 'y';
    % Choose y if you are running multiple instances of Matlab as a crude
    % parallelization. This will split up the parameter scan according to your
    % input into Start_Kinetic_Schemer_ME.  
end