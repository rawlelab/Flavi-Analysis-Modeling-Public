function [FigureHandles] = Draw_Lines_on_Plot(FigureHandles,DockingData,FusionData,UniversalData,...
    TraceGradData,Options)

set(0,'CurrentFigure',FigureHandles.TraceWindow)
hold on
LineToPlot = ylim;

if strcmp(Options.TypeofFusionData, 'TetheredVesicle') && strcmp(Options.FusionTrigger, 'Binding') 
    
    if strcmp(FusionData.Designation,'2 Fuse')
        XToPlot = [FusionData.FuseFrameNumbers(1), FusionData.FuseFrameNumbers(1)];
        plot(XToPlot,LineToPlot,'g--')
        XToPlot = [FusionData.FuseFrameNumbers(2), FusionData.FuseFrameNumbers(2)];
        plot(XToPlot,LineToPlot,'k--')
    
        Title = strcat('Bind = ',num2str(UniversalData.StandardBindTime),...
            '; Dock = ',num2str(DockingData.StopFrameNum),...
            '; 1fuse = ', num2str(FusionData.FuseFrameNumbers(1)),...
            '; 2fuse = ', num2str(FusionData.FuseFrameNumbers(2)),...
            '; BindtoF = ', num2str(FusionData.BindtoFusionTime(1)));
        title(Title);
        
    elseif strcmp(FusionData.Designation,'1 Fuse')
        XToPlot = [FusionData.FuseFrameNumbers(1), FusionData.FuseFrameNumbers(1)];
        plot(XToPlot,LineToPlot,'g--')
        Title = strcat('Bind = ',num2str(UniversalData.StandardBindTime),...
            '; Dock = ',num2str(DockingData.StopFrameNum),...
            '; 1fuse = ', num2str(FusionData.FuseFrameNumbers(1)),...
            '; BindtoF = ', num2str(FusionData.BindtoFusionTime(1)));
        title(Title);
        
    elseif strcmp(FusionData.Designation,'No Fusion')
        Title = strcat('Bind = ',num2str(UniversalData.StandardBindTime),...
            '; Dock = ',num2str(DockingData.StopFrameNum));
        title(Title);
        
    elseif strcmp(FusionData.Designation,'Slow')
        TraceRunMedian = TraceGradData.TraceRunMedian;
        DiffPosClusterData = TraceGradData.DiffPosClusterData;
        SlowFusePosFrameNumbers = TraceRunMedian.FrameNumbers(DiffPosClusterData.ClusterStartIndices);
        for d = 1:length(SlowFusePosFrameNumbers)
            XToPlot = [SlowFusePosFrameNumbers(d), SlowFusePosFrameNumbers(d)];
            plot(XToPlot,LineToPlot,'c--')
        end
             
    end

elseif strcmp(Options.TypeofFusionData, 'TetheredVesicle') && strcmp(Options.FusionTrigger, 'pH') 
 
        XToPlot = [UniversalData.pHDropFrameNumber, UniversalData.pHDropFrameNumber];
        plot(XToPlot,LineToPlot,'b--')

    if strcmp(FusionData.Designation,'2 Fuse')
        XToPlot = [FusionData.FuseFrameNumbers(1), FusionData.FuseFrameNumbers(1)];
        plot(XToPlot,LineToPlot,'g--')
        XToPlot = [FusionData.FuseFrameNumbers(2), FusionData.FuseFrameNumbers(2)];
        plot(XToPlot,LineToPlot,'k--')
    
        Title = strcat('pH = ',num2str(UniversalData.pHDropFrameNumber),...
            '; Dock = ',num2str(DockingData.StopFrameNum),...
            '; 1fuse = ', num2str(FusionData.FuseFrameNumbers(1)),...
            '; 2fuse = ', num2str(FusionData.FuseFrameNumbers(2)),...
            '; pHtoF = ', num2str(FusionData.pHtoFusionTime(1)));
        title(Title);
        
    elseif strcmp(FusionData.Designation,'1 Fuse')
        XToPlot = [FusionData.FuseFrameNumbers(1), FusionData.FuseFrameNumbers(1)];
        plot(XToPlot,LineToPlot,'g--')
        Title = strcat('pH = ',num2str(UniversalData.pHDropFrameNumber),...
            '; Dock = ',num2str(DockingData.StopFrameNum),...
            '; 1fuse = ', num2str(FusionData.FuseFrameNumbers(1)),...
            '; pHtoF = ', num2str(FusionData.pHtoFusionTime(1)));
        title(Title);
        
    elseif strcmp(FusionData.Designation,'No Fusion')
        Title = strcat('pH = ',num2str(UniversalData.pHDropFrameNumber),...
            '; Dock = ',num2str(DockingData.StopFrameNum));
        title(Title);
        
    elseif strcmp(FusionData.Designation,'Slow')
        TraceRunMedian = TraceGradData.TraceRunMedian;
        DiffPosClusterData = TraceGradData.DiffPosClusterData;
        SlowFusePosFrameNumbers = TraceRunMedian.FrameNumbers(DiffPosClusterData.ClusterStartIndices);
        for d = 1:length(SlowFusePosFrameNumbers)
            XToPlot = [SlowFusePosFrameNumbers(d), SlowFusePosFrameNumbers(d)];
            plot(XToPlot,LineToPlot,'c--')
        end
             
    end

end




if strcmp(DockingData.IsMobile ,'y')
    XToPlot = [DockingData.StopFrameNum, DockingData.StopFrameNum];
    plot(XToPlot,LineToPlot,'b--')
end
     
hold off
drawnow
end