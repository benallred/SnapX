class Tray
{
	initIcon()
	{
		Menu, Tray, Icon, shell32.dll, 160 ; other options: 16, 253, 255, 306
		Menu, Tray, NoStandard
	}

	__New(settings, build, updateChecker)
	{
		this.settings := settings
		this.build := build
		this.updateChecker := updateChecker

		this.InitIcon()

		aboutMethod := ObjBindMethod(this, "tray_About")
		Menu, Tray, Add, % this.settings.programTitle, % aboutMethod
		Menu, Tray, Icon, % this.settings.programTitle, shell32.dll, 160

		Menu, Tray, Add, &About, % aboutMethod
		Menu, Tray, Icon, &About, shell32.dll, 222 ; other options: 155, 176, 211, 222, 225, 278

		updateMethod := ObjBindMethod(this, "tray_Update")
		Menu, Tray, Add, Chec&k for update, % updateMethod
		Menu, Tray, Icon, Chec&k for update, shell32.dll, 47 ; other options: 47, 123

		Menu, Tray, Add

		settingsMethod := ObjBindMethod(this, "tray_Settings")
		Menu, Tray, Add, &Settings, % settingsMethod
		Menu, Tray, Icon, &Settings, shell32.dll, 316

		reloadMethod := ObjBindMethod(this, "tray_Reload")
		Menu, Tray, Add, &Reload, % reloadMethod
		Menu, Tray, Icon, &Reload, shell32.dll, 239

		suspendMethod := ObjBindMethod(this, "tray_Suspend")
		Menu, Tray, Add, S&uspend, % suspendMethod
		Menu, Tray, Icon, S&uspend, shell32.dll, 145 ; other options: 238, 220

		exitMethod := ObjBindMethod(this, "tray_Exit")
		Menu, Tray, Add, E&xit, % exitMethod
		Menu, Tray, Icon, E&xit, shell32.dll, 132
		
		Menu, Tray, Default, % this.settings.programTitle
		Menu, Tray, Tip, % this.settings.programTitle
	}

	tray_Noop(itemName, itemPos, menuName)
	{
	}

	tray_About(itemName, itemPos, menuName)
	{
		new AboutGui(this.settings, this.build)
	}

	tray_Update(itemName, itemPos, menuName)
	{
		updateFound := this.updateChecker.checkForUpdates()
		
		if (!updateFound)
		{
			MsgBox, 0x40, % this.settings.programTitle " Up To Date", % "You are running the latest version of " this.settings.programTitle "." ; 0x40 = Info
		}
	}

	tray_Settings(itemName, itemPos, menuName)
	{
		Run, % "notepad.exe " this.settings.iniFile
	}

	tray_Reload(itemName, itemPos, menuName)
	{
		Reload
	}

	tray_Suspend(itemName, itemPos, menuName)
	{
		if (A_IsSuspended)
		{
			Menu, Tray, Rename, Res&ume, S&uspend
			Menu, Tray, Icon, S&uspend, shell32.dll, 145
		}
		else
		{
			Menu, Tray, Rename, S&uspend, Res&ume
			Menu, Tray, Icon, Res&ume, shell32.dll, 302
		}
		
		Suspend, Toggle
	}

	tray_Exit(itemName, itemPos, menuName)
	{
		ExitApp
	}
}