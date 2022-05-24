function hp_gaussian_image = gaussian_high_pass_filter(img, D0)
    [M, N] = size(img);
    [u, v] = meshgrid(1:M, 1:N);
    img_fft = fftshift(fft2(img));
    
    % Create matric of Gaussian function
    D_u_v = sqrt((u - (M/2)).^2 + (v - (N/2)).^2); % D(u, v)
    H_u_v = exp((-D_u_v.^2)/(2*(D0^2))); % Gaussian function frequency matrix H(u, v)
    
    high_pass = 1 - H_u_v;
    
    img_fft_filtered = img_fft.*double(high_pass);
    hp_gaussian_image = abs(ifft2(img_fft_filtered));
end
