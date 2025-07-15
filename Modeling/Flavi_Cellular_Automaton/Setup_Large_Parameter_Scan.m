function Options = Setup_Large_Parameter_Scan(Options,SaveFolderDir)
    
% Define individual parameters that you want to scan (values in paper for off-pathway reversible shown below)
    Params{1,1} = [7.5e6];%[7.5e6]; %ktri
    Params{1,2} = [6.8]; %[8.5] %pK_12
    Params{1,3} = [5.5]; %this gives koff = 25.3 s-1 if param(1) is 8e6. pK_off
    Params{1,4} = [0.12]; %[100] kreturn
    Params{1,5} = [0, 0.1, 0.2, 0.3, 0.4, 0.5]; % Options.FractionEMonomersInactivated
    %Params{1,6} = [5]; %[1] don't know
    %Params{1,7} = [5]; %[0.005]
    %Params{1,8} = [100]; %[0.005]
    %Params{1,9} = [8]; %[0.005]

    
    
    
    
    %Params{1,5} = [.001746];
    
    %%%ADD ADDITIONAL PARAMETERS FOR 6 STATE MODEL
    
% Enumerate all possible combinations of your defined parameters. Note that
% the number of combinations can get quite large quite quickly...
    Options.ParameterArray = allcomb(Params{1,1:size(Params,2)});

    % Save parameter reference file
    if strcmp(Options.SaveData,'y')
        ParameterReference.ParameterArray = Options.ParameterArray;
        ParameterReference.Params = Params;
        save(strcat(SaveFolderDir,'/',Options.FileLabel,';ParameterReference','.mat'),'ParameterReference')
    end
    
end