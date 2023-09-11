clear
% close all

%% Extract frames for an image and see how the holes evolve

% Read the video
video = VideoReader("Test1_10fps.mp4");

% Set numbers of frames that will be used (10fps)
usedframes = 150;

% Check the number of frames
numframes = video.NumFrames;

% Open the first frame from the video
thisFrame = read(video, 1);

% Remove Background
[binaryImage,fleece_image] = extract_fleece(thisFrame);

% Extract largest blob from image
binaryImage = bwareafilt(binaryImage, 1);

% Fill in largest blob
binaryImage = imfill(binaryImage,'holes');

% Copy mask for future use
Originalbinary = binaryImage;

% Mask out the region in RGB image
fleece_image = image_filter(fleece_image, binaryImage);

% Initialize variables
Added_displacement = zeros([1080, 1920, 3]);

% Extract the next frame in the video
for frame = 2:usedframes

    % Open the first frame from the video
    nextFrame = read(video, frame);

    % Remove Background
    [binaryImage2,fleece_image2] = extract_fleece(nextFrame);

    % Extract largest blob from image
    binaryImage2 = bwareafilt(binaryImage2, 1);

    % Fill in largest blob
    binaryImage2 = imfill(binaryImage2, 'holes');

    % Mask out the region in RGB image
    fleece_image2 = image_filter(fleece_image2, binaryImage2);

    % Find completely black pixels
    black_pixels = all(binaryImage == 0, 3);

    % Mask out the region in RGB image
    fleece_image2 = image_filter(fleece_image2, binaryImage2);

    % Extract pixel displacement inside mask
    Pixel_difference = im2double(fleece_image2 - fleece_image) .* ~black_pixels;

    % Remove added displacement from pixels outside the original mask
    Added_displacement = Added_displacement - im2double(Pixel_difference) .* ~Originalbinary;


    % Add to the displacement within the original mask
    Added_displacement = Added_displacement + im2double(Pixel_difference) .* Originalbinary;


    % Restart variables
    fleece_image = fleece_image2;
    binaryImage = binaryImage2;

end
%% Remove pixels outside the last mask 

% Calculate pixel difference for the last frame (using the last mask)
Pixel_difference_last = im2double(fleece_image2 - fleece_image) .* ~black_pixels;

% Apply a buffer/margin to the mask
buffer_size = 24; % Adjust the buffer size as needed
binaryImage2_buffered = imerode(binaryImage2, strel('disk', buffer_size));

% Remove added displacement from pixels outside the last mask
Added_displacement = Added_displacement - im2double(Pixel_difference_last) .* ~binaryImage2_buffered;

% Add to the displacement within the last mask
Added_displacement = Added_displacement + im2double(Pixel_difference_last) .* binaryImage2_buffered;

% Remove  displacement from pixels outside the last mask
Added_displacement = Added_displacement.*binaryImage2_buffered;

%% Compute the mean error and display heatmap
% Calculate mean error over all frames
mean_error = sum(Added_displacement, 3) / (usedframes - 1); % Divide by (number of frames - 1)

% Calculate mean error over non-zero pixels
non_zero_pixels = mean_error > 0;
mean_error_no_bg = mean_error .* non_zero_pixels;

% Normalize mean error (no background) to the range [0, 1]
max_mean_error_no_bg = max(mean_error_no_bg(:));
min_mean_error_no_bg = min(mean_error_no_bg(:));
normalized_mean_errors_no_bg = (mean_error_no_bg - min_mean_error_no_bg) / (max_mean_error_no_bg - min_mean_error_no_bg);

% Create a colormap from blue to yellow to red
colormap_rgb = [linspace(0, 0, 64)', linspace(0, 1, 64)', linspace(1, 1, 64)';
    linspace(0, 1, 64)', linspace(1, 1, 64)', linspace(1, 0, 64)';
    linspace(1, 1, 64)', linspace(1, 0, 64)', linspace(0, 0, 64)'];

% Convert normalized mean errors (no background) to colormap indices
num_colors = size(colormap_rgb, 1);
mean_error_indices_no_bg = min(floor(normalized_mean_errors_no_bg * (num_colors - 1)) + 1, num_colors);

% Convert colormap indices to RGB colors for the mean error (no background)
mean_error_rgb_no_bg = ind2rgb(mean_error_indices_no_bg, colormap_rgb);

% Create a mask for non-zero pixels
non_zero_mask = repmat(non_zero_pixels, [1, 1, 3]);

% Display the colormap of the mean error (no background) on non-zero pixels
figure;
imshow(non_zero_mask .* mean_error_rgb_no_bg);
colormap(colormap_rgb); % Set the colormap for correct colorbar mapping
colorbar;
title('Colormap of Mean Error (No Background)');


%% Display clusters over Mean error image

error_map = Added_displacement;

% Apply smoothing
smoothed_error_map = imgaussfilt(error_map, 10);

% Apply thresholding
thresholded_map = imbinarize(smoothed_error_map, 1.25);

% Convert binary image to grayscale
gray_thresholded_map = uint8(thresholded_map) * 255;

 % Superimpose the first image onto the second image with transparency
figure;
imshow(non_zero_mask .* mean_error_rgb_no_bg);  % First image
hold on;
h2 = imshow(gray_thresholded_map);  % Second image
colormap(gray);
alphaData = 0.5 * non_zero_mask(:, :, 1);  % Adjust the transparency factor (0.5 in this case)
set(h2, 'AlphaData', alphaData);
colormap(colormap_rgb); % Set the colormap for correct colorbar mapping
colorbar;
title('Colormap of Average Error (No Background)');
hold off;
title(sprintf('Different sections highlighted at second %d', (frame/10)));

