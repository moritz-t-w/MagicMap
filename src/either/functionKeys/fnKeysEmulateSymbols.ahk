; Function keys will perform the functions they display

; Keymaps

	; Brightness keys
		F1::AdjustScreenBrightness(-10)
		F2::AdjustScreenBrightness(10)

	; Window management keys
		F3::send, #`t ; send windows+tab for mission controll key
		F4::send, {LWin} ; send windows key for launchpad

	; F5 & F6 change keyboard backlight brightness

	; Media keys
		F7::send, {Media_Prev}
		F8::send, {Media_Play_Pause}
		F9::send, {Media_Next}

	; Volume keys
		F10::send, {Volume_Mute}
		F11::send, {Volume_Down}
		F12::send, {Volume_Up}

; Functions

	; AdjustScreenBrightness() by krrr (https://gist.github.com/krrr/3c3f1747480189dbb71f)
	AdjustScreenBrightness(step) {
		static service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
		monitors := ComObjGet(service).ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=TRUE")
		monMethods := ComObjGet(service).ExecQuery("SELECT * FROM wmiMonitorBrightNessMethods WHERE Active=TRUE")
		for i in monitors {
			curr := i.CurrentBrightness
			break
		}
		toSet := curr + step
		if (toSet < 10)
			toSet := 10
		if (toSet > 100)
			toSet := 100
		for i in monMethods {
			i.WmiSetBrightness(1, toSet)
			break
		}
		BrightnessOSD()
	}
	; BrightnessOSD() by YashMaster and qwerty12 (https://gist.github.com/krrr/3c3f1747480189dbb71f?permalink_comment_id=3683539#gistcomment-3683539)
	BrightnessOSD() {
		static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
		,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
		static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
		HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
		IF !(HWND) {
			try IF ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
				try IF ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
					DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
					,ObjRelease(flyoutDisp)
				}
				ObjRelease(shellProvider)
			}
			HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
		}
		DllCall(PostMessagePtr, "Ptr", HWND, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
	}