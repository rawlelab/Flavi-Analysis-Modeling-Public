function [Options] = Extract_Analysis_Inputs(Options,CurrentAnalysisTextFilePath)
% The script will automatically extract relevant numbers as specified below.
% For example, a typical text might 
% 'find 3 ave 2 tzero 1 start 2 pH 25 foc 365 366 367 689 ignore NaN'. If there are no focus 
% events, then the text should read ' foc NaN'

AnalysisInputsText = extractFileText(CurrentAnalysisTextFilePath);
AnalysisInputsText = char(AnalysisInputsText);

        Key = 'foc';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.FocusFrameNumbers = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
        end

        Key = 'ave';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.FindFramesToAverage = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
        end

        Key = 'pH';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.PHdropFrameNum = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
        end

        Key = 'ignore';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.IgnoreFrameNumbers = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
        end
        
        Key = 'tzero';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.TimeZeroFrameNumber = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
        end

        Key = 'start';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.StartAnalysisFrameNumber = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
        end
        
        Key = 'find';
        IndexOfKey = strfind(AnalysisInputsText, Key);
        if ~isempty(IndexOfKey)
           Options.FrameNumToFindParticles = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
           if isempty(Options.FrameNumToFindParticles)
               Options.FrameNumToFindParticles = "Other";
           end
        end

        if isfield(Options,'ManuallyCorrectFind')
            if strcmp(Options.ManuallyCorrectFind,'y')
                Options.FrameNumToFindParticles  = Options.CorrectFindNumber;
            end
        end

        %If user has chosen to use a separate finding image (rather than using
        %an image already in the video to be analyzed), have them identify
        %where it is at. Note that this finding image will be used for all
        %files if multiple files are chosen to be analyzed.
        if strcmp(Options.FrameNumToFindParticles,"Other")
            disp("...")
            disp("It looks like you opted to choose a finding image that is not in the fusion video. So, please select the finding image...")
            [FindImageFilename, FindFolderPath] = uigetfile('*.*','Select the metadata file',...
                Options.DefaultPathname,'Multiselect', 'on');
            Options.FindImageFilePath = strcat(FindFolderPath,FindImageFilename);

            disp("Good! Let's continue.")
        else
            Options.FindImageFilePath = "Not applicable - didn't use separate find image file";
        end
        
        % If there are multiple videos to combine, then extract their inputs 
        % as well (only need to worry about focus and ignore for all videos 
        % after the first). 
        if strcmp(Options.CombineMultipleVideos,'y')
            
            Key = 'NumFrames';
            IndexOfKey = strfind(AnalysisInputsText, Key);
            if ~isempty(IndexOfKey)
               Options.NumFrames = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
            end
            
            for i= 2:Options.NumberOfVideosToCombine
                CurrentAnalysisTextFilePath = strcat(Options.DefaultPathnamesToCombine{1,i},Options.AnalysisTextFilename);
                AnalysisInputsText = extractFileText(CurrentAnalysisTextFilePath);
                AnalysisInputsText = char(AnalysisInputsText);
                
                OldNumFrames = sum(Options.NumFrames);
                % We sum up the list of frame numbers from the prior videos. We will 
                % use this to adjust the focus and ignore frame numbers to correspond 
                % to their actual positions in the combined video stream
                
                Key = 'NumFrames';
                IndexOfKey = strfind(AnalysisInputsText, Key);
                if ~isempty(IndexOfKey)
                   NewNumFrames = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
                   Options.NumFrames = [Options.NumFrames, NewNumFrames];
                end
                
                Key = 'foc';
                IndexOfKey = strfind(AnalysisInputsText, Key);
                if ~isempty(IndexOfKey)
                   NewFocusFrameNumbers = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
                   Options.FocusFrameNumbers = [Options.FocusFrameNumbers, NewFocusFrameNumbers + OldNumFrames];
                end
                
                Key = 'ignore';
                IndexOfKey = strfind(AnalysisInputsText, Key);
                if ~isempty(IndexOfKey)
                   NewIgnoreFrameNumbers = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
                   Options.IgnoreFrameNumbers = [Options.IgnoreFrameNumbers, NewIgnoreFrameNumbers + OldNumFrames];
                end
                
%                 WOULD HAVE TO FIX THIS BEFORE USING:
%                 Key = 'TimeDelay';
%                 IndexOfKey = strfind(AnalysisInputsText, Key);
%                 if ~isempty(IndexOfKey)
%                    NewTimeDelay = sscanf(AnalysisInputsText(IndexOfKey+length(Key)+1:end), '%i');
%                    Options.TimeDelayBetweenVideos = [Options.TimeDelayBetweenVideos NewTimeDelay];
%                 end
                
            end
        end
            
end