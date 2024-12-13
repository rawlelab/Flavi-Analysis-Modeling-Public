function [Options] = Setup_Options_User_Review()
    
 % ------Easy reference guide for prompt codes-----
        % To enter at prompt: PlotNumber.DesignationCode
        % DesignationCode as follows:
        % .0 = No Fusion
        % .1 = 1 Fuse
        % .12 = 1 Fuse designation is already correct, but wait time is wrong
        % .2 = Abnormal (e.g. slow) fusion
        % .3 = Unbound event (see sharp decrease)
        % .9 = Hard To Classify, Ignore This One

    % ------Options to double check-------
        Options.Label = '-Revd';

    % -------Options you are less likely to change regularly-------
        Options.StartingTraceNumber = input("   Please enter starting trace number (1 is typical): ");
        
        Options.NumPlotsX = 6;
        Options.NumPlotsY = 3;
        Options.TotalNumPlots = Options.NumPlotsX*Options.NumPlotsY;
        Options.SaveAtEachStep = 'y';
        Options.QuickModeNoCorrection = 'n';
    
        Options.FixWaitTime = 'y';
        
        Options.AddPresetOptions = 'n';
        if strcmp(Options.AddPresetOptions, 'y')
            PresetOptionsDir = '/Users/bobrawle/Matlab/Virus Fusion Scripts/Preset Options/User Review Traces';
            [PresetOptionsFile, PresetOptionsDir] = uigetfile('*.m','Select pre-set options .m file',...
                char(PresetOptionsDir),'Multiselect', 'off');
            run(strcat(PresetOptionsDir,PresetOptionsFile));
        end
end