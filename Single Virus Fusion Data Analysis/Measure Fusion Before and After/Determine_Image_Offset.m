function [Offset] = Determine_Image_Offset(CurrentImage,CurrentImage2,BinaryCurrentImage,Options,...
            ImageWidth,ImageHeight)
        
% Find the offset by applying the binary mask from the first image to the
% 2nd image at various offsets, summing the resulting pixels, and finding
% the offset which yields the maximum value.  

% Note: We are matching up the center quadrant of the 2 images. If the
% offset is very large (more than one 4th of the image in width or height),
% then you will get an error.  

    CenterXCoordinates = round(ImageWidth/4):round(ImageWidth*3/4);
    CenterYCoordinates = round(ImageHeight/4):round(ImageHeight*3/4);
    
    PixelOffsetsToScan = -Options.MaxPixelShift:Options.MaxPixelShift;
    
    BinaryCenterImage = BinaryCurrentImage(CenterYCoordinates,CenterXCoordinates);
    
    LoopNumber =  0;
    
    for XOffset = PixelOffsetsToScan
        for YOffset = PixelOffsetsToScan
            Image2wOffset = CurrentImage2(CenterYCoordinates+YOffset,CenterXCoordinates+XOffset);
            
            LoopNumber = LoopNumber + 1;
            ValueToMaximize(LoopNumber) = sum(Image2wOffset(BinaryCenterImage));
            
            OffsetIndex(LoopNumber, 1:2) = [XOffset,YOffset];
        end
    end

    Offset.X = OffsetIndex(find(ValueToMaximize==max(ValueToMaximize),1), 1);
    Offset.Y = OffsetIndex(find(ValueToMaximize==max(ValueToMaximize),1), 2);
end