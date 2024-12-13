function Options = Setup_Large_Parameter_Scan(Options,SaveFolderDir)
    
% Define individual parameters that you want to scan
    Params{1,1} = [1, 500, 800, 900, 1000, 1100, 1200, 1250, 1300, 1350, 1400, 1500, 1600, 10000];
    Params{1,2} = [6.8, 9];
    Params{1,3} = [6, 9];
    Params{1,4} = [40:10:100] 

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