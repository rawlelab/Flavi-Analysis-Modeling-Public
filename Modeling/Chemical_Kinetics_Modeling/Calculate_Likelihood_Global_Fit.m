function [MeanNegLogLike] = Calculate_Likelihood_Global_Fit(ModelData,CDFData_Exp,PHIndex,Options,FigureHandles)
NumberpHValues = length(ModelData);

for h = 1:NumberpHValues
    % load up the data from the model for the current pH value
    pH_Model = ModelData(h).RateConstantInfo.pH;
    CumX_Model = ModelData(h).CDFData.CumX;
    CumYNormalized_Model = ModelData(h).CDFData.CumYNormalized;
    CumY_Model = ModelData(h).CDFData.CumY;
    
    if strcmp(Options.NormalizeModelEfficiencies,'y')
        Efficiency_Model = ModelData(h).CDFData.EfficiencyNorm;
    else 
        Efficiency_Model = ModelData(h).CDFData.Efficiency;
    end
    
    
        % Record the gating efficiency for the gate test later on
        if strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies')  &&...
                pH_Model == Options.GatePHValues(1)
            GatingEfficiencies(1) = Efficiency_Model;
        elseif strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies')  &&...
                pH_Model == Options.GatePHValues(2)
            GatingEfficiencies(2) = Efficiency_Model;
        end
    
    % calculate the PDF from the model data by taking the derivative of the
    % CDF (which is really just the solution to the differential equations,
    % normalized to 1)
    CDFDerivative = gradient(CumYNormalized_Model)./gradient(CumX_Model);
    PDF_Model = abs(CDFDerivative/trapz(CumX_Model,CDFDerivative));
        %Take abs value to deal with rare occasions when small numbers in
        %tails are slightly negative

        if strcmp(Options.Diagnostics,'y')
            set(0,'CurrentFigure',FigureHandles.DiagnosticWindow)
            plot(CumX_Model,PDF_Model)
        end
    
    % load up the experimental data for the current pH value
    ExpIndex = find(PHIndex ==pH_Model);
    ExpWaitTimes = CDFData_Exp(ExpIndex).SortedpHtoFList;
    ExpEfficiency = CDFData_Exp(ExpIndex).EfficiencyCorrected;
    ExpNumberFused = length(ExpWaitTimes);
    ExpNumberNotFused = round(ExpNumberFused/ExpEfficiency) - ExpNumberFused;
        if ExpNumberNotFused < 0
            ExpNumberNotFused = 0;
        end
    ExpNumberTotal = ExpNumberFused + ExpNumberNotFused;
    
    % calculate the mean log likelihood for the current pH value. The
    % probability density for each experimental data point of a virus that
    % fused is calculated by interpolation of the PDF calculated from the
    % model data.
    ProbDensityFused = interp1(CumX_Model,PDF_Model,ExpWaitTimes);
    if strcmp(Options.LikelihoodMethod,'KineticsAndEfficiencies')
        if Efficiency_Model == 1
            LogLikePH = sum(Options.KineticWeightConstant*log(ProbDensityFused)) + ExpNumberFused*log(Efficiency_Model);
        else 
            LogLikePH = sum(Options.KineticWeightConstant*log(ProbDensityFused)) + ExpNumberFused*log(Efficiency_Model) + ExpNumberNotFused*log(1-Efficiency_Model);
        end
        
        MeanLogLikePH(h) = LogLikePH; %/ExpNumberTotal; add this if you want to equally weight all pH values.
    elseif strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies') 
        LogLikePH = sum(log(ProbDensityFused));
        MeanLogLikePH(h) = LogLikePH/ExpNumberFused;
    end
    
end

    % calculate the sum of all mean log likelihoods for each pH value. Multiply
    % by -1 to yield the negative mean log likelihood for the entire data set.
    MeanNegLogLike = -1*sum(MeanLogLikePH);
    
    
    %Gate test
    if strcmp(Options.LikelihoodMethod,'Kinetics,GatedEfficiencies') 
        if GatingEfficiencies(1) - GatingEfficiencies(2) >= Options.GateValue ...
                && GatingEfficiencies(1) >= Options.HighEffValueCutoff
%             GateTest = 1;
        else
%             GateTest = 0;
            MeanNegLogLike = NaN;
        end
    end
end