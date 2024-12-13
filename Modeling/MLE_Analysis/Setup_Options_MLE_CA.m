function [Options] = Setup_Options_MLE_CA()

% Options.ExpDataFilename = 'TestData.mat';
Options.ExpDataFilename = '240730DENVDataToFit.mat';
    % Path to experimental data file (.MAT) we will analyzing

Options.MakeMLESpreadsheet = 'y';
    %y or n. Whether to make a spreadsheet with all of the MLE analysis
    %data.

    Options.MaxTimeToAnalyze = 200;
    %Numerical value that sets the limit for which the data will be
    %analyzed. For example, setting this value to 200 means the
    %MLE_Analysis script will only look at the data that falls within the
    %range 0s <= t <= 200s.
    
Options.MultipleSerotypeValues = 'n';
    % y or n. Whether there are multiple serotype values at a given pH
    % (applies to DENV data).
    
Options.UseFractionInactivated = 'n';
    % y or n. Whether we want to use FractionInactivated or not. When
    % determining the best-fitting PSet (for simulations with equilibrations only), set this to 'y'. When
    % graphing/creating figures of the best-fitting PSet, set this to 'n'.
    if strcmp(Options.UseFractionInactivated, 'y')
        Options.CorrectEfficiencies = 'n';
            % y or n. Whether or not to correct the experimental efficiencies,
            % normalizing them to the value listed for Options.EffMax.
        Options.UseFractionInactviated_UpperBound = 0.76;
            % Calculated by (1-.24), which was the negative error bar of pH
            % 5.0 data from Chao, et al. 2014.
        Options.UseFractionInactviated_LowerBound = 0;
        Options.FractInactFreeParam = 'n';
            % y or n. Whether we want FractionInactivated to be a free
            % parameter or not. If set to 'n', FractionInactivated will be
            % set to a fixed value (see below).
        Options.FractInactFixedValue = 0.7235;
    elseif strcmp(Options.UseFractionInactivated, 'n')
        Options.CorrectEfficiencies = 'y';
    end

Options.NumberFreeParameters = 4;
    % Number of free parameters in the current model. Used to calculate AIC
    % values.

Options.EffMax = 0.2765;
    % 0.191 = efficiency before of Zika data pH 4.6
    % 0.309 = efficiency of WNV data pH 5.0
    % 0.25 is a placeholder for DENV while we are just interested in
    % graphing normalized curves
    
Options.TotalTime =  300;
    % Total time of simulation
    
Options.LikelihoodMethod = 'KineticsAndEfficiencies';
% Options.LikelihoodMethod = 'Kinetics,GatedEfficiencies';
    % This determines which likelihood function will be used

Options.NormalizeModelEfficiencies = 'y';
    % y or n. Normalize the efficiencies of the model to the first pH value
    % in the sequence when calculating the likelihood function. 
    
Options.KineticWeightConstant = 1;
    % Constant used in the log likelihood calculation to up weight the
    % kinetic terms relative to the efficiencies. Set equal to 1 if you want
    % equal weighting. Set below 1 if you would like the final efficiencies
    % to be weighted more heavily, and set above 1 if you would like the
    % curve shapes to be weighted more heavily.

    %-----Gating test options/parameters---
%     Options.GatePHValues = [4.6, 6.6];
    Options.GatePHValues = [5, 6];
    % The 2 pH values whose efficiencies (from the model) will be compared to
    % see if they pass the gate test 
    Options.GateValue =  0.5;
    % The minimum difference in efficiencies needed to pass the gate test
    Options.HighEffValueCutoff = 0;
    % The minimum efficiency that the lowest pH value must have in order for the gate test to be valid

Options.TopMLEPercentile = 100;
    % All parameter set numbers with maximum likelihood values above this
    % percentile will be printed out to the command prompt. The model data from these
    % parameter sets will also be visualized if you choose the Top Models display option 

%------Display options------
Options.DisplayOption = 'All';
% Options.DisplayOption = 'Max Only';
% Options.DisplayOption = 'Top Models';

    %------Options for Display Option = All or Max Only------
    Options.CDFDisplayOptions = 'Overlay';
%     Options.CDFDisplayOptions = 'Separate';
        % Overlay = display CDF of most likely model overlaid on the experimental data
        % Separate = display CDF side-by-side with the experimental data in a separate plot

    %------Options for Display Option = Top Models------
    Options.NumPlotsX = 6;
    Options.NumPlotsY = 3;
    Options.TotalNumPlots = Options.NumPlotsX * Options.NumPlotsY;
        % must be divisible by Options.NumPlotsPerFile

    Options.PlotEQData = 'y';
    Options.PlotEfficiencies = 'y';
    Options.NumPlotsPerFile = 2;

Options.Diagnostics = 'n';
end