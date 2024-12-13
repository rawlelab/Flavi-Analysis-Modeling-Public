function [] = Generate_Test_Data()

PHValues = [5,5.5,6,7];
k_base = 1300;
NumberPoints = 500;
TimeCutoff =  340;
DiagnosticWindow = figure(1);
clf;

for p = 1:length(PHValues)
    pH = PHValues(p);
    k = k_base*10^-pH;
    
    WaitTimeList = exprnd(1/k,NumberPoints,1);
    WaitTimeList = WaitTimeList(WaitTimeList <TimeCutoff);
    
    [CumX, CumY] = Calculate_CDF(WaitTimeList);
    
    % compile data to save
    CDFData(p).SortedpHtoFList = sort(WaitTimeList);
    CDFData(p).pH = pH;
    CDFData(p).EfficiencyBefore = length(WaitTimeList)/NumberPoints;
    CDFData(p).EfficiencyAfter = [];
    CDFData(p).Name = num2str(pH);
    CDFData(p).CumX = CumX;
    CDFData(p).CumY = CumY;
    CDFData(p).CumYNorm = CumY/max(CumY);
    
    set(0,'CurrentFigure',DiagnosticWindow)
    hold on
    plot(CumX,CumY,'o')
%     plot(CumX,CumY/max(CumY),'o')
    drawnow
    
    LegendInfo{1,p} = strcat('pH=',num2str(pH),'; Efficiency=',num2str(length(WaitTimeList)/NumberPoints));
end

set(0,'CurrentFigure',DiagnosticWindow)
legend(LegendInfo,'Location','best');
xlim([0 TimeCutoff])
xlabel('Time');
ylabel('CDF');

save('TestData47.mat','CDFData')

end

function [CumX, CumY] = Calculate_CDF(WaitTimeList)
%Changes WaitTimeList to proportion hemifused over time and makes cum
%dist(Not normalized)

    WaitTimeList = sort(WaitTimeList);
    
    Y = 1:length(WaitTimeList);
    New_Pt = 0;
    
    for i = 1:length(Y)
       if i == length(Y)
            New_Pt = New_Pt +1;
           CumX(New_Pt) = WaitTimeList(i);
           CumY(New_Pt) = Y(i);
           continue
       end
       if WaitTimeList(i) == WaitTimeList(i+1)
           continue
       else
           New_Pt = New_Pt +1;
           CumX(New_Pt) = WaitTimeList(i);
           CumY(New_Pt) = Y(i);
       end
    end
 
end