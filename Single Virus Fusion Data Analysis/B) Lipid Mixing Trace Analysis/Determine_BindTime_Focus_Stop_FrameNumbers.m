function [FrameAllVirusStoppedBy,PHdropFrameNum, StandardBindTime,FocusFrameNumbers,IgnoreFrameNumbers,focusproblems,ignoreproblems] =...
    Determine_BindTime_Focus_Stop_FrameNumbers(OtherImportedData,InputTraceData,Options)

%Determine standard bind time
    if isempty(Options.ChangeBindingTime)
        StandardBindTime = OtherImportedData.StandardBindTime;
        disp('standard bind time defined')
    else
        StandardBindTime = Options.ChangeBindingTime;
        disp('standard bind time re-defined')
    end

%Determine ph drop frame num
    if isempty(Options.ChangepHNumber)
        PHdropFrameNum  = OtherImportedData.PHdropFrameNum;
        disp('used pH frame num imported with traces')
    else
        PHdropFrameNum = Options.ChangepHNumber;
        disp('changed pH frame number to what is shown in options')
    end


%Determine frame number all virus particles have stopped moving
    if isfield(InputTraceData(1), 'FrameAllVirusStoppedBy')
        if isnan(InputTraceData(1).FrameAllVirusStoppedBy)
            FrameAllVirusStoppedBy = Options.FrameAllVirusStoppedBy;
        else
            FrameAllVirusStoppedBy = InputTraceData(1).FrameAllVirusStoppedBy;
        end
    else
%         FrameAllVirusStoppedBy = Options.FrameAllVirusStoppedBy;
        FrameAllVirusStoppedBy = [];
    end

%Determine focus frame nums
    if isfield(InputTraceData(1), 'FocusFrameNumbers_Shifted')
        if isempty(InputTraceData(1).FocusFrameNumbers_Shifted)
            InputTraceData(1).FocusFrameNumbers_Shifted = NaN;
        end
        
        if isnan(InputTraceData(1).FocusFrameNumbers_Shifted(1)) && isempty(Options.AdditionalFocusFrameNumbers_Shifted)
      
            focusproblems = 'n';
            FocusFrameNumbers = NaN;
        else
            focusproblems = 'y';
            if isnan(InputTraceData(1).FocusFrameNumbers_Shifted(1)) && ~isempty(Options.AdditionalFocusFrameNumbers_Shifted)
                FocusFrameNumbers = Options.AdditionalFocusFrameNumbers_Shifted;
            else 
                FocusFrameNumbers = InputTraceData(1).FocusFrameNumbers_Shifted;
                FocusFrameNumbers = [FocusFrameNumbers' Options.AdditionalFocusFrameNumbers_Shifted];
            end
            disp(strcat('user def focus problems, fr = ',num2str(FocusFrameNumbers)));
        end
    else
        focusproblems = 'n';
        FocusFrameNumbers = NaN;
    end

% Extract ignore frame nums. Note that these frame numbers were shifted automatically 
% in the Extract Traces program to account for the time zero or other frames at the 
% beginning that were chopped from the analysis.
    if isempty(InputTraceData(1).IgnoreFrameNumbers_Shifted)
        InputTraceData(1).IgnoreFrameNumbers_Shifted = NaN;
    end

    if isnan(InputTraceData(1).IgnoreFrameNumbers_Shifted(1)) && isempty(Options.AdditionalIgnoreFrameNumbers_Shifted)

        ignoreproblems = 'n';
        IgnoreFrameNumbers = NaN;
    else
        ignoreproblems = 'y';
        if isnan(InputTraceData(1).IgnoreFrameNumbers_Shifted(1)) && ~isempty(Options.AdditionalIgnoreFrameNumbers_Shifted)
            IgnoreFrameNumbers = Options.AdditionalIgnoreFrameNumbers_Shifted;
        else 
            IgnoreFrameNumbers = InputTraceData(1).IgnoreFrameNumbers_Shifted;
            IgnoreFrameNumbers = [IgnoreFrameNumbers' Options.AdditionalIgnoreFrameNumbers_Shifted];
        end
        disp(strcat('user def ignore problems, fr_shifted = ',num2str(IgnoreFrameNumbers)));
    end

end

function PHdropFrameNum = Auto_Find_pH_FrameNumber(OtherImportedData)

ThresholdVector = OtherImportedData.ThresholdsUsed;

%RoughBackVector = ThresholdVector*2^16;
RoughBackVector = OtherImportedData.RoughBack_Med;
    %RoughBackVector = fliplr(RoughBackVector');
    
    RunMedHalfLength = 1; %Num of points on either side, prev value = 5
        StartIdx = RunMedHalfLength + 1;
        EndIdx = length(RoughBackVector)-RunMedHalfLength;
    TraceRunMedian = zeros(length(RoughBackVector),1);
    
    for n = StartIdx:EndIdx
        TraceRunMedian(n) = median(RoughBackVector(n-RunMedHalfLength:n+RunMedHalfLength));
    end
    for n = 1:StartIdx-1
        TraceRunMedian(n) = TraceRunMedian(StartIdx);
    end
    for n = EndIdx+1:length(RoughBackVector)
        TraceRunMedian(n) = TraceRunMedian(EndIdx);
    end
    
 TestWindow = figure(33);
 set(0,'CurrentFigure',TestWindow);
 plot(RoughBackVector);
 hold on
 plot(TraceRunMedian,'r');

GradRoughBack = gradient(TraceRunMedian);

MaxGrad = max(GradRoughBack);
MinGrad = min(GradRoughBack(1:50));

if abs(MinGrad) > 2*std(GradRoughBack);
    PHdropFrameNum = find(gradient(TraceRunMedian)==MinGrad(1));
else
    % Allow the user to choose the pH drop frame number
    Prompts = {' Enter pH drop frame number:',...
        };
    DefaultInputs = {'16',...
        };
    UserDef = inputdlg(Prompts,' Error finding pH drop automatically', 1, DefaultInputs, 'on');

    PHdropFrameNum = str2double(UserDef(1,1)); 
end

if PHdropFrameNum > 1/5 * length(RoughBackVector)
    disp(strcat('PH drop Frame High = ', num2str(PHdropFrameNum)))
end

 title(strcat('SUV Inj Frame = ', num2str(PHdropFrameNum)));
 drawnow
disp(strcat('pH drop Frame = ', num2str(PHdropFrameNum)));

end