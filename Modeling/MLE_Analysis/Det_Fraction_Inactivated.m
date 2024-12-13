function MeanNegLogLike = Det_Fraction_Inactivated(FractionInactivated,ModelData,CDFData_Exp,PHIndex,Options,FigureHandles)

    MeanNegLogLike = Calculate_Likelihood_Global_Fit(ModelData,CDFData_Exp,PHIndex,Options,FigureHandles,FractionInactivated);

end 