function [FigureHandles] = Setup_Figures(Options)

%     if strcmp(Options.Diagnostics,'y')
%             FigureHandles.DiagnosticWindow = figure(3);
%             set(FigureHandles.DiagnosticWindow,'Position',[848   364   450   341]);
%             clf
%     end
    
%         FigureHandles.BackgroundTraceWindow = figure(4);
%         set(FigureHandles.BackgroundTraceWindow,'Position',[452 -130 450 341]);
        FigureHandles.MainPlot = figure(1);
        set(FigureHandles.MainPlot,'Position',[6   479   400    300]);
        clf
        
        FigureHandles.NormalizedPlot= figure(2);
        set(FigureHandles.NormalizedPlot,'Position',[407   405   400   300]);
        clf
        
        FigureHandles.EQWindow = figure(4);
        set(FigureHandles.EQWindow,'Position',[458   50   350   241]);
        clf
        
        FigureHandles.EfficiencyPlot = figure(5);
        set(FigureHandles.EfficiencyPlot,'Position',[808 405 400 300]);
        clf
end