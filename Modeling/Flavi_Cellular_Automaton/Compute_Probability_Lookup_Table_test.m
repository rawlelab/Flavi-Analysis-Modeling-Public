function [CumProbLookup,ProbLookup] = Compute_Probability_Lookup_Table(k,TimeStep,CoopFactor,Options,SimInput)
    [CumProbLookup,ProbLookup] = Reversible_Trimer_Probability_Table(k,TimeStep,CoopFactor,Options,SimInput);
end

function [CumProbLookup,ProbLookup] = Reversible_Trimer_Probability_Table(k,TimeStep,CoopFactor,Options,SimInput)
% We have 4 conditionals for geometrical states. 1) is the dimer partner in
% or out? This determines whether or not we include the cooperatively
% factor. 2) is it possible to form a trimer (or is the monomer already
% part of a trimer)? 3) is the monomer already in a trimer? 4) is the monomer
% already in a trimer and are there enough nearby trimers to allow fusion? 
% Each of these geometrical states is a yes or no answer, to which the lookup 
% key value is either 1 (yes) or 2 (no)

ProbLookup = cell(2, 2, 2, 2);
    % Probability lookup table, indexed according to geometrical state.
    % ProbLookup(IsDimerPartOut,CanITrimerize,AmIInTrimer,CanIFuse)
    
CumProbLookup = cell(2, 2, 2, 2);
    % cumulative probability lookup table, indexed according to geometrical state.
    % CumProbLookup(IsDimerPartOut,CanITrimerize,AmIInTrimer,CanIFuse)

kOriginal = k;

% Enumerate possibilities which are physically possible (note that not all
% possibilities are physically reasonable, so they will not be computed.
% For example it will never be possible to have CanITrimerize = 2 and CanIFuse = 1
    
GeoStatePossibilities = [1, 1, 1, 1;...
                         1, 1, 1, 2;...
                         1, 1, 2, 2;...
                         1, 2, 2, 2;...
                         2, 1, 1, 1;...
                         2, 1, 1, 2;...
                         2, 1, 2, 2;...
                         2, 2, 2, 2];
    % Each row is enumerated as (IsDimerPartOut,CanITrimerize,AmIInTrimer,CanIFuse)

    for p = 1:size(GeoStatePossibilities,1)
        
%         GeoStatePossibilities(p,:);
        IsDimerPartOut = GeoStatePossibilities(p, 1);
        CanITrimerize = GeoStatePossibilities(p, 2);
        AmIInTrimer = GeoStatePossibilities(p, 3);
        CanIFuse = GeoStatePossibilities(p, 4);
        
        k = kOriginal;
        
        if IsDimerPartOut == 1
            k(1,2) = CoopFactor*k(1,2);
        end

        if CanITrimerize == 2
            k(2,3) = 0;
            k(3,2) = 0;
            
            if strcmp(SimInput.AbortiveTrimer,'y')
                k(2,5) = 0;
                k(5,2) = 0;
            end
        end

        if AmIInTrimer == 1
            %If already in trimer, we don't let the monomer move back more
            %than one state in a single time step (i.e. from 3->2, but not 
            % 3->2->1 in a single step). This is because we also need to
            % disassemble the rest of the trimer and it doesn't seem
            % reasonable to move all of them back to state 1 in a single
            % time step).
            k23 = k(2,3);
            k(2,:) = 0;
            k(2,3) = k23;

        end

        if CanIFuse == 2
            k(3,4) = 0;
        end

        [CumTransMatrix,TransMatrix] = Calculate_Transition_Matrix(k,TimeStep,Options);
        
            ProbLookup{IsDimerPartOut,CanITrimerize,AmIInTrimer,CanIFuse} = TransMatrix;
            CumProbLookup{IsDimerPartOut,CanITrimerize,AmIInTrimer,CanIFuse} = CumTransMatrix;
    end

end

function [CumTransMatrix,TransMatrix] = Calculate_Transition_Matrix(k,TimeStep,Options)

    % Set on diagonal elements of the rate constant matrix to equal the
    % negative sum of all other elements in the row. This will ensure that
    % the probability transition matrix will sum to one across each row.  
    for i = 1:size(k,1)
        k(i,i) = -(sum(k(i,:)));
    end
    
    % Calculate transition probability matrix
    TransMatrix = expm(k .* TimeStep);

    % Check to see if off diagonal probabilities are above the probability cut off
%     Index = eye(size(TransMatrix));
%     if max(TransMatrix(~Index)) >  Options.ProbCutoff 
%         disp('Warning: Probabilities Likely Too High!! Results May Be Unreliable.')
%     end

    % Calculate the cumulative transition matrix, where each element in a
    % row represents the cumulative probability of undergoing any of the previous transitions in the row 
    for i = 1:size(TransMatrix,1)
        for j = 1:size(TransMatrix,2)
            if j == 1
                CumTransMatrix(i,j) = TransMatrix(i,j);
            else
                CumTransMatrix(i,j) = CumTransMatrix(i,j-1) + TransMatrix(i,j);
            end
        end
    end
%     CumTransMatrix
end