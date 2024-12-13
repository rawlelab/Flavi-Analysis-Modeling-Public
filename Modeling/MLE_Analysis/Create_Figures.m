function [FigureHandles] = Create_Figures(Options)
set(0, 'DefaultAxesFontSize',11)

if strcmp(Options.DisplayOption,'All')
    FigureHandles.LikeCompareWindow = figure(2);
    set(FigureHandles.LikeCompareWindow, 'Position', [681 240 600 300]);
    clf
end

if strcmp(Options.DisplayOption,'All')  || strcmp(Options.DisplayOption,'Max Only')
    Width = 400;
    Height = 300;
    FigureHandles.ExpPlot = figure(1);
    set(FigureHandles.ExpPlot,'Position',[6   479   Width  Height]);
    clf
    
    FigureHandles.ModelPlot= figure(2);
    set(FigureHandles.ModelPlot,'Position',[ 6 50 Width  Height]);
    clf
    
    FigureHandles.Efficiencies = figure(3);
    set(FigureHandles.Efficiencies,'Position',[458   479   Width  Height]);
    clf

    FigureHandles.NormalizedOverlay = figure(4);
    set(FigureHandles.NormalizedOverlay,'Position',[457 99   Width  Height]);
    clf
    
end

if strcmp(Options.Diagnostics,'y')
    FigureHandles.DiagnosticWindow = figure(4);
    set(FigureHandles.DiagnosticWindow,'Position',[458   364   450   341]);
    clf
end

if strcmp(Options.DisplayOption,'Top Models')
    FigureHandles.MasterWindow = figure(1);
    set(FigureHandles.MasterWindow, 'Position', [2 53 1278 652]);
    set(0, 'DefaultAxesFontSize',13)

    NumPlotsX = Options.NumPlotsX;
    NumPlotsY = Options.NumPlotsY;
    
    Gap = [.04,.01];
    MarginsHeight = [.04,.04];
    MarginsWidth = [.03,.02];

    FigureHandles.SubHandles = tight_subplot(NumPlotsY, NumPlotsX, Gap, MarginsHeight, MarginsWidth);
end

end