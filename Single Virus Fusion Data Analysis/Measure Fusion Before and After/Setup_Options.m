function [Options] = Setup_Options()

    Options.DataFileLabel = 'test2';
        % This is the label for the output .mat file.
    Options.AutoSaveFolder = 'y';
        % y to automatically create the save folder and datafile label, ignoring
        % what is written above for the data file. If you choose this, make sure
        % that you specify everything correctly in
        % Create_Save_Folder_And_Grab_Data_Labels.m.
        
    Options.Threshold = 120; 
        % This is the number of counts above background which will be used
        % to detect virus particles. You will need to optimize this number 
        % for each set of imaging conditions and/or each data set. An optimal 
        % threshold value has been reached when you are able to see that the
        % program is accurately finding the particles in each image. To avoid
        % bias introduced by the optimization process, you should make sure 
        % that changing the optimal threshold value somewhat doesn't 
        % significantly affect your data. Assuming similar particle 
        % densities/intensities between data sets, and that the same imaging 
        % conditions are used, you shouldn't need to change the threshold 
        % value much if at all between data sets.
    
    Options.FrameNumberLimit = NaN; 
        % Determines the number of frames which will be loaded and analyzed 
        % (for each of the before and after data sets, not the combined total). 
        % Use 'NaN' to indicate no limit (i.e. all frames will be included).        
        % You would likely only use this option if you wanted to quickly 
        % assess how the program is running without having 
        % to wait for an entire set of images to load. Alternatively, you could 
        % use it to exclude frames at the end of the image stack from your analysis.

    Options.FuseDifference = 0.4;
        % This is the fraction by which the intensity of the virus in the after
        % image must be higher than the intensity of the virus before in order to
        % be counted as fused in the initial analysis. This is only for the purposes 
        % of preliminarily determining the percentage of co-localized particles, calculated 
        % in the Find_And_Process_Virus.m script. You can re-visit this by
        % running the output .mat file through
        % Start_Fusion_Efficiency_Plotter.m
        
    Options.MinImageShow = 550;
    Options.MaxImageShow = 1200;    
    Options.MinImage2Show = 550;
    Options.MaxImage2Show = 1200; 
        % These determine the minimum and maximum intensity counts that will 
        % be used to set the contrast for the grayscale images that are displayed.
        % The minimum value will be displayed as black and the maximum value 
        % will be displayed as white. 2 refers to the after color image.

% ---------Parameters Used To Find Particles/Assess Particle 'Goodness'---------
    Options.MinParticleSize = 4;
        % This is the minimum particle size (defined as the number of connected pixels 
        % above the threshold) in order for a particle to be found. 
        % Particles smaller than this size will not be found (i.e. the program 
        % will assume that they are noise).
    Options.MaxParticleSize = 100; 
        % This is the maximum particle size (defined as the number of connected pixels 
        % above the threshold) in order for a particle to be considered "good". 
        % Particles larger than this size will be designated as "bad".
    Options.MaxEccentricity = 0.8;
        % This is the maximum eccentricity that a particle can have in order to still 
        % be considered "good". 0 = perfect circle, 1 = straight line. If the 
        % eccentricity is too high, that may indicate that the particle being 
        % analyzed is actually two diffraction limited particles close together.
        
    Options.MaxPixelShift = 10;
    
    Options.IgnoreAreaNearBigParticles = 'y';
        % 'y' OR 'n'
        % Choose 'y' if you want to ignore the region around bright particles 
        % because the noise nearby from those particles is being incorrectly 
        % identified as other particles. If you choose 'y', then you need 
        % to specify what size is considered "big" below. You will also need 
        % to scale your data to account for the regions which have been ignored, 
        % as this can artificially skew your results lower than they should be.
    Options.MinAreaBig = 200;
        % The number of pixels above threshold for a particle to be considered 
        % "too big", in which case the region around that particle will be 
        % ignored if that option is chosen above.
        
end