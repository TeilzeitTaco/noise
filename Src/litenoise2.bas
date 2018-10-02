'TV static noise generator in under 100 lines

#Define noise_type 2

Declare Sub rndProv
Declare Sub init
Declare Sub main

Const ver = "v0.2"
Const sig = __FB_SIGNATURE__
Const red = __DATE__ & ", " &  __TIME__

Dim Shared As Integer 	wMax, hMax 	'Screen specs
Dim Shared As Integer 	x, y			'scanline cords
Dim Shared As Byte Ptr 	framebuffer	'ptr to screen memory
Dim Shared As Any Ptr 	rp				'ptr to random provider thread
Dim Shared As Byte 		r				'random byte

Sub rndProv
	#If noise_type = 1
		Do
			r = Int(Rnd*2)+1
		Loop
	#ElseIf noise_type = 2
		Do
			Select Case r
				Case 0
					r = 1
				Case 1
					r = 0
			End Select
		Loop
	#Else
	#Error "Invalid noise type! Please define 1 or 2!"
	#EndIf
End Sub

Sub init
	'Start up the random number generator thread
	Randomize
	rp = ThreadCreate(@rndProv)
	If rp = 0 Then
		End
	EndIf

	'Initialize the graphic mode
	ScreenInfo(wMax, hMax)
	ScreenRes(wMax, hMax, , 1, &h08 Or &h80 Or &h20 Or &h40)
	framebuffer = ScreenPtr
	If framebuffer = 0 Then
		End
	EndIf
	SetMouse(,,0)
	ScreenLock

	'Start noise generator
	main
End Sub

Sub main
	Do
		Asm
			mov eax, [x]
			inc eax
			mov [x], eax
		End Asm
		Select Case r
			Case 1
				Poke Byte, framebuffer + (y * wMax) + x, 15
			Case Else
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
						ScreenUnLock
						ScreenSync
						ScreenLock
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
