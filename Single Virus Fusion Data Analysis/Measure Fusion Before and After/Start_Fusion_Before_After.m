function [] = Start_Fusion_Before_After(DefaultPath,SavePath)
% - - - - - - - - - - - - - - - - - - - - -

% Input:
% Start_Fusion_Before_After(DefaultPath,SavePath), where DefaultPath is the directory to which 
%       the user will be automatically directed to find the image 
%       stacks. Should be two image stacks.  The first 
%       is the before set of images that contains all areas that were imaged. 
%       The second is the after; it should include the same areas in exactly the same order. They must be
%       the same size, obviously. And they should be in the same file
%       folder.
%       After choosing the stacks, the user then chooses the 
%       parent folder where the output analysis files will be saved.  
%       SavePath is the parent folder where the output analysis files will be saved


% Useful info while program is running:
% Color codes for boxes on figures
%   Before image
%       Green = good virion
%       Red = bad virion
%   After image
%       Yellow = fused (fraction intensity change is above your
%       FuseDifference value)
%       Magenta = no fusion (fraction intensity change below)
%       Red = bad virion in 1st image, so we ignore it

% Output:
% A .mat file is created which saves all of the variables in the current 
% workspace. The information about the number of viruses bound, together 
% with the intensity in each color image, will be in the BindingDataToSave 
% structure, as defined in Find_And_Process_Virus.m.

% Originally written by Bob Rawle, Stanford University/UVA as a Postdoc
% (2016-ish) cobbled together from other bits of his code.
% Modified/updated by Bob Rawle, Williams College, Jan 2024

% - - - - - - - - - - - - - - - - - - - - -
close all

%Define which options will be used
    [Options] = Setup_Options();
    Threshold = Options.Threshold;


%Next, we load the .tif files.  Should be two image stacks.  The first 
%is the before set of images. The second is the after.

    disp('---------------------')
    disp('Lets begin shall we?')
    disp('First, select the before image file stack (tiff file)')

    [StackFilename_Before, DefaultPath] = uigetfile('*.*','Select before images',...
        DefaultPath,'Multiselect', 'off');
    
    disp('Good!')
    disp('Now select the after image file stack (tiff file)')
    [StackFilename_After, DefaultPath] = uigetfile('*.*','Select after images',...
        DefaultPath,'Multiselect', 'off');


    disp('Nice work!')
    disp('Now sit back and enjoy the show...')

    % Create the save folder
    if strcmp(Options.AutoSaveFolder,'y')
        [Options.DataFileLabel,SaveDataPathname] = Create_Save_Folder_And_Grab_Data_Labels(DefaultPath,...
            SavePath,Options);
    else
        DataFolderName = strcat('/BefAfterData','/');
        
        SaveDataPathname = strcat(SavePath,DataFolderName);
        mkdir(SaveDataPathname);
    end
        
    % Now we call the function to find the virus particles and extract
    % their fluorescence intensity
    [BindingDataToSave, OtherDataToSave] = ...
        Find_And_Process_Virus(StackFilename_Before,StackFilename_After,Threshold,...
            DefaultPath,Options);

save(strcat(SaveDataPathname,Options.DataFileLabel,'.mat'));

close all
disp('---------------------')
disp ('Thank you.  Come again.')

end