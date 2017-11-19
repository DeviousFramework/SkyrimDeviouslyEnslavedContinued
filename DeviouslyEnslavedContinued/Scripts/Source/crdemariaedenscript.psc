Scriptname crdeMariaEdenScript extends Quest  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Maria Eden
;
; Todo: Not sure what this does yet.
;
; This whole script is a mess with a mix and match of different coding styles from different
; developers and learning levels.
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

crdeMCMScript Property MCM Auto
crdePlayerMonitorScript Property PlayerMon Auto
crdeModsMonitorScript Property Mods Auto

;MariaEdensTools Property MariaTools Auto 
;MariaEdenDefeatStarter Property MariaDefeat Auto ; bad for soft mods
bool Property khajitEnslaveRanPreviously Auto

Event OnInit()
  Utility.wait(2)
  while Mods.finishedCheckingMods == false
    Debug.Trace("[crde]in maria eden:mods not finished yet", 1)
    Utility.wait(2) ; in seconds
  endWhile
endEvent

; enslave with target NPC
function enslave(actor actorRef = none)
  ;if getVersion() >= 2.0
  if true
    int handle = ModEvent.Create("MariaPlayerEnslaveBy")
    if(handle)
      if actorRef == None
        ; find some vanilla actor that isn't none?
        Mods.debugmsg("ERROR: Maria eden enslave called without an actor",5)
        return
      endif
      ModEvent.PushForm(handle, actorRef as Form)
      ModEvent.Send(handle)
      ; to stop DEC from getting in the way in the next 5 minutes
      PlayerMon.timeoutGameTime = Utility.GetCurrentGameTime() + (1*(1.0/24.0)) ; 1 hour
    else
      Mods.debugmsg("ERROR: Maria Eden failed to create handle",5)
    endif;;

  else
    Quest meSlave = Mods.meSlaveQuest
    (meSlave as MariaEdensTools).Enslave(actorRef, 0)
    ;  Mods.debugmsg("ERROR: Calling ME Enslave through tools is deprecaited, doing nothing",5)

  endif
  
endFunction

; there are other ways to enter maria's eden, right? maybe we can use those too, for the slave holders for instance
; deprecated, never used after 1.2
;function abduction(actor actorRef = none)
;  Quest meSlave = Mods.meSlaveQuest
;  (meSlave as MariaEdensTools).Abduction(actorRef) 
;endFunction

;person tries to sell you to khajit
; deprecated, never used after 1.2
;function defeat(actor actorRef = none)
;  khajitEnslaveRanPreviously = true
;  MariaEdensTools.DefeatPlayer(actorRef)
;endFunction

; person tries to sell you to khajit
; code kanged from maria eden's DA start script MaraiEdenDefeatStarter, doesn't require script declare
function defeat2(actor actorRef = none)
  
  int handle = ModEvent.Create("MariaPlayerDefeatBy")
  ;int result
  if handle
    ModEvent.PushForm(handle, actorRef as Form)
    ModEvent.Send(handle)
    khajitEnslaveRanPreviously = true
  else
    PlayerMon.debugmsg("ERR: Maria Eden Defeat has failed: handle does not exist")
  endif
endFunction

ReferenceAlias function getMaster()
  ;ReferenceAlias master = (Mods.meSlaveQuest as MariaEdensTools).TheMaster as ReferenceAlias
  ;return master
  Mods.debugmsg("ERROR: Getting Maria Master is no longer possible",5)

endFunction

; need because some features require certain versions
float function getVersion()
  ; TODO need to fix this for the new Maria
endFunction

; I'm not even sure this does anything right now, since you're permanently a slave under maria's eden it seems
bool function khajit_ran_previously()
  return khajitEnslaveRanPreviously
endFunction
