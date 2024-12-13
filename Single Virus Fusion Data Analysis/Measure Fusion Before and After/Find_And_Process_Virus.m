function [BindingDataToSave, OtherDataToSave] =...
    Find_And_Process_Virus(StackFilename_Before,StackFilename_After,ThresholdInput, ...
    DefaultPath,Options)
   

    StackFilePath_Before = strcat(DefaultPath,StackFilename_Before);
    StackFilePath_After = strcat(DefaultPath,StackFilename_After);

    %The first image in the before stack is read and displayed. A 3D array
    %(ImageStackMatrix) is created which will contain the data for all images in
    %both stacks. The before images are located first, then the after
    %images.
    %ImageStackMatrix is pre-allocated with zeros to make the next
    %for loop faster.
    
    StackInfo = imfinfo(StackFilePath_Before);
    if isnan(Options.FrameNumberLimit)
        NumFrames = length(StackInfo)*2; %Total number of before and after images
    else
        NumFrames = Options.FrameNumberLimit;
    end
        ImageWidth = StackInfo.Width; %in pixels
        ImageHeight = StackInfo.Height;
        BitDepth = StackInfo.BitDepth;
        ImageStackMatrix = zeros(ImageWidth, ImageHeight, NumFrames, 'uint16');
        BWStackMatrix = ImageStackMatrix > 0; %Create a logical stack the same size as the image stack.
        
        %Preallocate threshold vectors as well
        ThresholdToFindViruses = zeros(NumFrames,1);
        RoughBackground = zeros(NumFrames,1);
        %Back_MedMed = zeros(NumFrames,1);
        
        %Set up figures
        [FigureHandles] = Setup_Figures(Options);
        
    %This for loop populates the ImageStackMatrix with the data from each image
    %in both stacks.  The 1st two dimensions are the x,y of the image plane and the 3rd 
    %dimension is the frame number. Before images are odd. After are even.
    ImagePairCounter = 1;
    for b = 1:NumFrames
        
             if rem(b,2) == 1
                 CurrentFrameImage = imread(StackFilePath_Before,ImagePairCounter);
             else 
                 CurrentFrameImage = imread(StackFilePath_After,ImagePairCounter);
                 ImagePairCounter = ImagePairCounter + 1;
             end
            
            ImageStackMatrix(:,:,b) = CurrentFrameImage;
        
    end
    
    for b = 1:NumFrames
        CurrentFrameImage = ImageStackMatrix(:,:,b);
        
        if b == 1
%            Display first image
            set(0,'CurrentFigure',FigureHandles.ImageWindow);
            imshow(ImageStackMatrix(:,:,1), [Options.MinImageShow, Options.MaxImageShow], 'InitialMagnification', 'fit','Border','tight');
            drawnow
        end
        
        %We define the moving threshold which will be used to find Viruses
        %throughout the stream.
        RoughBackground(b) = mean(median(CurrentFrameImage));
        ThresholdToFindViruses(b) = (RoughBackground(b) + ThresholdInput)/2^BitDepth;
        
        %We apply the threshold to create a big logical matrix
        CurrThresh = ThresholdToFindViruses(b);
