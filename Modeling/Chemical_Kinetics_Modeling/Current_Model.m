function [RateConstantInfo] = Current_Model(CurrentParameters,RateConstantInfo)

    
    % Define number of states, etc. 
    RateConstantInfo.NumberStates =  5;
    RateConstantInfo.FusionState =  4;
    StartingState = 1;
    
    % Set up rate constant matrix for the target pH. k(starting state, ending state).
    % All rate constants have time units of seconds^-1. Those multiplied by
    % proton concentration also have units of M^-1.
    % Note: this is actually the transposition of the rate constant matrix
    % which will be used to solve the system of differential equations,
    % however I think it is more intuitive to set up the matrix this way,
    % so we will just transpose it below.
        pH = RateConstantInfo.pH;
            HConc = 10^-pH;
        
        k = zeros(RateConstantInfo.NumberStates,RateConstantInfo.NumberStates);
        
%         k12_base = CurrentParameters(1);
%         k12_base = 700000;
            pK_12 = 7;
%         k23_base = k12_base/100;
%         k23_base = 9000;
        k23_base = CurrentParameters(1);
        k12_base = k23_base*100;
            pK_23 = 8;
% 
        k(1,2) = k12_base(1) * HConc;
        k(2,3) = k23_base(1) * HConc;
%         k(2,3) = 1e-2;
% %         k(2,6) = k(2,3)/2;
        k(3,4) = 2e-2;
%         k(3,4) = CurrentParameters(2);
%         k(3,4) = k23_base(1) * HConc;
%         k(2,5) = k23_base*10^-5.7;
        k(2,5) = k23_base*10^-CurrentParameters(2);
%         k(3,5) = k23_base*10^- 7.4;
        
        k(2,1)= k12_base * 10^-pK_12;
        k(3,2) = k23_base * 10^-pK_23;
%         k(5,2) = k(2,5)*1e-3;
%         k(3,4) = 1;         
        
%     if pH == 6.9
%         k
%     end
    % Set up rate constant matrix for equilibration (pH 7.4).
        k_Eq = k;
            pH_Eq = 7.4;
        k_Eq(1,2) = k12_base * 10^-pH_Eq;
%         k_Eq(2,3) = k23_base * 10^-pH_Eq;
%         k_Eq(1,2) = 0;
        k_Eq(2,3) = 0;
        k_Eq(3,2) = 0;
        k_Eq(3,4) = 0;
        k_Eq(2,5) = 0;
%         
%         k_Eq = zeros(RateConstantInfo.NumberStates,RateConstantInfo.NumberStates);
    % Law of mass action, make sure that on diagonal elements equal
    % negative sum of all other elements in the row 
        for i = 1:size(k,1)
            k(i,i) = -(sum(k(i,:)));
        end

        for i = 1:size(k_Eq,1)
            k_Eq(i,i) = -(sum(k_Eq(i,:)));
        end

            
    % Record rate constant matrices as simulation inputs. Note: we
    % transpose the matrices in order to set up the system of differential
    % equations properly
        RateConstantInfo.RateConstantMatrix = k';
        RateConstantInfo.RateConstantMatrix_Eq = k_Eq';
    
    % Assume starting concentration (before
    % equilibration) is everything in state 1.
        StartingConc = zeros(RateConstantInfo.NumberStates,1);
        StartingConc(StartingState) = 1;
        RateConstantInfo.StartingConc = StartingConc;

end