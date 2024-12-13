function Options = Setup_Large_Parameter_Scan(Options,SaveFolderDir)
    
% Define individual parameters that you want to scan
    Params{1,1} = [1000000];%[7.5e6]; 
    Params{1,2} = [6.8]; %[8.5]
    Params{1,3} = [5.3:0.1:5.8]; %[6.5]
    Params{1,4} = [0]; %[100]
    %Params{1,5} = [0.5]; %[6.8] don't know
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