close all;
clear;

% Addpath of stlread
addpath('STLRead/')

% Read the stl
stlFileName = 'Fleece_hole_trial.stl';
[F, V, ~] = stlread(stlFileName);

% Read the image and preprocess it
img = imread('first_frame.png');

% Rotate image to match stl
img = rot90(img);
img = flip(img ,2);
img = flip(img ,1);

% Mask out the background
[binaryImage, img] = extract_fleece(img);

% Extract largest blob from image
binaryImage = bwareafilt(binaryImage, 1);

% Save Mask for later
mask = binaryImage;

% Mask out the background
img = image_filter(img, binaryImage);

% Convert the image to grayscale if it's not already
grayImg = rgb2gray(img);

% Enhance Image to make it easier to find edges
grayImg = imadjust(grayImg);

%% Vector Direction of all image

% Calculate gradient vectors using Sobel filters
[Gx, Gy] = imgradientxy(double(grayImg));

% Calculate the size of the gradient image
[height, width] = size(Gx);

% Set the window size for averaging (3x(3x3))
windowSize = 3;

% Initialize matrices for averaged gradient values
avgGx = zeros(floor(height/windowSize), floor(width/windowSize));
avgGy = zeros(floor(height/windowSize), floor(width/windowSize));

% Calculate average gradient values within the window for each 3x3 section
for i = 1:windowSize:height
    for j = 1:windowSize:width
        % Calculate window boundaries for the 3x3 section
        rowStart = i;
        rowEnd = min(i + windowSize - 1, height);
        colStart = j;
        colEnd = min(j + windowSize - 1, width);

        % Extract window of gradient values for the 3x3 section
        windowGx = Gx(rowStart:rowEnd, colStart:colEnd);
        windowGy = Gy(rowStart:rowEnd, colStart:colEnd);

        % Calculate average gradient values for the 3x3 section
        avgGx((i-1)/windowSize + 1, (j-1)/windowSize + 1) = mean(windowGx(:));
        avgGy((i-1)/windowSize + 1, (j-1)/windowSize + 1) = mean(windowGy(:));
    end
end

% Visualize the averaged gradient vectors using a quiver plot
% figure;
% imshow(grayImg);
% hold on;

% Create grids of coordinates for quiver plot using the size of avgGx and avgGy
[x, y] = meshgrid(1:size(avgGx, 2), 1:size(avgGx, 1));

% Display quiver plot with longer quivers
% quiverScale = 10;  % Adjust this value to control quiver length
% quiver(x(:) * windowSize - windowSize/2, y(:) * windowSize - windowSize/2, avgGx(:) * quiverScale, avgGy(:) * quiverScale, 'Color', 'r');
% 
% hold off;
% drawnow;

%% Superpixel

% Use superpixel to find the boundary and directions
[L, N] = superpixels(img, 1000);

% Create masks of areas inside superpixel
output_masks = cell(N, 1);

% Extract areas from superpixel 
stats = regionprops(L, 'PixelIdxList', 'PixelList','BoundingBox');

% Not good to solve like this but might come back to it later
new_stats = stats(1);

for i = 1:N
    % Create a mask for the current superpixel
    mask = L == i;
    % Get the intensity values of the original image where the mask is true
    maskedRegion = img .* uint8(mask);
    % Determine if the superpixel corresponds to a white background
    % This threshold can be adjusted based on your specific image characteristics
    if mean(maskedRegion(mask)) < 250
        % Store the mask if the region is not a white background
        output_masks{i} = mask;
        new_stats(end+1) = stats(i);

    end
end

output_masks = output_masks(~cellfun('isempty',output_masks));

% Delete first section
new_stats(1) = [];

%% Get vector direction inside each of the sections

stats = new_stats;
% Get the number of regions
numRegions = numel(stats);

quiverScale = 1.2;
arrowLineWidth = 1.2;  % Adjust this value to control the line width

% Empty variables
avgGxNormalized = zeros(numRegions, 1);
avgGyNormalized = zeros(numRegions, 1);

figure;
BW = boundarymask(L);
imshow(imoverlay(img, BW, 'cyan'), 'InitialMagnification', 67);
hold on;

% Loop through each section
for i = 1:numRegions
    % Get PixelIdxList for each section
    pixelIdxList = stats(i).PixelIdxList;

    % Get the corresponding Gx, Gy vectors for these pixels
    sectionGx = Gx(pixelIdxList);
    sectionGy = Gy(pixelIdxList);

    % Compute average Gx, Gy for this section
    avgGx = mean(sectionGx);
    avgGy = mean(sectionGy);
    
    % Compute average vector direction
    avgDirection = atan2(avgGy, avgGx);
    
    % Compute the direction and save 
    maxMagnitude = max(sqrt(avgGx^2 + avgGy^2), 1e-6); % Avoid division by zero
    avgGxNormalized(i) = avgGx / maxMagnitude;
    avgGyNormalized(i) = avgGy / maxMagnitude;

    % Plotting each section's average vector
    centroid = mean(stats(i).PixelList, 1);
    quiver(centroid(1), centroid(2), avgGx * quiverScale, avgGy * quiverScale, 'LineWidth', arrowLineWidth, 'Color', 'b');
