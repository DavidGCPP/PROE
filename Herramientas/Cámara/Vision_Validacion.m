%****Herramienta de visi�n para validar movimientos de robots del proyecto PROE
%****Implementada mediante Matlab

%Este programa tiene como objetivo la estimaci�n del �ngulo de giro y la
%separaci�n entre los agentes utilizando un patr�n visual como referencia
%Requiere de la captura de dos im�genes, una antes del movimiento y otra
%posterior al mismo.
%Adicionalmente, se realiza una calibraci�n de la c�mara para eliminar
%distorsion provocado por el lente, para mayor referencia : https://www.mathworks.com/help/vision/ug/camera-calibration.html
%Para ser capaces de manejar los datos de la webcam es necesario importar
%la biblioteca de webcam. Se descarga desde el gestor de bibliotecas.
%Home/Add-Ons y buscar webcam.


%--------------Etapa de captura de im�genes
clear cam;
CantidadEjemplosCaptura=1; %Esta es la cantidad de distintas mediciones que se tomar�n 
tamanoCuadroMedicion=40;
for img= 1:CantidadEjemplosCaptura
    cam=webcam(2);%Selecciona la camara USB
    %cam.Resolution='640x480'; %Es la resoluci�n m�xima de la c�mara (DroidCam)
    cam.Resolution='1920x1080'; %Es la resoluci�n m�xima de la c�mara (DroidCam)
    h = msgbox('Capture Imagen');
    for j=1:2
        filename=strcat('ejemplo',num2str(img),'(',num2str(j),').jpg');
        %strcat concatena caracteres
        preview(cam);
        pause;
        b=snapshot(cam);
        imwrite(b,filename);
        h = msgbox(strcat('ejemplo',num2str(img),'(',num2str(j),').jpg'));
        %msgbox crea una caja de mensaje
    end
    closePreview(cam);
    clear cam;
    
    %ejemplo corresponde al nombre de la imagen, carga el ejemplo 5(1).jpg y el
    %ejemplo 5(2).jpg.

    Im1=imread(strcat('ejemplo',num2str(img),'(1).jpg'));
    %Requiere la conversi�n del espacio de color rgb que corresponde a 3
    %matrices, una del color rojo, una del verde y otra del azul a una sola
    %matriz en intensidad de grises.
   
    Im2=imread(strcat('ejemplo',num2str(img),'(2).jpg'));
    %Leer la imagen a medir
    imOrig = Im1;

    points = detectCheckerboardPoints(imOrig);
    [undistortedPoints,reprojectionErrors] = undistortPoints(points, params);
    [im, newOrigin] = undistortImage(imOrig, params, 'OutputView', 'full');
    undistortedPoints = [undistortedPoints(:,1) - newOrigin(1), undistortedPoints(:,2) - newOrigin(2)];
    %Los pasos anteriores corresponden a la eliminaci�n de la distorsi�n de
    %la imagen, se utiliz� los par�metros de calibraci�n encontrados al
    %inicio.
    %Se realiza la conversi�n RGB to Grayscale de "im"
    Im1GRIS=rgb2gray(im);
    %Se realiza la conversi�n binaria de la imagen. Ahora solo habr� negro
    %o blanco, seg�n el umbral definido
    Im1BN=im2bw(Im1GRIS,0.6);%0.X corresponde al umbral para el aislamiento entre las zonas de inter�s y el fondo.
    
    %De aqu� en adelante se trabaja con im, que es la imagen con la distorsi�n
    %eliminada.
    [imagePoints, boardSize] = detectCheckerboardPoints(im);
    worldPoints = generateCheckerboardPoints(boardSize, tamanoCuadroMedicion);
    [R, t] = extrinsics(imagePoints, worldPoints, params);
    worldPoints1 = pointsToWorld(params, R, t, undistortedPoints);
    d = worldPoints1(2, :) - worldPoints1(1, :);
    mmCuadroPatron=hypot(d(1), d(2))
    d=undistortedPoints(2,:)-undistortedPoints(1,:)
    pixelesCuadroPatron=hypot(d(1),d(2))
    %Se toma como referencia la medida de uno de los cuadros del patr�n de
    %calibraci�n de la imagen para extraer la conversi�n de unidades de la
    %imagen a unidades reales.
    mmPorPixel=mmCuadroPatron/pixelesCuadroPatron
    %ya se tiene almacenado la conversion correspondiente en mm/pixel
    
    imOrig = Im2;

    points = detectCheckerboardPoints(imOrig);
    [undistortedPoints,reprojectionErrors] = undistortPoints(points, params);
    %Al quitar la distorsi�n a la imagen aumenta su tama�o de 480x640 a
    %625x785
    [im, newOrigin] = undistortImage(imOrig, params, 'OutputView', 'full');
    undistortedPoints = [undistortedPoints(:,1) - newOrigin(1), undistortedPoints(:,2) - newOrigin(2)];
    Im2GRIS=rgb2gray(im);
    Im2BN=im2bw(Im2GRIS,0.7);
    ImSuperpuesta=Im1BN&Im2BN;
    %Se superponen las dos im�genes con  la segmentaci�n del patr�n
    %utilizado para determinar la orientaci�n de los robots.

    %---Par�metros de detecci�n del patr�n----------------------- 
    cantidadCirculos=1; %Par�metro utilizado en las funciones de extracci�n de c�rculos
    %Importante: Rmin y Rmax est�n en pixels, no en mm.
    %Debe estimarse su valor medio como Rmedio= (RadioReal/mmPorPixel)�
    %tolerancia en pixels
    %Al cambiar la altura de la c�mara deben cambiarse estos valores
    Rmin=5;%usado para buscar los c�rculos peque�os, variar en caso de no detecci�n
    Rmax=12;%usado en el c�rculo peque�o
    Rmin2=11;%utilizado para determinar el c�rculo grande
    Rmax2=20;%utilizado para el c�rculo grande
    RminRef=90;% utilizados para la detecci�n del sistema de coordenadas.
    RmaxRef=110;
    
    %---Extracci�n de los c�rculos----------------------------
    %Se est� utilizando la funcion de Hough circular con la funci�n
    %imfindcircles,permite la detecci�n de c�rculos oscuros mediante
    %ObjectPolarity.
    %Se presenta la primera parte para la detecci�n de los c�rculos peque�os,
    %las respuestas se almacenan en centroPeque�o y radioPeque�o.
    [dimensionY dimensionX]=size(Im1(:,:,1));
    [centers, radii] = imfindcircles(Im1,[Rmin Rmax],'ObjectPolarity','dark');
    centroPequeno(1,:) = centers(1:cantidadCirculos,:);
    radioPequeno(1) = radii(1:cantidadCirculos); 
    %dark significa que los objetos circulares son m�s oscuros que el
    %fondo.
    [centers, radii] = imfindcircles(Im2,[Rmin Rmax],'ObjectPolarity','dark');
    centroPequeno(2,:) = centers(1:cantidadCirculos,:);
    radioPequeno(2) = radii(1:cantidadCirculos);
    d1=figure;
    imshow(ImSuperpuesta);
    hold on


    %Se realiza la b�squeda de los c�rculos grandes y los resultados se
    %almancenan en centroGrande y radioGrande.
    %Viscircles dibuja c�rculos con los ejes especificados y en los ejes
    %actuales
    viscircles(centroPequeno, radioPequeno,'EdgeColor','r');
    plot(centers(:,1),centers(:,2),'rx')
    [centers, radii] = imfindcircles(Im1,[Rmin2 Rmax2],'ObjectPolarity','dark');
    centroGrande(1,:) = centers(1:cantidadCirculos,:);
    radioGrande(1) = radii(1:cantidadCirculos); 
    [centers, radii] = imfindcircles(Im2,[Rmin2 Rmax2],'ObjectPolarity','dark');
    centroGrande(2,:) = centers(1:cantidadCirculos,:);
    radioGrande(2) = radii(1:cantidadCirculos); 
    viscircles(centroGrande, radioGrande,'EdgeColor','b');
    plot(centers(:,1),centers(:,2),'bx')

    %----Muestra de resultados de forma gr�fica-------------
    lineasCarro1=[centroGrande(1,:);centroPequeno(1,:)];
    lineasCarro2=[centroGrande(2,:);centroPequeno(2,:)];
    plot(lineasCarro1(:,1),lineasCarro1(:,2),'LineWidth',2,'Color','red');
    plot(lineasCarro2(:,1),lineasCarro2(:,2),'LineWidth',2,'Color','blue');


    %---Construcci�n de vectores para determinar orientaci�n y distancia de
    %separaci�n
    ab1 =[lineasCarro1(1,1)-lineasCarro1(2,1) -(lineasCarro1(1,2)-lineasCarro1(2,2))]; 
    ab2 = [lineasCarro2(1,1)-lineasCarro2(2,1) -(lineasCarro2(1,2)-lineasCarro2(2,2))]; 
    vect1 = ab1;%Vector del agente antes de iniciar su movimiento
    vect2 = ab2;%Vector del agente al finalizar su movimiento
    vectRef=[100 0];%Vector horizontal en la imagen
    %Se requiere determinar el �ngulo de separaci�n entre la orientaci�n
    %inicial y la orientaci�n final, para esto, se referencian ambos
    %vectores respecto al eje horizontal de la imagen
    %atan2 retorna la tangente inversa en el cuarto cuadrante de Y y X
    citaInicial=atan2(vect1(2),vect1(1))*180/pi; %cita_inicial en grados
    if(citaInicial<=0)
        citaInicial=360+citaInicial;
    end
    citaFinal=atan2(vect2(2),vect2(1))*180/pi;%cita_final
    if(citaFinal<=0)
        citaFinal=360+citaFinal;
    end
    deltaCita = citaFinal-citaInicial%delta_cita es el error en la orientaci�n
    %norm retorna la norma eucl�dea de un vector
    distancia=norm((centroGrande(1,:)-centroGrande(2,:))); %desplazamiento en pixeles del punto de partida y el punto final
    r_exp=distancia*mmPorPixel %r_experimental es el desplazamiento en mm
    deltaX=(centroGrande(1,2)-centroGrande(1,1))*mmPorPixel;%deltaX del desplazamiento experimental, con la imagen
    deltaY=(centroGrande(2,2)-centroGrande(2,1))*mmPorPixel;%deltay del desplazamiento exp, con la imagen
    %atan devuelve la arcotangente inversa del cuarto cuadrante.
    betaExp=atan2(deltaY,deltaX)*(180/pi);%angulo del desplazamiento experimental, referenciado con la imagen
    
    %Por revisar, al parecer es para tener un mismo marco de referencia (Por confirmar)
    %Lo que viene est� comentado porque anguloVector1 no est� definido
    %anteriormente
    %betaTeorico=anguloVector1;% se rota el sistema para que coincida con el del agente
    betaTeorico=-148;% se ingresa el �ngulo medido manualmente 
    deltaBeta=betaExp-betaTeorico;%diferencia entre el desplazamiento te�rico y el experimental
    deltaX2=r_exp*cos(deltaBeta)*180/pi;%proyecci�n x del r_exp sobre el desplazamiento te�rico
    deltaY2=r_exp*sin(deltaBeta)*180/pi;%proyecci�n y del r_exp sobre el desplazamiento te�rico
    %---Almacenamiento de resultados, la separaci�n es en mm y el �ngulo en
    %grados.
    result=strcat(num2str(deltaX2),';',num2str(deltaY2),';',num2str(deltaCita))
    cont=cont+1;
end