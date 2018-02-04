Scriptname crdePlayerScript extends ReferenceAlias  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Attacker
;
; Extends the script of the player to handle any events generated by the player.
;
; Many thanks to Chase Roxand and Verstort for all of their original work on this mod.
;
; � Copyright 2017 legume-Vancouver of GitHub
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

crdeStartQuestScript    Property Startup  Auto  
crdePlayerMonitorScript Property PlayerMonitorScript Auto
crdeModsMonitorScript   Property Mods Auto

;GlobalVariable Property crdeInvChange auto ; ignore for now
GlobalVariable Property crdeModEnabled auto ; ignore for now

bool Property equipmentChanged Auto
bool Property weaponChanged Auto
bool Property sittingInZaz Auto
bool Property releasedFromZaz Auto
bool Property isZazSexlabFurniture Auto

FormList Property playersRemovedItems Auto

; needs detailed description
Event OnPlayerLoadGame()
  Startup.needsMaintenance = true
  Startup.RegisterForSingleUpdate(2)
  equipmentChanged  = true
  weaponChanged     = true
  if Mods.bRefreshModDetect
    SendModEvent("crdemodsreset")
  endif
EndEvent

; we only need to test if the player is vulnerable when equipment changes
;  however, if we check once per item change, we might swamp the script engine if > 6 items get changed all at once
;  so instead, we set the variable to check, and we check once every onUpdate loop like before, we just don't need 
;  to check if no items are being swapped, should be a tad lighter on the scripts
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  
  if akBaseObject as Armor ; aparently eating/potions/herbs counts as equiping, also weapons
    equipmentChanged  = true
  ;elseif akBaseObject as Weapon
  ;  weaponChanged     = true
  endif
  weaponChanged = true ; just always check weapon for now

  ;if PlayerMonitorScript.playerIsWeaponDrawnProtected()
  ;  ; player is now protecting themselves, 
  ;endif
  ;PlayerMonitorScript.equipmentChanged = true
  ;crdeInvChange.SetValue(1)
endEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
  ; COULD put clause to check if player was already vulnerable first, you can't become vulnerable from not
  
  ; we should check if the mod is active and/or if the player is enslaved
  if akBaseObject != None && crdeModEnabled.GetValueInt() == 1 && PlayerMonitorScript.enslavedLevel != 3
    
    if akBaseObject as Armor ; apparently eating/potions/herbs counts as equiping, also weapons
      equipmentChanged = true
      ;if playersRemovedItems != None ; for now, since we're not really using stuff anyway
      ;  playersRemovedItems.addForm(akBaseObject)
      ;endif
    elseif akBaseObject as Weapon
      weaponChanged     = true
    endif
  endif
  ;PlayerMonitorScript.equipmentChanged = true
  ;(PlayerMonitorScript).equipmentChanged = true
  ;crdeInvChange.SetValue(1)
EndEvent

Event OnSit(ObjectReference akFurniture)
  if akFurniture.hasKeyword(Mods.zazKeywordFurniture)
    releasedFromZaz = false
    sittingInZaz    = true
  endif
  ; sexlab specific furniture, treat differently
  if akFurniture.hasKeyword(Mods.zazFurnitureMilkOMatic) || akFurniture.hasKeyword(Mods.zazFurnitureMilkOMatic2) || akFurniture.hasKeyword(Mods.zazFurnitureFuroTub1)
    isZazSexlabFurniture = true
  else
    isZazSexlabFurniture = false
  endif
EndEvent

Event OnGetUp(ObjectReference akFurniture)
  if akFurniture.hasKeyword(Mods.zazKeywordFurniture)
    sittingInZaz    = false
    releasedFromZaz = true
  endif
EndEvent


;Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
;endEvent


;bool Function getEquipmentChanged()
;  return equipmentChanged
;EndFunction