%         BWStackMatrix(:,:,b) =  CurrentFrameImage >(RoughBackground(b) + ThresholdInput);
        BWStackMatrix(:,:,b) = im2bw(CurrentFrameImage, CurrThresh);
        BWStackMatrix(:,:,b) = bwareaopen(BWStackMatrix(:,:,b), Options.MinParticleSize, 8);
        
        if rem(b,20)==0
            set(0,'CurrentFigure',FigureHandles.CurrentTraceWindow);
            title(strcat('Loading Frame :', num2str(b),'/', num2str(NumFrames)));
            drawnow
        end
        
    end
    
    set(0,'CurrentFigure', FigureHandles.BackgroundTraceWindow);
    hold on
    plot(RoughBackground,'r-')
    title('Background intensity versus frame number');
    
    NumFramesAnalyzed = 0;
    
    
    
    for CurrFrameNum = 1:2:NumFrames
        NumFramesAnalyzed = NumFramesAnalyzed + 1;
        NumberFusedGood = 0;
        NumberFusedTotal = 0;

                CurrentImage2 = ImageStackMatrix(:,:,CurrFrameNum+1);
                CurrentImage = ImageStackMatrix(:,:,CurrFrameNum);
                BinaryCurrentImage = BWStackMatrix(:,:,CurrFrameNum);
            
            set(0,'CurrentFigure',FigureHandles.Image2Window);
            hold off
            imshow(CurrentImage2, [Options.MinImage2Show, Options.MaxImage2Show], 'InitialMagnification', 'fit','Border','tight');
            title('After Image')
            hold on
        
        [Offset] = Determine_Image_Offset(CurrentImage,CurrentImage2,BinaryCurrentImage,Options,...
            ImageWidth,ImageHeight);
        
        if strcmp(Options.IgnoreAreaNearBigParticles,'y')
                [CurrentImage,BinaryCurrentImage] = Remove_Area_Around_Big_Particles(Options,...
                    ImageWidth,ImageHeight,CurrentImage,BinaryCurrentImage,FigureHandles);
        end
        
            NonzeroPixels = CurrentImage(CurrentImage ~= 0);
            NumberPixelsNotBlackedOut = length(NonzeroPixels);
            NumberMicronsNotBlackedOut = NumberPixelsNotBlackedOut*(0.16)^2;
        
        %All of the isolated regions left behind are "virus regions" and will
        %be analyzed.
            VirusComponentArray = bwconncomp(BinaryCurrentImage,8);

        %The properties associated with each virus in the binary image are
        %extracted.
            VirusProperties = regionprops(VirusComponentArray, CurrentImage, 'Centroid',...
                'Eccentricity', 'PixelValues', 'Area','PixelIdxList');
            NumberOfVirusesFound = length(VirusProperties);
            NumberGoodViruses = 0;
            NumberBadViruses = 0;
            
        %Plot the image
            set(0,'CurrentFigure',FigureHandles.ImageWindow);
            hold off
            imshow(CurrentImage, [Options.MinImageShow, Options.MaxImageShow], 'InitialMagnification', 'fit','Border','tight');
            hold on
            
            set(0,'CurrentFigure',FigureHandles.BinaryImageWindow);
            imshow(BinaryCurrentImage, 'InitialMagnification', 'fit','Border','tight');
            drawnow
        
        %Analyze each region
        for n = 1:NumberOfVirusesFound
            CurrentVirusProperties = VirusProperties(n);
            CurrVesX = round(VirusProperties(n).Centroid(1)); 
            CurrVesY = round(VirusProperties(n).Centroid(2));
                CurrentVirusProperties.Centroid = [CurrVesX, CurrVesY];
                
            set(0,'CurrentFigure',FigureHandles.ImageWindow);
            hold off
            title(strcat('Virus :', num2str(n),'/', num2str(NumberOfVirusesFound)));
            drawnow
            hold on
            
            %Apply many tests to see if Virus is good
            [IsVirusGood, CroppedImageProps, CurrentVirusBox, OffsetFrom2DFit, Noise,...
                DidFitWork, CroppedVesImageThresholded, SizeOfSquareAroundCurrVesicle,...
                CurrVesicleEccentricity, NewArea, ReasonVirusFailed] =...
                Simplified_Test_Goodness(CurrentImage,CurrentVirusProperties,BitDepth,...
                CurrThresh, Options.MinParticleSize, Options.MaxEccentricity,ImageWidth, ImageHeight,Options.MaxParticleSize,BinaryCurrentImage);
            
            if strcmp(IsVirusGood,'y')
                LineColor = 'g-';
                NumberGoodViruses = NumberGoodViruses + 1;
                
            elseif strcmp(IsVirusGood,'n')
                LineColor = 'r-';
                NumberBadViruses = NumberBadViruses + 1;
                disp(ReasonVirusFailed)    
            end
                                               
            %Plot a box around the Virus
                CVB = CurrentVirusBox;
                BoxToPlot = [CVB.Bottom,CVB.Left;CVB.Bottom,CVB.Right;CVB.Top,CVB.Right;CVB.Top,CVB.Left;CVB.Bottom,CVB.Left];

                set(0,'CurrentFigure',FigureHandles.ImageWindow);
                plot(BoxToPlot(:,2),BoxToPlot(:,1),LineColor)
                hold on
                drawnow
            
            %Now we grab the intensity of the current virus particle

                CurrentVirusArea = ImageStackMatrix(...
                    CurrentVirusBox.Top:CurrentVirusBox.Bottom,...
                    CurrentVirusBox.Left:CurrentVirusBox.Right,...
                    CurrFrameNum);

                CurrentRawIntensity = sum(sum((CurrentVirusArea)));

                CurrentIntensityBackSub = CurrentRawIntensity -...
                    RoughBackground(CurrFrameNum).*(CurrentVirusBox.Bottom - CurrentVirusBox.Top + 1)^2;
            
                % Now we calculate the intensity in the same region of 
                % interest in the second image.
                
                    CurrentVirusBox2 = CurrentVirusBox;
                    
                    CurrentVirusBox2.Top = CurrentVirusBox2.Top + Offset.Y;
                    CurrentVirusBox2.Bottom = CurrentVirusBox2.Bottom + Offset.Y;
                    CurrentVirusBox2.Left = CurrentVirusBox2.Left + Offset.X;
                    CurrentVirusBox2.Right = CurrentVirusBox2.Right + Offset.X;
                    
                    CVB2 = CurrentVirusBox2;
                    BoxToPlot2 = [CVB2.Bottom,CVB2.Left;CVB2.Bottom,CVB2.Right;CVB2.Top,CVB2.Right;...
                        CVB2.Top,CVB2.Left;CVB2.Bottom,CVB2.Left];
   
                    if CVB2.Bottom >= ImageHeight || ...
                        CVB2.Top <= 1 || ...
                        CVB2.Right >= ImageWidth || ...
                        CVB2.Left <= 1
                    
                        % Don't analyze or plot particles near the edge once offset is applied
                        IsVirusGood = 'n';
                        ReasonVirusFailed = 'Edge2';
                        RoughIntensity2 = NaN;
                        GaussianIntensity2 = NaN;
                        
                    else
                    
                        [IsVirusGood,LineColor,RoughIntensity2,GaussianIntensity2] = Calculate_Intensity_Second_Image(...
                        CurrentImage2,CurrentVirusBox2,RoughBackground,...
                        FigureHandles,BoxToPlot2,LineColor,CurrFrameNum,IsVirusGood);
                    
                        if RoughIntensity2 > CurrentIntensityBackSub + Options.FuseDifference*CurrentIntensityBackSub
                                NumberFusedTotal = NumberFusedTotal +1;
                                if strcmp(IsVirusGood,'y')
                                    LineColor2 = 'y-';
                                    NumberFusedGood = NumberFusedGood +1;
                                end
                        else
                                LineColor2 = 'm-';
                        end
                        
                        if ~strcmp(IsVirusGood,'y')
                            LineColor2 = 'r-';
                        end

                        set(0,'CurrentFigure',FigureHandles.Image2Window);
                        plot(BoxToPlot2(:,2),BoxToPlot2(:,1),LineColor2)
                        hold on
                        drawnow 
                    end                    
                


            %Save the data
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).RawIntensity = CurrentRawIntensity;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).IntensityBackSub = CurrentIntensityBackSub;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).Coordinates = VirusProperties(n).Centroid;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).Area = VirusProperties(n).Area;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).Eccentricity = VirusProperties(n).Eccentricity;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).FullFilePath_Before = StackFilePath_Before;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).StreamFilename_Before = StackFilename_Before;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).FullFilePath_After = StackFilePath_After;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).StreamFilename_After = StackFilename_After;

                BindingDataToSave(NumFramesAnalyzed).VirusData(n).BoxAroundVirus = CurrentVirusBox;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).IsVirusGood = IsVirusGood;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).ReasonVirusFailed = ReasonVirusFailed;
                
                
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).RoughIntensity2 = RoughIntensity2;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).GaussianIntensity2 = GaussianIntensity2;
               
        end
        BindingDataToSave(NumFramesAnalyzed).TotalVirusesBound = NumberOfVirusesFound;
        BindingDataToSave(NumFramesAnalyzed).NumberGoodViruses = NumberGoodViruses
        BindingDataToSave(NumFramesAnalyzed).NumberBadViruses = NumberBadViruses;
        BindingDataToSave(NumFramesAnalyzed).NumberPixelsNotBlackedOut = NumberPixelsNotBlackedOut;
        BindingDataToSave(NumFramesAnalyzed).NumberMicronsNotBlackOut = NumberMicronsNotBlackedOut;
       
        BindingDataToSave(NumFramesAnalyzed).NumberFusedGood = NumberFusedGood;
        BindingDataToSave(NumFramesAnalyzed).NumberFusedTotal = NumberFusedTotal;
        FractionFuseEstimate = NumberFusedGood/NumberGoodViruses
    end
    
    OtherDataToSave.ThresholdsUsed = ThresholdToFindViruses;
    OtherDataToSave.RoughBackground = RoughBackground;
    
end