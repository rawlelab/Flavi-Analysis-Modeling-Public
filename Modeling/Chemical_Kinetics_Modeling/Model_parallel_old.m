function [RateConstantInfo] = Model_parallel(CurrentParameters,RateConstantInfo)
    
    % Define number of states, etc. 
    RateConstantInfo.NumberStates =  5;
    RateConstantInfo.FusionState =  3;
    StartingState = 1;
    ParallelState = 5;
    
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
        
        k12_base = CurrentParameters(1);
            pK_12 = 8;
% 
        k(1,2) = k12_base(1) * HConc;
        k(2,1) = k12_base * 10^-pK_12;

        k(2,3) = 2e-2;

        k(1,4) = k12_base*10^-CurrentParameters(2);
        
        k(5,3) = 1e-2;
        
        k(1,5) = .5e-3;
        k(5,1) = .5e-3;
        
        % Set up rate constant matrix for equilibration (pH 7.4).
        k_Eq = k;
            pH_Eq = 7.4;

        k_Eq(1,2) = 0;
        k_Eq(2,1) = 0;
        k_Eq(2,3) = 0;
        k_Eq(1,4) = 0;
        k_Eq(5,3) = 0;
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

            
    % Record rate constant matrices as solver inputs. Note: we
    % transpose the matrices in order to set up the system of differential
    % equations properly
        RateConstantInfo.RateConstantMatrix = k';
        RateConstantInfo.RateConstantMatrix_Eq = k_Eq';
    
    % Set starting concentration
        StartingConc = zeros(RateConstantInfo.NumberStates,1);
        StartingConc(ParallelState) = 0.175;
        StartingConc(StartingState) = 1 - StartingConc(ParallelState);
        RateConstantInfo.StartingConc = StartingConc;

end