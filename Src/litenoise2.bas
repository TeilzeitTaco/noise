'TV static noise generator

Declare Sub rndProv
Declare Sub init
Declare Sub main

Const ver = "0.1"
Const sig = __FB_SIGNATURE__
Const red = __DATE__ & ", " &  __TIME__

Dim Shared As Byte Ptr framebuffer
Dim Shared As Integer wMax, hMax
Dim Shared As Integer x, y, r
Dim Shared As Any Ptr rp

Sub rndProv
	Do
		r = Int(Rnd*2)+1
	Loop
End Sub

Sub init
	'Start up the random number generator thread
	Randomize
	rp = ThreadCreate(@rndProv)

	'Initialize the graphic mode
	ScreenInfo(wMax, hMax)
	ScreenRes(wMax, hMax, , 1, &h08 Or &h80 Or &h20 Or &h40)
	framebuffer = ScreenPtr
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
