function [SimOutput] = Run_Simulation_Engine(HexagonData,Options,SimInput,EQRun)

% Define our starting E states, overall rate constant matrix, etc. depending on whether this is an equilibration run or not
if strcmp(EQRun,'y')
    k = SimInput.RateConstantMatrix_Eq;
    TimeStep = Options.TimeStep_Eq;
%     TotalTime = Options.TotalTime_Eq;
    EStates = SimInput.EStateData.InitEStatesGuess;
else 
    k = SimInput.RateConstantMatrix;
    TimeStep = Options.TimeStep;
    TotalTime = Options.TotalTime;
    EStates = SimInput.EStateData.EquilibratedEStates;
end

% Open Up SimInput for easier reference
    CoopFactor = SimInput.CoopFactor;
    MinNumTrimersForFusion = SimInput.MinNumTrimersForFusion;
    TransCounts = SimInput.EStateData.StateTransitionCounts;
    NumberStates = size(k, 2);

% Open up Options for easier reference
%     TimeStep = CurrentParameters(1);
    NumberVirions = Options.NumberVirions;
    
% Open up the hexagon data for easier reference
    MonomerInfoLibrary = HexagonData.MonomerInfoLibrary;
    DimerReferenceList = HexagonData.DimerReferenceList;
    TrimerReferenceList = HexagonData.TrimerReferenceList;
    TrimerInfoLibrary = HexagonData.TrimerInfoLibrary;
    NumberMonomers = length(MonomerInfoLibrary);
    
% Compute the probability lookup table given the rate constants. If the
% time step is being adaptively changed, determine the time step.  
if ischar(TimeStep) && strcmp(TimeStep,'Adapt')
    [CumProbLookup,ProbLookup,TimeStep] = Det_Time_Step(k,CoopFactor,Options,EQRun,SimInput);
else 
    [CumProbLookup,ProbLookup] = Compute_Probability_Lookup_Table(k,TimeStep,CoopFactor,Options,SimInput);
end

% Specify the number of steps in the simulation
if strcmp(EQRun,'y')
    NumberofSimulationSteps = Options.NumberSteps_Eq;
else
    NumberofSimulationSteps = floor(TotalTime/TimeStep);
end

    
% Set Up a record of the E State matrix, recorded periodically as
% specified by DataHowOften. The first page is the initial guess for
% the equilibration run, and is the equilibrated state at t = 0 for the
% real run.
    if strcmp(EQRun,'y')
        EDataHowOften_Eq = Options.EDataHowOften_Eq;
        EStatesRecord_Eq = zeros(NumberVirions,NumberMonomers,floor(NumberofSimulationSteps/EDataHowOften_Eq)+1);
            EStatesRecord_Eq(:,:,1) = EStates;
    else
        EDataHowOften = Options.EDataHowOften;
        if strcmp(Options.SaveEStateData,'y')
            EStatesRecord = zeros(NumberVirions,NumberMonomers,floor(TotalTime/EDataHowOften)+1);
                EStatesRecord(:,:,1) = EStates;
        else
            EStatesRecord = [];
        end
    end

% Set up other variables which will be needed
    
    if strcmp( EQRun,'y')
        ExistingTrimers = zeros(NumberVirions,NumberMonomers);
            % List of all of the current trimers (by trimer index number) 
            % that exist for each virion at the current time point, as 
            % referenced by the lead monomer index number.
        if strcmp(SimInput.AbortiveTrimer,'y')
            ExistingAbortiveTrimers = zeros(NumberVirions,NumberMonomers);
                % Same for the abortive trimers.
        end
    else
        ExistingTrimers = SimInput.ExistingTrimers;
        
        if strcmp(SimInput.AbortiveTrimer,'y')
            ExistingAbortiveTrimers = SimInput.ExistingAbortiveTrimers;
                % Same for the abortive trimers.
        end
    end
    
    FusionTimes = [];
        % Used to record the waiting times of fusion for each virion
        
