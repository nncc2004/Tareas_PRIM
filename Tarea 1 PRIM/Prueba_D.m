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
    %metodo_sense(16); 
    disp("Fij d3");
    
    metodo_GRAPPA_LINEAS(16);
    metodo_GRAPPA_KERNEL(16);

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
    
    espacio_k = [];
    espacio_k_sub = [];
    brain_sub = [];


    % obtener imágenes submuestreadas por bobina
    for n=1:size(C,3)
    
        espacio_k(:,:,n) = fftshift(fft2(rec_by_coil(:,:,n))).*mask(:,:,n);
    
        espacio_k_sub(:,:,n) = espacio_k(1:submuestreo:end,:,n);
    
        brain_sub(:,:,n) = ifft2(fftshift(espacio_k_sub(:,:,n)));
    
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


function metodo_GRAPPA_LINEAS(cant_lineas_acs)

    %Carga de archivos:
    DATA_m = load(fullfile('IMAGENES_TAREA1','DATOS_TAREA1_PREGUNTA_D','m.mat'));
    DATA_C = load(fullfile('IMAGENES_TAREA1','DATOS_TAREA1_PREGUNTA_D','C.mat'));
    nombres_m = fieldnames(DATA_m);
    nombres_C = fieldnames(DATA_C);
    m = double(DATA_m.(nombres_m{1}));
    C = double(DATA_C.(nombres_C{1}));

    % Imagen de cada bobina
    Nc = size(C,3);
    rec_by_coil = repmat(m,1,1,Nc) .* C;
    
    % Espacio-k de cada bobina
    for i = 1:Nc
        espacio_k(:,:,i) = fftshift(fft2(rec_by_coil(:,:,i)));
    end

    % Submuestreo x2 para simular luego el GRAPPA
    [Ny, Nx, Nc] = size(espacio_k);
    espacio_k_submuestreo = zeros(size(espacio_k));

    % Aquí el submuestreo per-sé
    espacio_k_submuestreo(1:2:end,:,:) = espacio_k(1:2:end,:,:);

        
    inicio = floor(Ny/2) - floor(cant_lineas_acs/2) + 1;
    fin    = inicio + cant_lineas_acs - 1;
    
    % Reconstruir las líneas centrales completas (ACS)
    espacio_k_submuestreo(inicio:fin,:,:) = espacio_k(inicio:fin,:,:);

    % Extraer región ACS completa
    acs = espacio_k(inicio:fin,:,:);
    
    % Matrices de entrenamiento GRAPPA
    X = [];
    Y = [];
    
    % Para x2: línea faltante entre una arriba y una abajo
    for y = 2:2:size(acs,1)-1
    
        % Líneas vecinas conocidas (todas las bobinas)
        arriba = reshape(acs(y-1,:,:),1,[]);
        abajo  = reshape(acs(y+1,:,:),1,[]);
    
        entrada = [arriba abajo];
    
        % Línea objetivo real (la del medio)
        objetivo = reshape(acs(y,:,:),1,[]);
    
        % Guardar ejemplo
        X = [X; entrada];
        Y = [Y; objetivo];
    
    end
    
    % Calcular pesos GRAPPA
    W = pinv(X) * Y;
        
    % Copiar el espacio k submuestrado para reconstruicción
    espacio_k_reconstruido = espacio_k_submuestreo;

    for y = 2:2:Ny-1;
        if y < inicio || y > fin
            arriba = reshape(espacio_k_reconstruido(y-1, :, :), 1, []);
            abajo = reshape(espacio_k_reconstruido(y+1, :, :), 1, []);
            entrada = [arriba, abajo];

            % estimacion linea faltante
            linea_estimada = entrada * W;

            % volver a forma inicial
            espacio_k_reconstruido(y, :, :) = reshape(linea_estimada,[1 Nx Nc]);
        end
    end

    % Volver a imagen por cada bobina reconstruida
    for i = 1:Nc
        img_rec(:,:,i) = ifft2(ifftshift(espacio_k_reconstruido(:,:,i)));
    end

    % Combinación pesada por sensibilidad
    numerador = sum(conj(C) .* img_rec, 3);
    denominador = sum(abs(C).^2, 3);
    denominador(denominador == 0) = eps;
    
    img_final = abs(numerador ./ denominador);
    img_final = img_final / max(img_final(:));


    % Mostrar resultados
    figure;

    subplot(1,3,1)
    imshow(m,[])
    title('Original')
    
    subplot(1,3,2)
    imshow(img_final,[])
    title('GRAPPA x2')
    
    subplot(1,3,3)
    imshow(abs(m - img_final),[])
    title('Diferencia')

