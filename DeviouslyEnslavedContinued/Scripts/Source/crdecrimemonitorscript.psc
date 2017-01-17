Scriptname crdeCrimeMonitorScript extends Quest
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Crime Monitor
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
crdeModsMonitorScript Property Mods auto ; not sure if we can even use this
crdePlayerMonitorScript Property PlayerMon auto
;import SlaveTats
;Quest Property SlaveTatsQuest auto
Actor player 
;SlaveTats Property STlibs auto

;init, might not need this one here
;Event OnInit()
  ; do we even need anything?
  ;player = Game.GetPlayer()
;EndEvent

; doesn't work, god damn it
Event OnStoryCrimeGold(ObjectReference akVictim, ObjectReference akCriminal, Form akFaction, int aiGoldAmount, int aiCrime)
  ;Debug.Trace( "OnStoryCrimeGold fired ...")
  if akCriminal == Game.GetPlayer() as ObjectReference ; slow I know, just testing for now
    String crime = ""
    if aiCrime == -1
      crime = " odd case "
    elseif aiCrime == 0
      crime = " stealing case "
    elseif aiCrime == 1
      crime = " pickpocketing case "
    endif  
    PlayerMon.debugmsg( ("Player caught with faction: " + akFaction + " while doing:" + crime + "gold:" + aiGoldAmount) , 0)
  endif 
   
  ;PlayerMon.debugmsg( ("Player caught with faction: " + akFaction + " while doing:" + crime + "gold:" + aiGoldAmount) , 0)
  Stop()
	Reset()
EndEvent
