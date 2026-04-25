function Prueba_B_1()
    
    DATA = load('C:\Users\nncc2\OneDrive\Documentos\Tareas PRIM\Tarea 1 PRIM\IMAGENES_TAREA1\DATOS_TAREA1_PREGUNTA_B\im1.mat');

    img = double(DATA.im1);

    figure;
    imagesc(img);
    colormap gray;
    axis image;
    title('Imagen 1 dañada');
    
    
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
    title('Espacio-k 1/ Magnitud Fourier 1');
    datacursormode on;

    %Empezamos el tema de las máscaras para empezar a filtrar
    mask = ones(size(F_centrada));
    mask(207, 207) = 0;
    mask(207, 257) = 0;
    mask(207, 307) = 0;
    mask(257, 207) = 0;
    mask(257, 307) = 0;
    mask(307, 207) = 0;
    mask(307, 257) = 0;
    mask(307, 307) = 0;

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

%Estrategia:
% imagen -> fft2 -> espacio-k -> máscara -> ifft2 -> reconstrucción
% Nota: En el espacio k generado se identifcaron 8 puntos simétricamente
% posicionados alrededor del centro, de color blanco que destacaban.
% Probablemente sean el artefacto en frecuencia que genera la distorción.
% Eliminarlos del espacio K debería reconstruir la imagen.