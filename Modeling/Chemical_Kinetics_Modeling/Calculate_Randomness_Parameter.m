function [RandomnessParameter, Nmin] = Calculate_Randomness_Parameter(FusePercent,Time)

    WaitTimeDerivative = gradient(FusePercent)./gradient(Time);
    WaitTimePDF = WaitTimeDerivative/trapz(Time,WaitTimeDerivative);
    MeanWaitTime = trapz(Time,WaitTimePDF.*Time);
    Variance = trapz(Time,WaitTimePDF.*(Time- MeanWaitTime).^2);

    RandomnessParameter = Variance/MeanWaitTime^2;
    Nmin = 1/RandomnessParameter;

    
%     figure
%     hold on
%     plot(Time,WaitTimePDF)

end