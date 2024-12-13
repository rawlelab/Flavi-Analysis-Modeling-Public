function Plot_Max_Like_PSet(ModelDataMax,FigureHandles,CDFData_Exp,PHIndex,Options,FractionInactivated)
    
    PSetNumberMax = ModelDataMax(1).HelpfulInfo.PSetNumber;
    ParametersMax = ModelDataMax(1).CurrentParameters;
    
    NumberpHValues = length(ModelDataMax);
    PlotCounter = 0;
    
    for h = 1:NumberpHValues
        % load up the data from the model for the current pH value
        pH_Model(h) = ModelDataMax(h).SimOutput.pH;
        CumX_Model = ModelDataMax(h).CDFData.CumX;
        CumYNormalized_Model = ModelDataMax(h).CDFData.CumYNormalized;

        if h == 1
            MaxEfficiency = ModelDataMax(h).CDFData.Efficiency;
        end
        
        if strcmp(Options.NormalizeModelEfficiencies,'y')
            Efficiency_Model(h) = ModelDataMax(h).CDFData.Efficiency./MaxEfficiency * (1-FractionInactivated);
        else 
            Efficiency_Model(h) = ModelDataMax(h).CDFData.Efficiency * (1-FractionInactivated)/100;
        end  

        CumY_Model = CumYNormalized_Model*Efficiency_Model(h);
        
        % plot model data from the current pH value
        if strcmp(Options.CDFDisplayOptions,'Overlay')
            
            PlotCounter = PlotCounter + 1;
            
            set(0,'CurrentFigure',FigureHandles.ExpPlot)
            plot(CumX_Model,CumY_Model,'-')
            pbaspect([1 1 1])
            hold on
            LegendInfo{1,PlotCounter} = strcat('pH=',num2str(pH_Model(h)),'; Model Eff=',num2str(Efficiency_Model(h)));


            set(0,'CurrentFigure',FigureHandles.NormalizedOverlay)
            plot(CumX_Model,CumYNormalized_Model,'-')
            pbaspect([1 1 1])
            hold on
            LegendInfo{1,PlotCounter} = strcat('pH=',num2str(pH_Model(h)),'; Model Eff=',num2str(Efficiency_Model(h)));
        elseif strcmp(Options.CDFDisplayOptions,'Separate')
            set(0,'CurrentFigure',FigureHandles.ModelPlot)
            plot(CumX_Model,CumY_Model,'x')
              pbaspect([1 1 1])
            hold on
            LegendInfo_Model{1,h} = strcat('pH=',num2str(pH_Model(h)),'; Model Eff=',num2str(Efficiency_Model(h)));
        end
        
        %Depending on the dataset, there are either multiple pH values or
        %multiple serotype values. This 'if' statement covers both of those
        %possibilities.
        if strcmp(Options.MultipleSerotypeValues, 'y')
            NumberSerotypeValues = length(CDFData_Exp)
            
                % load up the experimental data for the current pH value
                ExpIndex = find(PHIndex ==pH_Model(h));
                
            for z = 1:length(ExpIndex)
                CumX_Exp = CDFData_Exp(z).CumX;
                CumYNormalized_Exp = CDFData_Exp(z).CumYNorm;
                Efficiency_Exp(h) = CDFData_Exp(z).EfficiencyCorrected;
                CumY_Exp = CumYNormalized_Exp*Efficiency_Exp(h);

                % plot Exp data from the current serotype value
                if strcmp(Options.CDFDisplayOptions,'Overlay')
                    set(0,'CurrentFigure',FigureHandles.ExpPlot)
                    plot(CumX_Exp,CumY_Exp,'o')
                    hold on
                    PlotCounter = PlotCounter + 1;
                    LegendInfo{1,PlotCounter} = strcat('pH=',num2str(pH_Model(h)),'; serotype=',num2str(z),'; Exp Eff=',num2str(Efficiency_Exp(h),'%.2f'));

                elseif strcmp(Options.CDFDisplayOptions,'Separate')
                    set(0,'CurrentFigure',FigureHandles.ExpPlot)
                    plot(CumX_Exp,CumY_Exp,'o')
                    hold on
                    LegendInfo_Exp{1,h} = strcat('pH=',num2str(pH_Model(h)),'; serotype=',num2str(z),'; Exp Eff=',num2str(Efficiency_Exp(h),'%.2f'));
                end
            end    
        else
                % load up the experimental data for the current pH value
                ExpIndex = find(PHIndex ==pH_Model(h));
                CumX_Exp = CDFData_Exp(ExpIndex).CumX;
                CumYNormalized_Exp = CDFData_Exp(ExpIndex).CumYNorm;
                Efficiency_Exp(h) = CDFData_Exp(ExpIndex).EfficiencyCorrected;
                CumY_Exp = CumYNormalized_Exp*Efficiency_Exp(h);

                % plot model data from the current pH value
                if strcmp(Options.CDFDisplayOptions,'Overlay')
                    set(0,'CurrentFigure',FigureHandles.ExpPlot)
                    plot(CumX_Exp,CumY_Exp,'o')
                    hold on
                    PlotCounter = PlotCounter + 1;
                    LegendInfo{1,PlotCounter} = strcat('pH=',num2str(pH_Model(h)),'; Exp Eff=',num2str(Efficiency_Exp(h),'%.2f'));

                    set(0,'CurrentFigure',FigureHandles.NormalizedOverlay)
                    plot(CumX_Exp,CumYNormalized_Exp,'o')
                    hold on
                    LegendInfo{1,PlotCounter} = strcat('pH=',num2str(pH_Model(h)),'; Exp Eff=',num2str(Efficiency_Exp(h),'%.2f'));

                elseif strcmp(Options.CDFDisplayOptions,'Separate')
                    set(0,'CurrentFigure',FigureHandles.ExpPlot)
                    plot(CumX_Exp,CumY_Exp,'o')
                    hold on
                    LegendInfo_Exp{1,h} = strcat('pH=',num2str(pH_Model(h)),'; Exp Eff=',num2str(Efficiency_Exp(h),'%.2f'));
                end
        end
    end
    
    % add legend, etc. the plot
    if strcmp(Options.CDFDisplayOptions,'Overlay')
        set(0,'CurrentFigure',FigureHandles.ExpPlot)
        legend(LegendInfo,'Location','best');
        title(strcat('Max PSet=',num2str(PSetNumberMax),'; P=',num2str(ParametersMax),'; FractionInactivated=',num2str(FractionInactivated)))
        xlim([0 300])
        xlabel('Wait Time (s)')
        ylabel('Normalized Efficiencies')
    elseif strcmp(Options.CDFDisplayOptions,'Separate')
        set(0,'CurrentFigure',FigureHandles.ExpPlot)
        legend(LegendInfo_Exp,'Location','best');
        title(strcat('ExperimentalData'))
        xlim([0 300])
        xlabel('Wait Time (s)')
        
        set(0,'CurrentFigure',FigureHandles.ModelPlot)
        legend(LegendInfo_Model,'Location','best');
        title(strcat('Max PSet=',num2str(PSetNumberMax),'; P=',num2str(ParametersMax)))
        xlim([0 300])
        xlabel('Wait Time (s)')
    end
    
    % Plot the efficiencies
        set(0,'CurrentFigure',FigureHandles.Efficiencies)
        plot(pH_Model,Efficiency_Exp,'o-')
        hold on
        plot(pH_Model,Efficiency_Model,'o-')
        
        LegendInfo_Efficiency{1,1} = strcat('ExpData');
        LegendInfo_Efficiency{1,2} = strcat('Model');
        title('Efficiencies')
        %ylim([0 0.4])
        xlabel('pH')
        ylabel('Efficiency')
        legend(LegendInfo_Efficiency,'Location','best');
    
end