function [CorrectedAnalysisData] = FixWaitTime(CorrectedAnalysisData,UniversalData,FigureHandles,TraceNumberIndex)
            
         
            CurrTrace = CorrectedAnalysisData(TraceNumberIndex).Trace_BackSub;
            CurrTimeVector = CorrectedAnalysisData(TraceNumberIndex).TimeVector;
            FusionData = CorrectedAnalysisData(TraceNumberIndex).FusionData;
            PHDropFrameNum = FusionData.pHDropFrameNumber;

            %Correct focus and ignore frames for the current trace
            [CurrTrace_Corrected,~,CurrFrameNums_Corrected] = Correct_Focus_And_Ignore_Problems(CurrTrace,CurrTimeVector,UniversalData);

            %Set up while loop to determine new wait time. Ask user if it
            %looks good. If not, choose again.
            AskUserAgain = 'y';
            while AskUserAgain =='y'

                set(0,'CurrentFigure',FigureHandles.FixWaitPlot)
                cla
    
                plot(CurrFrameNums_Corrected,CurrTrace_Corrected,'b-')
                    % 240711 NOTE TO FUTURE BOB:we plot the corrected frame nums on x axis so
                    % that we will calculate the time to fusion correctly
                    % (since we go by difference in frame numbers). This is
                    % different than the Sendai analysis, which is done
                    % from the time vector with varying time intervals.
                hold on
                title(strcat("Trace ID = ", num2str(TraceNumberIndex)))
    
                LineToPlot = ylim;
                XToPlot = [PHDropFrameNum, PHDropFrameNum];
                plot(XToPlot,LineToPlot,'k--')
    
                [FrameNum,Yval] = ginput(1);
    
                Fuse1FrameNum = round(FrameNum);
    
                %NewWaitTime = CorrectedAnalysisData(TraceNumberIndex).TimeVector(Fuse1FrameNum) - CorrectedAnalysisData(TraceNumberIndex).TimeVector(PHDropFrameNum);
    
                FusionData.FuseFrameNumbers = Fuse1FrameNum;
                FusionData.pHtoFusionNumFrames = Fuse1FrameNum-PHDropFrameNum;
                FusionData.pHtoFusionTime = (Fuse1FrameNum-PHDropFrameNum).*...
                    CorrectedAnalysisData(TraceNumberIndex).FusionData.TimeInterval;
    
                set(0,'CurrentFigure',FigureHandles.FixWaitPlot)
                hold on
                LineToPlot = ylim;
                XToPlot = [FusionData.FuseFrameNumbers(1), FusionData.FuseFrameNumbers(1)];
                plot(XToPlot,LineToPlot,'g--')
                drawnow
    
                title(strcat("pH to Fuse wait time = ", num2str(FusionData.pHtoFusionTime), " sec"))

                Prompts = {'We all good here?'};
                DefaultInputs = {'y'};
                Heading = 'Type n if not';
                UserAnswer = inputdlg(Prompts,Heading, 1, DefaultInputs, 'on');
    
                if strcmp(UserAnswer{1,1},'n')
                    disp('Lets try again then')
                    
                    AskUserAgain = 'y';
                    
                else
                    % It is good so we exit out
                    AskUserAgain = 'n'; 

                    % Change this flag so that the wait time will be
                    % included in CDF program.
                    CorrectedAnalysisData(TraceNumberIndex).ChangedByUser = 'Reviewed, Fuse frame chosen by user';
                end
            end

            
            CorrectedAnalysisData(TraceNumberIndex).FusionData = FusionData;

            
end