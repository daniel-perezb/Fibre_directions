function [gradX, gradY] = gradient_im(image, method, neighborhoodSize)
% Check if the input image is color and convert it to grayscale
if size(image, 3) == 3
    image = rgb2gray(image);
end

% Convert the image to double precision for accurate calculations
image = im2double(image);

%% Sobel Operators
% Define Sobel and Prewitt operators for 3x3, 5x5, 7x7, and 9x9 neighborhoods
sobel3x3X = [-1 0 1; -2 0 2; -1 0 1];
sobel3x3Y = [-1 -2 -1; 0 0 0; 1 2 1];

sobel4x4X = [-1 0 1 2; -2 -1 0 1; -1 -2 -1 0; 0 -1 -2 -1];
sobel4x4Y = [-1 -2 -1 0; 0 -1 -2 -1; -1 0 -1 -2; 2 1 0 -1];

sobel5x5X = [-2 -1 0 1 2; -2 -1 0 1 2; -4 -2 0 2 4; -2 -1 0 1 2; -2 -1 0 1 2];
sobel5x5Y = [-2 -2 -4 -2 -2; -1 -1 -2 -1 -1; 0 0 0 0 0; 1 1 2 1 1; 2 2 4 2 2];

sobel6x6X = [-1 -1 0 0 1 1; -2 -2 0 0 2 2; -1 -1 0 0 1 1; -1 -1 0 0 1 1; -2 -2 0 0 2 2; -1 -1 0 0 1 1];
sobel6x6Y = [-1 -2 -1 -1 -2 -1; -1 -2 -1 -1 -2 -1; 0 0 0 0 0 0; 0 0 0 0 0 0; 1 2 1 1 2 1; 1 2 1 1 2 1];

sobel7x7X = [1 2 3 3 3 2 1; 2 3 4 4 4 3 2; 3 4 5 5 5 4 3; 4 5 6 6 6 5 4; 3 4 5 5 5 4 3; 2 3 4 4 4 3 2; 1 2 3 3 3 2 1];
sobel7x7Y = [1 2 3 4 3 2 1; 2 3 4 5 4 3 2; 3 4 5 6 5 4 3; 3 4 5 6 5 4 3; 3 4 5 6 5 4 3; 2 3 4 5 4 3 2; 1 2 3 4 3 2 1];

sobel8x8X = [-1 -2 -2 -2 0 2 2 2; -1 -2 -3 -3 0 3 2 1; -1 -2 -4 -4 0 4 2 1; -1 -2 -5 -5 0 5 2 1; ...
             -1 -2 -6 -6 0 6 2 1; -1 -2 -7 -7 0 7 2 1; -1 -2 -8 -8 0 8 2 1; -1 -2 -9 -9 0 9 2 1];
sobel8x8Y = [-1 -1 -1 -1 -1 -1 -1 -1; -2 -2 -2 -2 -2 -2 -2 -2; -2 -3 -4 -5 -6 -7 -8 -9; ...
             -2 -3 -4 -5 -6 -7 -8 -9; 0 0 0 0 0 0 0 0; 2 3 4 5 6 7 8 9; 2 2 2 2 2 2 2 2; 2 1 1 1 1 1 1 1];

sobel9x9X = [-1 -2 -3 -4 -4 -4 -4 -3 -2; -1 -2 -3 -4 -4 -4 -4 -3 -2; -1 -2 -3 -4 -4 -4 -4 -3 -2; ...
             -1 -2 -3 -4 -4 -4 -4 -3 -2; -1 -2 -3 -4 -4 -4 -4 -3 -2; -1 -2 -3 -4 -4 -4 -4 -3 -2; ...
             -1 -2 -3 -4 -4 -4 -4 -3 -2; -1 -2 -3 -4 -4 -4 -4 -3 -2; -1 -2 -3 -4 -4 -4 -4 -3 -2];
sobel9x9Y = [-1 -1 -1 -1 -1 -1 -1 -1 -1; -2 -2 -2 -2 -2 -2 -2 -2 -2; -3 -3 -3 -3 -3 -3 -3 -3 -3; ...
             -4 -4 -4 -4 -4 -4 -4 -4 -4; -4 -4 -4 -4 -4 -4 -4 -4 -4; -4 -4 -4 -4 -4 -4 -4 -4 -4; ...
             -4 -4 -4 -4 -4 -4 -4 -4 -4; -3 -3 -3 -3 -3 -3 -3 -3 -3; -2 -2 -2 -2 -2 -2 -2 -2 -2];

%% Prewitt Operators
prewitt3x3X = [-1 0 1; -1 0 1; -1 0 1];
prewitt3x3Y = [-1 -1 -1; 0 0 0; 1 1 1];

prewitt4x4X = [-3 -1  1 3; -3 -1 1 3; -3 -1 1 3];
prewitt4x4Y = [3 3 3 3; 1 1 1 1; -1 -1 -1 -1; -3 -3 -3 -3];

