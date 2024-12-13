function [MeanNegLogLike, MeanNegLogLike_Kinetic, MeanNegLogLike_Eff] = Calculate_Likelihood_Global_Fit(ModelData,CDFData_Exp,PHIndex,Options,FigureHandles,FractionInactivated)
NumberpHValues = length(ModelData);

for h = 1:NumberpHValues
    % load up the data from the model for the current pH value
    pH_Model = ModelData(h).SimOutput.pH;
    CumX_Model = ModelData(h).CDFData.CumX;
    FusionWaitTimes_Model = ModelData(h).SimOutput.FusionWaitTimes;
    CumYNormalized_Model = ModelData(h).CDFData.CumYNormalized;
    CumY_Model = ModelData(h).CDFData.CumY;
    
    CumY_Model = CumY_Model*(1-FractionInactivated);

    if h == 1
        MaxEfficiency = ModelData(h).CDFData.Efficiency;
    end
    
    %--SMOOTHING DATA 210408--%
    %Put a debug stop and use the command window and plot() to see how the
    %different smoothing algorithms change our data:
    %CumY_Model = smoothingfunction(CumY_Model);
    
    if strcmp(Options.NormalizeModelEfficiencies,'y')
        Efficiency_Model = ModelData(h).CDFData.Efficiency./MaxEfficiency * (1-FractionInactivated);
    else 
        Efficiency_Model = ModelData(h).CDFData.Efficiency * (1-FractionInactivated)/100;
    end    
    
        % Record the gating efficiency for the gate test later on
        if strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies')  &&...
                pH_Model == Options.GatePHValues(1)
            GatingEfficiencies(1) = Efficiency_Model;
        elseif strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies')  &&...
                pH_Model == Options.GatePHValues(2)
            GatingEfficiencies(2) = Efficiency_Model;
        end

        if strcmp(Options.Diagnostics,'y')
            set(0,'CurrentFigure',FigureHandles.DiagnosticWindow)
            plot(CumX_Model,PDF_Model)
        end
    
    % load up the experimental data for the current pH value
    ExpIndex = find(PHIndex ==pH_Model);
    ExpWaitTimes = CDFData_Exp(ExpIndex).SortedpHtoFList;
    
    % --- Added this on 210408 --- %
    ExpWaitTimes = ExpWaitTimes(ExpWaitTimes <= Options.MaxTimeToAnalyze);
    %We are still testing this, and might change it to be an actual
    %feature in the MLE_Analysis options.
    
    ExpEfficiency = CDFData_Exp(ExpIndex).EfficiencyCorrected;
    ExpNumberFused = length(ExpWaitTimes);
    ExpNumberNotFused = round(ExpNumberFused/ExpEfficiency) - ExpNumberFused;
        if ExpNumberNotFused < 0
            ExpNumberNotFused = 0;
        end
    ExpNumberTotal = ExpNumberFused + ExpNumberNotFused;
    
    % calculate the mean log likelihood for the current pH value. The
    % probability density for each experimental data point of a virus that
    % fused is calculated using the kernel density estimate from the model data
        if ~isempty(FusionWaitTimes_Model)
            [ProbDensityFused] = Estimate_Kernal_Density(FusionWaitTimes_Model,ExpWaitTimes,Options);
        else
            ProbDensityFused = 1;
                % If no fusion events were observed in the model, set the
                % probability density to 1, which will result in a 0 in the log
                % likelihood function below.  
        end

        if strcmp(Options.LikelihoodMethod,'KineticsAndEfficiencies')
            if Efficiency_Model == 1
                LogLikePH = sum(Options.KineticWeightConstant*log(ProbDensityFused)) + ExpNumberFused*log(Efficiency_Model);
                LogLikePH_Kinetic = sum(Options.KineticWeightConstant*log(ProbDensityFused));
                LogLikePH_Eff = ExpNumberFused*log(Efficiency_Model);
            else
                LogLikePH = sum(Options.KineticWeightConstant*log(ProbDensityFused)) + ExpNumberFused*log(Efficiency_Model) + ExpNumberNotFused*log(1-Efficiency_Model);
                LogLikePH_Kinetic = sum(Options.KineticWeightConstant*log(ProbDensityFused));
                LogLikePH_Eff = ExpNumberFused*log(Efficiency_Model) + ExpNumberNotFused*log(1-Efficiency_Model);
                % Note that as Efficiency_Model goes to zero, this will explode to negative infinity
            end
            MeanLogLikePH(h) = LogLikePH; %/ExpNumberTotal;
            MeanLogLikePH_Kinetic(h) = LogLikePH_Kinetic;
            MeanLogLikePH_Eff(h) = LogLikePH_Eff;

        elseif strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies') 
            LogLikePH = sum(log(ProbDensityFused));
            MeanLogLikePH(h) = LogLikePH; %/ExpNumberFused;
        end
    
end

    % calculate the sum of all mean log likelihoods for each pH value. Multiply
    % by -1 to yield the negative mean log likelihood for the entire data set.
    MeanNegLogLike = -1*sum(MeanLogLikePH);
    MeanNegLogLike_Kinetic = -1*sum(MeanLogLikePH_Kinetic);
    MeanNegLogLike_Eff = -1*sum(MeanLogLikePH_Eff);
    
    
    %Gate test
    if strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies') 
        if GatingEfficiencies(1) - GatingEfficiencies(2) >= Options.GateValue ...
                && GatingEfficiencies(1) >= Options.HighEffValueCutoff
        else
            MeanNegLogLike = NaN;
        end
    end
end