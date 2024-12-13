%Make a parent folder and call each subfolder 'run#', where # is a number. 

RunNumber = 0;
NumberofRepeats = 20;
FolderNameTest = uigetdir('Choose the directory where data folder will be saved');

for i=1:NumberofRepeats
    RunNumber = RunNumber + 1;
    Start_Zika_Cellular_Automaton('OffPath_CK_Mimic',1,1,strcat(FolderNameTest,'/run',num2str(RunNumber)));

end