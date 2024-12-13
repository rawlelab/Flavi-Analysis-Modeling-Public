 function [] = Start_Like_Analysis_CA(varargin)

% - - - - - - - - - - - - - - - - - - - - -
% Overview:
% This function (and called functions) conducts a likelihood analysis of
% cellular automaton simulation data compared to single virus fusion data.
% It displays various figures and output to the commandline to indicate the
% top-performing models.
%
% Input:
% Start_Like_Analysis_CA(varargin)
% 
% Output:
% Displayed figures and info at command prompt

% Original version by Bob Rawle, Kasson Lab, University of Virginia, 2017

% This is the 2024 updated version, with a variety of minor edits and 
% new functionalities. Updates put together by Bob Rawle, Williams College, 
% as well as members of the Rawle Lab, most notably Tasnim Anika, to model 
% DENV VLP hemi-fusion data.
% - - - - - - - - - - - - - - - - - - - - -

close all

% set up options, create figures
    [Options] = Setup_Options_MLE_CA();
    [FigureHandles] = Create_Figures(Options);

%Bring in NumberFreeParameters as a variable from the Setup_Options
    NumberFreeParameters = Options.NumberFreeParameters;
    
% load the experimental data
    ExpData = open(Options.ExpDataFilename);
    CDFData_Exp = ExpData.CDFData;
        
    % Create pH index for easy reference, also correct efficiencies if needed
    for e = 1:length(CDFData_Exp)
        PHIndex(e) = CDFData_Exp(e).pH;
        if strcmp(Options.CorrectEfficiencies,'y')
            CDFData_Exp(e).EfficiencyCorrected = CDFData_Exp(e).EfficiencyBefore/Options.EffMax;
        elseif strcmp(Options.CorrectEfficiencies,'n')
            CDFData_Exp(e).EfficiencyCorrected = CDFData_Exp(e).EfficiencyBefore;
        end
    end
    
% Identify the paths to the KSolver model data you wish to analyze
    [FileInfo] = Load_Data(varargin);
        NumberOfFiles = FileInfo(1).NumberOfFiles;
        
% for each file selected, calculate the average log likelihood (negative)
% of the model given the experimental data
    MeanNegLogLike = zeros(NumberOfFiles, 1);
    for p = 1:NumberOfFiles
        % Extract KSolver data that we will need
        CurrentFilePath = FileInfo(p).FilePath;
        InputData = open(CurrentFilePath);
        ModelData = InputData.DataToSave;
        
        if strcmp(Options.UseFractionInactivated, 'y')
            
        % Determine the time step
            UpperBound = Options.UseFractionInactviated_UpperBound;
            LowerBound = Options.UseFractionInactviated_LowerBound;
            InitialGuess = 0.5;

            OptimizationOptions = optimset('TolX', 1e-12,'TolFun', 1e-12,'Algorithm','interior-point','Display','none');

            if strcmp(Options.FractInactFreeParam, 'y')
                FractionInactivated(p) = fmincon(@Det_Fraction_Inactivated,InitialGuess,[],[],[],[],...
                    LowerBound,UpperBound,[],OptimizationOptions,... %everything after this is a variable passed to the Det_Fraction_Inactivated function
                    ModelData,CDFData_Exp,PHIndex,Options,FigureHandles);
            else
                FractionInactivated(p) = Options.FractInactFixedValue;
            end
            
            [MeanNegLogLike(p), MeanNegLogLike_Kinetic(p), MeanNegLogLike_Eff(p)] = Calculate_Likelihood_Global_Fit(ModelData,CDFData_Exp,PHIndex,Options,FigureHandles,FractionInactivated(p));
        else
            FractionInactivated(p) = 0;
            
            [MeanNegLogLike(p), MeanNegLogLike_Kinetic(p), MeanNegLogLike_Eff(p)] = Calculate_Likelihood_Global_Fit(ModelData,CDFData_Exp,PHIndex,Options,FigureHandles,FractionInactivated(p));
        end
        
        AIC(p) = (2*NumberFreeParameters)+ (2*MeanNegLogLike(p));
        
        ParamToDisplay(p) = ModelData(1).CurrentParameters(1);
%         ParamToDisplay2(p) = ModelData(1).CurrentParameters(2);
        PSetNumber(p) = ModelData(1).HelpfulInfo.PSetNumber;
        AllParamsToDisplay(p,:) = ModelData(1).CurrentParameters;
        
    end
    
    % If we are using a gating test, then filter the log likelihood outputs
    % by those that pass the gating test 
    if strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies')
        FilterIndex = ~isnan(MeanNegLogLike);
        MeanNegLogLike = MeanNegLogLike(FilterIndex);
        PSetNumber = PSetNumber(FilterIndex);
        ParamToDisplay = ParamToDisplay(FilterIndex);
    end
    
