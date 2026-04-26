function Prueba_A()

    IMG = dicomread('C:\Users\nncc2\OneDrive\Documentos\Tareas PRIM\Tarea 1 PRIM\IMAGENES_TAREA1\DATOS_TAREA1_PREGUNTA_A\MR-cerebro-ANON\IM.dcm');

    IMG = double(IMG);
    

    VOL = squeeze(IMG);
    disp("Dimensiones volumen original: ")
    disp(size(IMG));
    disp("Dimensiones volumen escalado: ")
    disp(size(VOL));

    VOL_OUT = trilineal_CHEHADE_CASIVAR(VOL, 1.2);
    disp(size(VOL_OUT));

    figure('Name','Volumen Escalado - 3D');
    volshow(VOL_OUT);

    figure('Name','Volumen Escalado - Cortes');
    sliceViewer(VOL_OUT);

end
function im_out = trilineal_CHEHADE_CASIVAR(im_in, factor)
    % Escala una imagen 3D según el factor indicado, utilizando
    % interpolación trilineal con método secuencial.
    %
    % Inputs:
    % - im_in: Imagen 3D de entrada.
    % - factor: Factor de escalamiento para el volumen de salida. 
    %
    % Outputs:
    % - im_out: Imagen 3D escalada resultante.
    %
    % Ejemplo de uso:
    % - Sea IMG una imagen 3D.
    % IMG_escalada = trilineal_CHEHADE_CASIVAR(IMG, 1.25);
    %
    % Estrategia:
    % Primero se generó el nuevo volumen del tamaño correspondiente según el
    % factor ingresado. Con ello, se aplicó interpolación en cada
    % coordenada para llenar el nuevo volumen. 
    %
    % Para ello se definieron dos funciones auxilares:
    % 1. obtener_vecinos: Retorna los vecinos del punto en el nuevo
    % volumen, y los pesos xd, yd, zd.
    %
    % 2. interpolar_trilineal: Retorna el valor de aplicar la interpolación
    % trilineal en el punto (i,j,k) del nuevo volumen, dado los vecinos y
    % pesos obtenidos previamente. 

  


    if factor < 0.05 || factor > 2
        error('El factor debe cumplir con 0.05 <= factor <= 2');
    end

    [nx, ny, nz] = size(im_in);
    
    nuevo_nx = round(nx * factor);
    nuevo_ny = round(ny * factor);
    nuevo_nz = round(nz * factor);

    % Crear nuevo volumen con el tamaño original multiplicado por el factor:
    im_out = zeros(nuevo_nx, nuevo_ny, nuevo_nz);

    % Recorrer cada punto en el nuevo volumen para ir haciendo la
    % interpolación:
    for i = 1:nuevo_nx
        for j = 1:nuevo_ny
            for k = 1:nuevo_nz
                %1. Encontrar el punto (x,y,z) en el volumen original
                x = 1 + (i - 1) * (nx - 1) / (nuevo_nx - 1);
                y = 1 + (j - 1) * (ny - 1) / (nuevo_ny - 1);
                z = 1 + (k - 1) * (nz - 1) / (nuevo_nz - 1);
                
                %2. Encontrar vecinos de x,y,z
                [vecinos, xd, yd, zd] = obtener_vecinos(im_in, x, y, z);

                
                %3. Aplicar la interpolación en el punto y almacenarlo en
                % el nuevo volumen
                im_out(i,j,k) = interpolar_trilineal(vecinos, xd, yd, zd);
                

            end
        end
    end
        
end


function [vecinos, xd, yd, zd] = obtener_vecinos(im_in, x, y, z)

    [nx, ny, nz] = size(im_in);

    % Índices inferior y superior
    x0 = floor(x);
    x1 = ceil(x);

    y0 = floor(y);
    y1 = ceil(y);

    z0 = floor(z);
    z1 = ceil(z);

    % Mantener índices dentro del volumen
    x0 = max(1, min(x0, nx));
    x1 = max(1, min(x1, nx));

    y0 = max(1, min(y0, ny));
    y1 = max(1, min(y1, ny));

    z0 = max(1, min(z0, nz));
    z1 = max(1, min(z1, nz));

    % Distancias: 

    if x1 == x0
        xd = 0;
    else
        xd = (x - x0) / (x1 - x0);
    end

    if y1 == y0
        yd = 0;
    else
        yd = (y - y0) / (y1 - y0);
    end

    if z1 == z0
        zd = 0;
    else
        zd = (z - z0) / (z1 - z0);
    end

    % Matriz para los 8 vecinos
    vecinos = zeros(2,2,2);

    vecinos(1,1,1) = im_in(x0,y0,z0);
    vecinos(2,1,1) = im_in(x1,y0,z0);
    vecinos(1,2,1) = im_in(x0,y1,z0);
    vecinos(2,2,1) = im_in(x1,y1,z0);
    vecinos(1,1,2) = im_in(x0,y0,z1);
    vecinos(2,1,2) = im_in(x1,y0,z1);
    vecinos(1,2,2) = im_in(x0,y1,z1);
    vecinos(2,2,2) = im_in(x1,y1,z1);

end

function valor_final = interpolar_trilineal(vecinos, xd, yd, zd)
    
    %Interpolación en X:
    C_00 = vecinos(1,1,1)*(1-xd) + vecinos(2,1,1)*xd;
    C_01 = vecinos(1,1,2)*(1-xd) + vecinos(2,1,2)*xd;
    C_10 = vecinos(1,2,1)*(1-xd) + vecinos(2,2,1)*xd;
    C_11 = vecinos(1,2,2)*(1-xd) + vecinos(2,2,2)*xd;

    %Interpolación en Y:
    C_0 = C_00*(1-yd) + C_10*yd;
    C_1 = C_01*(1-yd) + C_11*yd;

    %Interpolación en Z:
    C = C_0*(1-zd) + C_1*zd;
    valor_final = C;
    

end


