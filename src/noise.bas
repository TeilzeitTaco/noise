'TV static noise generator in under 100 lines (Version 2)

Declare Sub rndProv

Dim Shared As Boolean	r				'random bit from generator thread
Dim As UInteger 			wMax, hMax	'Screen resolution
Dim As UInteger 			x, y			'Scanline cords
Dim As UByte Ptr			frameBuffer	'PTR to screen memory
Dim As Any   Ptr			rp				'PTR to random byte provider thread

Sub rndProv
	Do
		r = Int(Rnd*2)						'Generate random bit (true or false)
	Loop
End Sub

Randomize									'Initialize random number generator

rp = ThreadCreate(@rndProv)			'Start random number generator
If rp = 0 Then: End: EndIf				'Check for errors

ScreenInfo(wMax, hMax)									'Get screen resolution, this creates problems on some platforms
ScreenRes(wMax, hMax, , , &h08 Or &h20 Or &h80)	'Initialize screen mode

frameBuffer = ScreenPtr 				'Get screen byte PTR
If frameBuffer = 0 Then: End: EndIf	'Check for errors

SetMouse(,,0)								'Hide mouse courser
ScreenLock									'Lock screen sync

Do
	x += 1

	If (r = TRUE) Then
		*(frameBuffer+(y*wMax)+x) = 15 'Set the pixel to white if [r] = 1
	Else
		*(frameBuffer+(y*wMax)+x) = 0  'Set the pixel to black if [r] <> 1
	EndIf

	If (x = wMax) Then
		X = 0

		If (y = hMax) Then
			y = 0

			ScreenUnlock	'Unlock screen sync
			ScreenSync		'Wait for screen sync
			ScreenLock		'Relock screen
		Else
			y += 1
		EndIf
	EndIf
Loop
