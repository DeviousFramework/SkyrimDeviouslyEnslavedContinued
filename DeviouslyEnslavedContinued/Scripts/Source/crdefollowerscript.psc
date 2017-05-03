Scriptname crdeFollowerScript extends ReferenceAlias  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Follower
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

; this is a catch all for now, might split this into master script or just leave them as one, not sure

;crdeStartQuestScript Property Startup  Auto  
crdePlayerMonitorScript Property PlayerMon Auto
crdeModsMonitorScript Property Mods Auto
crdePlayerScript Property PlayerScript Auto

int Property hasEnteredCombat Auto
int Property hitByPlayer auto
; 0 is unknown, 10-19 is shout, 20-29 is spell, 30-39 is arrow, 40-49 is melee

Faction  Property CurrentFollowerFaction Auto

FormList Property itemsPutOnPlayer  auto

; places where your follower might find some ancient weird stuff
Keyword Property LocTypeDwarvenAutomatons Auto
Keyword Property LocTypeFalmerHive Auto
Keyword Property LocTypeDragonPriestLair Auto
Keyword Property LocTypeCastle Auto
Keyword Property LocTypeWarlockLair Auto
Keyword Property LocTypeClearable Auto
;loctypeclearablemightbegood

; in town "public"
Keyword Property LocTypeHabitation Auto
Keyword Property LocTypeGuild Auto
Keyword Property LocTypeInn Auto
Keyword Property LocTypeHold Auto

Event OnInit()
;zadBQ00.psc:    RegisterForModEvent("DDI_RemoveDevice", "OnDDIRemoveDevice")
  ;RegisterForModEvent("crde", "OnDDIRemoveDevice")
  RegisterForModEvent("crdePlayerSexConsentStarting", "addFollowerAddedItemEvent")
  
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
Event addFollowerAddedItemEvent(armor armorRef)
  addFollowerAddedItem(armorRef)
endEvent

; when master adds to the player, we know this because it's our mod (assuming no other interaction)
Function addFollowerAddedItem(armor armorRef)
  itemsPutOnPlayer.addform(armorRef as Form)
endFunction

bool Function WasCalmSpell(Spell s)
  MagicEffect effecttest
  int i = 0
  while i < s.GetNumEffects()
    effecttest = s.GetNthEffectMagicEffect(i)
    if effecttest == InfluenceAggDownFFAimed || effecttest == InfluenceAggDownFFAimedArea
      return true
    endif
    i += 1
  endwhile
  return false
EndFunction

; if master is hit by player, punishment
; works fine, healing counts as a hit though
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  if akAggressor == PlayerMon.player 
    if akSource as Shout
      PlayerMon.debugmsg("follower was shouted on:" + akSource.GetName() ,2)
      hitByPlayer += 1
      PlayerMon.follower_attack_type = 10
      return
    elseif akSource.HasKeyword(VendorItemArrow)
      ; TODO This doesn't count arrows summoned with conjuration
      PlayerMon.debugmsg("follower was shot with arrow:" + akSource.GetName() ,2)
      hitByPlayer += 1
      PlayerMon.follower_attack_type = 30
      return
    endif
    
    Spell spellRef = akSource as Spell
    if spellRef && spellRef.IsHostile() ; not healing spell
      if !hasEnteredCombat && WasCalmSpell(spellRef); checking for calm after combat ends
        ; drop approach, drop some frustration
        PlayerMon.debugmsg("follower has been hit with calm spell, resetting",2)
        PlayerMon.clear_force_variables(false) ; we don't want to reset follower aliases here, just the appraoch numbers
      else ; in combat, keep a tally
        ; if healed or calmed we should do other stuff too
        hitByPlayer += 1
        PlayerMon.follower_attack_type = 20
      endif
    elseif spellRef ; healing spell? what else could count as non-hostile?
      PlayerMon.debugmsg("follower has been hit with \"non-hostile\" spell, assuming healing:" + spellRef.GetName() ,2)
      PlayerMon.modFollowerFrustration( GetActorReference() , -1)
      hitByPlayer -= 1      
    endif
  endif
  
EndEvent

Event OnCombatStateChanged(Actor akTarget, Int aeCombatState)
  if aeCombatState != 0 && !hasEnteredCombat
    hasEnteredCombat = 1
    PlayerMon.debugmsg(" follower as entered combat ... ", 3)
  elseif hasEnteredCombat
    if hitByPlayer > 1
      PlayerMon.debugmsg(" follower was hit by player: " + hitByPlayer + " times", 3)
      PlayerMon.follower_thinks_player_dom = StorageUtil.GetFloatValue(akTarget, "crdeThinksPCEnjoysDom")
      PlayerMon.forceGreetFollower = 10
    endif
    hitByPlayer = 0
    hasEnteredCombat = 0
  else
    PlayerMon.debugmsg(" follower has changed combat states, under unknown condition", 3)
  endif
EndEvent


; detects if the player is in a locaiton
; for follower to get horny and find DD items
bool function isInLocationDDLootable()
  if !PlayerMon.player.GetparentCell().IsInterior()
    Location here = PlayerMon.player.GetCurrentLocation()
    if here == none || here.haskeyword(LocTypeWarlockLair) \
      || here.haskeyword(LocTypeFalmerHive) \
      || here.haskeyword(LocTypeDwarvenAutomatons) \
      || here.haskeyword(LocTypeCastle) \
      || here.haskeyword(LocTypeDragonPriestLair)  
        return true
    endif
  endif    
  return false
endFunction

; for "fun" with follower later
bool function isInPublicPlace()
  if !PlayerMon.player.GetparentCell().IsInterior()
    Location here = PlayerMon.player.GetCurrentLocation()
    if here == none || here.haskeyword(LocTypeHabitation) \
      || here.haskeyword(LocTypeGuild) \
      || here.haskeyword(LocTypeInn) \
      || here.haskeyword(LocTypeHold) 
        return true
    endif
  endif    
  return false
endFunction

; we need to check if the followers watched the player have sex, helps the follower determine if they should talk to player about becoming slave
; potential conditions: Player is victim, Player is Wearing items, Player came, Player is sucking,anal?
Function checkFollowersSawPlayerSex(int tif)
    ;	StorageUtil.SetFloatValue(actorRef, "crdeLastEval", Utility.GetCurrentRealTime()) float lastEval = StorageUtil.GetFloatValue(actorRef, "crdeLastEval")
  actor player = PlayerMon.player ; might as well, since we check like 3 times
  if player.WornHasKeyword(Mods.zazKeywordWornCollar) || player.WornHasKeyword(Mods.zazKeywordWornGag) ; todo: offer alternative zbfWornStuff, all zbf or all DD
    ;actor ourFollower = getclosestfollower() ; TODO: expand this for all followers
    ;if ourFollower != None && ourFollower.HasLOS(player)
    ;  PlayerMon.debugmsg("Follower " + ourFollower.GetDisplayName() + " saw us having sex while wearing devious gear!", 2)
    ;  ;store storageutil for that character
     ; ;ourFollower ;ZZZ
     ; ; crdeFollowerWitnessSubSex?
    ;endif
  endif
endFunction

MagicEffect Property InfluenceAggDownFFAimed Auto
MagicEffect Property InfluenceAggDownFFAimedArea Auto

Keyword Property VendorItemArrow Auto
