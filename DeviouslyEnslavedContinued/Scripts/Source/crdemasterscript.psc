Scriptname crdeMasterScript extends ReferenceAlias  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Master
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

;crdeStartQuestScript Property Startup  Auto  
crdePlayerMonitorScript Property PlayerMonitorScript Auto
crdeModsMonitorScript Property Mods Auto
crdePlayerScript Property PlayerScript Auto

int Property hasEnteredCombat Auto
int Property hitByPlayer auto

FormList Property itemsPutOnPlayer auto

float property follower_enjoys_dom            auto
float property follower_enjoys_sub            auto
float property follower_thinks_player_sub     auto
float property follower_thinks_player_dom     auto
float property follower_frustration           auto

function updateFollowerOpinions(actor actorRef)
  follower_enjoys_dom           = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysDom")
  follower_enjoys_sub           = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysSub") 
  follower_thinks_player_sub    = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysSub")
  follower_thinks_player_dom    = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysDom") 
  follower_frustration          = StorageUtil.GetFloatValue(actorRef, "crdeFollowerFrustration")
endFunction


Event OnInit()
;zadBQ00.psc:    RegisterForModEvent("DDI_RemoveDevice", "OnDDIRemoveDevice")
  ;RegisterForModEvent("crde", "OnDDIRemoveDevice")
  RegisterForModEvent("crdePlayerSexConsentStarting", "addMasterAddedItemEvent")
  
  ; reset formlist
  itemsPutOnPlayer.Revert()
endEvent

; looks like the DDi function isn't called internally, only for external use by other mods
;  so we can't expect it to fire for all itemsPutOnPlayer
; however, we can detect if the player takes off ANY item
;  and then just call this function from the player script where it has to exist
; we COULD, instead, check against all current worn items the player is wearing and focus on that instead,
;  which could be a lot slower (n2 > n1)
function RefreshPlayerRemovedItems()
  int i = 0
  int size = PlayerScript.playersRemovedItems.GetSize()
  while i < size
    armor armorRef = PlayerScript.playersRemovedItems.GetAt(i) as armor
    if itemsPutOnPlayer.HasForm(armorRef)
      itemsPutOnPlayer.RemoveAddedForm(armorRef)
    endif
    ; remove the item from the recent list since we're done checking it
    PlayerScript.playersRemovedItems.RemoveAddedForm(armorRef)
    i += 1
  endWhile
  
endFunction

; decided this might be faster for our given purposes than calling the function, maybe not
;  too bad the compiler can't inline for shit
Event addMasterAddedItemEvent(armor armorRef)
  addMasterAddedItem(armorRef)
endEvent

; when master adds to the player, we know this because it's our mod (assuming no other interaction)
Function addMasterAddedItem(armor armorRef)
  itemsPutOnPlayer.addform(armorRef as Form)
endFunction

; if master is hit by player, punishment
; works fine, healing counts as a hit though
;Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
;  if akAggressor == PlayerMonitorScript.player 
;    Spell healTest = akSource as Spell
;    if healTest && healTest.IsHostile()
;      hitByPlayer += 1
;    endif
;    ;PlayerMonitorScript.debugmsg("player attacked master detected",5)
;    ; send modevent to catch
 ; endif
  
;EndEvent

; for now this doesn't get used, turn it off

;Event OnCombatStateChanged(Actor akTarget, Int aeCombatState)
;  if aeCombatState != 0 && !hasEnteredCombat
;    hasEnteredCombat = 1
;    PlayerMonitorScript.debugmsg(" master as entered combat ... ", 3)
;  elseif hasEnteredCombat
;    PlayerMonitorScript.debugmsg(" master was hit by player: " + hitByPlayer + " times", 3)
;    hitByPlayer = 0
;    if hitByPlayer > 1
;      PlayerMonitorScript.forceGreetFollower = 10
;    endif
;    hasEnteredCombat = 0
;  else
;    PlayerMonitorScript.debugmsg(" master has changed combat states, under unknown condition", 3)
;  endif
;EndEvent



; Eventually, we'll want an onorgasm detection to detect if the master fucked their slave


  ; ObjectReference PlayerRef = Game.GetPlayer()
  ; Bool boHitByMagic = FALSE  ; True if likely hit by Magic attack.
  ; Bool boHitByMelee = FALSE  ; True if likely hit by Melee attack.
  ; Bool boHitByRanged = FALSE ; True if likely his by Ranged attack.

  ; Weapon krHand = kSlave.GetEquippedWeapon()
  ; Weapon klHand = kSlave.GetEquippedWeapon( True )


  ; IF (akAggressor == PlayerRef) ; && PlayerRef.IsInCombat() && akAggressor.IsHostileToActor(PlayerRef)

    ; IF ((kSlave.GetEquippedItemType(0) == 8) || (kSlave.GetEquippedItemType(1) == 8) \
            ; || (kSlave.GetEquippedItemType(0) == 9) || (kSlave.GetEquippedItemType(1) == 9))  && akProjectile != None
      ; boHitByMagic = TRUE

    ; ELSEIF (kSlave.GetEquippedItemType(0) != 7) && (akProjectile == None) && ((kSlave.IsWeaponDrawn())) && (krHand || klHand)
      ; boHitByMelee = TRUE

    ; ELSEIF (kSlave.GetEquippedItemType(0) == 7) && (kSlave.IsWeaponDrawn()) && (krHand || klHand)
      ; boHitByRanged = TRUE

;    ENDIF
;  ENDIF

;  If  ((boHitByMelee) || (boHitByRanged)) && (!boHitByMagic) ; (!fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableFight"))
;    Debug.Messagebox( "Your collar compels you to drop your weapon when attacking your owner." )

;    ; Drop current weapon
;    if(kSlave.IsWeaponDrawn())
;            kSlave.SheatheWeapon()
;            Utility.Wait(2.0)
;    endif

;    If ( krHand )
    ;       kSlave.DropObject( krHand )
;            kSlave.UnequipItem( krHand )
;    EndIf
;    If ( klHand )
    ;       kSlave.DropObject( klHand )
;            kSlave.UnequipItem( klHand )
;    EndIf

;    enslavement.PunishSlave(kMaster,kSlave,"Yoke")

;    If (fctSlavery.ModMasterTrust( kMaster, -1)<0)
;      ; add punishment
;      Int iRandomNum = Utility.RandomInt(0,100);
;
;      if (iRandomNum > 70)
;        ; Whipping
;        ; _SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 5 )
;        kMaster.SendModEvent("PCSubWhip")
;      Else
;        ; Punishment
;        ; _SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 3, aiValue2 = RandomInt( 0, _SDGVP_punishments.GetValueInt() ) )
;        kMaster.SendModEvent("PCSubPunish")
;      EndIf
;    Endif
;  EndIf
