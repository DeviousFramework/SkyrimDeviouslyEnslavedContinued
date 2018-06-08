Scriptname crdeSlaverunScript extends Quest conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Slaverun
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

crdeMCMScript Property MCM Auto
crdeModsMonitorScript Property Mods Auto
crdePlayerMonitorScript Property PlayerMonitor Auto
bool Property canRunQuest auto conditional

;Quest 


; Event OnInit()
  ;try to load something from slaverun reloaded
  ; if SlaverunReloaded
    
  ; endif
; EndEvent

;old function, leave it here as legacy
bool function SlaverunEnslaveEligible()
  return canRun()
endFunction

; for now,
function enslave(actor actorRef = none, bool local = true)  ; Slaverun

  if Mods.modLoadedSlaverun
    Quest slaverun_quest = game.getformfromfile(0x00011cbe, "slaverun.esp") as Quest
    ;GetOwningQuest().setstage(30)
    slaverun_quest.setstage(30)
    ;GetOwningQuest().SetObjectiveCompleted(0)
    slaverun_quest.SetObjectiveCompleted(0)
    ;GetOwningQuest().SetObjectiveCompleted(10)
    slaverun_quest.SetObjectiveCompleted(10)
    Actor pla = Game.GetPlayer()
    ; alt: slave gear chest: 010c70, 
    ; can we remove DD items first?
    PlayerMonitor.ItemScript.removeDDbyKWD(PlayerMonitor.player, Keyword.GetKeyword("zad_DeviousCollar")) ; these might work
    PlayerMonitor.ItemScript.removeDDbyKWD(PlayerMonitor.player, Keyword.GetKeyword("zad_DeviousArmCuffs"))
    
    pla.RemoveAllItems(game.getformfromfile(0x000111ee , "slaverun.esp") as ObjectReference)
    ;pla.RemoveAllItems(StashContainer)
    pla.EquipItem(game.getformfromfile(0x0001f6c5, "slaverun.esp") as Armor)
    pla.EquipItem(game.getformfromfile(0x0001f6c6, "slaverun.esp") as Armor)
    pla.EquipItem(game.getformfromfile(0x0001f6c7, "slaverun.esp") as Armor)
    pla.UnequipSpell(pla.GetEquippedSpell(0),0)
    pla.UnequipSpell(pla.GetEquippedSpell(1),1)
    pla.UnequipSpell(pla.GetEquippedSpell(2),2) ; unequip all spells
  elseif Mods.modLoadedSlaverunR  
    ; need quest stages and what happens when
    ; is the location already enslaved?
    ; is the player in whiterun?
    ; has the player been enslaved before?
    ; for now, just use the regular entrance
    if isPlayerInWhiterun()
      ; player is in whiterun, let's do the soft enslave
      ; kanged straight from the fragment, attached to slv_mainquest
      ;(Mods.slaverunRMCMQuest as SLV_Utilities).enslavement(Self) ;<- don't know what this does
      (Mods.slaverunRMCMQuest as SLV_Utilities).SLV_enslavement() ; new

      PlayerMonitor.player.AddToFaction(Mods.zazFactionSlave) 
      Mods.slaverunRMainQuest.SetObjectiveCompleted(250)
      Mods.slaverunRMainQuest.SetStage(1000)

      Mods.slaverunRTrainingQuest.Reset() 
      Mods.slaverunRTrainingQuest.Start() 
      Mods.slaverunRTrainingQuest.SetActive(true) 
      Mods.slaverunRTrainingQuest.SetObjectiveCompleted(0)
      Mods.slaverunRTrainingQuest.SetStage(350) ; 100 causes rape too
    else
      ; not in whiterun, send to mundus through express mail
      Mods.DistantEnslaveScript.enslaveSlaverunRSold()
    endif
  endif
  
endFunction

; we need to handle all of the conditions we can't test for at dialog time here
bool function canRun()
  ;todo convert this to boolean
  ; Game.GetPlayer().IsInLocation(WhiterunProperty) ; too many false positives (everywhere, this covers the whole hold)  
  ;if Mods.modLoadedSlaverun && MCM.bSlaverunEnslaveToggle && Game.GetPlayer().IsInLocation(WhiterunProperty)
  if  MCM.bSlaverunEnslaveToggle && MCM.iEnslaveWeightSlaverun > 0
  ; if this works, it will match the exact conditions slaverun uses
  ; we wait until we're this far so as to avoid calling a function in a esp we don't have, or won't use
    ;if (Quest.getQuest("SlaverunPeriodicChecking") as SlaverunPeriodicCheck).PlayerIsInEnforcedLocation()
    ;if Mods.slaverunEnforcerQuest.PlayerIsInEnforcedLocation() ; Fine, I'll just copy it then, 
    if Mods.modLoadedSlaverun && Game.GetPlayer().IsInFaction(Mods.slaverunSlaveFaction) == false  && PlayerIsInEnforcedLocation()
      ;&& (Mods.slaverunSlaveQuest.GetStage() < 20)
      canRunQuest = true
      PlayerMonitor.debugmsg("canrun:Slaverun true")
      return canRunQuest
    elseif Mods.modLoadedSlaverunR  && Game.GetPlayer().IsInFaction(Mods.slaverunSlaveFaction) == false && PlayerIsInEnforcedLocation()
      canRunQuest = true
      PlayerMonitor.debugmsg("canrun:Slaverun true")
      return canRunQuest
    endif

  endIf
  canRunQuest = false
  return canRunQuest
  
