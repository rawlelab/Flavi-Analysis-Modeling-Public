function [] = Evaluate_And_Plot_Fit_Solution(CurrentParams,Options,FigureHandles,CDFData_Exp,PHIndex)

    NumberPHValues = length(Options.pHValues);
    PlotCounter = 0;

    % For the current set of parameters, evaluate the model at each pH value
    for h = 1:NumberPHValues
        RateConstantInfo.pH = Options.pHValues(h);

        % set up rate constants for the given set of parameters and pH value
        [RateConstantInfo] = Setup_Rate_Constants(CurrentParams,RateConstantInfo,Options);

        % Calculate equilibrated start state for the given model
        % We only need to calculate the equilibrated state once for each parameter set
        if h == 1
            [StateData_Eq,RateConstantInfo] = Solve_Kinetic_Model(RateConstantInfo,Options,'Equilibration');
        end

        % Set the starting concentration for the
        % normal round to be the end state data of the equilibration 
           RateConstantInfo.StartingConc = StateData_Eq(:,end);
           RateConstantInfo.StartingConc(RateConstantInfo.FusionState) = 0;

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

        % Display the figures        
            if strcmp(Options.DisplayFigures,'y')
                % Plot the solution
                set(0,'CurrentFigure',FigureHandles.ModelPlot)
                hold on
                
                if strcmp(Options.NormalizeModelEfficiencies,'y')
                    Efficiency_Model(h) = CumY(end)/FirstEfficiency;
                    plot(CumX,CumY/FirstEfficiency,'-')
                      pbaspect([1 1 1])
                else
                    Efficiency_Model(h) = CumY(end);
                    plot(CumX,CumY,'-')
                      pbaspect([1 1 1])
                end

                set(0,'CurrentFigure',FigureHandles.ModelNormalizedPlot)
                hold on
                plot(CumX,CumYNormalized,'-')
                pbaspect([1 1 1])
                drawnow
                
                PlotCounter = PlotCounter + 1;
                LegendInfo_Model{1,h} = strcat('pH=',...
                    num2str(RateConstantInfo.pH),'; Nmin=',num2str(Nmin,'%.2f'),'; Eff=',num2str(CumY(end),'%.2f'));

                % load up the experimental data for the current pH value
                ExpIndex = find(PHIndex ==RateConstantInfo.pH);
                CumX_Exp = CDFData_Exp(ExpIndex).CumX;
                CumYNormalized_Exp = CDFData_Exp(ExpIndex).CumYNorm;
                Efficiency_Exp(h) = CDFData_Exp(ExpIndex).EfficiencyCorrected;
                CumY_Exp = CumYNormalized_Exp*Efficiency_Exp(h);

                % plot experimental data from the current pH value
                set(0,'CurrentFigure',FigureHandles.ExpPlot)
                plot(CumX_Exp,CumY_Exp,'o')
                  pbaspect([1 1 1])
                hold on
                
                    if strcmp(Options.OverlayFitOnData,'y')
                        if strcmp(Options.NormalizeModelEfficiencies,'y')
                            plot(CumX,CumY/FirstEfficiency,'-')
                        else
                            plot(CumX,CumY,'-')
                        end
                        
                    end

                set(0,'CurrentFigure',FigureHandles.ExpNormalizedPlot)
                plot(CumX_Exp,CumYNormalized_Exp,'o')
                  pbaspect([1 1 1])
                hold on
                
                    if strcmp(Options.OverlayFitOnData,'y')
                        plot(CumX,CumYNormalized,'-')
                    end

                PlotCounter = PlotCounter + 1;
                LegendInfo_Exp{1,h} = strcat('pH=',num2str(RateConstantInfo.pH),'; Eff=',num2str(Efficiency_Exp(h),'%.2f'));

            end
    end


    
    if strcmp(Options.DisplayFigures,'y')
        % Make efficiency plot
            set(0,'CurrentFigure',FigureHandles.EfficiencyPlot)
            plot(Options.pHValues,Efficiency_Exp,'o-');
            hold on
            plot(Options.pHValues,Efficiency_Model,'o-');
            ylim([0 1])
            LegendInfo_Efficiency{1,1} = strcat('Exp Data');
            LegendInfo_Efficiency{1,2} = strcat('Model');
            legend(LegendInfo_Efficiency,'Location','best');
            xlabel('pH');
            ylabel('Efficiency');

        % Put legends on plots
        set(0,'CurrentFigure',FigureHandles.ModelPlot)
        legend(LegendInfo_Model,'Location','best');
        xlabel('Time');
        ylabel('Percent Fusion');
        title(strcat('Solution=',num2str(CurrentParams)))

        set(0,'CurrentFigure',FigureHandles.ModelNormalizedPlot)
        legend(LegendInfo_Model,'Location','best');
        xlabel('Time');
        ylabel('Normalized Fusion');
        title(strcat('Solution=',num2str(CurrentParams)))
        
        set(0,'CurrentFigure',FigureHandles.ExpPlot)
        legend(LegendInfo_Exp,'Location','best');
        xlabel('Time');
        ylabel('Percent Fusion');
        title(strcat('ExperimentalData'))

        set(0,'CurrentFigure',FigureHandles.ExpNormalizedPlot)
        legend(LegendInfo_Exp,'Location','best');
        xlabel('Time');
        ylabel('Normalized Fusion');
        title(strcat('ExperimentalData'))
    end

end