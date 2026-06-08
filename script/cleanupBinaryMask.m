function mask = cleanupBinaryMask(mask, minArea, openRadius, closeRadius, fillHoles)
%CLEANUPBINARYMASK Shared morphology cleanup.

mask = logical(mask);

if openRadius > 0
    mask = imopen(mask, strel("disk", openRadius, 0));
end

if closeRadius > 0
    mask = imclose(mask, strel("disk", closeRadius, 0));
end

if fillHoles
    mask = imfill(mask, "holes");
end

if minArea > 0
    mask = bwareaopen(mask, minArea);
end

end

