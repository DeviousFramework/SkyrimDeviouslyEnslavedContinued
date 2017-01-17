ScriptName crdeTrainingEffect extends ActiveMagicEffect
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Training Effect
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
;
; 1.00 2017-01-17 by legume
; This script  was copied from zad_efftrainingplug.psc in DDi
;***********************************************************************************************

; Libraries
zadLibs                   Property Libs Auto
SexlabFramework           Property Sexlab Auto
crdePlayerMonitorScript   Property PlayMonScript Auto


; these were already here
Bool Property Terminate Auto
actor Property Target Auto

ReferenceAlias Property masterAlias Auto 


; Extend this function to set a day passed event.
Function OnTrainingDayPassed(int daysRemaining)
	if daysRemaining == 1
		libs.NotifyPlayer("You hear a single chime originating from inside of you.")
	Else
		libs.NotifyPlayer("You hear a set of "+daysRemaining+" chimes originating from inside of you.")
	EndIf
EndFunction

; Extend this function to set training completed event.
Function OnTrainingComplete() 
	libs.Log("The training plug within you lets out a chime, and begins to vibrate!")
	ModDaysRemaining(7, maxRange=GetTrainingRange())
	libs.VibrateEffect(Target, 5, 120, teaseOnly=false)
EndFunction

; Extend this function to set the maximum training duration.
int Function GetTrainingRange()
	return 7
EndFunction

; Extend this function to easily set your own criteria for violations.
Event OnTrainingViolation(string eventName, string argString, float argNum, form sender)
	libs.Log("OnTrainingViolation("+argString+")")
	if argString == "SpellCast"
		ModDaysRemaining(1, maxRange=GetTrainingRange())
		libs.NotifyPlayer("Your mental reserves are dramatically drained as the plug punishes you.")
		libs.PlayerRef.DamageAv("Magicka", 200)
	EndIf
EndEvent

Function DoRegisterModEvent()
	UnregisterForModEvent("TrainingViolation")
	RegisterForModEvent("TrainingViolation", "OnTrainingViolation")
  
	RegisterForModEvent("TrainingViolation", "OnSexStart")

EndFunction

Event OnUpdateGameTime()
	if !Terminate
		DoRegister()
	EndIf
EndEvent

float Function InitNextTickTime()
	float ret = Utility.GetCurrentGameTime() + 1.0
	StorageUtil.SetFloatValue(Target, "zad.NextTickTime", ret)
	return ret
EndFunction

Function DoRegister()
	float nextTime = StorageUtil.GetFloatValue(Target, "zad.NextTickTime", -1.0)
	if nextTime == -1.0
		nextTime = InitNextTickTime()
	EndIf
	libs.Log("DoRegister(Training):"+Utility.GetCurrentGameTime()+" / "+ nextTime)
	if !Terminate && Utility.GetCurrentGameTime() >= nextTime
		InitNextTickTime()
		int daysRemaining = ModDaysRemaining(-1, maxRange=GetTrainingRange())
		libs.Log("DoRegister(Training): Day passed. Days Remaining: "+daysRemaining +".")
		if daysRemaining == 0
			libs.Log("Player has completed training.")
			OnTrainingComplete()
		Else
			OnTrainingDayPassed(daysRemaining)
		EndIf
	EndIf
	RegisterForSingleUpdateGameTime(1.0)
EndFunction
		
int Function ModDaysRemaining(int changeBy, int maxRange) 
	int daysRemaining = StorageUtil.GetIntValue(Target, "zad.TrainingDaysRemaining", maxRange)
	int newDaysRemaining = daysRemaining + changeBy
	if newDaysRemaining <0
		newDaysRemaining = 0
	EndIf
	if newDaysRemaining > maxRange
		newDaysRemaining = maxRange
	EndIf
	InitNextTickTime()
	libs.log("Days remaining was: "+daysRemaining+". Now set to "+newDaysRemaining+".")
	StorageUtil.SetIntValue(Target, "zad.TrainingDaysRemaining", newDaysRemaining)
	return newDaysRemaining
EndFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Target = akTarget
	if Target != libs.PlayerRef
		PlayMonScript.debugmsg("OnEffectStart(Training): Not player, doing nothing.")
	else
    actor master = masterAlias.GetActorRef()
    if master == None  
      PlayMonScript.debugmsg("OnEffectStart(Training): player is plugged but no master")
    else
      PlayMonScript.debugmsg("OnEffectStart(Training), player has master: " + master.GetDisplayName())
    endif
		Terminate = False
		DoRegisterModEvent()
		DoRegister()
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Terminate = True
	UnregisterForModEvent("TrainingViolation")
	UnregisterForUpdateGameTime()
	libs.Log("OnEffectFinish(Training)")
EndEvent

Event OnLoad()
	if Target == libs.PlayerRef
		DoRegisterModEvent()
		DoRegister()
	Endif
EndEvent

Event OnSexStart(int tid, bool HasPlayer)
  sslThreadController Thread = SexLab.GetController(tid)
  ;sslActorAlias[] property ActorAlias auto hidden
  sslActorAlias[] actors = Thread.ActorAlias ; passed compiler, will it pass the rest?
  
  actor player = None
  int i = 0
  while i < 5
    if actors[i] != None && actors[i].isPlayer
      player = actors[i]
    endif
  endWhile

EndEvent

