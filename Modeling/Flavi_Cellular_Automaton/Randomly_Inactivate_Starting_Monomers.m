function [EStates] = Randomly_Inactivate_Starting_Monomers(EStates,NumberVirions,NumberMonomers,FractToInactivate)

    NumMonToInactivePerVirus = round(FractToInactivate*NumberMonomers);
    IdxToInactivate = randi(NumberMonomers,NumberVirions,NumMonToInactivePerVirus);
    
    for i = 1:NumberVirions
        for j = 1:NumMonToInactivePerVirus
            EStates(i,IdxToInactivate(i,j)) = 0.9;
                % Set to E state = 0.9, which should be ignored by
                % everything in the simulation, acting as a "dead" monomer
                % from the get go.
        end
    end

end