% Run the simulation
    for StepNum = 1:NumberofSimulationSteps
        % Make a gigantic matrix of random numbers for all monomers on all
        % viruses at this time point
            DiceMatrix = rand(NumberVirions,NumberMonomers);

        for VirionNum = 1:NumberVirions
            % Check to make sure that this virion hasn't fused already
            if EStates(VirionNum,1) ~= 4 
                % Randomize order in which monomers are simulated
                MonomerOrder = randperm(NumberMonomers);
                
                for MonomerNum = MonomerOrder
                % First we check to make sure we aren't ignoring this
                % monomer (e.g. it is part of a trimer, but is not the lead
                % monomer). If you end up having more ways to ignore, you
                % could change this to rem(EStates(VirionNum,Monomer),1) == 0
                    if rem(EStates(VirionNum,MonomerNum),1) == 0 %EStates(VirionNum,MonomerNum) ~= 3.1
                        % Now we determine the geometrical state of this
                        % monomer. First we check if its dimer partner is already
                        % extended, then we check if it can form a trimer (or if it
                        % is already in a trimer). If it is already in a trimer, we
                        % also determine whether it has enough nearby trimer neighbors
                        % for fusion to occur. This geometrical state will
                        % determine which transition probability matrix we will use
                        % to figure out what this monomer will do next.
                        
                        % By default, we set all of the geometrical state
                        % flags to no (2), and we will flip them to yes (1)
                        % if the right conditionals are met  
                            IsDimerPartOut = 2;
                            CanITrimerize = 2;
                            CanIFuse = 2;
                            
                        % Check if dimer partner exists (i.e. is not index 0), and if so whether it is extended or not
                        DimerPartner = DimerReferenceList(MonomerNum);
                        if DimerPartner ~=0 && EStates(VirionNum,DimerPartner) > 1
                            IsDimerPartOut = 1;
                        end

                        % If the rate constant to form a trimer is not zero
                        % (as might be the case in an equilibrium run), and
                        % if this monomer is not already in a trimer, check to  
                        % see if it has available partners with which it
                        % could form a trimer (either abortive or productive).
                        if k(2,3) ~= 0  && EStates(VirionNum,MonomerNum) ~= 3 && EStates(VirionNum,MonomerNum) ~= 5 && strcmp(SimInput.AbortiveTrimer,'y')...
                                || k(2,3) ~= 0  && EStates(VirionNum,MonomerNum) ~= 3 && strcmp(SimInput.AbortiveTrimer,'n')
                            
                            NumberPossibleTrimers = MonomerInfoLibrary(MonomerNum).NumberPossibleTrimers;
                            % Randomize order in which possible trimer partners are checked
                            OrderToCheck = randperm(NumberPossibleTrimers);
                            for GroupNum = OrderToCheck
                                CandidateTrimerPartners = MonomerInfoLibrary(MonomerNum).PossibleTrimerPairs(GroupNum,:);
                                if EStates(VirionNum,CandidateTrimerPartners(1)) == 2 && ...
                                        EStates(VirionNum,CandidateTrimerPartners(2)) == 2
                                    % Set toggle switch to y to let us know we can trimerize
                                    CanITrimerize = 1;

                                    % Note: We will
                                    % determine below whether or not this trimer forms
                                    % during the current time step. Since the possible
                                    % trimers are checked in a random order, this will not introduce bias.
                                    break
                                end
                            end
                            
                            % Finally, because we are not in state 3, we do
                            % not allow fusion to be possible. This is the
                            % approach to dealing with
                            % otherwise difficult geometrical possibilities 

                        % If we are already in a productive trimer (i.e. in state 3),
                        % determine how many (if any) nearby trimers have also
                        % formed to know whether or not fusion is possible
                        elseif EStates(VirionNum,MonomerNum) == 3
                             CanITrimerize = 1; % By default this monomer can form a trimer because it is already in one

                             CurrTrimerIndex = ExistingTrimers(VirionNum,MonomerNum);
                             NumNearbyTrimersFound = 0;

                             %Keep a running tally of the number of nearby
                             %trimers
                                 for n = 1:TrimerInfoLibrary(CurrTrimerIndex).NumberNearbyTrimers
                                     FindTrimerVector = ExistingTrimers(VirionNum,:) == ...
                                         TrimerInfoLibrary(CurrTrimerIndex).NearbyTrimers(n);
                                     DoesTrimerExist = find(FindTrimerVector,1);
                                     if ~isempty(DoesTrimerExist)
                                         NumNearbyTrimersFound = NumNearbyTrimersFound + 1;
                                     end
                                 end

                             % If there are at least the minimum number of nearby trimers 
                             % available, it is possible for this trimer to initiate fusion
                             % Note: all extended trimers are sampled independently, rather than operating as a group
                             if NumNearbyTrimersFound >= MinNumTrimersForFusion - 1
                                 CanIFuse = 1;
                             end
                             
                        % If we are already in an abortive trimer (i.e. in state 5)
                        % switch CanITrimerize flag to yes (1).
                        elseif EStates(VirionNum,MonomerNum) == 5 && strcmp(SimInput.AbortiveTrimer,'y')
                             CanITrimerize = 1; % By default this monomer can form a trimer because it is already in one
                                 
                             %For the current monomer (because in this loop
                             %we're cycling through each monomer in a 
                             %random order), identifies its neighbor 
                             %monomers that compose the abortive trimer.
                             MonoIndexes = TrimerReferenceList(ExistingAbortiveTrimers(VirionNum,MonomerNum),:);
                             CandidateTrimerPartners(1:2) = MonoIndexes(MonoIndexes ~= MonomerNum);
                                    
                        end

                    % Now we feed the geometrical state and E state information into 
                    % probability lookup table to determine which row of which probability matrix we will use 
                    % Then, we determine which transition occurs for this monomer
                    for NewEState = 1:NumberStates
                        if DiceMatrix(VirionNum,MonomerNum) <= ...
                            CumProbLookup{IsDimerPartOut,CanITrimerize,CanIFuse}(EStates(VirionNum,MonomerNum),NewEState)
                        
                            % Record the transition count
                            TransCounts(EStates(VirionNum,MonomerNum),NewEState) = ...
                                TransCounts(EStates(VirionNum,MonomerNum),NewEState) + 1;
                            
                            % Depending on which transition occurs, we may need to take some additional action
                            if EStates(VirionNum,MonomerNum) == NewEState
                                % We stay in the same state. No change.
                            elseif NewEState == 3
                                 % If the trimer forms, set only this monomer (hereafter called the lead monomer)
                                 % to state 3. The others will be set to state 3.1 (rendering them invisible to the 
                                 % simulation). This ensures that we treat the entire trimer 
                                 % as a group, not oversampling it. If the trimer disassociates, 
                                 % we will set the states of all the participating monomers back to state 2.
                                 EStates(VirionNum,MonomerNum) = 3;
                                 EStates(VirionNum,CandidateTrimerPartners(1)) = 3.1;
                                 EStates(VirionNum,CandidateTrimerPartners(2)) = 3.1;
                                 % Make a note that this trimer exists, referenced by the lead monomer index number
                                 NewTrimer = sort([MonomerNum, CandidateTrimerPartners(1), CandidateTrimerPartners(2)]);
                                 TrimerIndexVector = TrimerReferenceList(:, 1) == NewTrimer(1,1) &...
                                    TrimerReferenceList(:, 2) == NewTrimer(1,2) & TrimerReferenceList(:,3) == NewTrimer(1,3);
                                 NewTrimerIndex = find(TrimerIndexVector,1);
                                 ExistingTrimers(VirionNum,MonomerNum) = NewTrimerIndex;

                            elseif EStates(VirionNum,MonomerNum) == 3 && NewEState ~= 4
                                % The trimer has broken up. Set all trimer partners back to state 2
                                    MonoIndexes = TrimerReferenceList(ExistingTrimers(VirionNum,MonomerNum),:);
                                    MonoIndexes = MonoIndexes(MonoIndexes ~= MonomerNum);
                                    if NewEState == 5 && strcmp(SimInput.AbortiveTrimer,'y')
                                        % We don't allow the simulation to
                                        % hop directly from the trimer
                                        % state (state 3) to the
                                        % off-pathway state (state 5) if
                                        % the off-pathway is an abortive
                                        % trimer. This would assume that
                                        % the trimer broke up and reformed
                                        % into an abortive trimer in a
                                        % single time step, and the
                                        % calculations aren't set up that
                                        % way. This should be a rare
                                        % occurrence anyway.
                                        EStates(VirionNum,MonomerNum) = 2;

                                        % We also correct the transition
                                        % counts
                                        TransCounts(EStates(VirionNum,MonomerNum),NewEState) = ...
                                            TransCounts(EStates(VirionNum,MonomerNum),NewEState) - 1;
                                        TransCounts(EStates(VirionNum,MonomerNum),2) = ...
                                            TransCounts(EStates(VirionNum,MonomerNum),2) + 1;
                                    else
                                        EStates(VirionNum,MonomerNum) = NewEState;
                                    end
                                    EStates(VirionNum,MonoIndexes(1)) = 2;
                                    EStates(VirionNum,MonoIndexes(2)) = 2;
                                    
                                % Remove existing trimer index so it won't
                                % show up as an existing trimer
                                    ExistingTrimers(VirionNum,MonomerNum) = 0;
                                     
                            elseif NewEState == 5 && strcmp(SimInput.AbortiveTrimer,'y')
                                 % If an abortive trimer forms, set only this monomer (hereafter called the lead monomer)
                                 % to state 5. The others will be set to state 5.1 (rendering them invisible to the 
                                 % simulation). This ensures that we treat the entire trimer 
                                 % as a group, not oversampling it. If the trimer disassociates, 
                                 % we will set the states of all the participating monomers back to state 2.
                                 EStates(VirionNum,MonomerNum) = 5;
                                 EStates(VirionNum,CandidateTrimerPartners(1)) = 5.1;
                                 EStates(VirionNum,CandidateTrimerPartners(2)) = 5.1;
                                 
                                 % Make a note that this abortive trimer exists, referenced by the lead monomer index number
                                 NewAbortTrimer = sort([MonomerNum, CandidateTrimerPartners(1), CandidateTrimerPartners(2)]);
                                 TrimerIndexVector = TrimerReferenceList(:, 1) == NewAbortTrimer(1,1) &...
                                    TrimerReferenceList(:, 2) == NewAbortTrimer(1,2) & TrimerReferenceList(:,3) == NewAbortTrimer(1,3);
                                 NewTrimerIndex = find(TrimerIndexVector,1);
                                 ExistingAbortiveTrimers(VirionNum,MonomerNum) = NewTrimerIndex;

                            elseif EStates(VirionNum,MonomerNum) == 5 &&...
                                    strcmp(SimInput.AbortiveTrimer,'y')
                                % The abortive trimer has broken up. Set all trimer partners back to state 2
                                    MonoIndexes = TrimerReferenceList(ExistingAbortiveTrimers(VirionNum,MonomerNum),:);
                                    MonoIndexes = MonoIndexes(MonoIndexes ~= MonomerNum);
                                    if NewEState == 3
                                        % Similar to above, we don't allow hopping
                                        % from state 5 to state 3 in a
                                        % single time step b/c how we
                                        % account for the partners gets
                                        % funny. This should be a very rare
                                        % occurrence anyway.
                                        EStates(VirionNum,MonomerNum) = 2;

                                        % We also correct the transition
                                        % counts
                                        TransCounts(EStates(VirionNum,MonomerNum),NewEState) = ...
                                            TransCounts(EStates(VirionNum,MonomerNum),NewEState) - 1;
                                        TransCounts(EStates(VirionNum,MonomerNum),2) = ...
                                            TransCounts(EStates(VirionNum,MonomerNum),2) + 1;
                                    else
                                        EStates(VirionNum,MonomerNum) = NewEState;
                                    end
                                    EStates(VirionNum,MonoIndexes(1)) = 2;
                                    EStates(VirionNum,MonoIndexes(2)) = 2;
                                    
                                % Remove existing trimer index so it won't
                                % show up as an existing trimer
                                    ExistingAbortiveTrimers(VirionNum,MonomerNum) = 0;
                                   
                            elseif NewEState == 4
                                % We have fused! Mark all monomers within the current virus as fused
                                EStates(VirionNum,:) = 4;
                                    % Record fusion data
                                     FusionWaitingTime = StepNum*TimeStep;
                                     FusionTimes = [FusionTimes,FusionWaitingTime];
                            else
                                % Change the E state of the current monomer
                                EStates(VirionNum,MonomerNum) = NewEState;
                            end
                            
                            % Exit the for loop checking which E state we transition to
                            break
                        end
                    end
                    
                    end
                end
            end
        end

        % Check to see if we should record EState data. If so, do it.
        if strcmp( EQRun,'y')
            if rem(StepNum,EDataHowOften_Eq) == 0
               EStatesRecord_Eq(:,:,(StepNum/EDataHowOften_Eq)+1) = EStates;
            end
        else 
            if strcmp(Options.SaveEStateData,'y')
                if rem(StepNum*TimeStep,EDataHowOften) == 0
                   EStatesRecord(:,:,(StepNum*TimeStep/EDataHowOften)+1) = EStates;
                end
            end
        end
    end