end

hold off;
drawnow;

%% Find the image blob Centroid

% Stats of mask with single blob
mask_stats = regionprops(binaryImage, 'Centroid', 'BoundingBox');

% Extract centroid
centroid = mask_stats.Centroid; % Centroid [x, y]
boundingBox = mask_stats.BoundingBox; % Bounding box [x, y, width, height]

% Calculate the minimum and maximum x and y coordinates from the bounding box
minX = boundingBox(1);
maxX = boundingBox(1) + boundingBox(3);
minY = boundingBox(2);
maxY = boundingBox(2) + boundingBox(4);

%% Rotate and scale the stl to match images

% Calculate translation vector
imageCentroid = [centroid(1), 0, centroid(2)]; % Swap Y and Z coordinates for image centroid

% Calculate scaling factors
imageWidth = maxX - minX; % Width of the image blob
imageHeight = 0; % Ignore the Y-axis for scaling
imageDepth = maxY - minY; % Depth of the image blob (corresponds to the Z-axis of STL)

stlDimensions = max(V) - min(V); % Dimensions of the entire STL model
maxScaleFactor = max(imageWidth / stlDimensions(1), imageDepth / stlDimensions(3));
scalingFactors = [maxScaleFactor, maxScaleFactor, maxScaleFactor];


% Apply scaling to the STL model
ScaledV = V.* scalingFactors;

% Apply translation to the stl
stlCentroid = mean(ScaledV, 1); % Centroid of the entire STL model
translationVector = imageCentroid - stlCentroid;

translatedAndScaledV = ScaledV+ repmat(translationVector, size(V, 1), 1);


% % Plot the translated and scaled STL model
% figure;
% trisurf(F, translatedAndScaledV(:, 1), translatedAndScaledV(:, 2), translatedAndScaledV(:, 3), 'FaceColor', 'cyan');
% axis equal;
% xlabel('X');
% ylabel('Y'); % This will be the Z-axis of the STL
% zlabel('Z'); % This will be the new Y-axis of the image
% title('Translated and Scaled STL Model');
% rotate3d on;

%% Extract the stl of each of the masks and save it 
% Load your STL file (replace with your file path)

V = translatedAndScaledV;

% Assuming masks is a cell array where each element is a 2D logical array representing a mask
for i = 1:size(output_masks,1)
    mask = output_masks{i};

    % Convert the mask to a polygon
    boundaryMask = boundarymask(mask);
    [B,~,~,~] = bwboundaries(boundaryMask, 'noholes');
    polygon = cell2mat(B(1));

    % Check which vertices lie inside the polygon
    isVertexInside = inpolygon(V(:, 1), V(:, 3), polygon(:, 2), polygon(:, 1));

    % Include vertices that are nearby the polygon boundary
    threshold = 20; 
    distances = pdist2(V(:, [1 3]), polygon(:, [2 1]));
    minDistances = min(distances, [], 2);
    isVertexNearby = minDistances < threshold;
    isVertexInside = isVertexInside | isVertexNearby;

    % Find the faces that are entirely inside the polygon
    isFaceInside = all(isVertexInside(F), 2);

    insideFaces = F(isFaceInside, :);
    insideVertices = V(isVertexInside, :);

    % Update the indices in insideFaces to match the new vertex list
    [~, newIndices] = ismember(insideFaces, find(isVertexInside));
    insideFaces = reshape(newIndices, size(insideFaces));

    invTranslatedVertices = insideVertices - repmat(translationVector, size(insideVertices, 1), 1);
    invScaledVertices = invTranslatedVertices ./ scalingFactors;

    if isempty(insideFaces) == 1
        continue
    else
        stlwrite(sprintf('cutfiles/file_%d.stl',i),insideFaces,invScaledVertices,'mode','ascii');
    end


%     figure;
%     trisurf(insideFaces, invScaledVertices(:, 1), invScaledVertices(:, 2), invScaledVertices(:, 3), 'FaceColor', 'cyan');
%     axis equal;
%     xlabel('X');
%     ylabel('Y'); % This will be the Z-axis of the STL
%     zlabel('Z'); % This will be the new Y-axis of the image

end

%% Save fibre direction of each of the sections

% Empty vector
direction = zeros(size(avgGxNormalized,1),3);

% Loop through oritentations
for i =1:size(avgGxNormalized,1)
    direction(i,:) = [avgGxNormalized(i), 0 , avgGyNormalized(i)];
end

% Save json
json_name = 'cutfiles/fibre_direction.json';
json.direction = direction;
json = jsonencode(json);
[fid, msg] = fopen(json_name,'wt');
fprintf(fid,'%s\n',json);
fclose(fid);
clear json