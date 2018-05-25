Scriptname crdeStartQuestScript extends Quest  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Start Quest
;
; Todo: Not sure what this does yet.
;
; Many thanks to Chase Roxand and Verstort for all of their original work on this mod.
;
; © Copyright 2017 legume-Vancouver of GitHub
; This file is part of the Deviously Enslaved Continued Skyrim mod.
;
; The Deviously Enslaved Continued Skyrim mod is free software: you can redistribute it and/or
; modify it under the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 3 of the License, or (at your option) any later version.
;
; The Deviously Enslaved Continued Skyrim mod is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
; A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along with The Deviously
; Enslaved Continued Skyrim mod.  If not, see <http://www.gnu.org/licenses/>.
;
; History:
; 14.00 2017-01-17 by legume
; Received existing work from the original Deviously Enslaved Continued mod.  Added headers.
;***********************************************************************************************

Quest Property Mods Auto  
Quest Property Player Auto  
;Quest Property Settings Auto  

float lastVersion
bool Property needsMaintenance Auto 

; float version is Xxx.Yy.Zz = > Xxx.YyZz
; IE 3.2.1 would be 3.0201, 2.13.2 would be 2.1302
float function getVersion()
  return 13.1407
  EndFunction

string function getVersionString()
  return "13.14.7"
EndFunction

Function Maintenance()
  Debug.trace("[CRDE] startquest::Maintenance version: " + getVersionString() )
  needsMaintenance = true
  lastVersion = getVersion()
  if getVersion() > lastVersion
    string upOrStart = "Updating to "
    if(lastVersion == 0)
      upOrStart = "Starting "
      needsMaintenance = false
    ;else 
    ; this might be a good place to force a mod refresh
    endif
    Debug.Notification(upOrStart + "Deviously Enslaved Cont. v" + getVersionString())
    Debug.trace("[CRDE] " + upOrStart + "DEC v" + getVersionString())
  endIf

	Utility.Wait(3)

	if Mods.isRunning() == false
		bool sOK = Mods.start()
		Debug.Trace("[CRDE] startquest, ModsMon startup: " + sOK)
		;(Mods as crdeModsMonitorScript).Maintenance() ; WARNING this can waitlock as start->mods.maint looks at MCM values, and MCM.init looks at Mods
    SendModEvent("crderesetmods") 
  else
    (Mods as crdeModsMonitorScript).Maintenance() 
 		;SendModEvent("crderesetmods")

	endif

	Utility.Wait(0.25)		

	if Player.isRunning() == false
		bool sOK = Player.start()
		Debug.Trace("[CRDE] startquest, PlayerMon startup: " + sOK)
	else
		(Player as crdePlayerMonitorScript).Maintenance()
	endif
EndFunction


Event OnInit()
  Debug.trace("[CRDE] StartQuest: Init")
  ;Utility.Wait(3.0)
  needsMaintenance = true
  RegisterForSingleUpdate(1)
  
EndEvent

Event onUpdate()
  Debug.trace("[CRDE] startquest::onUpdate ...")
  if needsMaintenance == true && !Utility.IsInMenuMode()
    Maintenance()
  else
    Debug.Trace("[crde] startquest::onupdate, don't need to update")
  endif
  ;(Mods as crdeModsMonitorScript).OnUpdate() ; always turn this on, now that we've turned off Mods's ability to keep itself alive
  ;RegisterForSingleUpdate(100) ; this is getting called forever, do we need it forever?
EndEvent