prewitt5x5X = [-2 -1 0 1 2; -2 -1 0 1 2; -2 -1 0 1 2; -2 -1 0 1 2; -2 -1 0 1 2];
prewitt5x5Y = [-2 -2 -2 -2 -2; -1 -1 -1 -1 -1; 0 0 0 0 0; 1 1 1 1 1; 2 2 2 2 2];

prewitt6x6X = [-5 -3 -1 1 3 5; -5 -3 -1 1 3 5; -5 -3 -1 1 3 5; -5 -3 -1 1 3 5; -5 -3 -1 1 3 5;  -5 -3 -1 1 3 5];
prewitt6x6Y = [5 5 5 5 5 5; 3 3 3 3 3 3; 1 1 1 1 1 1; -1 -1 -1 -1 -1 -1;  -3 -3 -3 -3 -3 -3; -5 -5 -5 -5 -5 -5];

prewitt7x7X = [-3 -2 -1 0 1 2 3; -3 -2 -1 0 1 2 3; -3 -2 -1 0 1 2 3; -3 -2 -1 0 1 2 3; -3 -2 -1 0 1 2 3; -3 -2 -1 0 1 2 3; -3 -2 -1 0 1 2 3];
prewitt7x7Y = [3 3 3 3 3 3 3; 2 2 2 2 2 2 2; 1 1 1 1 1 1 1; 0 0 0 0 0 0 0; -1 -1 -1 -1 -1 -1 -1; -2 -2 -2 -2 -2 -2 -2; -3 -3 -3 -3 -3 -3 -3];


prewitt8x8X = [-7 -5 -3 -1 1 3 5 7; -7 -5 -3 -1 1 3 5 7; -7 -5 -3 -1 1 3 5 7; -7 -5 -3 -1 1 3 5 7; -7 -5 -3 -1 1 3 5 7; -7 -5 -3 -1 1 3 5 7; ...
    -7 -5 -3 -1 1 3 5 7; -7 -5 -3 -1 1 3 5 7];

prewitt8x8Y = [7 7 7 7 7 7 7 7; 5 5 5 5 5 5 5 5; 3 3 3 3 3 3 3 3; 1 1 1 1 1 1 1 1; -1 -1 -1 -1 -1 -1 -1 -1; -3 -3 -3 -3 -3 -3 -3 -3;...
    -5 -5 -5 -5 -5 -5 -5 -5; -7 -7 -7 -7 -7 -7 -7 -7];


prewitt9x9X = [-4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4; ...
    -4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4; -4 -3 -2 -1 0 1 2 3 4];

prewitt9x9Y = [4 4 4 4 4 4 4 4 4; 3 3 3 3 3 3 3 3 3; 2 2 2 2 2 2 2 2 2; 1 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0 0; -1 -1 -1 -1 -1 -1 -1 -1 -1; -2 -2 -2 -2 -2 -2 -2 -2 -2;...
    -3 -3 -3 -3 -3 -3 -3 -3 -3; -4 -4 -4 -4 -4 -4 -4 -4 -4];

%% Appliactions

if strcmpi(method, 'sobel')
    switch neighborhoodSize
        case 3
            operatorX = sobel3x3X;
            operatorY = sobel3x3Y;
        case 4
            operatorX = sobel4x4X;
            operatorY = sobel4x4Y;
        case 5
            operatorX = sobel5x5X;
            operatorY = sobel5x5Y;
        case 6
            operatorX = sobel6x6X;
            operatorY = sobel6x6Y;
        case 7
            operatorX = sobel7x7X;
            operatorY = sobel7x7Y;
        case 8
            operatorX = sobel8x8X;
            operatorY = sobel8x8Y;
        case 9
            operatorX = sobel9x9X;
            operatorY = sobel9x9Y;
        otherwise
            error('Invalid neighborhood size. Choose 3, 4, 5, 6, 7, 8, or 9.');
    end
elseif strcmpi(method, 'prewitt')
    switch neighborhoodSize
        case 3
            operatorX = prewitt3x3X;
            operatorY = prewitt3x3Y;
        case 4
            operatorX = prewitt4x4X;
            operatorY = prewitt4x4Y;
        case 5
            operatorX = prewitt5x5X;
            operatorY = prewitt5x5Y;
        case 6
            operatorX = prewitt6x6X;
            operatorY = prewitt6x6Y;
        case 7
            operatorX = prewitt7x7X;
            operatorY = prewitt7x7Y;
        case 8
            operatorX = prewitt8x8X;
            operatorY = prewitt8x8Y;
        case 9
            operatorX = prewitt9x9X;
            operatorY = prewitt9x9Y;
        otherwise
            error('Invalid neighborhood size. Choose 3, 4, 5, 6, 7, 8, or 9.');
    end
else
    error('Invalid method. Choose ''sobel'' or ''prewitt''.');
end

% Convolve the image with the selected operator
gradX = conv2(image, operatorX, 'same');
gradY = conv2(image, operatorY, 'same');
end