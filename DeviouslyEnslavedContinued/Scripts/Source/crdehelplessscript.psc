Scriptname crdeHelplessScript extends Quest  Conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Helpless
;
; An interface to stop and clear the Deviously Helpless quest.
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
Quest helpless

function StopSceneAndClear()
  Debug.Trace("[CRDE] Clearing Helpless for real...")
  helpless = Game.GetFormFromFile(0x00000D62, "DeviouslyHelpless.esp") as quest
  (helpless as WD_Util).StopSceneAndClear()
  Debug.Trace("[CRDE] Clearing Helpless is done!")
endFunction
