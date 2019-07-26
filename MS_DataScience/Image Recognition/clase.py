import cv2
import numpy as np
import sys
def main():
    imgStr = 'mord_fustang.jpg'
    img = cv2.imread(imgStr)

    alto = img.shape[0]
    ancho = img.shape[1]
    canales = img.shape[2]

    print('Alto: ' + str(alto))
    print('Ancho: ' + str(ancho))
    print('Canales: ' + str(canales))

    out = np.zeros((alto, ancho, 3))
    #gris = np.zeros((alto, ancho, 1))
    
    for i in range(alto):
        for j in range(ancho):
            pixel = img[i,j]
            #grisAritmetico = int((pixel[0] + pixel[1] + pixel[2])/3)
            azul = pixel[0]
            rojo = pixel[2]
            #gris[i,j] = grisAritmetico
            out[i,j] = [azul, 0, rojo]

    pixel = img[0,0]    
    print('Pixel: ' + str(pixel))

    cv2.imshow('Resultado', img)

    cv2.imwrite('salida.jpg', out)
    #cv2.imwrite('gris.jpg', gris)
    
    cv2.imshow('Color', out)
    #cv2.imshow('Aritmetico', gris)
    
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    sys.exit()


main()