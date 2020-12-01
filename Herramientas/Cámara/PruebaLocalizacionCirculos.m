%Con este script se puede poner a prueba la detecci�n de los c�rculos en 
%una imagen. El rango de radios es en p�xels, y depende de la altura a la
%que se ubique la c�mara.

%Para obtener una primera aproximaci�n del tama�o en p�xeles de estos
%radios, se utilizar� la variable mmPorPixel, ya sea cargando el Workspace
%m�s reciente, o realizando el proceso de calibraci�n.

%El radio del c�rculo peque�o impreso (PDF llamado "Vision_Guia"), es de
%15mm. El radio del c�rculo grande es de 25mm. Por lo tanto, con los
%c�lculos siguientes se desea aproximar a cu�ntos p�xeles equivalen estos
%radios.

RadioPequeno=15; %15mm es el radio del c�rculo peque�o
RadioGrande=25; %25mm es el radio del c�rculo grande

%El rango de radios peque�os se establece como el radio calculado en
%p�xeles � un porcentaje (debe ajustarce de ser necesario). Se utiliza la funci�n round para redondear el
%resultado al entero m�s cercano, ya que no pueden existir fracciones de
%p�xeles.
RminPequeno=round((RadioPequeno/mmPorPixel)*0.5)
RmaxPequeno=round((RadioPequeno/mmPorPixel)*1.5)

%Ahora se hace el mismo procedimiento para el c�rculo grande.
RminGrande=round((RadioGrande/mmPorPixel)*0.75)
RmaxGrande=round((RadioGrande/mmPorPixel)*1.5)

%Prueba de b�squeda c�rculo peque�o
%Dark se refiere a que el c�rculo es oscuro sobre un fondo claro.

A = imread('ejemplo1(1).jpg'); imshow(A)
[centersDarkp, radiiDarkp] = imfindcircles(A,[RminPequeno RmaxPequeno],'ObjectPolarity','dark');
viscircles(centersDarkp, radiiDarkp,'EdgeColor','b');

%Prueba de b�squeda c�rculo grande

B = imread('ejemplo1(1).jpg'); imshow(B)
[centersDarkg, radiiDarkg] = imfindcircles(B,[RminGrande RmaxGrande],'ObjectPolarity','dark');
viscircles(centersDarkg, radiiDarkg,'EdgeColor','r');
