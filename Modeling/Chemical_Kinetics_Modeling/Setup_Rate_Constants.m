function [RateConstantInfo] = Setup_Rate_Constants(CurrentParameters,RateConstantInfo,Options)
% Choose which model you will be using to set up the rate constant matrix
    switch Options.ModelToUse
        case '4StatesLinear'
            [RateConstantInfo] = Model_linearfourstate(CurrentParameters,RateConstantInfo);
        case '4StateswOffPath'
            [RateConstantInfo] = Model_fourstateoffpath(CurrentParameters,RateConstantInfo);
        case '3StatesLinear'
            [RateConstantInfo] = Model_threestatelinear(CurrentParameters,RateConstantInfo);
        case '3StateswOffPath'
            [RateConstantInfo] = Model_threestateoffpath(CurrentParameters,RateConstantInfo);
        case 'ParallelTest'
            [RateConstantInfo] = Model_parallel(CurrentParameters,RateConstantInfo);
    end    
end

