function Visualize_Top_Models(FileInfo,Options,FigureHandles,TopModelsInfo)
    
% Determine how many files are being analyzed
    TopModelsIndex = TopModelsInfo(:, 1);
    NumberOfFiles = length(TopModelsIndex);
        
% Define variables we will need
    NumPlotsPerFile = Options.NumPlotsPerFile;
    NumPlotRounds = ceil(NumPlotsPerFile*NumberOfFiles/Options.TotalNumPlots);
    IndexCounter = 1;
    
% Visualize plots round by round
    for b = 1:NumPlotRounds
        disp(strcat('Round-', num2str(b),'-of-', num2str(NumPlotRounds)))
        
        if b ~= NumPlotRounds
            CurrentIndexRange = IndexCounter:IndexCounter - 1 + (Options.TotalNumPlots)/NumPlotsPerFile;
            IndexCounter = max(CurrentIndexRange) +1;
        else
            CurrentIndexRange = IndexCounter:NumberOfFiles;
            for d = length(CurrentIndexRange)*NumPlotsPerFile + 1: Options.TotalNumPlots
                set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(d));
                cla
            end
        end
        
        % Load and plot each file in the current range
        PlotCounter = 0;
        for i = CurrentIndexRange
            
            CurrentModelIndex = TopModelsIndex(i);
            
            % Extract KSolver data that we will need
            CurrentFilePath = FileInfo(CurrentModelIndex).FilePath;
            InputData = open(CurrentFilePath);
            DataToSave = InputData.DataToSave;
            NumberpHValues = length(DataToSave);
            CurrentParameters = DataToSave(1).CurrentParameters;
            PSetNumber = DataToSave(1).HelpfulInfo.PSetNumber;
            LegendInfo = [];
            
            % Plot each pH value for the current parameter set
                PlotCounter = PlotCounter + 1;
                set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(PlotCounter))
                cla
                
                for h = 1:NumberpHValues
                    pH = DataToSave(h).SimOutput.pH;
                    Nmin = DataToSave(h).CDFData.Nmin;
                    CumX = DataToSave(h).CDFData.CumX;
                    CumYNormalized = DataToSave(h).CDFData.CumYNormalized;
%                     CumY = DataToSave(h).CDFData.CumY;
                    
                    if strcmp(Options.NormalizeModelEfficiencies,'y')
                        Efficiency = DataToSave(h).CDFData.EfficiencyNorm;
                    else 
                        Efficiency = DataToSave(h).CDFData.Efficiency;
                    end
                    CumY  = CumYNormalized*Efficiency;

                    set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(PlotCounter));
                    hold on
                    plot(CumX,CumYNormalized,'o')
                    drawnow

                    LegendInfo{1,h} = strcat('pH=',num2str(pH),'; Eff=',num2str(Efficiency));
                    
                    pHValuesToPlot(h) = pH;
                    EfficienciesToPlot(h) = Efficiency;
                end

                % Add the legend and title
                set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(PlotCounter));
                legend(LegendInfo,'Location','best');
%                 xlabel('Time');
                xlim([0 340])
%                 ylabel('Normalized Fusion');

                title(strcat('PSet ',num2str(PSetNumber),'; P=',num2str(CurrentParameters)))
                
                % Plot efficiencies, if chosen
                if strcmp(Options.PlotEfficiencies,'y')
                    PlotCounter = PlotCounter + 1;
                    set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(PlotCounter))
                    cla
                    plot(pHValuesToPlot,EfficienciesToPlot,'o-')
                    ylim([0 1])
                    title('Eff vs. pH')
                    drawnow
                end

                if strcmp(Options.PlotEQData,'y')
                    % Plot the equilibrium E state data (assume only one
                    % equilibrium run) in the next window
                        PlotCounter = PlotCounter + 1;
                        set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(PlotCounter))
                        cla

                        % Extract the equilibrium data we need
                        RateConstantInfo = DataToSave(h).RateConstantInfo;
                        StateData_Eq = DataToSave(h).EQData.StateData;
                        Time_Eq = DataToSave(h).EQData.Time;

                        % Plot data
                        plot(Time_Eq,StateData_Eq)

                        for State = 1:RateConstantInfo.NumberStates
                            DLegend{1,State} = strcat('State=',num2str(State));
                        end

                        % Add the legend and title
                        set(FigureHandles.MasterWindow,'CurrentAxes',FigureHandles.SubHandles(PlotCounter))
                        legend(DLegend,'Location','best');
%                         xlabel('Time');
%                         ylabel('EState Frequency');
                end

        end
        
        % Wait for user input to go to next round
        RerunThisRound = 'y';
        while RerunThisRound =='y'
            Prompts = {strcat(num2str(b),'/', num2str(NumPlotRounds),'; Enter To Continue')};
            DefaultInputs = {'Continue'};
            Heading = 'Type q to quit';
            UserAnswer = inputdlg(Prompts,Heading, 1, DefaultInputs, 'on');

            if isempty(UserAnswer)
                % There has been an error, re-run the last round to avoid crash
                RerunThisRound = 'y';
                
            elseif strcmp(UserAnswer{1,1},'q')
                disp('You Chose To Quit')
                ThisWillCauseError
            
            elseif strcmp(UserAnswer{1,1},'Continue')
                % move to next round
                RerunThisRound = 'n';            
            else
                % There has been an error, re-run the last round to avoid crash
                RerunThisRound = 'y';
                
            end
        end
    end
end