Scriptname crdeAttackerScript extends ReferenceAlias  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Attacker
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

crdePlayerMonitorScript Property PlayerMonitorScript Auto

MagicEffect Property InfluenceAggDownFFAimed Auto      ; calm spells
MagicEffect Property InfluenceAggDownFFAimedArea Auto

;Event OnInit()
;endEvent

; should hopefully be rather light, considering we're talking about a script only active for seconds on few characters
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  Spell calmtest = akSource as Spell
  if calmtest 
    MagicEffect effecttest
    int i = 0
    while i < calmtest.GetNumEffects()
      effecttest = calmtest.GetNthEffectMagicEffect(i)
      if effecttest == InfluenceAggDownFFAimed || effecttest == InfluenceAggDownFFAimedArea
        PlayerMonitorScript.debugmsg("attacker has been hit with calm spell, resetting",2)
        PlayerMonitorScript.clear_force_variables(true)
      endif
      i += 1
    endwhile
  endif
  
EndEvent

