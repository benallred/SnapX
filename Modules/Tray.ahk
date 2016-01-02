class Tray
{
	initIcon()
	{
		if (A_IsCompiled)
		{
			Menu, Tray, Icon, % A_ScriptName, 1
		}
		else
		{
			Menu, Tray, Icon, Resources\SnapX.ico
		}
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

		Menu, Tray, Add, &About, % aboutMethod

		updateMethod := ObjBindMethod(this, "tray_Update")
		Menu, Tray, Add, Chec&k for update, % updateMethod

		Menu, Tray, Add

		helpMethod := ObjBindMethod(this, "tray_Help")
		Menu, Tray, Add, &Help, % helpMethod

		settingsMethod := ObjBindMethod(this, "tray_Settings")
		Menu, Tray, Add, &Settings, % settingsMethod

		reloadMethod := ObjBindMethod(this, "tray_Reload")
		Menu, Tray, Add, &Reload, % reloadMethod

		suspendMethod := ObjBindMethod(this, "tray_Suspend")
		Menu, Tray, Add, S&uspend, % suspendMethod

		exitMethod := ObjBindMethod(this, "tray_Exit")
		Menu, Tray, Add, E&xit, % exitMethod
		
		if (A_IsCompiled)
		{
			Menu, Tray, Icon, % this.settings.programTitle, % A_ScriptName, 1
			Menu, Tray, Icon, &About, % A_ScriptName, 6
			Menu, Tray, Icon, Chec&k for update, % A_ScriptName, 7
			Menu, Tray, Icon, &Help, % A_ScriptName, 13
			Menu, Tray, Icon, &Settings, % A_ScriptName, 8
			Menu, Tray, Icon, &Reload, % A_ScriptName, 9
			Menu, Tray, Icon, S&uspend, % A_ScriptName, 10
			Menu, Tray, Icon, E&xit, % A_ScriptName, 12
		}
		else
		{
			Menu, Tray, Icon, % this.settings.programTitle, Resources\SnapX.ico
			Menu, Tray, Icon, &About, Resources\About.ico
			Menu, Tray, Icon, Chec&k for update, Resources\Update.ico
			Menu, Tray, Icon, &Help, Resources\Help.ico
			Menu, Tray, Icon, &Settings, Resources\Settings.ico
			Menu, Tray, Icon, &Reload, Resources\Reload.ico
			Menu, Tray, Icon, S&uspend, Resources\Suspend.ico
			Menu, Tray, Icon, E&xit, Resources\Exit.ico
		}
	
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

	tray_Help(itemName, itemPos, menuName)
	{
		new HelpGui(this.settings)
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
		new SettingsGui(this.settings)
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
			if (A_IsCompiled)
			{
				Menu, Tray, Icon, S&uspend, % A_ScriptName, 10
			}
			else
			{
				Menu, Tray, Icon, S&uspend, Resources\Suspend.ico
			}
		}
		else
		{
			Menu, Tray, Rename, S&uspend, Res&ume
			if (A_IsCompiled)
			{
				Menu, Tray, Icon, Res&ume, % A_ScriptName, 11
			}
			else
			{
				Menu, Tray, Icon, Res&ume, Resources\Resume.ico
			}
		}
		
		Suspend, Toggle
	}

	tray_Exit(itemName, itemPos, menuName)
	{
		ExitApp
	}
}