% if selected, plot Pset number versus mean negative log likelihood
    if strcmp(Options.DisplayOption,'All')
        set(0,'CurrentFigure',FigureHandles.LikeCompareWindow)
        plot(PSetNumber,MeanNegLogLike)
        xlabel('PSetNumber')
%         plot(ParamToDisplay2,MeanNegLogLike)
%         xlabel('Param')
        ylabel('-Mean(LogLikelihood)')
%         plot3(ParamToDisplay,ParamToDisplay2,MeanNegLogLike,'o')
%         xlabel('Param1')
%         ylabel('Param2')
%         zlabel('-Mean(LogLikelihood)')
    end

% plot the parameter set with the maximum average log likelihood (minimum negative) together with the experimental data
if strcmp(Options.DisplayOption,'All')  || strcmp(Options.DisplayOption,'Max Only')
    
    % find the model data with the maximum likelihood
    PSetIndexMax = find(MeanNegLogLike == min(MeanNegLogLike), 1);
    % Extract KSolver data that we will need
        CurrentFilePath = FileInfo(PSetIndexMax).FilePath;
        InputData = open(CurrentFilePath);
        ModelDataMax = InputData.DataToSave;
        FractionInactivatedMax = FractionInactivated(PSetIndexMax);
    
    Plot_Max_Like_PSet(ModelDataMax,FigureHandles,CDFData_Exp,PHIndex,Options,FractionInactivatedMax);
    
end
    
% Display list of PSet numbers in the top percentile of maximum likelihood
% (bottom percentile of negative likelihood). We only use the real part in the rare cases where the mean NLL is imaginary 
    MLECutoff = prctile(real(MeanNegLogLike),Options.TopMLEPercentile);
    
    PSetCounter = 0;
    for p = 1:length(MeanNegLogLike)
        if MeanNegLogLike(p) <= MLECutoff
            PSetCounter = PSetCounter + 1;
            TopModelsInfo(PSetCounter,1:6) = [PSetNumber(p),MeanNegLogLike(p),MeanNegLogLike_Kinetic(p),MeanNegLogLike_Eff(p),AIC(p),FractionInactivated(p)];
            AllParamsToDisplay_toppercentile(PSetCounter,:) = AllParamsToDisplay(p,:);
        end
    end
    
    %Convert all the arrays into tables, and combine into one final table
    %that we will later print out
    AllParamsToDisplayAsATable = array2table(AllParamsToDisplay_toppercentile);
    TopModelsInfoAsATable = array2table(TopModelsInfo);
    CombinedTable = [TopModelsInfoAsATable AllParamsToDisplayAsATable];
    FinalTable = sortrows(CombinedTable,2);
    
    %Create column titles for the final table
    TableColumnNames(1,1:6) = {'PSet' 'NLL' 'NLL_Kinetics' 'NLL_Eff' 'AIC' 'PctInactivated'};
        for z = 1:(width(AllParamsToDisplayAsATable))
            TableColumnNames(1,z+6) = {strcat('Param_',num2str(z))};
        end    
    FinalTable.Properties.VariableNames = TableColumnNames;
    
    format long
    
    if strcmp(Options.MakeMLESpreadsheet,'y')
        writetable(FinalTable, [FileInfo(1).DefaultPathname strcat('MLE_Spreadsheet-MaxTime_',num2str(Options.MaxTimeToAnalyze),'s-Created-',date,'-',datestr(now,'HH-MM-SS'),'.xlsx')]);
    end
    
    disp('-------MLE Report--------')
    disp(strcat('PSetNumbers in top-',num2str(Options.TopMLEPercentile),'-percent'))
    disp(FinalTable)
    disp('-----------------------')
    
    % Visualize all of the models with the top maximum likelihood values, if chosen as a display option
    if strcmp(Options.DisplayOption,'Top Models')
        Visualize_Top_Models(FileInfo,Options,FigureHandles,TopModelsInfo);
    end
end

function [FileInfo] = Load_Data(varargin)
    if length(varargin) == 1
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed',...
            char(varargin{1}),'Multiselect', 'on');
    else
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed', 'Multiselect', 'on');
    end

    
    % Determine how many files are being analyzed
    if iscell(DataFilenames) %This lets us know if there is more than one file
        NumberOfFiles = length(DataFilenames);
    else
        NumberOfFiles = 1;
    end

    for i = 1:NumberOfFiles
        FileInfo(i).DefaultPathname = DefaultPathname;
        if NumberOfFiles > 1
           FileInfo(i).FileName = DataFilenames{1,i};
        else
           FileInfo(i).FileName = DataFilenames;
        end
        
        FileInfo(i).FilePath = strcat(DefaultPathname,'/',FileInfo(i).FileName);
        FileInfo(i).NumberOfFiles = NumberOfFiles;
    end

end