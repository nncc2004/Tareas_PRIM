Nicolás Chehade Casivar 
Rol: 202373508-6
Especificaciones para ejecutar la tarea:
 - MATLAB R2025B (Debería funcionar igualmente con otras versiones)
 - Tener el directorio '/IMAGENES_TAREA1' a la misma altura que el .mlx, y con las carpetas descomprimidas para poder acceder al contenido desde el código. 


d.4:
GRAPPA es un método de reconstrucción de datos de MRI paralela de múltiples bobinas. Trabaja con el espacio-k y reconstruye datos faltantes de una bobina con información conjunta de todas. Esto lo hace con líneas centrales completamente adquiridas, denominadas ACS (Auto Calibration Signal), con las cuales estima pesos de reconstrucción que permiten interpolas datos faltantes del espacio-k de la bobina. 

Una de las principales ventajas del método es la no necesidad de mapas explícitos de sensibilidades de las bobinas que, como se explica en el paper, pueden ser complejos de obtener o de medir su real precisión por elementos como el ruido. En vez de esto, usa los ACS para hacer la estimación de puntos faltantes en los espacios-k de cada bobina de forma combinada.

Una vez reconstruido el espacio-k de cada bobina, se aplicada la transformada inversa de Furier para obtener la imagen individual de cada una de las bobinas. Finalmente, se aplica algún método como suma de cuadrados, o combinación pesada para combinar todas las imágenes en la imagen final. 

Nota: Como no tengo en espacio-k por bobina, acá para simularlo, igualmente hubo que utilizar el mapa de sensibilidades para generar cada espacio-k.

Descripción de mi implementación: 

Mi implementación usa un kernel en vez de los bloques que menciona el paper, para tener un enfoque más parecido al visto en clases de otros métodos, pero la lógica es muy similar. 
Elegí un tamaño de 2x3 para el kernel por simpleza. Notar que no es cuadrado tipo 3x3 porque precisamente nos falta información de una de las líneas (la del medio) por lo que sólo necesitamos lainformación de las líneas superior e inferior. 
Usé 16 líneas ACS porque en el paper se presentó la idea de usar 8 o 16 indistintamente y ver resultados. Funcionó bien con ambos. 

El código sigue la siguiente lógica:
1. Genera el espacio-k de cada bobina con transformada de Fourier.
2. Simula submuestreo (x2) y conserva la región central ACS completa.
3. Extrae las líneas ACS para usarlas como datos de calibración.
4. Forma ejemplos de entrenamiento con el kernel sobre la región ACS.
5. Calcula los pesos GRAPPA.
6. Reconstruye los puntos faltantes del espacio-k submuestreado usando esos pesos.
7. Aplica transformada inversa de Fourier para recuperar la imagen de cada bobina.
8. Combina todas las bobinas mediante ponderación por sensibilidad para obtener la imagen final.

