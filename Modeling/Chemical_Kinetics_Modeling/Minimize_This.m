function [MeanNegLogLike] = Minimize_This(CurrentParams,Options,CDFData_Exp,PHIndex,FigureHandles)

NumberPHValues = length(Options.pHValues);

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

    % Compile data to save across pH values
        ModelData(h).RateConstantInfo = RateConstantInfo;
        ModelData(h).CurrentParameters = CurrentParams;
        ModelData(h).CDFData.CumX = CumX;
        ModelData(h).CDFData.CumY = CumY;
        ModelData(h).CDFData.CumYNormalized = CumYNormalized;
        ModelData(h).CDFData.RandomnessParameter = RandomnessParameter;
        ModelData(h).CDFData.Nmin = Nmin;
        ModelData(h).CDFData.StateData = StateData;
        ModelData(h).CDFData.Efficiency = CumY(end);
        ModelData(h).CDFData.EfficiencyNorm = CumY(end)/FirstEfficiency;
%         ModelData(h).HelpfulInfo.PSetNumber = p;
        ModelData(h).EQData.StateData = StateData_Eq;
        ModelData(h).EQData.Time = Options.Time_Eq;
end

% Calculate negative mean log likelihood of the model with the current
% parameters, given our experimental data
    [MeanNegLogLike] = Calculate_Likelihood_Global_Fit(ModelData,CDFData_Exp,PHIndex,Options,FigureHandles);
end