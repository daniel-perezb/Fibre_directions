function image = image_filter(image, mask)
    R = image(:,:, 1);
    G = image(:,:, 2);
    B = image(:,:, 3);
    
    R(mask == 0) = 255;
    G(mask == 0) = 255;
    B(mask == 0) = 255;
    
    image = cat(3, R, G, B);
end