endFunction

; if skyrim doesn't want me to use this function as it was in slaverunenforcer, then I'll just copy it
;  with slaverun reloaded, this function is huge, use what slaverunReloaded uses
Bool Function PlayerIsInEnforcedLocation()
  if Mods.modLoadedSlaverunR 
    if Mods.slaverunRPeriodicQuest == None
      Mods.debugmsg("Err: SRR installed but period quest did not load!",4)
    else
      return (Mods.slaverunRPeriodicQuest as SLV_EnforcerLocationCheck).PlayerIsInEnforcedLocation()
    endif
  elseif Mods.modLoadedSlaverun
    return isPlayerInWhiterun()
  endif
  return false
endFunction
  
bool Function isPlayerInWhiterun()
  Actor PlayerRef = Game.GetPlayer()
  PlayerCurrentWorld     = PlayerRef.GetWorldSpace()
  PlayerCurrentLocation   = PlayerRef.GetCurrentLocation()
  if PlayerCurrentLocation == WhiterunBreezehomeLocation
    return false
  endif
  if PlayerCurrentWorld == WhiterunWorld ;|| PlayerCurrentLocation == WhiterunAmrensHouseLocation
    return true
  endif
  if PlayerCurrentLocation == WhiterunArcadiasCauldronLocation || PlayerCurrentLocation == WhiterunBanneredMareLocation
    return true
  endif
  if PlayerCurrentLocation == WhiterunBelethorsGeneralGoodsLocation ;|| PlayerCurrentLocation == WhiterunCarlottaValentiasHouseLocation
    return true
  endif
  if PlayerCurrentLocation == WhiterunDragonsreachBasementLocation
    return true
  endif
  if PlayerCurrentLocation == WhiterunDragonsreachLocation
    return true
  endif
  if PlayerCurrentLocation == WhiterunDrunkenHuntsmanLocation
    return true
  endif
  if PlayerCurrentLocation == WhiterunGuardHouseLocation
    return true
  endif
  If PlayerCurrentLocation == WhiterunHeimskrsHouseLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunHouseGrayManeLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunHouseofClanBattleBornLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunHouseoftheDeadLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunJailLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunJorrvaskrBasementLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunJorrvaskrLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunOlavatheFeeblesHouseLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunSeverioPelagiasHouseLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunTempleofKynarethLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunUlfberthsHouseLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunUnderforgeInteriorLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunUthgerdTheUnbrokensHouseLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunWarmaidensLocation 
    return true
  endif
  If PlayerCurrentLocation == WhiterunYsoldasHouseLocation
    return true
  endif
  return false
endFunction

WorldSpace PlayerCurrentWorld = none
Location PlayerCurrentLocation = none

Location Property WhiterunAmrensHouseLocation auto
Location Property WhiterunArcadiasCauldronLocation auto
Location Property WhiterunBanneredMareLocation auto
Location Property WhiterunBelethorsGeneralGoodsLocation auto
Location Property WhiterunBreezehomeLocation auto
Location Property WhiterunCarlottaValentiasHouseLocation auto
Location Property WhiterunDragonsreachBasementLocation auto
Location Property WhiterunDragonsreachLocation auto
Location Property WhiterunDrunkenHuntsmanLocation auto
Location Property WhiterunGuardHouseLocation auto
Location Property WhiterunHeimskrsHouseLocation auto
Location Property WhiterunHouseGrayManeLocation auto
Location Property WhiterunHouseofClanBattleBornLocation auto
Location Property WhiterunHouseoftheDeadLocation auto
Location Property WhiterunJailLocation auto
Location Property WhiterunJorrvaskrBasementLocation auto
Location Property WhiterunJorrvaskrLocation auto
Location Property WhiterunOlavatheFeeblesHouseLocation auto
Location Property WhiterunSeverioPelagiasHouseLocation auto
Location Property WhiterunTempleofKynarethLocation auto
Location Property WhiterunUlfberthsHouseLocation auto
Location Property WhiterunUnderforgeInteriorLocation auto
Location Property WhiterunUthgerdTheUnbrokensHouseLocation auto
Location Property WhiterunWarmaidensLocation auto
Location Property WhiterunYsoldasHouseLocation auto
Location Property WhiterunProperty  Auto


Worldspace Property WhiterunWorld auto

; old variables now collected as needed
;ObjectReference Property StashContainer  Auto  

;Armor Property Item01  Auto  
;Armor Property Item02  Auto  
;Armor Property Item03  Auto 
