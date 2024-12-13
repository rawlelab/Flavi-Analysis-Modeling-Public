function [StateData,RateConstantInfo] = Solve_Kinetic_Model(RateConstantInfo,Options,SolverSwitch)

    % Depending on whether we are looking at equilibration or not, determine
    % the time points to evaluate and the rate constant matrix
    if strcmp(SolverSwitch,'Equilibration')
        k = RateConstantInfo.RateConstantMatrix_Eq;
        Time = Options.Time_Eq;
    elseif strcmp(SolverSwitch,'Normal')
        k = RateConstantInfo.RateConstantMatrix;
        Time = Options.Time;
    end

    % Evaluate the system of differential equations at each time point
    NumberSteps = length(Time);
    StateData = zeros(RateConstantInfo.NumberStates,NumberSteps);
    StartingConc = RateConstantInfo.StartingConc;
    for Step = 1:NumberSteps
        CurrentTime = Time(Step);
        StateData(:,Step) = expm(k*CurrentTime)*StartingConc;
    end

end