% Para cada sinograma:
% 1. Retroproyección simple
% 2. Retroproyección filtrada
% 3. Reconstrucción con Furier en base a la retroproyección filtrada

function Prueba_C_1()

    % Cargar sinograma 1
    DATA = load(fullfile('IMAGENES_TAREA1','DATOS_TAREA1_PREGUNTA_C','sinogram1.mat'));

    % Obtener variable interna
    nombres = fieldnames(DATA);
    sino = DATA.(nombres{1});

    % Convertir a double
    sino = double(sino);

    % Mostrar tamaño
    disp('Tamaño del sinograma:');
    disp(size(sino));

    % Visualizar sinograma
    figure;
    imagesc(sino);
    colormap gray;
    axis normal;
    title('Sinograma 1');
    xlabel('\theta');
    ylabel('Detector');

    % 1. Retroproyección simple:
    img_rec = retroproyeccion_simple(sino);
    figure;
    imagesc(img_rec);
    colormap gray;
    axis image;
    title('Retroproyección simple');

    % 2. Retroproyección filtrada:
    img_rec_filtrada = retroproyeccion_filtrada(sino);
    figure;
    imagesc(img_rec_filtrada);
    colormap gray;
    axis image;
    title('Retroproyección filtrada');

    % 3. Reconstrucción con Furier sobre retroproyección filtrada
    % Pendiente!


end

function img_rec = retroproyeccion_simple(sino)

    % Tamaño del sinograma
    [num_detectores, num_angulos] = size(sino);

    % Imagen de salida
    N = num_detectores;
    img_rec = zeros(N,N);

    % Ángulos
    angulos = linspace(0,180,num_angulos);

    % Recorrer cada proyección
    for k = 1:num_angulos

        % Tomar columna k del sinograma
        proyeccion = sino(:,k);

        % Repetir proyección en filas para formar imagen temporal
        banda = repmat(proyeccion,1,N);

        % Rotar al ángulo correspondiente
        banda_rotada = imrotate(banda,-angulos(k),'bilinear','crop');

        % Acumular
        img_rec = img_rec + banda_rotada;

    end
end

function img_rec = retroproyeccion_filtrada(sino)

    % Tamaño del sinograma
    [num_detectores, num_angulos] = size(sino);

    % Imagen de salida
    N = num_detectores;
    img_rec = zeros(N,N);

    % Ángulos
    angulos = linspace(0,180,num_angulos);

    % Filtro Hann
    n = floor(num_detectores/2);
    freq = (-n:n)';
    f = freq / max(abs(freq));
    filtro = abs(f) .* (0.5 + 0.5*cos(pi*f));


    % Recorrer proyecciones
    for k = 1:num_angulos

        % Proyección original
        r = sino(:,k);

        % Fourier de la proyección
        R = fftshift(fft(r));

        % Aplicar filtro rampa
        R_filtrado = R .* filtro;

        % Volver al dominio espacial
        r_filtrada = real(ifft(ifftshift(R_filtrado)));

        % Crear banda 2D
        banda = repmat(r_filtrada,1,N);

        % Retroproyectar
        banda_rotada = imrotate(banda,-angulos(k),'bilinear','crop');

        % Acumular
        img_rec = img_rec + banda_rotada;

    end

    % Normalizar
    %img_rec = img_rec / num_angulos;

end


% Notas: El sinograma es de 729 detectores y 181 ángulos, de ahí se asume
% que las columnas van en los ángulos del 0-180

% Filtros:

% Filtro Ram-Lak simple
%n = floor(num_detectores/2);
%freq = (-n:n)';
%filtro = abs(freq);
%filtro = filtro(1:num_detectores);

% Filtro Shepp-Logan
%n = floor(num_detectores/2);
%freq = (-n:n)';
%f = freq / max(abs(freq));
%x = f/2;
%s = ones(size(x));
%idx = (x ~= 0);
%s(idx) = sin(pi*x(idx)) ./ (pi*x(idx));
%filtro = abs(f) .* s;



% Filtro Cosine
%n = floor(num_detectores/2);
%freq = (-n:n)';
%f = freq / max(abs(freq));
%filtro = abs(f) .* cos((pi/2) * f);


% Filtro Hann
%n = floor(num_detectores/2);
%freq = (-n:n)';
%f = freq / max(abs(freq));
%filtro = abs(f) .* (0.5 + 0.5*cos(pi*f));


% Filtro Hamming
%n = floor(num_detectores/2);
%freq = (-n:n)';
%f = freq / max(abs(freq));
%filtro = abs(f) .* (0.54 + 0.46*cos(pi*f));