% Compile the simulation output data
    SimOutput = SimInput;
    
    if strcmp( EQRun,'y')
        SimOutput.ProbLookup_Eq = ProbLookup;
        SimOutput.CumProbLookup_Eq = CumProbLookup;
        SimOutput.EStateData.StateTransitionCounts_Eq = TransCounts;
        SimOutput.EStateData.EStatesRecord_Eq = EStatesRecord_Eq;
            TimeVectorForERecord = 1:size(EStatesRecord_Eq,3);
            TimeVectorForERecord = (TimeVectorForERecord - max(TimeVectorForERecord))*EDataHowOften_Eq;
        SimOutput.EStateData.TimeVector_Eq = TimeVectorForERecord;
        SimOutput.ExistingTrimers = ExistingTrimers;
        
        %Record the existing Abortive Trimers data
        if strcmp(SimInput.AbortiveTrimer,'y')
            SimOutput.ExistingAbortiveTrimers = ExistingAbortiveTrimers;
        end
        
    else
        SimOutput.ProbLookup = ProbLookup;
        SimOutput.CumProbLookup = CumProbLookup;
        SimOutput.EStateData.EStatesRecord = EStatesRecord;
        SimOutput.EStateData.StateTransitionCounts = TransCounts;
        if strcmp(Options.SaveEStateData,'y')
            TimeVectorForERecord = 1:size(EStatesRecord,3);
            TimeVectorForERecord = (TimeVectorForERecord - 1)*EDataHowOften;
            SimOutput.EStateData.TimeVector = TimeVectorForERecord;
        else
            SimOutput.EStateData.TimeVector = [];
        end
        SimOutput.FusionWaitTimes = FusionTimes;
    end
   
end