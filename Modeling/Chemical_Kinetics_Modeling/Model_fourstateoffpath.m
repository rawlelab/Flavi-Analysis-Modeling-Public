function [RateConstantInfo] = Model_fourstateoffpath(CurrentParameters,RateConstantInfo)

    % Define number of states, etc. 
    RateConstantInfo.NumberStates =  5;
    RateConstantInfo.FusionState =  4;
    %%the fusion state can be whatever state you want it to be 
    
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
            
        k23_base = 170000;
        k12_base = CurrentParameters(2) * 10^28;
            
        
        
            koff_pK2 = 6.53;
            pK_12 = 6.8;
            pK_23 = 6.8;

       
        k(1,2) = k12_base * (HConc^CurrentParameters(1));
        k(2,1)= k12_base * (10^-pK_12);%^CurrentParameters(1);        
        
        k(2,5)= k23_base * 10^-koff_pK2;
        
        k(2,3) = k23_base*HConc;
        k(3,2) = k23_base*10^-pK_23;
        
        k(3,4) = .024;


    
    %Options.TotalTime_Eq 
    % Set up rate constant matrix for equilibration (pH 7.4).
    % for all the ks that you dont want to equib over set to 0
        k_Eq = k;
            HConc_Eq = 10^-7.4;
            
         k_Eq(1,2) = k12_base * (HConc_Eq^CurrentParameters(1));
         k_Eq(2,3) = k23_base*HConc_Eq;
     

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
        StartingConc(1) = 1*(1-CurrentParameters(3));
        RateConstantInfo.StartingConc = StartingConc;

end