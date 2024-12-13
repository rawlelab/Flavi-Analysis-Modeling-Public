function [NumberOfFiles,FileOptions,NumberOfParameters] = Load_Image_Files(Options,varargin)

% Output:
% SaveFolderDir = directory where the analysis files will be saved
% StackFilenames = file names of the image video stacks (should be a stack of .tif)
% DefaultPathname = directory where the image video stacks are located

FileOptions = [];
InputPaths = varargin{1,1};

if ~strcmp(Options.CombineMultipleVideos,'y')
    %First, we load the .tif files.  Should be an image stack.  We'll also
    %set up the save folder.
    
    disp('   All righty. Please select the fusion video file (or metadata file if you are using that).')

    if length(InputPaths) == 1
        
        [StackFilenames, DefaultPathname] = uigetfile('*.*','Select the metadata file',...
            InputPaths{1},'Multiselect', 'on');

        disp("   Great. Now select the location of the save folder...")

        SaveFolderDir = uigetdir(InputPaths{1},'Choose the directory where data folder will be saved');

    elseif length(InputPaths) == 2
        SaveFolderDir = InputPaths{1,2};   
        [StackFilenames, DefaultPathname] = uigetfile('*.*','Select the metadata file',...
            InputPaths{1,1},'Multiselect', 'on');
        
    else
     
        [StackFilenames, DefaultPathname] = uigetfile('*.*', 'Multiselect', 'on');

        disp("    Great. Now select the location of the save folder...")

        SaveFolderDir = uigetdir(DefaultPathname,'Choose the directory where data folder will be saved');

    end

    disp("   Awesome - let's continue!")
    
    %If user has chosen to use a separate finding image (rather than using
    %an image already in the video to be analyzed), have them identify
    %where it is at. Note that this finding image will be used for all
    %files if multiple files are chosen to be analyzed.
    disp("   ...")
    disp("   You selected Options.FrameNumToFindParticles = Other")
    disp("   So, please select the other find image you wish to use...")

    if strcmp(Options.FrameNumToFindParticles,"Other")
        [FindImageFilename, FindFolderPath] = uigetfile('*.*','Select the metadata file',...
            DefaultPathname,'Multiselect', 'on');
        Options.FindImageFilePath = strcat(FindFolderPath,FindImageFilename);
    else
        Options.FindImageFilePath = "Not applicable - didn't use separate find image file";
    end

    disp("   Great - let's move on")

    %Determine the number of files selected by the user
    if iscell(StackFilenames)
        NumberOfFiles = length(StackFilenames);
    else
        NumberOfFiles = 1;
    end
    
else
    SaveFolderDir = InputPaths{1,2};
    for i= 1:Options.NumberOfVideosToCombine
        disp("   Select the metadata file for video #"+num2str(i))
        [StackFilenames{1,i}, DefaultPathnamesToCombine{1,i}] = uigetfile('*.*','Select the metadata file',...
            InputPaths{1,1},'Multiselect', 'on');
    end
    DefaultPathname = DefaultPathnamesToCombine{1,1};
    NumberOfFiles = 1;
    % We call this 1 file because that is what we will ultimately be combining it into
end



    for i= 1:NumberOfFiles     
        CurrentOptions = Options;
        CurrentOptions.DefaultPathname = DefaultPathname;
        CurrentOptions.SaveParentFolder = SaveFolderDir;
        if ~strcmp(Options.CombineMultipleVideos,'y')
            if NumberOfFiles == 1
                CurrentOptions.VideoFilename = StackFilenames;
            else
                CurrentOptions.VideoFilename = StackFilenames{1,i};
            end
        else
            CurrentOptions.VideoFilename = StackFilenames{1,1};
            % We set the VideoFile name as referring to the first video. 
            % That way, if we display the finding image in a later program 
            % (e.g. trace analysis) it won't cause any problems
            
            CurrentOptions.VideoFilenamesToCombine = StackFilenames;
            CurrentOptions.DefaultPathnamesToCombine = DefaultPathnamesToCombine;
        end
              
        if strcmp(Options.ScanParameters,'y')
            [FileOptions,NumberOfParameters] = Setup_Parameter_Scan(FileOptions,i,CurrentOptions);
        else
            FileOptions(i).Parameter(1).Options = CurrentOptions;
            NumberOfParameters = 1;
        end
    end
end