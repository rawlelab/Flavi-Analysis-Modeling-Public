function [] = Start_Kinetic_Schemer_ME(ModelToUse,CurrentInstance,NumberInstances,SavePath)

% - - - - - - - - - - - - - - - - - - - - -
% Start_Kinetic_Schemer_ME('4StateswOffPath',1,1,[])
%
% Input:
% Start_Kinetic_Schemer_ME(ModelToUse,CurrentInstance,NumberInstances,SavePath)
%     ModelToUse = The name of the model which will be run, see
%     Setup_Rate_Constants.m.
% 
%     CurrentInstance = The number of the current instance of Matlab if you
%     are running multiple instances as a crude parallelization. 
% 
%     NumberInstances = The total number of instances of Matlab you are
%     running if performing a crude parallelization. 
% 
%     SavePath = Directory where the output .mat file will be saved

% Output:
% If chosen, the model data will be saved as a .MAT file.

% Original version by Bob Rawle, Kasson Lab, University of Virginia, 2017

% This is the 2024 updated version, with a variety of minor edits and 
% new functionalities. Updates put together by Bob Rawle, Williams College, 
% as well as members of the Rawle Lab, most notably Tasnim Anika, to model 
% DENV VLP hemi-fusion data.
% - - - - - - - - - - - - - - - - - - - - -

tic
% Set up options, including the parameters to scan
    [Options] = Setup_Options();

    if strcmp(Options.SaveData,'y')
        SaveFolderDir = SavePath;
    else
        SaveFolderDir = [];
    end
    
    % Set up larger parameter scan, if chosen
    if ischar(Options.ParameterArray) && strcmp(Options.ParameterArray,'Large')
        Options = Setup_Large_Parameter_Scan(Options,SaveFolderDir);
    end
        
        if isnan(Options.ParameterArray)
            NumberParameterCycles = 1;
        else 
            NumberParameterCycles = size(Options.ParameterArray,1);
        end
        
        % Define parameter range, which may change if you are running
        % multiple instances of Matlab as a crude parallelization 
        if strcmp(Options.Parallel,'y')
            NumCyclesPerInstance = floor(NumberParameterCycles/NumberInstances);
            if CurrentInstance==NumberInstances
                ParameterRange = (CurrentInstance-1)*NumCyclesPerInstance+1:NumberParameterCycles;
            else
                ParameterRange = (CurrentInstance-1)*NumCyclesPerInstance+1:CurrentInstance*NumCyclesPerInstance;
            end
        else 
            ParameterRange = 1:NumberParameterCycles;
        end

% Set up figure handles
    if strcmp(Options.DisplayFigures,'y')
        [FigureHandles] = Setup_Figures(Options);
    else
        FigureHandles = [];
    end

% Record which model we are using
    Options.ModelToUse = ModelToUse;

% Initialize other variables
    CycleCounter = 0;
    NumberPHValues = length(Options.pHValues);
    