end

function metodo_GRAPPA_KERNEL(cant_lineas_acs)

    %Carga de archivos:
    DATA_m = load(fullfile('IMAGENES_TAREA1','DATOS_TAREA1_PREGUNTA_D','m.mat'));
    DATA_C = load(fullfile('IMAGENES_TAREA1','DATOS_TAREA1_PREGUNTA_D','C.mat'));
    nombres_m = fieldnames(DATA_m);
    nombres_C = fieldnames(DATA_C);
    m = double(DATA_m.(nombres_m{1}));
    C = double(DATA_C.(nombres_C{1}));

    % Imagen de cada bobina
    Nc = size(C,3);
    rec_by_coil = repmat(m,1,1,Nc) .* C;

    % Espacio-k de cada bobina
    for i = 1:Nc
        espacio_k(:,:,i) = fft2(rec_by_coil(:,:,i));
    end

    % Submuestreo x2 para simular luego el GRAPPA
    [Ny, Nx, Nc] = size(espacio_k);
    espacio_k_submuestreo = zeros(size(espacio_k));

    % Aquí el submuestreo per-sé
    espacio_k_submuestreo(1:2:end,:,:) = espacio_k(1:2:end,:,:);

    inicio = floor(Ny/2) - floor(cant_lineas_acs/2) + 1;
    fin    = inicio + cant_lineas_acs - 1;

    % Reconstruir las líneas centrales completas (ACS)
    espacio_k_submuestreo(inicio:fin,:,:) = espacio_k(inicio:fin,:,:);

    % Extraer región ACS completa
    acs = espacio_k(inicio:fin,:,:);

    % Matrices de entrenamiento GRAPPA
    X = [];
    Y = [];

    % Kernel 2D usando vecinos arriba y abajo
    for y = 2:2:size(acs,1)-1
        for x = 2:Nx-1

            arriba = acs(y-1,x-1:x+1,:);
            abajo  = acs(y+1,x-1:x+1,:);

            entrada = [arriba(:); abajo(:)].';

            objetivo = reshape(acs(y,x,:),1,[]);

            X = [X; entrada];
            Y = [Y; objetivo];

        end
    end

    % Calcular pesos GRAPPA
    W = pinv(X) * Y;

    % Copiar el espacio k submuestrado para reconstrucción
    espacio_k_reconstruido = espacio_k_submuestreo;

    for y = 2:2:Ny-1
        if y < inicio || y > fin

            for x = 2:Nx-1

                arriba = espacio_k_reconstruido(y-1,x-1:x+1,:);
                abajo  = espacio_k_reconstruido(y+1,x-1:x+1,:);

                entrada = [arriba(:); abajo(:)].';

                % Estimación punto faltante
                punto_estimado = entrada * W;

                espacio_k_reconstruido(y,x,:) = reshape(punto_estimado,[1 1 Nc]);

            end
        end
    end

    % Volver a imagen por cada bobina reconstruida
    for i = 1:Nc
        img_rec(:,:,i) = ifft2(espacio_k_reconstruido(:,:,i));
    end

    % Combinación pesada por sensibilidad
    numerador = sum(conj(C) .* img_rec, 3);
    denominador = sum(abs(C).^2, 3);
    denominador(denominador == 0) = eps;

    img_final = abs(numerador ./ denominador);
    img_final = img_final / max(img_final(:));

    % Mostrar resultados
    figure;

    subplot(1,3,1)
    imshow(m,[])
    title('Original')

    subplot(1,3,2)
    imshow(img_final,[])
    title('GRAPPA x2')

    subplot(1,3,3)
    imshow(abs(m - img_final),[])
    title('Diferencia')

end