'TV static noise generator in 100 lines (Version 2)

Declare Sub rndProv

Dim Shared As UInteger 	wMax, hMax 	'Screen resolution
Dim Shared As UInteger 	x, y			'Scanline cords
Dim Shared As UByte 		r				'random byte from generator thread
Dim Shared As UByte Ptr frameBuffer	'PTR to screen memory
Dim Shared As Any   Ptr rp				'PTR to random byte provider thread

Sub rndProv
	Do
		r = Int(Rnd*2)+1					'Generate random byte (1 or 2)
	Loop
End Sub

Randomize									'Initialize random number generator

rp = ThreadCreate(@rndProv)			'Start random number generator
If rp = 0 Then: End: EndIf				'Check for errors

ScreenInfo(wMax, hMax) 												'Get screen resolution
ScreenRes(wMax, hMax, , 1, &h08 Or &h80 Or &h20 Or &h40) 'Initialize screen mode

frameBuffer = ScreenPtr 				'Get screen byte PTR
If frameBuffer = 0 Then: End: EndIf	'Check for errors

SetMouse(,,0)								'Hide mouse courser
ScreenLock									'Lock screen sync

Do
	x += 1

	If (r = 1) Then
		*(frameBuffer+(y*wMax)+x) = 15 'Set the pixel white if [r] = 1
	Else
		*(frameBuffer+(y*wMax)+x) = 0  'Set the pixel black if [r] <> 1
	EndIf

	If (x = wMax) Then
		X = 0

		If (y = hMax) Then
			y = 0

			ScreenUnLock	'Unlock screen sync
			ScreenSync		'Wait for screen sync
			ScreenLock		'Relock screen
		Else
			y += 1
		EndIf
	EndIf
Loop