% For each set of parameters to scan and pH values, run the simulation and compile the data
    for p = ParameterRange
        % Reset the data to save for each parameter set
            DataToSave = [];
            StateData_Eq = [];
            
        for h = 1:NumberPHValues
            CurrentParameters = Options.ParameterArray(p,:);
            CycleCounter = (p-1)*NumberPHValues+h;
            RateConstantInfo.pH = Options.pHValues(h);
            
            % set up rate constants for the given set of parameters and pH value
            [RateConstantInfo] = Setup_Rate_Constants(CurrentParameters,RateConstantInfo,Options);
            
            % Calculate equilibrated start state for the given model
            % We only need to calculate the equilibrated state once for each parameter set
            if h == 1
                [StateData_Eq,RateConstantInfo] = Solve_Kinetic_Model(RateConstantInfo,Options,'Equilibration');
            end
            
            % Set the starting concentration for the
            % normal round to be the end state data of the equilibration 
               RateConstantInfo.StartingConc = StateData_Eq(:,end);
               RateConstantInfo.StartingConc(RateConstantInfo.FusionState) = 0;

            
            disp(' ');disp(' ');
            disp(strcat(' *** Simulation_',num2str(CycleCounter),'/',num2str(NumberParameterCycles*NumberPHValues),' ***'));                
            disp(strcat('----Params =',num2str(CurrentParameters),'; pH = ',num2str(RateConstantInfo.pH),' -----'));
            
            % Solve the differential equations for the given model
            [StateData,RateConstantInfo] = Solve_Kinetic_Model(RateConstantInfo,Options,'Normal');
                CumX = Options.Time;
                    FuseStateNumber = RateConstantInfo.FusionState;
                CumY = StateData(FuseStateNumber,:);
                CumYNormalized = CumY/max(CumY);
                
            % Record the efficiency value of the first pH value in the
            % sequence, to which we will calculate the normalized efficiency 
            if h == 1
                FirstEfficiency = CumY(end);
            end

            % Calculate the randomness parameter
                [RandomnessParameter, Nmin] = Calculate_Randomness_Parameter(CumY,CumX);
                
            % Plot the data
            if strcmp(Options.DisplayFigures,'y')
                
                set(0,'CurrentFigure',FigureHandles.MainPlot)
                hold on
                
                if strcmp(Options.DisplayNormalizedEfficiencies,'y')
                    EfficiencyToPlot(h) = CumY(end)/FirstEfficiency;
                    plot(CumX,CumY/FirstEfficiency,'o')
                else
                    plot(CumX,CumY,'o')
                    EfficiencyToPlot(h) = CumY(end);
                end

                set(0,'CurrentFigure',FigureHandles.NormalizedPlot)
                hold on
                plot(CumX,CumYNormalized,'o')
                drawnow

                LegendInfo{1,CycleCounter} = strcat('Param=',num2str(CurrentParameters),'; pH=',...
                    num2str(RateConstantInfo.pH),'; Nmin=',num2str(Nmin,'%.2f'));
                
                if h == 1
                    set(0,'CurrentFigure',FigureHandles.EQWindow)
                    clf
                    plot(Options.Time_Eq,StateData_Eq)
                    
                    for State = 1:RateConstantInfo.NumberStates
                        DLegend{1,State} = strcat('State=',num2str(State));
                    end
                    
                    set(0,'CurrentFigure',FigureHandles.EQWindow)
                    legend(DLegend,'Location','best');
                    xlabel('Time');
                    ylabel('State Frequency');
                    title('Equilibration')
                end
            end

            % Compile data to save across pH values
            if strcmp(Options.SaveData,'y')
                DataToSave(h).RateConstantInfo = RateConstantInfo;
                DataToSave(h).CurrentParameters = CurrentParameters;
                DataToSave(h).CDFData.CumX = CumX;
                DataToSave(h).CDFData.CumY = CumY;
                DataToSave(h).CDFData.CumYNormalized = CumYNormalized;
                DataToSave(h).CDFData.RandomnessParameter = RandomnessParameter;
                DataToSave(h).CDFData.Nmin = Nmin;
                DataToSave(h).CDFData.StateData = StateData;
                DataToSave(h).CDFData.Efficiency = CumY(end);
                DataToSave(h).CDFData.EfficiencyNorm = CumY(end)/FirstEfficiency;
                DataToSave(h).HelpfulInfo.PSetNumber = p;
                DataToSave(h).EQData.StateData = StateData_Eq;
                DataToSave(h).EQData.Time = Options.Time_Eq;
            end

        end
        
        % Save data for each parameter set to a separate file
        if strcmp(Options.SaveData,'y')
            save(strcat(SaveFolderDir,'/',Options.FileLabel,'_ParamSet=',num2str(p),'.mat'),'DataToSave')
        end
        
        if strcmp(Options.DisplayFigures,'y')
        % Plot efficiencies
            set(0,'CurrentFigure',FigureHandles.EfficiencyPlot)
            plot(Options.pHValues,EfficiencyToPlot,'o-');
            hold on
            ylim([0 1])
            xlabel('pH');
            ylabel('Efficiency');
        end
    end

    
    if strcmp(Options.DisplayFigures,'y')
        % Put legends on plots
        set(0,'CurrentFigure',FigureHandles.MainPlot)
        legend(LegendInfo,'Location','best');
        xlabel('Time');
        ylabel('Percent Fusion');

        set(0,'CurrentFigure',FigureHandles.NormalizedPlot)
        legend(LegendInfo,'Location','best');
        xlabel('Time');
        ylabel('Normalized Fusion');
    end

    toc
    disp('Thank You, Come Again')

end