function out = segmentWBC(rgb, wbcChannel, config)
%SEGMENTWBC Segment WBC so it can be excluded from the RBC mask.
% Search terms: imbinarize, graythresh, adaptthresh, imopen, imclose.

img = wbcChannel.blurred;

mu = mean(img(:));
sigma = std(img(:));
threshold = min(1, mu + config.wbc.stdMultiplier * sigma);

maskStd = img > threshold;

try
    adaptiveT = adaptthresh(img, 0.55);
    maskAdaptive = imbinarize(img, adaptiveT);
catch
    maskAdaptive = false(size(img));
end

% Prefer recall for WBC removal: combine high-saturation outliers and
% adaptive bright/saturated regions.
mask = maskStd | maskAdaptive;

mask = cleanupBinaryMask(mask, config.wbc.minArea, config.wbc.openRadius, config.wbc.closeRadius, true);

if config.wbc.excludeDilateRadius > 0
    maskForExclusion = imdilate(mask, strel("disk", config.wbc.excludeDilateRadius, 0));
else
    maskForExclusion = mask;
end

out = struct();
out.mask = mask;
out.maskForExclusion = maskForExclusion;
out.channelName = wbcChannel.name;
out.threshold = threshold;
out.meanIntensity = mu;
out.stdIntensity = sigma;
out.notes = "WBC mask combines mean+std threshold and adaptive threshold; recall is preferred over precision.";

end

