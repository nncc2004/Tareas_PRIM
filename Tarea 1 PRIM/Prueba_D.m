% m es la imagen del cerebro
% C es la info de las bobinas
% Voy a hacer tres funciones y ya
% notar, la imagen tien 128 filas y hay 8 bobinas. En el resultado de la
% última parte, cuando se ingresa 4 y 8 funciona bien, pero con 6 se rompe
% totalmente. Esto es:
% 128 / 4 = 32 (No se rompe)
% 128 / 8 = 16 (No se rompe)
% 128 / 6 = 21.333... (Se rompe)


function Prueba_D()

    disp("Ejecutando d1...");
    %suma_de_cuadrados();
    disp("Fin d1");


    disp("Ejecutando d2...");
    %comb_sensibilidad_pesadas();
    disp("Fin d2");

    disp("Ejecutando d3...");
    metodo_sense(16); 
    disp("Fij d3");


end


function suma_de_cuadrados()

    %Carga de archivos:
    DATA_m = load(fullfile('IMAGENES_TAREA1', 'DATOS_TAREA1_PREGUNTA_D', 'm.mat'));
    DATA_C = load(fullfile('IMAGENES_TAREA1', 'DATOS_TAREA1_PREGUNTA_D','C.mat'));
    nombres_m = fieldnames(DATA_m);
    nombres_C = fieldnames(DATA_C);
    m = DATA_m.(nombres_m{1});
    C = DATA_C.(nombres_C{1});
    m = double(m);
    C = double(C);

    % 1. Imagen de cada bobina
    Nc = size(C,3);
    rec_by_coil = repmat(m,1,1,Nc) .* C;
    
    %%%% Hasta aquí es igual en d1 y d2 %%%%
    
    % Suma de cuadrados
    img_final = sqrt(sum(abs(rec_by_coil).^2,3));

    figure;
    imagesc(img_final);
    colormap gray;
    axis image;
    title('Reconstrucción SoS');



end



function comb_sensibilidad_pesadas()
    %Carga de archivos:
    DATA_m = load(fullfile('IMAGENES_TAREA1', 'DATOS_TAREA1_PREGUNTA_D', 'm.mat'));
    DATA_C = load(fullfile('IMAGENES_TAREA1', 'DATOS_TAREA1_PREGUNTA_D','C.mat'));
    nombres_m = fieldnames(DATA_m);
    nombres_C = fieldnames(DATA_C);
    m = DATA_m.(nombres_m{1});
    C = DATA_C.(nombres_C{1});
    m = double(m);
    C = double(C);

    % Imagen de cada bobina
    Nc = size(C,3);
    rec_by_coil = repmat(m,1,1,Nc) .* C;

    % Ec. 
    numerador = sum(conj(C) .* rec_by_coil, 3);
    denominador = sum(abs(C).^2, 3);
    denominador(denominador == 0) = eps;
    img_final = abs(numerador ./ denominador);

    % Mostrar resultado
    figure;
    imagesc(img_final);
    colormap gray;
    axis image;
    title('Reconstrucción sensibilidad pesada');

end

function metodo_sense(submuestreo)
    
    %Carga de archivos:
    DATA_m = load(fullfile('IMAGENES_TAREA1', 'DATOS_TAREA1_PREGUNTA_D', 'm.mat'));
    DATA_C = load(fullfile('IMAGENES_TAREA1', 'DATOS_TAREA1_PREGUNTA_D','C.mat'));
    nombres_m = fieldnames(DATA_m);
    nombres_C = fieldnames(DATA_C);
    m = DATA_m.(nombres_m{1});
    C = DATA_C.(nombres_C{1});
    m = double(m);
    C = double(C);

    % Imagen de cada bobina
    Nc = size(C,3);
    rec_by_coil = repmat(m,1,1,Nc) .* C;
    
    % generamos un submuestreo uniforme en la direccion de las fases
    mask = zeros(size(C));
    mask(1:submuestreo:end,:,:) = mask(1:submuestreo:end,:,:) + 1;
    
    kspace = [];
    kspace_sub = [];
    brain_sub = [];


    % obtener imágenes submuestreadas por bobina
    for n=1:size(C,3)
    
        kspace(:,:,n) = fftshift(fft2(rec_by_coil(:,:,n))).*mask(:,:,n);
    
        kspace_sub(:,:,n) = kspace(1:submuestreo:end,:,n);
    
        brain_sub(:,:,n) = ifft2(fftshift(kspace_sub(:,:,n)));
    
    end


    % reconstrucción SENSE
    M  = size(brain_sub,1);
    N  = size(brain_sub,2);
    MM = size(C,1);
    
    IMSENSE = complex(zeros([MM,N]));

    for jj=1:M
        for ii=1:N
    
            filas = jj:M:MM;
    
            CC = squeeze(C(filas,ii,:)).';
            a  = squeeze(brain_sub(jj,ii,:));
    
            IMSENSE(filas,ii) = pinv(CC)*a;
    
        end
    end
    
    IMSENSE = abs(IMSENSE);
    IM_R = IMSENSE/max(IMSENSE(:));
    
    
    figure;
    
    subplot(1,3,1)
    imshow(m,[])
    title('Original')
    
    subplot(1,3,2)
    imshow(IM_R,[])
    title(['SENSE x',num2str(submuestreo)])
    
    subplot(1,3,3)
    imshow(abs(m-IM_R),[])
    title('Diferencia')

end