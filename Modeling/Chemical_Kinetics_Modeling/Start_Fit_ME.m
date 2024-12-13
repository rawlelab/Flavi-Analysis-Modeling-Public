function [] = Start_Fit_ME(ModelToUse)

% - - - - - - - - - - - - - - - - - - - - -
%Start_Fit_ME('3StateswOffPath')
% Input:
% Start_Fit_ME(ModelToUse)
%     ModelToUse = The name of the model which will be run, see
%     Setup_Rate_Constants.m.
% 
% Output:
% Solution displayed at command prompt

% Original version by Bob Rawle, Kasson Lab, University of Virginia, 2017

% This is the 2024 updated version, with a variety of minor edits and 
% new functionalities. Updates put together by Bob Rawle, Williams College, 
% as well as members of the Rawle Lab, most notably Tasnim Anika, to model 
% DENV VLP hemi-fusion data.
% - - - - - - - - - - - - - - - - - - - - -

close all
tic
% Set up options, including the initial guesses for the fit
    [Options] = Setup_Options_Fit_ME();
 
    
    EqTime = ['Equilibration Time = ', num2str(Options.TotalTime_Eq), ' seconds'];
    disp(EqTime)
    
% load the experimental data
    ExpData = open(Options.ExpDataFilename);
    CDFData_Exp = ExpData.CDFData;
    
    % Create pH index for easy reference, also use relative efficiencies if needed
    for e = 1:length(CDFData_Exp)
        PHIndex(e) = CDFData_Exp(e).pH;
        if strcmp(Options.UseRelEfficiencies,'y')
            CDFData_Exp(e).EfficiencyCorrected = CDFData_Exp(e).EfficiencyBefore/Options.EffMax;
        else
            CDFData_Exp(e).EfficiencyCorrected = CDFData_Exp(e).EfficiencyBefore;
        end
    end

% Set up figure handles
    if strcmp(Options.DisplayFigures,'y')
        [FigureHandles] = Setup_Figures_Global_Fit(Options);
    else
        FigureHandles = [];
    end

% Record which model we are using
    Options.ModelToUse = ModelToUse;
    
% Initialize other variables
    NumberInitialGuesses = size(Options.GuessArray,1);
    
% For each set of initial guesses, run the global fit to the experimental data
    for p = 1:NumberInitialGuesses
            CurrentGuess = Options.GuessArray(p,:);
            
            disp(' ');disp(' ');
            disp(strcat('----InitialGuess =',num2str(CurrentGuess),' -----'));
            
            % Perform the global fit using the chosen algorithm
            if strcmp(Options.FitMethod,'Constrained-InteriorPoint')
                LowerBound = Options.LowerBounds(p,:);
                UpperBound = Options.UpperBounds(p,:);
                disp(strcat('  LowerBound =',num2str(LowerBound)));
                disp(strcat('  UpperBound =',num2str(UpperBound)));
                
                if strcmp(Options.DisplayFitNotes,'y')
                    OptimizationOptions = optimoptions('fmincon','StepTolerance',1e-14,'Display','iter'); %'TypicalX', [1, 1e43, 1]);
                else
                    OptimizationOptions = optimoptions('fmincon','StepTolerance',1e-14); %, 'TolX', 1e-9,'TolFun', 1e-9,'Display','none');
                end

                [Solution,MeanNegLogLike] = fmincon(@Minimize_This,CurrentGuess,[],[],[],[],...
                    LowerBound,UpperBound,[],OptimizationOptions,Options,CDFData_Exp,PHIndex,FigureHandles);
                
            elseif strcmp(Options.FitMethod,'Unconstrained-NelderMead')
                
                if strcmp(Options.DisplayFitNotes,'y')
                    OptimizationOptions = optimset('TolX', 1e-9,'TolFun', 1e-9,'Display','iter');
                else
                    OptimizationOptions = optimset('TolX', 1e-9,'TolFun', 1e-9,'Display','notify','MaxFunEvals',1e10);
                end
                

                [Solution,MeanNegLogLike] = fminsearch(@Minimize_This,CurrentGuess,OptimizationOptions,...
                    Options,CDFData_Exp,PHIndex,FigureHandles);
            end
            
        
            disp(strcat('Solution =',num2str(Solution)));
            disp(strcat('MeanNegLogLikelihood=',num2str(MeanNegLogLike)));
            
            % Evaluate and plot the fit solution
            Evaluate_And_Plot_Fit_Solution(Solution,Options,FigureHandles,CDFData_Exp,PHIndex);
        
    end
    
    toc
    disp('Thank You, Come Again')

end