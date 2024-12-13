function [Options] = Setup_Options_Trace_Analysis(DefaultPathname)

% ==============Options you might change regularly==================
       
    Options.BobStyleSave = 'y';
%         If y, Options.Label will be replaced by part of the filename - see Bob_Style_Save.m for details.
        Options.UseFullFileNameAsLabel = 'y';
        Options.ExtraLabel = '_AnalyzedRecentnew'; %'-Anl8-10';
        % Only relevant if Bob style save is on.
    
    Options.MinImageShow = 350;
    Options.MaxImageShow = 600;
   
%================= Options You Might Change While Optimizing For a Particular Data Type (after consulting Bob) ================
    Options.DisplayFigures = 'y';

    % --------Analysis Parameters--------
    % These parameters determine how the traces will be analyzed, setting 
    % thresholds to decide what is considered a fusion event. They should 
    % be optimized for your particular application; the values listed below 
    % are only suggestions that work well with my data. As different parameters 
    % may be needed for fusion to tethered vesicles or to supported bilayers,
    % they are listed separately as needed.
    % Usually once you have optimized them for a given type of data, you don't
    % need to re-optimize.
    
        Options.TypeofFusionData  = 'TetheredVesicle';
        Options.FusionTrigger = 'pH';
            % What is the trigger for fusion you are looking at. 
            % Options = 'pH' or 'Binding', for Dengue use 'pH' 
            % 230112 Note: Binding hasn't yet been fully tested in this version of the
            % program, so beware if that is what you choose. Better to
            % update to the current binding version in use for Sendai
    
        Options.NoFusionAllowedBeforeTrigger = 'y';
            % This will not allow fusion events to be found by the gradient test 
            % before the fusion trigger (most likely a good idea, as these are probably 
            % spurious events anyway).
        Options.ClipFramesAtEnd = 'n';
            % This will not allow fusion events to be found by the gradient test within a certain number 
            % of frames at the end of the video. Empirically, I have noticed that 
            % very occasionally events are erroneously found within the last couple of 
            % frames, so this is a way to correct that. 'y' OR 'n'
        Options.NumFramesToClip = 2;
            % This is the number of frames from the end of the video in which fusion 
            % events will not be found by the gradient test.
            
            
        if strcmp(Options.TypeofFusionData, 'TetheredVesicle') 
            
            % --------Gradient Test Parameters--------
            Options.RunMedHalfLength = 0; 
                % This is the number of frames on either side which will be used to 
                % calculate the running median trace, which will then be used to calculate 
                % the gradient and other values.
            Options.GradientThreshold = 5; %5;
                % This is the number of standard deviations above which the 
                % gradient must reach (either positive or negative) in order 
                % to be considered a possible fusion event. In the case of tethered 
                % vesicles, the negative value is not used.
                % Zika data = 5
            Options.NumFramesBetweenGradientEvents = 10;
                % This is the number of frames apart below which possible fusion events 
                % identified by the gradient test will be considered the same event. 
            
            % --------Spike Trace Test Parameters--------
            Options.RunMedHalfLengthSpike = 5;
                % This is the number of frames on either side which will be used to 
                % calculate a separate running median trace, which will then be used to 
                % calculate the spike trace. This value should be large relative to 
                % the duration of the spikes which you are trying to detect.
            Options.SpikeThreshold = 5; %5; %10
                % This is the number of standard deviations above which the spike trace 
                % must reach in order to be considered a true spike.
            Options.NumFramesBetweenSpikeEvents = 12; %12
                % This is the number of frames apart below which spike events will be 
                % considered the same event.
                % Abe sendai value = 5
                
            % --------Difference Trace Test Parameters--------
            Options.NumberFramesBackToSubtract = 10;
                % This is the number of frames to subtract backward in order 
                % to create the difference trace.
                % default value = 25
                % Flu TR intensity, 1 = 10
                % Abe sendai value = 5
            Options.DifferenceTraceThresholdPos = 7.5; %7.5
                % This is the number of standard deviations above which the 
                % difference trace must reach in the positive direction in order to be considered a 
                % possible fusion event. 
                %Zika data = 14
                % Flu TR intensity, 4 = 7
                % Flu TR intensity, 4 = 8
                % Flu TR intensity, 8 = 12
                % R18,1 = 8;
                % R18,3 = 8;
                % R18,6 = 10;
                % Abe sendai value = 7.5
            Options.DifferenceTraceThresholdNeg = 7.5; %7.5 %9
                % This is the number of standard deviations above which the 
                % difference trace must reach in the negative direction in order to be considered a 
                % possible fusion event (or be excluded as abnormal in the case
                % of fusion to tethered vesicles).
            Options.ClusterSizePosConsideredFastFusion = 15;
            Options.ClusterSizeNegConsideredFastFusion = 15;
                % This is the number of adjacent frames (clusters) flagged as a fusion event by 
                % the difference trace test below which we will consider them to be a 
                % fast (i.e. normal) fusion event. Separate values are defined for 
                % difference trace values that are positive (i.e. an increase in 
                % fluorescence) or negative (i.e. a decrease in fluorescence). 
                % Note that these values are added to the NumberFramesBackToSubtract 
                % value, since a fluorescence intensity sharp jump will likely have 
                % at least that many adjacent frames which will pass the difference 
                % trace test.
            Options.NumFramesBetweenDifferentClusters = 10;
                % This is the number of frames apart below which possible fusion events 
                % identified by the difference trace test (clusters) will be considered the same event.
                % Abe sendai value = 5
            
        elseif strcmp(Options.TypeofFusionData, 'SLBSelfQuench') 
            % WARNING: This option is not fully set up
            % Note that if this option is chosen, there are additional parameters 
            % that are defined in order to identify the frame in which the virus 
            % docks (i.e. stops moving). These are listed in the 
            % Define_and_Apply_Gradient_Filters.m script. If you are doing this 
            % regularly, you may wish to move them here.
            
            Options.RunMedHalfLength = 0; 
                % Defined above
            Options.GradientThreshold = 4.5;
                % Defined above
            Options.NumFramesBetweenFusionEvents_Gradient = 5;
                % Defined above
            Options.RunMedHalfLengthSpike = 5; 
                % Defined above
            Options.SpikeThreshold = 5;
                % Defined above
            Options.NumFramesBetweenSpikeEvents = 12;
                % Defined above
            
            Options.NumberFramesBackToSubtract = 25;
                % Defined above
            Options.DifferenceTraceThreshold = 9;
                % Defined above        
            Options.ClusterSizePosConsideredFastFusion = 15;
            Options.ClusterSizeNegConsideredFastFusion = 5;
            Options.NumFramesBetweenDifferentClusters = 10;
        else
            disp(' Type of fusion data not specified correctly');
        end        
    
    % --------Debugging/Quick Correct Options (usually don't alter these)--------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Be very careful about changing any of these numbers below. They
        % should all be at default values most likely
    
        Options.FrameToStartAnalysis = 1; %240711 - NOT CURRENTLY WORKING SO LEAVE AT 1
    %         If you want to skip over some frames at the beginning
        Options.FrametoEndAnalysis = NaN; %240711 - NOT CURRENTLY WORKING SO LEAVE AT NaN
            %NaN to indicate length of current trace as frame to end analysis
    
        Options.StartingTraceNumber = 1;
            % If you want to skip to a specific trace number (i.e. for debugging)
        Options.AdditionalFocusFrameNumbers_Shifted = [];
            % e.g. [842:847,901];
            %[] if you don't want to add any additional focus frame numbers
            % NOTE: the numbers you input here are the shifted numbers (shifted to 
            % account for time zero or other frames ignored at the beginning). They 
            % will correspond to the frames as they appear in the traces within this 
            % program, and not necessarily in the original data set in FIJI or whatever  
        Options.AdditionalIgnoreFrameNumbers_Shifted = [];
            % e.g. [842:847,901];
            %[] if you don't want to add any additional ignore frame numbers that were not 
            % specified during the Extract Traces From Video program
            % NOTE: the numbers you input here are the shifted numbers (shifted to 
            % account for time zero or other frames ignored at the beginning). They 
            % will correspond to the frames as they appear in the traces within this 
            % program, and not necessarily in the original data set in FIJI or whatever
        Options.ChangeBindingTime = [];
            % This will change the standard binding time (normally specified during the 
            % Extract Traces From Video program, but added here in case that 
            % number is incorrect and/or you want to play with it).
            % [] If you don't want to change.
        Options.ChangepHNumber = [];
            % This will change the pH drop frame number (normally specified during the 
            % Extract Traces From Video program, but added here in case that 
            % number is incorrect and/or you want to play with it).
            % [] If you don't want to change.
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % --------- Legacy Options You are Unlikely to Change---------
        Options.Label = 'Test'; %Will be overwritten if BobStyleSave = 'y'
            %This is label for the output file
    %     Options.DataLabelSuffix = '-1';
            %This suffix will be added to the end of every datafile
    
        Options.AddPresetOptions = 'n';
        % If choose y, make sure you direct the program to the correct file at
        % the end of this script, as it will overwrite some of the options listed below.
        Options.FrameAllVirusStoppedBy = NaN;
            % This value will not be used if it was already predefined in the
            % raw trace data. It will also not be used if your viruses are not mobile.
    
        if strcmp(Options.AddPresetOptions, 'y')
    %         PresetOptionsDir = '/Users/bobrawle/Matlab/Analyzed data/170302-R18-1,3,6 fus to teth ves/Traces';
    %         [PresetOptionsFile, PresetOptionsDir] = uigetfile('*.m','Select pre-set options .m file',...
    %             char(PresetOptionsDir),'Multiselect', 'off');
    %         run(strcat(PresetOptionsDir,PresetOptionsFile));
            
    %         PresetOptionsAutoChooseFile = '/Users/bobrawle/Matlab/Analyzed data/170329-zika-b160608-w-h-ch3,4-a,t/Traces/ZikaPresetsTA.m';
    %         PresetOptionsAutoChooseFile = '/Users/bobrawle/Matlab/Virus Fusion Scripts/Preset Options/Trace Analysis/R18_2_int4_6.m';
    %         PresetOptionsAutoChooseFile = '/Users/bobrawle/Matlab/Virus Fusion Scripts/Preset Options/Trace Analysis/R18_4_6_int6.m';
    %         PresetOptionsAutoChooseFile = '/Users/bobrawle/Matlab/Virus Fusion Scripts/Preset Options/Trace Analysis/R18_2_int8_10.m';
            PresetOptionsAutoChooseFile = '/Users/bobrawle/Matlab Scripts/Virus Fusion Scripts/Preset Options/Trace Analysis/TR6_int4_6.m';
    %         PresetOptionsAutoChooseFile = '/Users/bobrawle/Matlab/Virus Fusion Scripts/Preset Options/Trace Analysis/TR6_int8_10.m';
            run(PresetOptionsAutoChooseFile);
    end
end