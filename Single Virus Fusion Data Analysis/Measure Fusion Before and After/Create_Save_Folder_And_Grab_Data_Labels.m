function [DataFileLabel,SaveDataPathname] = Create_Save_Folder_And_Grab_Data_Labels(DefaultPathname,...
    SaveParentFolder,Options)

% Information is automatically grabbed from the filenames and/or pathnames to make more 
% informative save folder directory and output analysis filenames.

% WARNING: This script is highly specialized to the way that I format my folder 
% names (which contain much of the information about my experiment). So if you 
% want to use this script, you should modify the appropriate sections below 
% to match the way you format your data.

    Datalabel=  DefaultPathname;
            IndexofSlash = find(Datalabel=='/');
            DataLabelForSaveFolder = Datalabel(IndexofSlash(end- 2) : IndexofSlash(end- 1));
            InfoLabel = Datalabel(IndexofSlash(end- 2) : end);

            FileFolderInfo = Datalabel(IndexofSlash(end-1):end);
            IndexofDash = find(FileFolderInfo == '-');
            
            % Grab information which will be used to label the output analysis file.
            if numel(IndexofDash)==0
                DataFileLabel = 'NoLabel';
            else
                DataFileLabel = FileFolderInfo(2:IndexofDash(1)-1);
            end
            
            DataFileLabel  = strcat(DataFileLabel,'-',Options.DataFileLabel,'-BefAft');
    
% The folder where the output analysis files will be saved is created.
    SaveFolderName = strcat(DataLabelForSaveFolder,'BefAfterData','/');
    SaveDataPathname = strcat(SaveParentFolder,SaveFolderName);
    mkdir(SaveDataPathname);

end