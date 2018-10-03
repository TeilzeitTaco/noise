'TV static noise generator in 100 lines

#Define noise_type 0
Declare Sub rndProv
Declare Sub init
Declare Sub main

Const ver = "v0.2"
Const sig = __FB_SIGNATURE__
Const red = __DATE__ & ", " &  __TIME__

Dim Shared As Integer 	wMax, hMax 	'Screen resolution
Dim Shared As Integer 	x, y			'Scanline cords
Dim Shared As Byte Ptr 	framebuffer	'PTR to screen memory
Dim Shared As Any Ptr 	rp				'PTR to random byte provider thread
Dim Shared As Byte 		r				'random byte from generator thread

Sub rndProv
	#If noise_type = 1					'Noise type 1 is random mode
	Do
		r = Int(Rnd*2)+1					'Generate random byte (1 or 2)
	Loop
	#ElseIf noise_type = 2				'Noise type 2 is switch mode
	Do
		Select Case r
			Case 0							'If [r] = 0 then set [r] to 1
				Asm
					mov eax, 1
					mov [r], eax
				End Asm
			Case 1							'If [r] = 1 then set [r] to 0
				Asm
					mov eax, 0
					mov [r], eax
				End Asm
		End Select
	Loop
	#Else
	#Error "Invalid noise type! Please define ""1"" or ""2""!"
	#EndIf
End Sub

Sub init
	Randomize								'Initialize random number generator
	rp = ThreadCreate(@rndProv)		'Start random number generator
	If rp = 0 Then							'Check for errors
		End
	EndIf
	ScreenInfo(wMax, hMax) 				'Get screen resolution
	ScreenRes(wMax, hMax, , 1, &h08 Or &h80 Or &h20 Or &h40) 'Initialize screen mode
	framebuffer = ScreenPtr 			'Get screen byte PTR
	If framebuffer = 0 Then				'Check for errors
		End
	EndIf
	SetMouse(,,0)							'Hide mouse courser
	ScreenLock								'Lock screen sync
	main 										'Start noise generator
End Sub

Sub main
	Do
		Asm
			mov eax, [x]
			inc eax
			mov [x], eax
		End Asm
		Select Case r
			Case 1							'Set the pixel white if [r] = 1
				Poke Byte, framebuffer + (y * wMax) + x, 15
			Case Else						'Set the pixel black if [r] <> 1
				Poke Byte, framebuffer + (y * wMax) + x, 0
		End Select
		Select Case x
			Case wMax
				Asm
					mov eax, 0
					mov [x], eax
				End Asm
				Select Case y
					Case hMax
						Asm
							mov eax, 0
							mov [y], eax
						End Asm
						ScreenUnLock		'Unlock screen sync
						ScreenSync			'Wait for screen sync
						ScreenLock			'Relock screen
					Case Else
						Asm
							mov eax, [y]
							inc eax
							mov [y], eax
						End Asm
				End Select
		End Select
	Loop
End Sub

init
