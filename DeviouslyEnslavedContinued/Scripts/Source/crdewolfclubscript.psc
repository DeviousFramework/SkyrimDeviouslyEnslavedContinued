Scriptname crdeWolfclubScript extends Quest conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Wolf Club
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
bool Property canRunQuest auto conditional

crdeModsMonitorScript Property Mods Auto

event OnInit()
  Utility.wait(10)
  while Mods.finishedCheckingMods == false
    Debug.Trace("[crde]in wolfclub:mods not finished yet", 1)
    Utility.wait(2) ; in seconds
  endWhile
  RegisterForModEvent("crdeStartWolflcubQuest", "enslave")
endEvent

function enslave(actor actorRef = none)
  ; broken zombie  code, works but isn't soft dependency??? missing conclusive proof
  ;Quest wolfclub = (Quest.getQuest("crdeModsMonitor") as crdeModsMonitorScript).wolfclubQuest
  ;(wolfclub as pchsWolfclubDAYMOYL).QuestStart(none, none, none)
  ;(Mods.wolfclubQuest as pchsWolfclubDAYMOYL).QuestStart(none, none, none)
  ;Mods.wolfclubQuest.QuestStart(none, none, none) ; Can I not just start the quest without the specifics? NOPE, why the fuck have inheritance then bethesda?
  
  ; old method, works without bugging out, right?
  ;Quest wolfclub = (Quest.getQuest("crdeModsMonitor") as crdeModsMonitorScript).wolfclubQuest
  ;(wolfclub as pchsWolfclubDAYMOYL).QuestStart(none, none, none)
  
  ; lets try a try get instead, getting the quest from the ether rather than from a dependency
    ; nope, still issues for some users
  ;Quest wolfclub = (Quest.GetQuest("pchsWolfclub"))
  ;(wolfclub as pchsWolfclubDAYMOYL).QuestStart(none, none, none)
  
  ; mod event might work better, if we can get it to work
  SendModEvent("WolfClubEnslavePlayer") ; maybe this one is broken?
endFunction

bool function canRun()
  
  ; maybe this code is what was giving me greif? I doubt it frankly.
  ;Quest wolfclub = Mods.wolfclubQuest
  ;if (wolfclub.getStage() > 0 || wolfclub.isRunning() == false)
  
  if Mods.modLoadedWolfclub == false
    canRunQuest = false
    return false
  else
    canRunQuest = true
    return true
  endif
endFunction
