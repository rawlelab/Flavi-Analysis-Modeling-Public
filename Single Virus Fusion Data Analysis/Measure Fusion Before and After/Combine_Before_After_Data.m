function Combine_Before_After_Data(varargin)
    Label = 'TR14-Outside'
    
    %First, we load the .mat data files.
    if length(varargin) == 1
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed',...
            varargin{1},'Multiselect', 'on');
    elseif length(varargin) == 2
        DefaultPathname = varargin{1,1}; DataFilenames = varargin{1,2};
    else
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed', 'Multiselect', 'on');
    end
    
    if iscell(DataFilenames) 
        NumberFiles = length(DataFilenames);
    else
        NumberFiles = 1;
    end
    
        for i = 1:NumberFiles
            if iscell(DataFilenames) 
                CurrDataFileName = DataFilenames{1,i};
            else
                CurrDataFileName = DataFilenames;
            end
            CurrDataFilePath = strcat(DefaultPathname,CurrDataFileName);
            
            InputData = open(CurrDataFilePath);
            
            NewDataToAdd = InputData.BindingDataToSave;
            if i ~= 1
                PreviousNumber = length(BindingDataToSave);
                NumbertoAdd = length(NewDataToAdd);
                
                BindingDataToSave(PreviousNumber+1:NumbertoAdd+PreviousNumber) = NewDataToAdd;
            else
                BindingDataToSave = NewDataToAdd;
            end
                        
        end
    
    save(strcat(DefaultPathname,Label,'.mat'),'BindingDataToSave');
    
disp('Thank you.  Come Again.')