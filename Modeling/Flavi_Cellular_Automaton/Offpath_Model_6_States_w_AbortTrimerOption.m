function [SimInput] = Offpath_Model(CurrentParameters,SimInput)
    % Hardcoded states for each E protein monomer:
        %1: retracted (starting state)
        %6: extended
        %3: in a trimer
        %4: hemifused
    % You can add other states and create connections between them as you
    % see fit, but don't modify the states above as they are hardcoded into
    % the simulation
    
    % Additional states added:
        %5 off-pathway state
        %2 extended + membrane-engaged
        
        % SCHEMATIC:
        %   1(F)  <-->  6(E)  <--> 2(I)  <-->  3(T)  -->  4(HF)
        %               |   
        %               V 
        %               5(O)
        
  %CHANGING THIS ONE       
        
    SimInput.PossibleStates = 1:6;
    SimInput.NumberStates = length(SimInput.PossibleStates);
    SimInput.AbortiveTrimer = 'n'; %'y' or 'n' Whether or not we want to 
    %include abortive trimers. If marked 'n', the model allows monomers to 
    %enter the off-pathway state. If marked 'y', activated monomers must
    %have two adjacent activated monomers (all in state 2) to enter the
    %off-pathway state (State 5).
    SimInput.SingleMonomer = 'n';
     SimInput.StartingState = 1;

    pH = SimInput.pH;
        HConc = 10^-pH;
    
    % Set up rate constant matrix for the target pH. k(starting state, ending state).
    % All rate constants have time units of seconds^-1. Those multiplied by
    % proton concentration also have units of M^-1.
        k = zeros(SimInput.NumberStates,SimInput.NumberStates);
    
    %Second step (Insertion)
        k62_base = 1.69e5;
        pK_26 = CurrentParameters(2);
     
    %First step (Extension)
        k16_base = k62_base*CurrentParameters(4);
        pK_16 = CurrentParameters(5);
        
    %OFFPATHWAY
        k65_base = k62_base;   
        pK_65 = CurrentParameters(3);
       
    %Third step (Productive Trimer)
        k23_base = 0.005;
        
        k(1,6) = k16_base * HConc;      %%FREE
        k(6,1) = k16_base * 10^-pK_16;
        
        k(6,2) = (k62_base*CurrentParameters(1)) * HConc; %scan 2-5     %%FREE
        k(2,6) = k62_base * 10^-pK_26;  %%FREE
        
        k(2,3) = k23_base/CurrentParameters(6);  %10-20 scan 10 15 20             %%FREE
        k(3,2) = 0;
        
        k(3,4) = CurrentParameters(7);

        k(6,5) = k65_base * 10^-pK_65;  %%FREE
        
 %currentparam 8 deleted
    
       % Set up rate constant matrix for equilibration run (pH 7.4).
        k_Eq = k;
            pH_Eq = 7.4;
            
        k_Eq(6,5) = 0;
        %k_Eq(5,2) = 0;
        
        k_Eq(1,6) = k16_base * 10^-pH_Eq;
        %k_Eq(1,2)=0;
        %k_Eq(2,1)=0;
        
       k_Eq(6,2) = k62_base * 10^-pH_Eq;
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
    SimInput.MinNumTrimersForFusion = 2;
        % Minimum number of adjacent trimers required for fusion.

end
    