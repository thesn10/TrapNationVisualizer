; IMPORTANT: You have to reload the skin TWICE until your changes are visible!
[Variables]

;--BASIC--
; Bands: Amount of data points that get visualized (CPU intensive!)
; Height: Height/Width of the outer visualization
; Radius: Radius of the inner circle
Bands=100
Height=150
Radius=200
Smoothing=1
Mirror=1
InvertMirror=0
HollowCenter=0

; --Image Settings--
; ImageName: The file name of the center image
; ImageScale: The Scale of the image
; ImageAudioReactIntensity: The intensity of the reaction to audio
; ImageAlpha: The transparency of the image (255 = 100%)
; ImageTint: The tint of the image (default: none)
ImageName=trapnation.png
ImageXScale=1.23
ImageYScale=1.23
ImageAudioReactIntensity=0.2
ImageAlpha=255
ImageTint=

; --Angle Settings--
; Rotate by changing "StartAngle"
; Changing AngularDisplacement will result in some interesting shapes :)
StartAngle=0
EndAngle=360
AngularDisplacement=0

; --FTT Settings--
FFTSize=8192
FFTBufferSize=16384
FFTAttack=0
FFTDecay=0
FreqMin=25
FreqMax=200
Sensitivity=35

; --WORK IN PROGRESS--
; If you want to scale it, please use "Radius" and "Height"
Scale=1

; --DANGEROUS--
; !!! only change "Config" if you renamed the skin file/location !!!
SkinGroup=TrapNationVis
Config=TrapNationVis
Channel=
Port=
ID=

; --Color/Layer Settings--
; Layers: Amount of color layers (recommended 3-5, but there is no limit) (CPU intensive!)
; DelayPerLayer: The Delay per Layer from the previous layer
Layers=5
DelayPerLayer=4
Layer0Color=255,255,255,255
Layer1Color=255,185,15,255
Layer2Color=255,0,0,255
Layer3Color=255,0,255,255
Layer4Color=58,95,205,255
Layer5Color=50,205,50,255
