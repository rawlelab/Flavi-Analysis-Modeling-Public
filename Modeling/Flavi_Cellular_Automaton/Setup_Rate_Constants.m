function [SimInput] = Setup_Rate_Constants(CurrentParameters,SimInput,Options)
% Choose which model you will be using to set up the rate constant matrix
    switch Options.ModelToUse
        case 'Linear2pHRateContants'
            [SimInput] = Lin2pH_Model(CurrentParameters,SimInput);
        case 'OffPath'
            [SimInput] = Offpath_Model(CurrentParameters,SimInput);
        case 'OffPath_AbortTrimer'
            [SimInput] = Offpath_Model_Abort_Trimer(CurrentParameters,SimInput);
        case 'Linear1pHRateContant'
            [SimInput] = Lin1pH_Model(CurrentParameters,SimInput);
        case 'OffPath_6_States_w_AbortTrimerOption'
            [SimInput] = Offpath_Model_6_States_w_AbortTrimerOption(CurrentParameters,SimInput);
        case 'OffPath_CK_Mimic'
            [SimInput] = Offpath_Model_CK_Mimic(CurrentParameters,SimInput);
    end
    
end