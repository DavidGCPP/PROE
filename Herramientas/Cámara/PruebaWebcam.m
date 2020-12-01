%Este script permite probar el correcto funcionamiento de 
%la aplicaci�n Droid Cam. Para su correcto funcionamiento
%se requiere tener instalado y corriendo el app en el m�vil
%android, as� como el cliente para Windows. (Ambos dispositivos)
%Deben estar conectados a la misma red Wi-fi.
%Adem�s, debe instalarse el Matlab Support Package for USB webcams
% que se puede encontrar en el siguiente url:
%https://la.mathworks.com/matlabcentral/fileexchange/45182-matlab-support-package-for-usb-webcams

%elimina las sesiones webcam anteriores y variables anteriores
clear all 
%limpia el command window
clc 
camList=webcamlist %muestra las c�maras disponibles
cam=webcam(2) %selecciona la 2, es decir Droidcam
preview(cam); %muestra en tiempo real la c�mara
img=snapshot(cam) %toma de una imagen
image(img) %muestra la imagen capturada