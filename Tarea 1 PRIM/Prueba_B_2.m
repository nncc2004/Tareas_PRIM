function Prueba_B_2()
    
    DATA = load('C:\Users\nncc2\OneDrive\Documentos\Tareas PRIM\Tarea 1 PRIM\IMAGENES_TAREA1\DATOS_TAREA1_PREGUNTA_B\im2.mat');

    img = double(DATA.im2);

    figure;
    imagesc(img);
    colormap gray;
    axis image;
    title('Imagen dañada');
    
    % Transformada de Fourier
    F = fft2(img);

    % Centrar frecuencias bajas en el medio
    F_centrada = fftshift(F);

    % Magnitud para visualizar
    K = log(1 + abs(F_centrada));

    figure;
    imagesc(K);
    colormap gray;
    axis image;
    title('Espacio-k / Magnitud Fourier');
    datacursormode on;


    mask = ones(size(F_centrada));
    mask(141, 64) = 0;
    mask(191, 114) = 0;    
    mask(216, 139) = 0;
    mask(266, 189) = 0;
    mask(291, 214) = 0;
    mask(341, 264) = 0;
    
    % Aplicar la máscara en el espacio-k
    F_filtrado = F_centrada .* mask;
    
    % Reconstruir la imagen en el dominio espacial
    img_reconstruida = ifft2(ifftshift(F_filtrado));
    
    % Visualizar la imagen reconstruida
    figure;
    imagesc(real(img_reconstruida));
    colormap gray;
    axis image;
    title('Imagen reconstruida 1');
end


%Notas: Al igual que en la primera imagen, se observan artefactos, sólo que
%ahora son 6, posicionados de manera diagonal descendente de izquierda a
%derecha. Mismo procedimiento preliminarmente.