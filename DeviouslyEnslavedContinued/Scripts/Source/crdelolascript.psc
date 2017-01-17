Scriptname crdeLolaScript extends Quest
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Lola
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

; definitions
crdeModsMonitorScript Property Mods auto
crdePlayerMonitorScript Property PlayerMon auto
;import SlaveTats
Quest Property SlaveTatsQuest auto
Actor player 
;SlaveTats Property STlibs auto

;init, might not need this one here
Event OnInit()
; wait for mods to finish
  Utility.wait(8) ; in seconds
  while Mods.finishedCheckingMods == false
    Debug.Trace("[crde]in lola, mods not finished yet", 1)
    Utility.wait(2) ; in seconds
  endWhile

  player = Game.GetPlayer() ; not even sure if I need this yet, or ever  
EndEvent

Actor Function GetOwner()
  if Mods.lolaDSMainQuest != None ; using this for now
    return (Mods.lolaDSMainQuest as vkjMQ).Owner.GetReference() as actor
  endif
  return none
EndFunction

