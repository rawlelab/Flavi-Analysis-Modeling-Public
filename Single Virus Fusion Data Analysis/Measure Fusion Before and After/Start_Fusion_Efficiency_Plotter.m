function [] = Start_Fusion_Efficiency_Plotter(varargin)
close all

IntensityChangeCutoff = 0.40;
        % This is the fraction by which the intensity of the virus in the after
        % image must be higher than the intensity of the virus before in order to
        % be counted as fused in the analysis. 
        % 0.40 chosen as the number at which the negative control gives 2% or less error (error was about 1.97%).
        
NegIntensityChangeCutoff = -10;
    % Viruses with an intensity change lower than this value will be excluded
    % from the analysis - presumably they represent viruses which dislodged
    % during the course of the experiment.  

Options.HistogramIntensityChanges = 'y';
    if strcmp(Options.HistogramIntensityChanges,'y')
        FigureHandles.IntensityChangeWindow = figure(2);
        set(FigureHandles.IntensityChangeWindow,'Position',[472   476   450   300]);
        cla
    end
    
    %First, we load the .mat data files.
    if length(varargin) == 1
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed',...
            varargin{1},'Multiselect', 'on');
    else
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed', 'Multiselect', 'on');
    end

    
    if iscell(DataFilenames) 
        NumberFiles = length(DataFilenames);
    else
        NumberFiles = 1;
    end
    
    for CurrentFileNumber = 1:NumberFiles
        if iscell(DataFilenames) 
            CurrDataFileName = DataFilenames{1,CurrentFileNumber};
        else
            CurrDataFileName = DataFilenames;
        end

        CurrDataFilePath = strcat(DefaultPathname,CurrDataFileName);
        XLabels{CurrentFileNumber,1} = CurrDataFileName(1,1:min(length(CurrDataFileName(1,:)),15));
        
        InputData = open(CurrDataFilePath);
        
        if isfield(InputData,'BindingDataToSave')
            TypeOfInputData = 'BeforeAfter';

            BindingDataToSave = InputData.BindingDataToSave;

            IntensityChangeList = [];
            FusionEfficiencyPerDataSet = [];
            
            for b = 1:length(BindingDataToSave)
                VirusData = BindingDataToSave(b).VirusData;
                CurrentIntensityChangeList = [];
                
                for j = 1:length(VirusData)
                    CurrentVirusData = VirusData(j);
                    if strcmp(CurrentVirusData.IsVirusGood,'y')

                       Color1Intensity = CurrentVirusData.IntensityBackSub;
                       Color2IntensityRough = CurrentVirusData.RoughIntensity2;
%                        Color2IntensityGauss = CurrentVirusData.GaussianIntensity2;
                       IntensityChange = (Color2IntensityRough - Color1Intensity)/Color1Intensity;
                        
                       if IntensityChange > NegIntensityChangeCutoff
                           CurrentIntensityChangeList = [CurrentIntensityChangeList IntensityChange];
                           IntensityChangeList = [IntensityChangeList IntensityChange];
                       end

                    end
                end
                
                NumberVirusesAnalyzedPerDataSet(b) = length(CurrentIntensityChangeList);
                FusionEfficiencyPerDataSet(b) = length(CurrentIntensityChangeList(...
                    CurrentIntensityChangeList>IntensityChangeCutoff))/...
                    NumberVirusesAnalyzedPerDataSet(b);
            end 


            NumberVirusesAnalyzed(CurrentFileNumber) = length(IntensityChangeList);
            FusionEfficiency(CurrentFileNumber) = length(IntensityChangeList(IntensityChangeList>IntensityChangeCutoff))/...
                NumberVirusesAnalyzed(CurrentFileNumber);
            STDFusionEfficiency(CurrentFileNumber) = std(FusionEfficiencyPerDataSet);
            
            % Draw a histogram of intensity changes for current data set
            if strcmp(Options.HistogramIntensityChanges,'y')
                set(0,'CurrentFigure',FigureHandles.IntensityChangeWindow);
                Edges = -2:0.1:5;
                histogram(IntensityChangeList,Edges)
                xlabel('Intensity Change');
                ylabel('Number of Particles');
                drawnow
            end
            
        elseif isfield(InputData,'DataToSave')
            TypeOfInputData = 'TraceAnalyzed';
            
            AnalyzedTraceData = InputData.DataToSave.CombinedAnalyzedTraceData;
            NumberofTraces = length(AnalyzedTraceData);
            NumberFuse1 = 0;
            NumberFuse1ToPlot = 0;
            NumberFuse2 = 0;
            NumberNoFuse = 0;
            NumberSlow = 0;
            NumberOther = 0;

            for k = 1:NumberofTraces
                CurrentFusionData = AnalyzedTraceData(k).FusionData;
                if strcmp(AnalyzedTraceData(k).ChangedByUser,'Incorrect Designation-Not Changed')
                    % The designation is wrong, but has not been corrected, so we will skip it.

                elseif strcmp(CurrentFusionData.Designation,'Strange-Ignore')
                    % This trace was flagged as hard to classify, so we will ignore it
                    NumberOther = NumberOther + 1;

                else
                    if strcmp(CurrentFusionData.Designation,'No Fusion')
                        NumberNoFuse = NumberNoFuse + 1;
                    elseif strcmp(CurrentFusionData.Designation,'1 Fuse')
                        if strcmp(AnalyzedTraceData(k).ChangedByUser,'Reviewed By User') ||...
                                strcmp(AnalyzedTraceData(k).ChangedByUser,'Not analyzed')
                            NumberFuse1 = NumberFuse1 + 1;
                            NumberFuse1ToPlot = NumberFuse1ToPlot + 1;
                        else
                            % We Can't Necessarily Trust The Wait Time
                            NumberFuse1 = NumberFuse1 + 1;
                        end

                    elseif strcmp(CurrentFusionData.Designation,'2 Fuse')
                        NumberFuse2 = NumberFuse2 + 1;
                    elseif strcmp(CurrentFusionData.Designation,'Slow')
                        NumberSlow = NumberSlow + 1;
                    else
                        NumberOther = NumberOther + 1;
                    end
                end
            end

            NumberVirusesAnalyzed(CurrentFileNumber) = NumberFuse1 + NumberFuse2 + NumberNoFuse + NumberSlow;
            FusionEfficiency1(CurrentFileNumber) = NumberFuse1/NumberVirusesAnalyzed(CurrentFileNumber);
            FusionEfficiency(CurrentFileNumber) = (NumberFuse1 + NumberFuse2 + NumberSlow)/NumberVirusesAnalyzed(CurrentFileNumber);
            STDFusionEfficiency(CurrentFileNumber) = 0;
            
        end
        
    end
    
    % Plotting
    
    FigureHandles.MainWindow = figure(1);
    set(FigureHandles.MainWindow,'Position',[6   479   451   300]);
    cla
    
    set(0,'CurrentFigure',FigureHandles.MainWindow);
    
    BarHandle = barwitherr(STDFusionEfficiency, FusionEfficiency);
    % BarHandle(1).BarWidth = 0.5;
    set(gca,'XTickLabel',XLabels)
    ylabel('Efficiency')
    set(BarHandle(1),'FaceColor','y');
    CurrentAxes = gca;
    CurrentAxes.XTickLabelRotation=45;
    
    NumberVirusesAnalyzed
    FusionEfficiency
        
end