function [SimInput] = Offpath_Model(CurrentParameters,SimInput)
    % Hardcoded states for each E protein monomer:
        %1: retracted (starting state)
        %6: extended
        %3: in a trimer
        %4: hemifused
    % You can add other states and create connections between them as you
    % see fit, but don't modify the states above as they are hardcoded into
    % the simulation
    
        
        
        % SCHEMATIC:
        %              1     2(Starting)  <--> 3(pH-Activated) -->  4(HF)
        %                   Λ
        %                   |   
        %                   V 
        %                   5(OffPathway)
        
        
    SimInput.PossibleStates = 1:5;
    SimInput.NumberStates = length(SimInput.PossibleStates);
    SimInput.AbortiveTrimer = 'n'; %'y' or 'n' Whether or not we want to 
    %include abortive trimers. If marked 'n', the model allows monomers to 
    %enter the off-pathway state. If marked 'y', activated monomers must
    %have two adjacent activated monomers (all in state 2) to enter the
    %off-pathway state (State 5).
    SimInput.SingleMonomer = 'n'; %'y' or 'n' Whether to use a single 
    %monomer to model the virion like the CK model. If marked 'y', all 
    %monomers but one are labeled as State 1.1, unable to access other 
    %states.
    
    %Set the Starting State below. 
    SimInput.StartingState = 1;
    
    pH = SimInput.pH;
        HConc = 10^-pH;
    
    % Set up rate constant matrix for the target pH. k(starting state, ending state).
    % All rate constants have time units of seconds^-1. Those multiplied by
    % proton concentration also have units of M^-1.
        k = zeros(SimInput.NumberStates,SimInput.NumberStates);
    
    %Trimerization step
        k23_base = CurrentParameters(1);
        pK_23 = CurrentParameters(2);
    
    %First step (pH-activation)
        k12_base = k23_base*CurrentParameters(8);
        pK_12 = CurrentParameters(9);
    
    %OFFPATHWAY
        k25_base = k23_base;   
        pK_25 = CurrentParameters(4);
        
    %Fusion step 
        k34_base = CurrentParameters(3); %CurrentParameters(5); 
        
    % =========
        
        k(1,2) = k12_base * HConc;      
        k(2,1) = 0; %k12_base * 10^-pK_12;       
      
        k(2,3) = (k23_base/CurrentParameters(6)) * HConc;
        k(3,2) = (k23_base) * 10^-pK_23;
        
        k(3,4) = k34_base/CurrentParameters(7);
           
        k(2,5) = (k25_base/CurrentParameters(5)) * 10^-pK_25; 
%       Makes off-pathway state reversible

        k(5,2) = 0;
        
    
       % Set up rate constant matrix for equilibration run (pH 7.4).
        k_Eq = k;
            pH_Eq = 7.4;
            
%        k_Eq(6,5) = 0;
        %k_Eq(5,2) = 0;
        
%        k_Eq(1,6) = k16_base * 10^-pH_Eq;
        %k_Eq(1,2)=0;
        %k_Eq(2,1)=0;
        
%       k_Eq(6,2) = k62_base * 10^-pH_Eq;
%         k_Eq(2,3) = 0;
%         k_Eq(3,2) = 0;
%         
%         k_Eq(3,4) = 0;
        
    % Record rate constant matrices as simulation inputs
    SimInput.RateConstantMatrix = k;
    SimInput.RateConstantMatrix_Eq = k_Eq;
    
	% Define other parameters which will be used in the simulation
     SimInput.CoopFactor = 1;
 
        % Factor by which probability of a given monomer becoming active 
        % will increase if its dimer pair is already out
    SimInput.MinNumTrimersForFusion = 1;
        % Minimum number of adjacent trimers required for fusion.

end
    