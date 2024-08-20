## Work description 

The initial stage of the pipeline focuses on the extraction of multiple fibre clusters found within the fleece in the before skirt image. This is achieved by partitioning the fleece with the superpixels algorithm, which uses k-means clustering to find the boundaries of each superpixel. This adaptation enables the efficient generation of superpixels, facilitating the accurate identification of the distinct fibre clusters in the before skirt image.

Once the superpixels are defined, the Sobel operator is employed to compute the image gradient within each superpixel area. The Sobel operator functions by detecting changes in intensity across a specific pixel array, generating a gradient vector. This method is particularly effective when applied to the grayscale image of the before skirt fleece, as it accentuates the distinction between the fibres and the background.

To obtain the direction of the fibre, the gradient vectors inside each superpixel are added together. During the summation process, opposing gradients or sides of the fibres effectively cancel out, leaving a resultant vector representing the direction of the fibre orientation within the superpixel.

Once all the superpixels are obtained, the mesh is spatially transformed to match the scale and coordinates of the image. The transformed mesh is segmented into multiple meshes by cutting it along the superpixel boundaries. 


## Required Files

Ensure that the image and STL files are located in the correct paths. These paths can be adjusted on lines 8 and 13 within main.m.

## Required Dependencies 

The Image Processing Toolbox is required to run the code in main.m. Additionally, an external STL reading function is necessary, as the built-in MATLAB function does not provide all the required functionalities for this project.

## Running the Code

To run the code, execute main.m, which is located inside the main folder.

## Code Description

The code begins by loading an STL file and an image of a fleece. This occurs within the first 15 lines of the script. A mask of the image is then created using the extract_fleece function, and the largest blob is extracted, isolating the fleece within the image.

Once the image is processed, the vector direction for each 3x3 area is extracted using the Sobel operator (line 72). The gradients within predefined sections are summed to find the average direction.

The image is then divided into multiple sections using superpixels, and the gradient vectors within each superpixel are summed to obtain the average direction.

Finally, the initial mesh is divided into predefined superpixels and saved in a specified folder (line 337), along with their respective gradient directions obtained in the previous steps.

