function [Options] = Setup_Options_Fit_ME

%-----Fit Options-----
%Options.FitMethod = 'Unconstrained-NelderMead';
 Options.FitMethod = 'Constrained-InteriorPoint';
    % Choose the fit method. Unconstrained with Nelder-Mead algorithm (see
    % reference file for fminsearch) or Constrained with Interior Point
    % algorithm (see reference file for fmincon). If you choose constrained
    % fit, make sure you specify constraint boundaries on the parameters.
  
 %Options.GuessArray = 'Large';
  Options.GuessArray = [10000, 5.38882063, 0.024, 50]; %, 6];
  
    % First three parameters fixed since they don't seem to be affecting
    % the NLL values that much 
    
    % Your initial guess (these will be defined in Setup_Rate_Constants)
    % If you are scanning more than one guess, have additional 
    % guesses in separate rows. 'Large' means you will set up a larger guess
    % scan in Setup_Guess_Scan, at the bottom of this file.    
    if strcmp(Options.GuessArray,'Large')
        Options = Setup_Guess_Scan(Options);
    end
    
Options.LowerBounds = [10000, 4, 0.01, 1];
Options.UpperBounds = [2*10^5, 7, 0.03, 100];
    % The lower and upper bounds on your fit parameters. Should be the same
    % size as your initial guess matrix. These values will only be used if
    % you are performing a constrained fit.

Options.LikelihoodMethod = 'KineticsAndEfficiencies';
    % This determines which likelihood function will be used. Don't change.

Options.KineticWeightConstant = 1;
    % Constant used in the log likelihood calculation to weight the
    % kinetic terms relative to the efficiencies.Set equal to 1 if you want
    % equal weighting. 

Options.NormalizeModelEfficiencies = 'y';
    % y or n. Normalize the efficiencies of the model to the first pH value
    % in the sequence when calculating the likelihood function. 
    
Options.DisplayFitNotes = 'y';
    % Display the output notes to the command line from the built in Matlab minimization
    % functions which are used.
    
%-----Experimental data options-----
Options.ExpDataFilename = strcat(pwd,'/DataToFit/240730DENVDataToFit.mat');
    % Path to experimental data file (.MAT) we will be fitting
Options.UseRelEfficiencies = 'y';
    % y or n. Whether or not to use relative experimental efficiencies,
    % normalizing to the value below 
Options.EffMax = 0.2765;
    % 0.2765 = efficiency at pH 5 for DENV2 VLP data, 240730
    % 0.191 = efficiency before, Zika data pH 4.6

%------Kinetic Solver Options-----
Options.pHValues = [5.0, 5.25, 5.50, 5.75, 6, 6.25];
    % pH values you want to scan in the simulation
Options.TotalTime = 300;
    % Total time to evaluate, in seconds. Experimental data usually
    % collected for 340 seconds following pH drop. 
Options.NumberDataPoints = 300;
    % Number data points to evaluate
Options.Time = linspace(0,Options.TotalTime,Options.NumberDataPoints);
    % Time vector. Each time value will be evaluated to find the fraction fused.
 
%-------Equilibration Options------
Options.TotalTime_Eq = 0.01;
    % Total time in equilibration.
Options.Time_Eq = linspace(0,Options.TotalTime_Eq,15);
    % Time vector for the equilibration
    
%----Other Options----
Options.DisplayFigures = 'y';
    % y or n. Whether or not to display any figures at all.
Options.OverlayFitOnData = 'y';
    % y or n. Choose whether or not to overlay fit on experimental data
Options.Parallel = 'n';
    % Choose y if you are running multiple instances of Matlab as a crude
    % parallelization. This will split up the parameter scan according to your
    % input into Start_Kinetic_Schemer_ME.  
Options.Diagnostics = 'n';

%-----Legacy options, don't change----
    %-----Gating test options/parameters---
    % Options.LikelihoodMethod = 'Kinetics,GatedEfficiencies';
    Options.GatePHValues = [4.6, 6.6];
%     Options.GatePHValues = [5, 6];
    % The 2 pH values whose efficiencies (from the model) will be compared to
    % see if they pass the gate test 
    Options.GateValue =  0.4;
    % The minimum difference in efficiencies needed to pass the gate test
    Options.HighEffValueCutoff = 0.8;
    % The minimum efficiency that the lowest pH value must have in order for the gate test to be valid
    
end

function Options = Setup_Guess_Scan(Options)
    
% Define individual parameters that you want to scan initial guesses
    Params{1,1} = [ 100000, 150000, 200000, 250000, 300000];
     Params{1,2} = [6.8, 9];
     Params{1,3} = [6, 9];
% Add Params 4 and 5

% Enumerate all possible combinations of your defined parameters. Note that
% the number of combinations can get quite large quite quickly...
    Options.GuessArray = allcomb(Params{1,1:size(Params,2)});    
end