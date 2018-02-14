Scriptname crdeItemManipulateScript extends Quest 
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Item Manipulation
;
; Manipulates items on the player.
; This functionality was taking too much space in the Player Monitor Script.  Moved here.
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

zadLibs         Property libs Auto
ZadXLibs         Property libsx Auto
SexLabFramework Property SexLab Auto

crdePlayerMonitorScript   Property PlayerMon Auto
crdeMCMScript             Property MCM Auto
crdeModsMonitorScript     Property Mods Auto

actor Property player auto

; these are armors to be equipped on the player or other, 
;Formlist Property followerArmorFormList Auto ; don't think I'll end up using this... 

Armor Property previousBelt Auto ; for reapplication
Armor Property previousGag Auto ; for reapplication

;Armor[] Property PlayerMon.petGear  Auto  ; ebonite collar should be in the back

Outfit Property BallandChainRedOutfit Auto
Outfit Property BlackPonyMixedOutfit Auto

; one day I will be lubed enough to move this shit over here to this class
;Armor[] Property randomDDxCuffs  Auto  
;Armor[] Property randomDDxRGlovesBoots  Auto 
Armor[] Property randomDDxHarnesss  Auto  ;switching to locking slave harness, because no chastity or collar req
;Armor[] Property randomDDVagPlugs  Auto  
;Armor[] Property randomDDVagPiercings  Auto 
Armor[] Property randomDDNipplePiercings  Auto 
;Armor[] Property randomDDGags  Auto  
;Armor[] Property randomDDCollars  Auto  
;Armor[] Property randomDDArmbinders  Auto  
Armor[] Property randomDDYokes Auto
Armor[] Property randomDDBlindFolds Auto
;Armor[] Property randomDDHoods Auto for now hoods are soft depenedency due to DDi4 schism
; punishment version
Armor[] Property randomDDPunishmentVagPlugs  Auto  
Armor[] Property randomDDPunishmentAnalPlugs  Auto  
Armor[] Property randomDDPunishmentVagPiercings  Auto 

Race[] Property alternateRaces Auto

; todo, break this into individual keywords, since the creation kit is a fickle bitch
Keyword[] Property deviceKeywords  Auto 

; for when we already know what we want to equip at dialogue time
Armor[] Property followerFoundArmorBuffer Auto

bool  actorWearingArmbinder        
bool  actorWearingBlindfold       
bool  actorWearingCollar           
bool  actorWearingGag              
bool  actorWearingPiercings        
bool  actorWearingHarness          
bool  actorWearingSlaveBoots      
bool  actorWearingAnkleChains      
bool  actorWearingBelt             

armor actorKnownArmbinder
armor actorKnownBlindfold
armor actorKnownCollar
armor actorKnownGag
armor actorKnownBelt
armor actorKnownHarness
armor actorKnownSlaveBoots
armor actorKnownAnkleChains



Event OnInit()
  player = Game.GetPlayer()
  followerFoundArmorBuffer = new Armor[10]
endEvent

; just from player, was meant to clear armor quickly, not sure if it's even still being used 
function removeDDs(actor targetActor = none, bool hasChastityKey = true, bool hasRestraintsKey = true)
  ; bool cursedLootOnly = PlayerMon.isBlockFromDCURItemsOnly()
 
  ; if player.WornHasKeyword(libs.zad_DeviousCollar); && !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric))
   ; if PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric) && (!cursedLootOnly || !MCM.bEnslaveLockoutDCUR)
     ; debugmsg("not enslaved: zad block generic detected, but only on DCUR items", 3)
   ; else
     ; removeDDbyKWD(player, libs.zad_DeviousCollar)
   ; endif
 ; endif
 ; if player.WornHasKeyword(libs.zad_DeviousArmbinder) 
   ; if PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric) && (!cursedLootOnly || !MCM.bEnslaveLockoutDCUR)
     ; debugmsg("not enslaved: zad block generic detected, but only on DCUR items", 3)
   ; else
     ; removeDDbyKWD(player, libs.zad_DeviousCollar)
   ; endif
  ; endif
  ; if player.WornHasKeyword(libs.zad_DeviousGag) 
    ; removeDDbyKWD(player, libs.zad_DeviousGag)
    ;;removeDDbyArmor(PlayerMon.knownGag)
  ; endif
  ; if player.WornHasKeyword(libs.zad_DeviousBlindFold) 
    ; removeDDbyKWD(player, libs.zad_DeviousBlindFold)
    ;;removeDDbyArmor(PlayerMon.knownBlindfold)
  ; endif
  ; if targetActor == none
    ; targetActor = player
  ; endif
  
  ; borrowed from kimy, modified
  Armor id    ; inventory device, physical device that exists in the inventory
  Armor rd    ; rendered device, the device that shows on the player, depending on circumstances
  Keyword kw  ; keyword we want to check against
  if !targetActor.WornHasKeyword(libs.zad_Lockable)
    ; no DD items equipped, can abort here
    return
  endif   
  bool playerHasBlockingKeyword = player.WornHasKeyword(libs.zad_BlockGeneric) ; only need to call this once
  int i = deviceKeywords.length 
  While i > 0
    i -= 1
    kw = deviceKeywords[i]    
    if targetActor.wornhaskeyword(kw)
      id = libs.GetWornDevice(targetActor, kw)
      if id
        rd = libs.GetRenderedDevice(id)
      Endif     
      If id && rd       
        ; dcur_removableBlockedItems.Find(tmp_armor) == -1
        if playerHasBlockingKeyword  
          if  id.HasKeyword(libs.zad_BlockGeneric) || rd.HasKeyword(libs.zad_BlockGeneric) 
            ; need to check if the item is cursed loot removable or not
            if !MCM.bEnslaveLockoutDCUR && Mods.modLoadedCursedLoot \
               && Mods.dcur_removableBlockedItems.Find(id) > 0 ; we look 
              ; TODO TODO
              libs.removeDevice(targetActor, id, rd, kw, false, skipevents = false, skipmutex = true)      
              Utility.Wait(0.5)
            else
              PlayerMon.debugmsg("Cannot remove " + id +" because its blocked")
              ; do nothing
            endif
        
          else 

            if targetActor == player  && libs.IsLockJammed(targetActor, kw)
              ; we don't remove jammed devices if we're removing generic devices only
              PlayerMon.debugmsg("Cannot remove " + id + " because the lock is jammed")
            ; for now, lets see what happens if we leave this out
            ; Elseif rd.HasKeyWord(dcur_kw_QuestItem)
              ; ;That's a quest item. Needs to be taken off with the proper routine
              ; libs.RemoveQuestDevice(targetActor, id, rd, kw, dcur_kw_QuestItem, destroyDevice = destroyDevices, skipMutex = true)
            Else
              libs.removeDevice(targetActor, id, rd, kw, false, skipevents = false, skipmutex = true)      
              Utility.Wait(0.5)
            EndIf
            
          endif
        endif   
      Endif
    endif
  EndWhile
  
  PlayerMon.updateWornDD(); good idea
  ; TODO add other items that we might want to remove, like cuffs/belts
  ;TODO add specifics for specialty colars later

endFunction

function removeDDbyArmor(actor actorRef, armor armorRef)
  keyword kwd = libs.GetDeviceKeyword(armorRef)
  armor rndrd = libs.GetRenderedDevice(armorRef)
  libs.removeDevice(actorRef, armorRef, rndrd, kwd)
  if armorRef != None && armorRef.haskeyword(libs.zad_DeviousBelt)
    previousBelt = armorRef
  endif
endFunction

function removeDDbyKWD(actor actorRef, keyword keywordRef)
  armor dd    = libs.GetWornDevice(actorRef, keywordRef)
  armor rndrd = libs.GetRenderedDevice(dd)
  libs.removeDevice(actorRef, dd, rndrd, keywordRef)
  if dd != None && dd.haskeyword(libs.zad_DeviousBelt)
    previousBelt = dd
  endif
endFunction

function removeDDArmbinder(actor actorRef)
  form armbinder = actorRef.GetWornForm(0x00010000) 
  if armbinder != NONE && armbinder.HasKeyword(libs.zad_DeviousHeavyBondage)
    if armbinder.HasKeyword(libs.zad_DeviousYoke)
      removeDDbyKWD(actorRef, libs.zad_DeviousYoke)
    elseif armbinder.HasKeyword(libs.zad_DeviousArmbinder)
      removeDDbyKWD(actorRef, libs.zad_DeviousArmbinder)
    else
      removeDDbyKWD(actorRef, libs.zad_DeviousArmbinderElbow)
    endif
  endif
endFunction

; TODO rewrite this to work with any direction player and NPC, not just one direction
function stealKeys(actor actorRef)
  if actorRef == None
    PlayerMon.Debugmsg("stealKeys err: none reference")
    return
  endif
  PlayerMon.debugmsg("" + actorRef.getDisplayName() + " is stealing keys from " + player.GetDisplayName(), 1)
  int index = 0
  int cnt
  While (index < PlayerMon.deviousKeys.length)
    cnt = player.getItemCount(PlayerMon.deviousKeys[index])
    player.removeItem(PlayerMon.deviousKeys[index], cnt, true)
    actorRef.addItem(PlayerMon.deviousKeys[index], cnt, true)
    index += 1
  endWhile
  if Mods.deviousRegImperialKey != None
    cnt = player.getItemCount(Mods.deviousRegImperialKey)
    if cnt > 0
      player.removeItem(Mods.deviousRegImperialKey, cnt, true)
      actorRef.addItem(Mods.deviousRegImperialKey, cnt, true)
      endif
      cnt = player.getItemCount(Mods.deviousRegStormCloakKey)
    if cnt > 0
      player.removeItem(Mods.deviousRegStormCloakKey, cnt, true)
      actorRef.addItem(Mods.deviousRegStormCloakKey, cnt, true)
    endif
  endif
endFunction

; just unequip everything in certain sockets
function unequipAllNonDD()
  ;for all in thing
  ;if ; not dd and not zaz items
    ; unequip
  ;endif
  if !PlayerMon.isNude
    player.UnEquipItemSlot(32) ; body/curius
  endif
  player.UnEquipItemSlot(30) ; head
  player.UnEquipItemSlot(31) ; hair
  player.UnEquipItemSlot(33) ; hands
  player.UnEquipItemSlot(34) ; forarms
  player.UnEquipItemSlot(37) ; feet

endFunction

; removing all DD, and all items, all at once can crash the stack because of all the scripting it sets off
; so lets remove items 2-3 at a time, instead
; shouldn't need to worry about blocking devices here, since we don't get this far
function unequipAllNonImportantSlow()
  ; at first, we ignore gag, armbinder, DD items
  
  ; first we remove head, shoes, and gloves
  player.UnEquipItemSlot(30) ; head
  player.UnEquipItemSlot(37) ; feet
  player.UnEquipItemSlot(33) ; hands
  ; 44 should just be the mouth piece, ignorable when it comes to errors
  player.UnEquipItemSlot(44) ; face
  ; short pause
  Utility.Wait(1)
  ;then we remove forarms, chest, legs2?
  player.UnEquipItemSlot(34) ; forarms
  player.UnEquipItemSlot(34) ; forarms
  player.UnEquipItemSlot(32) ; chest
  
  Utility.Wait(0.5)
  ; Then we remove necklace, ear rings, face, tail
  player.UnEquipItemSlot(44) ; face
  player.UnEquipItemSlot(40) ; tail
  player.UnEquipItemSlot(43) ; ears
  ; shorter pause
  Utility.Wait(0.5)
  ;DON'T ASSUME DD IS UP TO DATE, we can get enslaved through proxy sex now
  ;lazy, will write later
  
  ;then we remove Arm and leg cuffs, 
  if player.WornHasKeyword(libs.zad_DeviousArmCuffs) ; ARM CUFFS
    removeDDbyKWD(player, libs.zad_DeviousArmCuffs)
    Utility.Wait(1)
  endif
  if player.WornHasKeyword(libs.zad_DeviousLegCuffs) ; LEG CUFFS
    removeDDbyKWD(player, libs.zad_DeviousLegCuffs)
    Utility.Wait(1)
  endif
  ;Utility.Wait(1)
  ; followed by Restrictive boots, arms
  if player.WornHasKeyword(libs.zad_DeviousGloves) ; GLOVES
    removeDDbyKWD(player, libs.zad_DeviousGloves) ; 33
    Utility.Wait(1)
  endif
  if player.WornHasKeyword(libs.zad_DeviousBoots) ; LEGGINGS
    removeDDbyKWD(player, libs.zad_DeviousBoots) ; 37
    Utility.Wait(1)
  endif
    
  ;Utility.Wait(1)
  ; followed by collar, hood
  ;Utility.Wait(0.5)
  
  ;removeDDbyKWD(libs.keyword) ;libs.zad_DeviousLegCuffs libs.zad_DeviousArmCuffs
  PlayerMon.debugmsg("slow removal of items is finished",1)
  
endFunction

;remove DD collars so we can change them reliably
; tags: unequipCollar removecollar
bool function removeCurrentCollar(actor actorRef)
  ; we use DeviousCollar and not zaz because we don't care about non-devious items, they unequip if we equip something else
  ;Armor collar  = player.GetWornForm( 0x00008000 ) as Armor ; maybe this doesn't always work?
  armor collar   = libs.GetWornDevice(actorRef, libs.zad_DeviousCollar)
  if collar != None && actorRef.WornHasKeyword(libs.zad_DeviousCollar) && !collar.HasKeyword(libs.zad_BlockGeneric) 
    ;PlayerMon.debugmsg("Trying to remove: " + collar.GetName())
    ;removeDDbyKWD(libs.zad_DeviousCollar)
    removeDDbyArmor(actorRef, collar)
    Utility.Wait(2) ; 1 wasn't enough during 13.13.7 testing
    return true
  ;elseif actorRef.WornHasKeyword(libs.zad_DeviousHarness) ;&& !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric)
  ;  ; lets assume there are no blocking harnesses, I'm sure this won't come back and bite me in the ass one day...
  ;  removeDDbyArmor(PlayerMon.knownCollar)
  ;  return true
    
  elseif actorRef.WornHasKeyword(Mods.zazKeywordWornCollar)
    PlayerMon.debugmsg("Note: removecurrentcollar called but actorRef has collar but blocking keyword present")
    return false
  else 
    ;PlayerMon.debugmsg("Note: removecurrentcollar called but actorRef is not wearing collar")
    ; removed because users got confused by this error, thinking it was an actual error
    return true ; we 'succeeded' in removing the collar
  endif
  return false
endFunction

; should equip any DD item
function equipRegularDDItem(actor actorRef, Armor dd, keyword kw)
  if dd != None
    armor rndrd = libs.GetRenderedDevice(dd) 
    if kw == None
      kw = libs.GetDeviceKeyword(dd)
    endif
    libs.equipDevice(actorRef, dd , rndrd, kw)
  endif
endFunction


; this function doesn't get abstracted because getRandomMultipleDD uses outfits and events, which makes it all much harder
bool function equipRandomDD(actor actorRef, actor attacker = None, bool canEnslave = false)
  PlayerMon.clear_force_variables() ; we reach this spot through the dialogue 
  ;PlayerMon.CheckDevices()
  PlayerMon.updateWornDD()
  Armor collar          = actorRef.GetWornForm( 0x00008000 ) as Armor 
  armor yoke            = actorRef.GetWornForm( 0x00010000 ) as Armor ;46
  bool collarBlocked    = collar != None && collar.HasKeyword(libs.zad_DeviousCollar) && collar.HasKeyword(libs.zad_BlockGeneric) ;PlayerMon.knownCollar != None && PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric)
  bool isCollarable     = !(( yoke != None && yoke.HasKeyword(Mods.zazKeywordWornYoke)) || collarBlocked || Mods.iEnslavedLevel > 0)
  int uniqueChance      = MCM.iWeightUniqueCollars * (isCollarable as int)
  int total = MCM.iWeightSingleDD + MCM.iWeightMultiDD + uniqueChance
  int roll = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("single/multi/uniqueCol(" + MCM.iWeightSingleDD + "/" + MCM.iWeightMultiDD + "/" + uniqueChance + ")roll/total:(" + roll + "/" + total + ")", 2)
  armor[] items = new armor[10]
  if total == 0
    PlayerMon.debugmsg("All item weights are zero, no items to be added")
    return false; quiet, all off
  endif
  
  if roll <= MCM.iWeightSingleDD 
    PlayerMon.debugmsg("adding single",1)
    equipRandomSingleDD(actorRef)
  elseif roll <= MCM.iWeightSingleDD + MCM.iWeightMultiDD ; multiple items
    PlayerMon.debugmsg("adding multiple",1)
    equipRandomMultipleDD(actorRef)
  else ;roll <= MCM.iWeightSingleDD + MCM.iWeightMultiDD + MCM.iWeightUniqueCollars
    PlayerMon.debugmsg("adding unique collar",1)
    equipRandomUniqueCollar(actorRef)
  endif
  return true
endFunction

; just returns items, doesn't equip them
armor[] function getRandomDD(actor actorRef, actor attacker = None, bool canEnslave = false)
  ;PlayerMon.debugmsg("Resetting approach at start of equiprandomDD",1)
  PlayerMon.clear_force_variables() ; we reach this spot through the dialogue 
  ;PlayerMon.CheckDevices()
  PlayerMon.updateWornDD()
  Armor collar          = actorRef.GetWornForm( 0x00008000 ) as Armor 
  bool collarBlocked    = collar != None && actorRef.WornHasKeyword(libs.zad_DeviousCollar) && collar.HasKeyword(libs.zad_BlockGeneric) ;PlayerMon.knownCollar != None && PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric)
  bool isCollarable     = !(actorRef.WornHasKeyword(Mods.zazKeywordWornYoke) || collarBlocked || Mods.iEnslavedLevel > 0)
  int uniqueChance      = MCM.iWeightUniqueCollars * (isCollarable as int)
  int total = MCM.iWeightSingleDD + uniqueChance ;+ MCM.iWeightMultiDD 
  int roll = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("single/multi/uniqueCol(" + MCM.iWeightSingleDD + "/" + MCM.iWeightMultiDD + "/" + uniqueChance + ")roll/total:(" + roll + "/" + total + ")", 2)
  armor[] items = new armor[10]
  if total == 0
    PlayerMon.debugmsg("All item weights are zero, no items to be added")
    return items; quiet, all off
  endif
  
  if roll <= MCM.iWeightSingleDD 
    PlayerMon.debugmsg("adding single",1)
    items = getRandomSingleDD(actorRef)
;  elseif roll <= MCM.iWeightSingleDD + MCM.iWeightMultiDD ; multiple items
;    PlayerMon.debugmsg("adding multiple",1)
;    items = getRandomMultipleDD(actorRef)
  else ;roll <= MCM.iWeightSingleDD + MCM.iWeightMultiDD + MCM.iWeightUniqueCollars
    PlayerMon.debugmsg("adding unique collar",1)
    items[0] = getRandomUniqueCollar(actorRef)
  endif
  return items
endFunction

; this is for DD single items, for all random DD item events, use equipPlayerMon.randomDD
bool function equipRandomSingleDD(actor actorRef)
  armor[] items = getRandomSingleDD(actorRef)
  int i = 0
  while i < items.length && items[i] != None
    equipRegularDDItem( actorRef, items[i], none)
    i += 1
  endWhile
  return i > 0
endFunction

; caviate: pairs count as 'single' for our uses, mostly because I hate just getting gloves with no boots and visaversa
; getsingleitem, getsingledditem
armor[] function getRandomSingleDD(actor actorRef)

  ; TODO check if player is already blocked, return with false
  ; TODO optimize all of these wornhaskeywords away, this is waaay too slow
  int glovesbootsChance   = MCM.iWeightSingleGlovesBoots * ((!actorRef.wornHasKeyword(libs.zad_DeviousGloves) && !actorRef.wornHasKeyword(libs.zad_DeviousBoots)) as int)
  int armbinderChance     = MCM.iWeightSingleArmbinder * ((!actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) && !actorRef.wornHasKeyword(libs.zad_DeviousYoke)) as int)
  int collarChance        = MCM.iWeightSingleCollar * ((!actorRef.wornHasKeyword(libs.zad_DeviousCollar)) as int) ; could do harness too
  int gagChance           = MCM.iWeightSingleGag * ((!actorRef.wornHasKeyword(libs.zad_DeviousGag)) as int)
  int harnessChance       = MCM.iWeightSingleHarness * ((!actorRef.wornHasKeyword(libs.zad_DeviousHarness) && !actorRef.wornHasKeyword(libs.zad_DeviousBelt)) as int) ; do I not need the keyword for corset
  int beltChance          = MCM.iWeightSingleBelt * ((!actorRef.wornHasKeyword(libs.zad_DeviousBelt)) as int) 
  int cuffsChance         = MCM.iWeightSingleCuffs * ((!actorRef.wornHasKeyword(libs.zad_DeviousLegCuffs) && !actorRef.wornHasKeyword(libs.zad_DeviousArmCuffs)) as int)
  int ankleChance         = MCM.iWeightSingleAnkleChains * ((!actorRef.wornHasKeyword(Mods.zazKeywordWornAnkles)) as int)
  
  int yokeChance          = MCM.iWeightSingleYoke * ((!actorRef.wornHasKeyword(libs.zad_DeviousHeavyBondage)) as int)
  int hoodChance          = MCM.iWeightSingleHood * ((!actorRef.wornHasKeyword(libs.zad_DeviousHood)) as int)
  int blindfoldChance     = MCM.iWeightSingleBlindFold * ((!actorRef.wornHasKeyword(libs.zad_DeviousBlindFold)) as int)
  int elbowbinderChance   = MCM.iWeightSingleElbowbinder * ((!actorRef.wornHasKeyword(libs.zad_DeviousArmbinder)) as int)
  
  int total = armbinderChance + glovesbootsChance + collarChance + gagChance + harnessChance + beltChance \
            + cuffsChance + ankleChance + yokeChance + hoodChance + blindfoldChance + elbowbinderChance
            
  if total == 0
    PlayerMon.debugmsg("single: total is zero, no more items left to put on?")
    return None
  endif
  int roll  = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("single roll: gloveboot/armbind/collar/gag/harn/belt/cuffs/ankle/yoke/hood/bfold/elbow (" +\
           glovesbootsChance + "/" +\
           armbinderChance + "/" +\
           collarChance + "/" +\
           gagChance + "/" +\
           harnessChance + "/" +\
           beltChance + "/" +\
           cuffsChance + "/" +\
           yokeChance + "/" +\
           hoodChance + "/" +\
           blindfoldChance + "/" +\
           elbowbinderChance + "/" +\
           ") roll/total:(" + roll + "/" + total + ")")
  armor[] items = new armor[3]     
  if roll <= glovesbootsChance
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " gave you some lovely boots and gloves before leaving!")
    endif 
    return getRandomDDxRGlovesBoots()
  elseif roll <= glovesbootsChance + armbinderChance
    items[0] = getRandomDDArmbinders()
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks a armbinder on you before leaving!")
    ; endif
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance; Collars
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks a collar on you before leaving!")
    ; endif
    items[0] = getRandomDDCollars(actorRef)
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance ; gag
    items[0] = getRandomGag() 
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " shoves a gag in your mouth before leaving!")
    ; endif
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance; harness and plug
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks a harness on you before leaving!")
    ; endif
    return getRandomHarnessAndStuff(actorRef)
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance; belt and plug
    PlayerMon.debugmsg("attempting belt ...")
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks a tight chastity belt on you before leaving!")
    ; endif ;ankleChance
    return getRandomBeltAndStuff(actorRef, Utility.RandomInt(1, (MCM.iWeightBeltPunishment + MCM.iWeightBeltRegular)) <= MCM.iWeightBeltPunishment)
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance; legs and arm cuffs
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks arm and leg cuffs to you before leaving!")
    ; endif
    return getRandomDDCuffs()
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance; legs and arm cuffs
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks ankle chains on you before leaving!")
    ; endif
    items[0] = getRandomAnkleChains()
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance + yokeChance
    ; if actorRef != None && actorRef == player
      ; Debug.Notification(actorRef.GetDisplayName() + " locks a yoke on you!")
    ; endif
    items[0] = getRandomDDYoke(actorRef)
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance + yokeChance + hoodChance
    items[0] = getRandomHood(actorRef)
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance + yokeChance + hoodChance + blindfoldChance
    items[0] = getRandomDDBlindfolds()
    return items
  else;if roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance + yokeChance + hoodChance + blindfoldChance + elbowbinderChance
    items[0] = getRandomDDElbowbinder()
    return items
  endif  

endFunction

; unlike the other functions, because this one contains outfits, I elected to leave it alone
function equipRandomMultipleDD(actor actorRef) 
  ; animate fall to knees or tied up
  ; fade to black or straight to black

  int ponyChance          = MCM.iWeightMultiPony * ((!actorRef.wornHasKeyword(libs.zad_DeviousHarness)) as int)
  int ballandchainChance  = MCM.iWeightMultiRedBNC ;* ((!actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) && !actorRef.wornHasKeyword(libs.zad_DeviousYoke)) as int)
  int transparentChance   = MCM.iWeightMultiTransparent  *  ((!actorRef.wornHasKeyword(libs.zad_DeviousSuit)) as int)
  int rubberChance        = MCM.iWeightMultiRubber  * ((!actorRef.wornHasKeyword(libs.zad_DeviousSuit)) as int)
  int multiChance         = MCM.iWeightMultiSeveral  * ((!actorRef.wornHasKeyword(libs.zad_DeviousHarness)) as int) ; do I not need the keyword for corset
  int total = ponyChance + ballandchainChance + transparentChance + rubberChance + multiChance
  if total == 0
    PlayerMon.debugmsg("single: total is zero, no more items left to put on?")
    return
  endif
  int roll  = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("multi roll: pony/redebonite/transparent/rubber/multi (" +\
           ponyChance + "/" +\
           ballandchainChance + "/" +\
           transparentChance + "/" +\
           rubberChance + "/" +\
           multiChance + "/" +\
           ") roll/total:(" + roll + "/" + total + ")")
    
  if roll <= ponyChance
    equipRandomPonySuit(actorRef)
  elseif roll <= ponyChance + ballandchainChance 
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BallandChainRedOutfit) 
  elseif roll <= ponyChance + ballandchainChance + transparentChance
    equipTransparentOutfit(actorRef)
  elseif roll <= ponyChance + ballandchainChance + transparentChance + rubberChance 
    removeCurrentCollar(actorRef)
    equipDCURRubberOutfit(actorRef)
  elseif roll <= ponyChance + ballandchainChance + transparentChance + rubberChance + multiChance
    int n = Utility.RandomInt(0,2)
    while n <= 3
      Utility.Wait(1)
      equipRandomSingleDD(actorRef)
      n += 1
    endWhile
  endif
  ; time skip
  ; wait fade in
  ; get up off the ground
endFunction

function equipRandomPonySuit(actor actorRef)
; roll chance
  int originalSuit = MCM.iWeightSingleHarness * (!Mods.modLoadedDD4) as int
  int newSuit      = MCM.iWeightMultiRubber    * (Mods.modLoadedDD4) as int
  int newHarnessed = MCM.iWeightSingleHarness * (Mods.modLoadedDD4) as int
 

  int total = originalSuit + newSuit + newHarnessed
  if total == 0
    PlayerMon.debugmsg("Err: Cannot add pony suit, total is 0, none available")
    return
  endif
  removeCurrentCollar(actorRef)
  actorRef.UnEquipItemSlot(32)

  int roll = Utility.RandomInt(0, total)
  PlayerMon.debugmsg("pony roll: original, suit, harness (" +\
           originalSuit + "/" +\
           newSuit + "/" +\
           newHarnessed + "/" +\
           ") roll/total:(" + roll + "/" + total + ")")

  if roll < originalSuit
    actorRef.SetOutfit(BlackPonyMixedOutfit) 
  else ; all dd suits, lets mix items so less redundant code
    ; roll for belt and plug or plug and armbinder?
    equipRegularDDItem( actorRef, Mods.DD4PonyTailPlug, none) ; pony plug
    
    if roll < originalSuit + newSuit
      ; add pony gag, pony plug, pony shoes, cat suit body, arms, armbinder
      equipRegularDDItem( actorRef, Mods.DD4CatsuitBodyBlack, none) ; cat suit
      equipRegularDDItem( actorRef, Mods.DD4CatsuitArmsBlack, none) ; cat gloves long

    else;if roll <originalSuit + newSuit + newHarnessed
      ; add pony gag, pony plug, pony shoes, black harness, armbinder
      equipRegularDDItem( actorRef, randomDDxHarnesss[0], none) ; harness
      equipRegularDDItem( actorRef, PlayerMon.randomDDxCuffs[0], none) ; arm cuffs
      equipRegularDDItem( actorRef, PlayerMon.randomDDxCuffs[1], none) ; leg cuffs
 
    endif
    equipRegularDDItem( actorRef, Mods.DD4PonyGagBlackHarn, none) ; pony gag
    equipRegularDDItem( actorRef, PlayerMon.ponyGearDD[2], none) ; pony boots
    ;equipRegularDDItem( actorRef, PlayerMon.ponyGearDD[0], none) ; armbinder
    armor binder = getRandomHeavyBondage(actorRef)
    if binder
      equipRegularDDItem( actorRef, binder, none) ; armbinder
    endif
      
    
  endif
  
endfunction


; unlike the other functions, because this one contains outfits, I elected to leave it alone
function getRandomMultipleDD(actor actorRef) 
  ; animate fall to knees or tied up
  ; fade to black or straight to black

  int ponyChance          = MCM.iWeightMultiPony * ((!actorRef.wornHasKeyword(libs.zad_DeviousHarness)) as int)
  int ballandchainChance  = MCM.iWeightMultiRedBNC ;* ((!actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) && !actorRef.wornHasKeyword(libs.zad_DeviousYoke)) as int)
  int transparentChance   = MCM.iWeightMultiTransparent  *  ((!actorRef.wornHasKeyword(libs.zad_DeviousSuit)) as int)
  int rubberChance        = MCM.iWeightMultiRubber  * ((!actorRef.wornHasKeyword(libs.zad_DeviousSuit)) as int)
  int multiChance         = MCM.iWeightMultiSeveral  * ((!actorRef.wornHasKeyword(libs.zad_DeviousHarness)) as int) ; do I not need the keyword for corset
  int total = ponyChance + ballandchainChance + transparentChance + rubberChance + multiChance
  if total == 0
    PlayerMon.debugmsg("single: total is zero, no suits available?")
    return
  endif
  int roll  = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("multi roll: pony/redebonite/transparent/rubber/multi (" +\
           ponyChance + "/" +\
           ballandchainChance + "/" +\
           transparentChance + "/" +\
           rubberChance + "/" +\
           multiChance + "/" +\
           ") roll/total:(" + roll + "/" + total + ")")
    
  if roll <= ponyChance
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BlackPonyMixedOutfit) 
  elseif roll <= ponyChance + ballandchainChance 
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BallandChainRedOutfit) 
  elseif roll <= ponyChance + ballandchainChance + transparentChance
    equipTransparentOutfit(actorRef)
  elseif roll <= ponyChance + ballandchainChance + transparentChance + rubberChance 
    removeCurrentCollar(actorRef)
    equipDCURRubberOutfit(actorRef)
  elseif roll <= ponyChance + ballandchainChance + transparentChance + rubberChance + multiChance
    int n = Utility.RandomInt(0,2)
    while n <= 3
      Utility.Wait(1)
      equipRandomSingleDD(actorRef)
      n += 1
    endWhile
  endif
  ; time skip
  ; wait fade in
  ; get up off the ground
endFunction


Function equipRandomUniqueCollar(actor actorRef)
  armor collar = getRandomUniqueCollar(actorRef)
  if collar
    equipRegularDDItem(actorRef, collar, None)
  endif
endFunction


armor function getRandomUniqueCollar(actor actorRef)
  ; we shouldn't need collarable anymore, since we can't do anything here without it anymore
  bool isPlayer = actorRef == player
  int weightPetCollar             = MCM.iWeightPetcollar * ( Mods.modLoadedPetCollar ) as int
  int weightDCURCursedCollar      = MCM.iWeightCursedCollar * ( Mods.modLoadedCursedLoot && (actorRef == player) && isPlayer) as int
  int weightDCURSlave             = MCM.iWeightSlaveCollar * ( Mods.modLoadedCursedLoot && isPlayer) as int
  int weightDCURSlut              = MCM.iWeightSlutCollar * (Mods.modLoadedCursedLoot&& isPlayer ) as int
  int weightDCURRubberDollCollar  = MCM.iWeightRubberDollCollar * (  Mods.modLoadedCursedLoot && (actorRef == player) && isPlayer) as int
  int weightFBanned               = MCM.iWeightdeviousPunishEquipmentBannnedCollar * (  Mods.deviousPunishEquipmentBannnedCollar != None ) as int
  int weightFProstituted          = MCM.iWeightdeviousPunishEquipmentProstitutedCollar * (  Mods.deviousPunishEquipmentProstitutedCollar != None ) as int
  int weightFNaked                = MCM.iWeightdeviousPunishEquipmentNakedCollar * (  Mods.deviousPunishEquipmentNakedCollar != None ) as int
  int weightStripTease            = mcm.iWeightStripCollar * (Mods.modLoadedCursedLoot ) as int
  int weightDCURHeavyCollar       = MCM.iWeightHeavyCollar * (Mods.modLoadedCursedLoot ) as int
  int weightCatSuitCollar          = MCM.iWeightCatSuitCollar * (Mods.modLoadedCursedLoot || Mods.modLoadedDD4) as int
  
  ;int suits       = MCM.iWeightMultiDD * 
  int weightTotal = weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut \
                  + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked + weightStripTease\
                  + weightDCURHeavyCollar + weightCatSuitCollar
  if weightTotal == 0
    PlayerMon.debugmsg("equipPlayerMon.randomDD: weight is zero, equipping nothing", 4)
  endif  
  int   roll    = Utility.RandomInt(1, weightTotal)
  bool  removed = false
  ;PlayerMon.debugmsg("equipPlayerMon.randomDD: rolled " + roll, 2)
  PlayerMon.debugmsg("pet/cursed/slave/slut/rubberdoll/banned/prostituted/naked/stripTease/heavy/rubber(" \
                     + weightPetCollar + "/" + weightDCURCursedCollar + "/" + weightDCURSlave + "/" + weightDCURSlut + "/"\
                     + weightDCURRubberDollCollar + "/" + weightFBanned + "/" + weightFProstituted + "/" \
                     + weightFNaked + "/" + weightStripTease + "/" + weightDCURHeavyCollar + "/" + weightCatSuitCollar \
                     +") roll/total:(" + roll + "/" + weightTotal + ")", 2)

  armor collar
  if (roll == 0)
    PlayerMon.debugmsg("equipPlayerMon.randomDD: nothing to equip?")
    return collar
  endif
  removed = removeCurrentCollar(actorRef)
  if roll <= weightPetCollar 
    if actorRef != None && actorRef != player
      Debug.Notification(actorRef.GetDisplayName() + " puts a collar on the bitch.")
    else
      Debug.Notification("The bitch has earned a collar")
    endif
    ;ods.equipPetCollar(actorRef)
    return Mods.petCollar
  elseif roll <=  weightPetCollar + weightDCURCursedCollar 
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " puts a strange collar on you! What's this strange letter...?")
    else
      Debug.Notification("Suddenly you notice a strange collar around your neck. What's this letter...?")
    endif
    ;Mods.equipCursedCollar()
    return Mods.dcurCursedCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave 
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " puts a slave collar on you!")
    else
      Debug.Notification("The slave has been marked")
    endif
    return Mods.dcurSlaveCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a collar on the slut.")
    else
      Debug.Notification("The slut has earned a collar")
    endif
    return Mods.dcurSlutCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a rubbery collar around your neck!")
    else
      Debug.Notification("The rubbery collar locks around your neck")
    endif
    return Mods.dcurRubberCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned 
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a weird collar around your neck!")
    else
      Debug.Notification("The slut has earned a collar")
    endif
    return Mods.deviousPunishEquipmentBannnedCollar 
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted 
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a weird collar around your neck!")
    else
      Debug.Notification("The prositute has earned a collar")
    endif
    return Mods.deviousPunishEquipmentProstitutedCollar 
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked   
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a weird collar around your neck!")
    else
      Debug.Notification("The exhibitionist has earned a new collar")
    endif
    return Mods.deviousPunishEquipmentNakedCollar 
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked + weightStripTease
      if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a StripTease collar around your neck!")
    else
      Debug.Notification("The slut has earned a new collar")
    endif
    return Mods.dcurStripTeaseCollar 

  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked + weightStripTease + weightDCURHeavyCollar
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a Heavy collar around your neck!")
    else
      Debug.Notification("The Slave has earned a new collar")
    endif
    return Mods.dcurHeavyCollar 
    
  else;if roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked + weightStripTease + weightDCURHeavyCollar + weightCatSuitCollar
    if actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a rubber collar around your neck!")
    else
      Debug.Notification("The Slave has earned a new collar")
    endif
    roll = Utility.RandomInt(0,2) ; reuse and recycle kids
    if roll == 0
      return mods.DD4CatsuitCollarBlack
    elseif roll == 1
      return mods.DD4CatsuitCollarRed
    else
      return mods.DD4CatsuitCollarWhite
    endif
      
  endif
endFunction



bool function equipRandomDDCuffs(actor actorRef)
  int i = 0
  PlayerMon.debugmsg("checking if arm + leg cuffs are worn already ...", 1)
  if(actorRef.wornHasKeyword(libs.zad_DeviousLegCuffs) == false && player.wornHasKeyword(libs.zad_DeviousArmCuffs) == false)

    armor[] items = getRandomDDCuffs()
    while i < items.length && items[i] != None
      equipRegularDDItem(actorRef, items[i], None)
      i += 1
    endWhile
  endif

  return i > 0
endFunction

armor[] function getRandomDDCuffs()
  armor[] pair      = new armor[2]
  int offsetIndex    = Utility.Randomint(0,2) * 2 ; 01 are ebonite, 23 are red, 45 are white
  pair[0] = PlayerMon.randomDDxCuffs[offsetIndex]
  pair[1] = PlayerMon.randomDDxCuffs[offsetIndex + 1]
  return pair
endFunction

bool function equipRandomAnkleChains(actor actorRef)
  int i = 0
  PlayerMon.debugmsg("checking if ankle chains are worn already ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousLegCuffs) == false
    armor chains = getRandomAnkleChains()
    if chains
      return equipRegularDDItem(actorRef, chains, None)
    endif
  endif
  return false
endFunction

armor function getRandomAnkleChains()
  armor chains = None
  if Mods.modLoadedCursedLoot 
    if Mods.dcurAnkleChains == None
      PlayerMon.debugmsg("Err: Cursed loot chains are no loaded, but cursed loot is, re-cycle mod detection",5)
      chains = Mods.zazLegCuffs
    endif
    chains = Mods.dcurAnkleChains
  elseif Mods.zazLegCuffs != None
    chains = Mods.zazLegCuffs
  else
    PlayerMon.debugmsg("Err: No chains to put on the player, reset mods or report to support thread",5)
  endif
  return chains
endFunction

; TODO finish this, can't find the model in creation kit
bool function equipRandomDDxRGlovesBoots(actor actorRef)
  int i = 0
  PlayerMon.debugmsg("checking if gloves + boots are worn already ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousGloves) == false && actorRef.wornHasKeyword(libs.zad_DeviousBoots) == false
    armor[] items = getRandomDDxRGlovesBoots()
    while i < items.length && items[i] != None
      equipRegularDDItem(actorRef, items[i], None)
      i += 1
    endWhile
  endif

  return i > 0
endFunction

; r for restrictive, not red
armor[] function getRandomDDxRGlovesBoots()
  armor[] pair = new armor[2]
  ; remove gloves cuffs first, then put them back?
  
  int offsetIndex = 0 ; 01 are ebonite, 23 are red, 45 are white
  offsetIndex     = Utility.Randomint(0,2) * 2
  pair[0] = PlayerMon.randomDDxRGlovesBoots[offsetIndex]
  pair[1] = PlayerMon.randomDDxRGlovesBoots[offsetIndex + 1]
  return pair
endFunction

; used more than once, might as well functionize it
; adds random plugs and piercings before a belt or harness 
; merging punishment and regular into one function
;  punishment bool states that this is a punishing act, both reg and punish items possible
;    if not punish, do not use punishment items
function equipRandomStuff(actor actorRef, Armor belt, bool punishment = false, bool force = false)
  int i = 0
  armor[] items = getRandomBeltStuff(actorRef, belt, punishment, force)
  while i < items.length && items[i] != None
    equipRegularDDItem(actorRef, items[i], None)
    i += 1
  endWhile
endFunction

; where "stuff" in this context is plug and piercing under a belt
armor[] function getRandomBeltStuff(actor actorRef, Armor belt, bool punishment = false, bool force = false, bool forceGem = false)
  bool has_plug     = actorRef.WornHasKeyword(libs.zad_DeviousPlug) ;TODO extend to other plugs
  bool has_piercing = actorRef.WornHasKeyword(libs.zad_DeviousPiercingsVaginal)
  armor[] stuff = new armor[4] ; enough space for two plugs and a piercing, and the belt one level up
  int stuff_index = 0
  ;PlayerMon.debugmsg("adding candy ... ")
  if !has_plug && (has_piercing || Utility.Randomint(0, 99) >= (100 - MCM.iWeightPlugs) || force)
    int newSoulGem  = (MCM.iWeightPlugSoulGem / 1 +(punishment as int))
    int newInflate  = (MCM.iWeightPlugInflatable / 1 + (punishment as int))
    int newCharging = (MCM.iWeightPlugCharging / 1 + (punishment as int))
    int newShock    = (MCM.iWeightPlugShock * (punishment as int))
    int newTraining = (MCM.iWeightPlugTraining * (punishment as int))
    int newCDEffect = (MCM.iWeightPlugCDEffect / 1 + (punishment as int))
    int total = newSoulGem + newInflate + newCharging\
              + newShock + newTraining + newCDEffect
              ;+ MCM.iWeightPlugDasha \           + MCM.iWeightPlugCDEffect \         + MCM.iWeightPlugCDSpecial \

    int vRoll = Utility.RandomInt(1,total)
    PlayerMon.debugmsg("soul/inflate/charging/shock/training/cdeff(" \
                      + newSoulGem + "/" + newInflate + "/" + newCharging + "/" + newShock + "/"\
                      + newTraining + "/" + newCDEffect +")roll/total:(" + vRoll + "/" + total + ")", 2)
                      
                      
    actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the harness
    
    Armor vplug = None
    Armor aplug = None
    if vRoll < newSoulGem
      vplug = PlayerMon.randomDDVagPlugs[2]
     elseif vRoll < newSoulGem + newInflate
      vplug = PlayerMon.randomDDVagPlugs[1]
     elseif vRoll < newSoulGem + newInflate + newCharging
      vplug = PlayerMon.randomDDVagPlugs[0]
    elseif vRoll < newSoulGem + newInflate + newCharging + newShock
      vplug = PlayerMon.randomDDPunishmentVagPlugs[1]
    elseif vRoll < newSoulGem + newInflate + newCharging + newShock + newTraining
      vplug = PlayerMon.randomDDPunishmentVagPlugs[0]
    else;if vRoll < newSoulGem + newInflate + newCharging + newShock + newTraining + newCDEffect
      if belt.HasKeyword(libs.zad_PermitAnal)  
        int pRoll = Utility.RandomInt(1,4)
        ;vag = finisher Mods.cdFinisherPlug
        if pRoll == 1 
          vplug = Mods.cdPunisherPlug
          aplug = Mods.cdTeaserPlug
        elseif pRoll == 2
          vplug = Mods.cdOrgasmPlug
          aplug = Mods.cdSpoilerPlug
        elseif pRoll == 3
          vplug = Mods.cdTormentingPlug
          aplug = Mods.cdTeaserPlug
        else;if pRoll == 4
          vplug = Mods.cdExciterPlug
          aplug = randomDDPunishmentAnalPlugs[0]   
        endif
      else
        int pRoll = Utility.RandomInt(1,4)
        if pRoll == 1
          vplug = Mods.cdTormentingPlug
        elseif pRoll == 2
          vplug = Mods.cdOrgasmPlug
        elseif pRoll == 3
          vplug = Mods.cdExciterPlug
        else;if pRoll == 4
          vplug = Mods.cdFinisherPlug
        endif
      endif
    endif     
    stuff[stuff_index] = vplug
    stuff_index += 1
    
    if aplug != None
      stuff[stuff_index] = aplug
      stuff_index += 1
    endif
    
  endif
  
  if !has_piercing && actorRef.HasPerk(libs.PiercedClit) && Utility.Randomint(0, 99) >= (100 - MCM.iWeightBeltPiercings)
      stuff[stuff_index] = PlayerMon.randomDDVagPiercings[(Utility.Randomint(1, PlayerMon.randomDDVagPiercings.length) - 1)]
  endif
  return stuff
endFunction

;deprecated, too complicated with too much redundant code, so merged with equipRandomStuff
function equipPunishmentStuff(actor actorRef, Armor belt)
  equipRandomStuff(actorRef, belt, True)
endFunction

bool function equipRandomHarnessAndStuff(actor actorRef)
  int i = 0
  armor[] items = getRandomHarnessAndStuff(actorRef)
  actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the harness
  while i < items.length && items[i] != None
    equipRegularDDItem(actorRef, items[i], None)
    i += 1
  endWhile
endFunction

armor[] function getRandomHarnessAndStuff(actor actorRef, bool punishment = false, bool force_stuff = false)
  PlayerMon.debugmsg("checking if harness are worn already ...", 1)
  armor[] items = new armor[5]
  if actorRef.wornHasKeyword(libs.zad_DeviousHarness) == false 
    Armor harness = getRandomHarness(actorRef)

    armor[] stuff = getRandomBeltStuff(actorRef, harness)
    ;armor rndrd = libs.GetRenderedDevice(harness)
    int i = 0
    while i < stuff.length && stuff[i] != None
      items[i] = stuff[i]
      i += 1
    endWhile
    items[i] = harness
  endif
    return items
endFunction

bool function equipRandomHarness(actor actorRef)
  Armor harness = getRandomHarness(actorRef)
  if harness != None
    return equipRegularDDItem(actorRef, harness, None)
  endif
  return false
endFunction

armor function getRandomHarness(actor actorRef)
  if actorRef.wornHasKeyword(libs.zad_DeviousHarness) == false 
    int offsetIndex = Utility.Randomint(0,2);0 ; 0 are ebonite, 1 are red, 2 are white
    return randomDDxHarnesss[offsetIndex]
  endif
  return NONE
endFunction

;moving everything here because same code normally
bool function equipRandomBeltAndStuff(actor actorRef, bool punishment = false, bool force_stuff = false)
  int i = 0
  if(actorRef.wornHasKeyword(libs.zad_DeviousBelt) == false )
    actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the belt
    armor[] items = getRandomBeltAndStuff(actorRef, punishment, force_stuff)
    while i < items.length && items[i]!= None
      equipRegularDDItem(actorRef, items[i], None)
      i += 1
    endWhile
  endif
  return i > 0
endFunction

; where "stuff" is plugs and piercings
armor[] function getRandomBeltAndStuff(actor actorRef, bool punishment = false, bool forceStuff = false, bool forceGem = false)
  PlayerMon.debugmsg("checking if belt and stuff are already worn ...", 1)
  ; check what color the other items are, modify index
  ; todo: can we check if they are loyal imperial or stormcloak? if so we could add them to non-punishment
  
  int newPadded   = MCM.iWeightBeltPadded  / ((1 * (punishment as int)) + 1)
  int newIron     = MCM.iWeightBeltIron    / ((1 * (punishment as int)) + 1)
  int newImperial = MCM.iWeightBeltRegulationsImperial   * (Mods.modLoadedDeviousRegulations as int) / ((1 * (punishment as int)) + 1)
  int newSCloak   = MCM.iWeightBeltRegulationsStormCloak * (Mods.modLoadedDeviousRegulations as int) / ((1 * (punishment as int)) + 1)
  int newShame    = MCM.iWeightBeltShame                 * (Mods.modLoadedCursedLoot as int) / ((1 * (punishment as int)) + 1)
  int total = newPadded + newIron + newImperial\
            + newSCloak + newShame
            ;+ MCM.iWeightPlugDasha \           + MCM.iWeightPlugCDEffect \         + MCM.iWeightPlugCDSpecial \

  int roll = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("padded/iron/imperial/stormcloak/shame(" + newPadded + "/" + newIron + "/" + newImperial + "/" + newSCloak + "/" + newShame + ")roll/total:(" + roll + "/" + total + ")", 2)
  Armor belt
  if roll < newPadded
    belt = libs.beltPaddedOpen
  elseif roll < newPadded + newIron
    belt = libs.beltIron
  elseif roll < newPadded + newIron + newImperial
    belt = Mods.deviousRegImperialBelt
  elseif roll < newPadded + newIron + newImperial + newSCloak
    belt = Mods.deviousRegStormCloakBelt   
  else;if roll < newPadded + newIron + newImperial + newSCloak + newShame
    belt = Mods.dcurBeltOfShame
  endif     
  armor[] items = getRandomBeltStuff(actorRef, belt, punishment, forceStuff) ; now that we know which belt we're getting...
  int i = 0
  while i < items.length && items[i] != None
    i += 1
  endWhile
  items[i] = belt
  return items
endFunction

;punishment version
function equipPunishmentBeltAndStuff(actor actorRef) 
  equipRandomBeltAndStuff(actorRef, false, true)
endfunction

function equipSpellPunishmentBelt(actor actorRef) 
  ; get random belt
  ; can I just use shock belt
  ; equip plugs
  ; equip belt
  equipRandomBeltAndStuff(actorRef, true, true)

endfunction


; used by pf_crde_followeragrgagandplug1
bool function equipArousingPlugAndBelt(actor actorRef, actor masterRef = None)
  if actorRef.wornhaskeyword(libs.zad_DeviousPlug) ; if wearing a plug already
    removeDDbyKWD(actorRef, libs.zad_DeviousPlug)
    if actorRef.wornhaskeyword(libs.zad_DeviousPlug) ; wearing two
      removeDDbyKWD(actorRef, libs.zad_DeviousPlug)
    endif
  endif

  ; TODO set player's master as the follower who equipped this
  if actorRef == player && masterRef != None
    PlayerMon.masterRefAlias.forceRefTo(masterRef)
  endif

  int i = 0
  actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the harness

  armor[] items = getArousingPlugAndBelt(actorRef)
  debug.trace( "items: " + items )
  while i < items.length && items[i] != None
    equipRegularDDItem(actorRef, items[i], None)
    ;Utility.Wait(1.5) ; if we try to equip several unique individual items at once the script can lag and belt gets put on before some 
    i += 1
  endWhile
  return i > 0
endFunction

armor[] function getArousingPlugAndBelt(actor actorRef)
  ;armor[] items = new armor[3]
  armor[] items = getRandomBeltStuff(actorRef, libs.beltPadded, true, true) ; size 4, 2 plugs + 1 pierce + 1 belt
  ;items[0] = Mods.crdeTrainingPlug
  ;bool cdloaded = Mods.modLoadedCD
  ;if cdloaded
  ;  items[1] = Mods.cdTeaserPlug
  ;endif
  
  ;items[1 + (cdloaded as int)] = libs.beltPadded
  int i = 3
  while i >= 0
    if items[i] != NONE
      items[i+1] = libs.beltPadded
      i -= 16
    endif
    i -= 1
  endWhile
  if i > -16
    debug.trace("[crde] ERR: no space for belt found")
  endif
  
  return items
endfunction

; used by fragment for adding gag to player
bool function equipRandomGag(actor actorRef)
  PlayerMon.debugmsg("checking if gag is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousGag) == false
    armor gag = getRandomGag()
    if gag
      return equipRegularDDItem(actorRef, gag, None)
    else
      PlayerMon.debugmsg("Err: Random gag returned nothing")
    endif
  endif
  return false
endFunction

armor function getRandomGag()
  armor gag
  int ballgag  = MCM.iWeightGagBall  
  int panelgag = MCM.iWeightGagPanel
  int ringgag  = MCM.iWeightGagRing
  int penisgag = MCM.iWeightGagPenis * (Mods.modLoadedCursedLoot as int)
  int ponygag  = MCM.iWeightGagPony * (Mods.modLoadedDD4 as int)
  int total = ballgag + panelgag + ringgag  + penisgag + ponygag

  if total < 1
    PlayerMon.debugmsg("ERR: Gag total was 0, cannot add gag")
    return none
  endif
  int roll = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("ball/ring/panel/penis/pony("\
    + ballgag + "/" + ringgag + "/" + panelgag + "/" + penisgag + "/" + ponygag\
    + ")roll/total:(" + roll + "/" + total + ")", 2)
  ; gags are ordered in the array by theme rather by type, ball -> panel -> ring, for black red white
  if roll <= ballgag
    gag = PlayerMon.randomDDgags[3 * Utility.RandomInt(0,2)]
  elseif roll <= ballgag + panelgag 
    gag = PlayerMon.randomDDgags[3 * Utility.RandomInt(0,2) + 1]
  elseif roll <= ballgag + panelgag + ringgag
    gag = PlayerMon.randomDDgags[3 * Utility.RandomInt(0,2) + 2]
  elseif roll <= ballgag + panelgag + ringgag + penisgag 
    gag = Mods.dcurHeavyGag
  else;if roll <= ballgag + panelgag + ringgag + penisgag + ponygag
    roll = Utility.RandomInt(0, 2)
    if roll == 0
      gag = Mods.DD4PonyGagBlackHarn
    elseif roll == 1
      gag = Mods.DD4PonyGagRedHarn
    else; roll == 2
      gag = Mods.DD4PonyGagWhiteHarn
    endif
  endif     

  return gag
endFunction

;PlayerMon.randomDDCollars
bool function equipRandomDDCollars(actor actorRef)
  PlayerMon.debugmsg("checking if collar is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousCollar) == false 
    armor collar = getRandomDDCollars(actorRef)
    if collar
      return equipRegularDDItem(actorRef, collar, None)
    endif
  endif

  return false
endFunction

; modified to return regular collar or return unique collar, random
armor function getRandomDDCollars(actor actorRef)
  bool collarBlocked     = collar != None && actorRef.WornHasKeyword(libs.zad_DeviousCollar) && collar.HasKeyword(libs.zad_BlockGeneric) ;PlayerMon.knownCollar != None && PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric)
  int isCollarable        = (!(actorRef.WornHasKeyword(Mods.zazKeywordWornYoke) || collarBlocked || Mods.iEnslavedLevel > 0)) as int
  int weightUniqueCollars   = MCM.iWeightUniqueCollars * ( isCollarable )
  int weightRegularCollars  = MCM.iWeightSingleCollar * ( isCollarable )
  
  int weightTotal = weightUniqueCollars + weightRegularCollars
  if weightTotal == 0
    PlayerMon.debugmsg("Err: Cannot add collar, roll total is zero", 4)
    return None
  endif
  int roll = Utility.RandomInt(1, weightTotal)

  armor collar
  if roll <= weightUniqueCollars 
    collar = getRandomUniqueCollar(actorRef)
  else
    ; check what color the other items are, modify index
    int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDCollars.length - 1)
    collar = PlayerMon.randomDDCollars[offsetIndex]
  endif
  return collar 
endFunction

bool function equipRandomDDArmbinders(actor actorRef)
  PlayerMon.debugmsg("checking if armbinder is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) == false && actorRef.wornHasKeyword(libs.zad_DeviousYoke) == false 
    armor armbinder = getRandomDDArmbinders()
    if armbinder ; if we can equip on that actor
      return equipRegularDDItem(actorRef, armbinder, None)
    else
      PlayerMon.debugmsg("Err: Random armbinder returned nothing")
    endif
  endif
  return false
endFunction

; todo alter this so we check if the NPC can take an armbinder
; todo alter this so we can do yokes or armchains
armor function getRandomDDArmbinders()
  armor armbinder = None
  ; check what color the other items are, modify index
  int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDArmbinders.length - 1);0 ; 0 are ebonite, 1 are red, 2 are white
  armbinder = PlayerMon.randomDDArmbinders[offsetIndex]
  return armbinder
endFunction

bool function equipRandomDDElbowbinder(actor actorRef)
  if Mods.modLoadedDD4 == false
    PlayerMon.debugmsg("Cannot equip elowbinder user is not using DDi 4.0", 1)
    return false
  endif
  PlayerMon.debugmsg("checking if arm binder is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) == false && actorRef.wornHasKeyword(libs.zad_DeviousYoke) == false 
    armor binder = getRandomDDElbowbinder()
    if binder ; if we can equip on that actor
      return equipRegularDDItem(actorRef, binder, None)
    else
      PlayerMon.debugmsg("Err: Random elbowbinder returned nothing")
    endif
  endif

endFunction

armor function getRandomDDElbowbinder()
  int roll = Utility.Randomint(0,2)
  if     roll == 0
    return Mods.DD4ElbowbinderBlack
  elseif roll == 1
    return Mods.DD4ElbowbinderRed
  else ; roll == 2
    return Mods.DD4ElbowbinderWhite
  endif
endFunction

bool function equipRandomDDYokes(actor actorRef)
  PlayerMon.debugmsg("checking if armbinder is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) == false && actorRef.wornHasKeyword(libs.zad_DeviousYoke) == false 
    armor yoke = getRandomDDYoke(actorRef)
    if yoke ; if we can equip on that actor
      return equipRegularDDItem(actorRef, yoke, None)
    else 
      PlayerMon.debugmsg("Err: Random Yoke returned nothing")
    endif
  endif
  return false
endFunction

armor function getRandomDDYoke(actor actorRef)
  ;int offsetIndex = 
  ;return randomDDYokes[Utility.Randomint(0, randomDDYokes.length)]
  return Mods.DD4YokeSteel ; not actually 4.0 I don't think
endFunction

; returns an armbinder, yoke, or elbowbinder, based on user rolling
; currently only used by pony suit, but I might have more use for it
armor function getRandomHeavyBondage(actor actorRef)
  if player.WornHasKeyword(libs.zad_DeviousHeavyBondage)
    PlayerMon.debugmsg("Err: Player is already wearing heavy bondage")
  endif
  ; even if we're not modifying the chances here, we should still save them locally
  ; because papyrus is stupid, and will expensivly retrieve the values of a property everytime you link them, it will not cache
  int yoke      = MCM.iWeightSingleArmbinder 
  int elbow     = MCM.iWeightSingleElbowbinder
  int armbinder = MCM.iWeightSingleYoke
  int total = yoke + elbow + armbinder
  if total == 0
    PlayerMon.debugmsg("Err: No heavybondage set in MCM settings, cannot add anything")
  endif

  int roll = Utility.RandomInt(0, total)
  
  if roll < yoke
    return getRandomDDYoke(actorRef)
  elseif roll < yoke + elbow
    return getRandomDDElbowbinder()
  else;if roll < yoke + elbow + armbinder
    return getRandomDDArmbinders()
  endif
  
endFunction

bool function equipRandomDDBlindfolds(actor actorRef)
  PlayerMon.debugmsg("checking if blindfold is already worn ...", 1)
  keyword blindfold_kw = libs.zad_DeviousBlindFold
  if actorRef.wornHasKeyword(blindfold_kw) == false && actorRef.wornHasKeyword(libs.zad_DeviousHood) == false 
    armor blindfold = getRandomDDBlindfolds()
    if blindfold
      return equipRegularDDItem(actorRef, blindfold, None)
    endif
  else
    PlayerMon.debugmsg("Err: target " + actorRef + " is already wearing a hood or blindfold", 1)
  endif
  return false
endFunction

armor function getRandomDDBlindfolds()
  ;keyword blindfold = libs.zad_DeviousBlindFold
  ;armor  b = libs.blindfold
  return libs.GetGenericDeviceByKeyword(libs.zad_DeviousBlindFold)
  ;return libs.blindfold 
endFunction

;; hoods

bool function equipRandomHood(actor actorRef)
  PlayerMon.debugmsg("checking if hood is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousBlindFold) == false && actorRef.wornHasKeyword(libs.zad_DeviousHood) == false 
    armor hood = getRandomHood(actorRef)
    if hood
      return equipRegularDDItem(actorRef, hood, None)
    endif
  else
    PlayerMon.debugmsg("Err: target " + actorRef + " is already wearing a hood or blindfold", 1)
  endif
  return false
endFunction

; only two hoods, one DCUR one DD4
armor function getRandomHood(actor actorRef)
  ; we can probably move this to init, or to mods update
  int ddHood = 2 * ((libs.GetVersion() >= 8.0) as int)
  int dcurHood = 2 * (Mods.modLoadedCursedLoot as int)
  int total = ddHood + dcurHood
  if total == 0
    PlayerMon.debugmsg("Err: No hoods, roll total is zero")
    return none
  endif
  int roll = Utility.RandomInt(0,total)
  PlayerMon.debugmsg("hood roll: dd, dcur (" \
  + ddHood + "/" \
  + dcurHood + "/" \
  + ")")
  ; can we replace this with a static array that gets reset with mods reset?
  if roll < ddHood
    if roll == 0
      return Mods.DD4HoodBlackEbonite
    else
      return Mods.DD4HoodRubberHood
    endif
  else;if roll < ddHood + dcurHood
    roll = roll - 2
    if roll == 0
      return Mods.dcurBaloonHoodBlk
    elseif roll == 1
      return Mods.dcurBaloonHoodPink
    else
      return Mods.DD4HoodRubberHood
    endif
  endif
  
  return None
endFunction


bool function equipRandomStraitjacket(actor actorRef)
  if Mods.modLoadedDD4 == false
    PlayerMon.debugmsg("Cannot equip elowbinder user is not using DD 4.0", 1)
    return false
  endif
  PlayerMon.debugmsg("checking if straitjacket is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousStraitjacket) == false
    armor jacket = getRandomDDBlindfolds()
    if jacket
      return equipRegularDDItem(actorRef, jacket, None)
    endif
  else
    PlayerMon.debugmsg("Err: target " + actorRef + " is already wearing a straitjacket", 1)
  endif
  return false
endFunction

armor function getRandomStraitjacket()
  if Mods.modLoadedDD4 == false
    PlayerMon.debugmsg("Cannot get strait jacket requires DD v4", 1)
    return None
  endif
  return libs.GetGenericDeviceByKeyword(libs.zad_DeviousStraitjacket)
endFunction


; not finished
bool function equipRandomSingleZazFromArray(actor actorRef, Armor[] item_array, Keyword type_kw, Keyword type_kw2 = None, int theme_width , int type_width = 1)
  if(actorRef.wornHasKeyword(type_kw) == false && !(type_kw2 != None && actorRef.wornHasKeyword(type_kw) == true))
    ; get a type we can use, rolling based on what we have
    ; roll for remaining themes
    ;int offsetIndex = theme * theme_width 
    ;int total = red + white + reg + 
    ; if elses to figure out theme
    
    int offsetIndex
    offsetIndex = Utility.RandomInt(0,2) * theme_width
    ;int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDGags.length - 1);0 ; 01 are ebonite, 23 are red, 45 are white
    offsetIndex = offsetIndex + Utility.Randomint(0, theme_width - 1)
    ;armor rndrd = libs.GetRenderedDevice(item_array[offsetIndex])
    ;libs.equipDevice(actorRef, item_array[offsetIndex], rndrd, type_kw)
    return true
  endif
  return false
endFunction

; I think this function is borked, will need to double check
; yep, stops the mod from working every single time
;function equipPonygirlOutfit(actor actorRef)
; if you want to see what this looked like, revert to < 13

; more than one collar type we can use here
; return type describes if attempted adding worked
bool function equipPetGirlCollar(actor actorRef)
  armor collar = getPetGirlCollar()
  if collar
    return equipRegularDDItem(actorRef, collar, None)
  endif
  return false
endFunction

armor function getPetGirlCollar()
  ; right now there is only one collar from one mod, 
  return Mods.petCollar
endFunction

; pet items, if attacker thinks of you as his bitch
; cat or dog, not sure it matters so long as I can get one of them working
bool function equipRandomPetItem(actor actorRef)
  armor item = getRandomPetItem()
  if item
    return equipRegularDDItem(actorRef, item, None)
  endif
  return false
endFunction

armor function getRandomPetItem()
    return PlayerMon.petGear[Utility.randomint(PlayerMon.petGear.length)]
endFunction

function equipPetGirlOutit(actor actorRef)

  actorRef.UnEquipItemSlot(32)
  int index = 0
  equipPetGirlCollar(actorRef)
  while index < PlayerMon.petGear.length
    libs.ManipulateGenericDevice(actorRef, PlayerMon.petGear[index], true)
    index = index + 1
  endWhile
endFunction

; player only 
function equipDCURRubberOutfit(actor actorRef)
  ;nah, player only 
  ;SendModEvent("dcur_triggerRubberSuit") ; greaaaat this doesn't work now?
  
  libs.ManipulateGenericDevice(actorRef, Mods.dcurRubberSuit, true)
  libs.ManipulateGenericDevice(actorRef, Mods.dcurRubberCollar, true)
  
endFunction

function equipTransparentOutfit(actor actorRef)
  ; assuming cursed loot checking happens before we get this far
  PlayerMon.debugmsg("trying out transparent suit",3)
  int weightDDsuit = (Mods.modLoadedDD4 as int) * 50           ; for now 50/50?
  int weightDCURSuit = (Mods.modLoadedCursedLoot as int) * 50
  int total = weightDDsuit + weightDCURSuit
  if total == 0
    PlayerMon.debugmsg("Err: equipTransparentOutfit called but cursed loot isn't installed")
    return 
  endif
  int roll = Utility.RandomInt(0, total)
  
  if roll < weightDDsuit
    ; if player is PlayerMon.wearing items on top of the suit, take them off, keep them, put them back on?
    SendModEvent("dcur-triggerExhibitionistSuit")
  else;if roll < weightDDsuit + weightDCURSuit
  ; I think its suit then boots, but it might not matter
    libs.ManipulateGenericDevice(actorRef, Mods.DD4TransparentCatsuit, true)
    libs.ManipulateGenericDevice(actorRef, Mods.DD4TransparentCatsuitBoots, true)
  endif

endFunction

function equipCDxFullSet(actor actorRef)

  ; gold or silver roll here

endFunction


armor[] function getRandomCDItems(actor actorRef)    
  armor[] items = new armor[6]
  int item_index = 0
  int style = Utility.RandomInt(1,5) ; 0 is padded, 1 is gold, 2 is silver, 3 is white, 4 is black, 5 is red
  
  ; plug roll
  int roll = Utility.RandomInt(1,5)
  ;PlayerMon.debugmsg("roll is " + roll + " and style was " + style)
  if roll <= 2
    armor[] stuff = getCDStuff(actorRef)
    ;while i < stuff.length
    ;  if stuff[i]
    ;endWhile
    items[item_index] = stuff[0] ; for now just the one item, finish this later
    item_index += 1
  endif
  
  armor tmp = None
  roll = Utility.RandomInt(1,5) ; belt
  if roll <= 2
    if MCM.iWeightSingleBelt  == 0 && MCM.iWeightBeltCD == 0; b r w
      if style == 0
        tmp = None 
      elseif style == 1
        tmp = randomDDxHarnesss[0]
      elseif style == 2
        tmp = randomDDxHarnesss[0]
      elseif style == 3
        tmp = randomDDxHarnesss[1]
      elseif style == 4
        tmp = randomDDxHarnesss[0]
      elseif style == 5
        tmp = randomDDxHarnesss[1]
      endif
    else
      if style == 0
        tmp = None
      elseif style == 1
        tmp = Mods.cdGoldBelt
      elseif style == 2
        tmp = Mods.cdSilverBelt
      elseif style == 3
        tmp = Mods.cdWhiteBelt
      elseif style == 4
        tmp = Mods.cdBlackBelt
      elseif style == 5
        tmp = Mods.cdRedBelt
      endif
      ;PlayerMon.debugmsg("adding belt " + tmp)
    
    items[item_index] = tmp ; for now just the one item, finish this later
    item_index += 1

    endif  
  endif
  
  roll = Utility.RandomInt(1,5) ; cuffs
  if roll <= 2
    if style == 0
      tmp = None
    elseif style == 1
      items[item_index]     = Mods.cdGoldArmCuffs 
      items[item_index + 1] = Mods.cdGoldLegCuffs
      item_index += 2
    elseif style == 2
      items[item_index]     = Mods.cdSilverArmCuffs 
      items[item_index + 1] = Mods.cdSilverLegCuffs
      item_index += 2
    elseif style == 3
      items[item_index]     = Mods.cdWhiteArmCuffs 
      items[item_index + 1] = Mods.cdWhiteLegCuffs
      item_index += 2
    elseif style == 4
      items[item_index]     = Mods.cdBlackArmCuffs 
      items[item_index + 1] = Mods.cdBlackLegCuffs
      item_index += 2
    elseif style == 5
      items[item_index]     = Mods.cdRedArmCuffs 
      items[item_index + 1] = Mods.cdRedLegCuffs
      item_index += 2
    endif
  endif

  roll = Utility.RandomInt(1,5) ; collar
  if roll <= 2
    if style == 0
      tmp = None
    elseif style == 1
      tmp = Mods.cdGoldCollar
    elseif style == 2
      tmp = Mods.cdSilverCollar
    elseif style == 3
      tmp = Mods.cdWhiteCollar
    elseif style == 4
      tmp = Mods.cdBlackCollar
    elseif style == 5
      tmp = Mods.cdRedCollar
    endif
    ;PlayerMon.debugmsg("adding collar " + tmp)
    items[item_index] = tmp ; for now just the one item, finish this later
    item_index += 1
  endif

  if item_index == 0
    items[0] = Mods.cdTeaserPlug
    PlayerMon.debugmsg("pity roll for teaser")
  endif
  
  return items

endFunction

armor function getRandomNipplePiercings(actor actorRef)
  ; would you believe me if I told you Utility.RandomInt rolled 81 here for a size of 3? no idea
  ;[11/15/2017 - 06:31:12PM] ERROR: Array index 81 is out of range (0-2)
;stack:
	;[crdePlayerMonitor (9E001827)].crdeitemmanipulatescript.getRandomNipplePiercings() - "crdeItemManipulateScript.psc" Line 1360

  ;return randomDDNipplePiercings[Utility.RandomInt(randomDDNipplePiercings.length)]
  return randomDDNipplePiercings[Utility.RandomInt(0,2)]
endFunction

; todo finish this
armor[] function getCDStuff(actor actorRef)
  ; different anal and vag chances too.
  armor[] items = new armor[3]
  ; if all plugs are set to zero, no plugs
  int helpersChance = 10
  int devilsChance  = 10
  int roll = Utility.RandomInt(helpersChance + devilsChance)

    ; TODO change this to a random vag + anal where you can get more than one plug
  if roll < helpersChance
    roll = Utility.RandomInt(3)
    if roll == 0
      items[0] = Mods.cdTheifPlug
    elseif roll == 1
      items[0] = Mods.cdMagePlug
    elseif roll == 2
      items[0] = Mods.cdAssassinPlug
    else
      items[0] = Mods.cdFighterPlug
    endif
  else;if roll < helpersChance + devilsChance
    roll = Utility.RandomInt(6)
    if roll == 0
      items[0] = Mods.cdTormentingPlug
    elseif roll == 1
      items[0] = Mods.cdOrgasmPlug
    elseif roll == 2
      items[0] = Mods.cdTeaserPlug
    elseif roll == 3
      items[0] = Mods.cdFinisherPlug
    elseif roll == 4
      items[0] = Mods.cdSpoilerPlug
    elseif roll == 5
      items[0] = Mods.cdExciterPlug
    elseif roll == 6
      items[0] = Mods.cdPunisherPlug
    endif
  endif
  
  return items
endFunction

;followerItemsWhichOneFree
int function checkItemAddingAvailability(actor actorRef, keyword keywordRef)
  if keywordRef == None
    PlayerMon.debugmsg("Err checkItemAddingAvailability: keyword provided is none",1)
    return 0
  endif
    if actorRef == None
    PlayerMon.debugmsg("Err checkItemAddingAvailability: actor provided is none",1)
    return 0
  endif

  bool playerAlreadyWearing  = player.WornHasKeyword(keywordRef)
  bool actorAlreadyWearing   = actorRef.WornHasKeyword(keywordRef)
  if playerAlreadyWearing && actorAlreadyWearing
    return 0
  elseif playerAlreadyWearing
    return 1
  elseif actorAlreadyWearing
    return 2
  else
    return 3
  endif
endFunction

function setFollowerFoundItem(actor actorRef, int itemCombo, keyword kw, objectReference c, armor a1, armor a2 = none, armor a3 = none)
  PlayerMon.followerItemsCombination = itemCombo
  ;PlayerMon.debugmsg("two armors: " + a1 + a2)
  c.RemoveItem(a1, abSilent = true)
  followerFoundArmorBuffer[0] = a1
  followerFoundArmorBuffer[1] = a2
  followerFoundArmorBuffer[2] = a3
  PlayerMon.followerItemsWhichOneFree = checkItemAddingAvailability(actorRef, kw)
endFunction

; this assumes the armors passed are shuffled to allow for random searching, 
;  as this doesn't shuffle or randomize the armor and checks sequentially
; this needs to be updated for more potential items
bool function checkFollowerFoundItems(actor actorRef, armor[] armorArray, objectReference[] containerArray)
  ; for keyword, check to see if an item in the list is included
  int i = 0
  armor tmp 
  int last = 0
  keyword itemDDKeyword = None
  ; for all items in the armor array
  while i < armorArray.length
    if armorArray[i] == NONE
      last = i
      i = 100
      ;PlayerMon.debugmsg("Leaving check items at [" + i + "] because we have reached NONE(end)")
      ;return false
    endif 
    tmp = libs.GetRenderedDevice(armorArray[i]) ; the rendered one has the type keywords, the inventory item only has the inventory item
    itemDDKeyword = libs.GetDeviceKeyword(armorArray[i])
    if itemDDKeyword == NONE
      PlayerMon.debugmsg(" * keyword was none")
    endif
    PlayerMon.debugmsg("Checking item: " + armorArray[i] + " has keyword: " + itemDDKeyword.GetString())

    ; can't think of a faster way than something like this
    ; TODO flesh this out later with more stuff, and/or write a section at the bottom for random selection
      ; might need more dialogue
    if    itemDDKeyword == libs.zad_DeviousCollar
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar) == 0
        PlayerMon.debugmsg(" * Collar found but NPCs not available")
      elseif MCM.iWeightSingleCollar == 0
        PlayerMon.debugmsg(" * Collar found but player has set that item weight 0")        
      endif
      PlayerMon.debugmsg(" * Collar found: " + tmp)
      setFollowerFoundItem(actorRef, 1, libs.zad_DeviousCollar, containerArray[i], armorArray[i])
      return true

    elseif itemDDKeyword == libs.zad_DeviousPlug
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousPlug) == 0
        PlayerMon.debugmsg(" * Plug found but NPCs not available")
      elseif MCM.iWeightPlugs == 0
        PlayerMon.debugmsg(" * Plug found but player has set that item weight 0")        
      endif
      PlayerMon.debugmsg(" * Plug found: " + tmp)
      setFollowerFoundItem(actorRef, 2, libs.zad_DeviousCollar, containerArray[i], armorArray[i], libs.beltIron)
      return true

    elseif itemDDKeyword == libs.zad_DeviousArmbinder
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousArmbinder) == 0
        PlayerMon.debugmsg(" * Armbinder found but NPCs not available")
      elseif MCM.iWeightSingleArmbinder == 0
        PlayerMon.debugmsg(" * Armbinder found but player has set that item weight 0")        
      endif
      PlayerMon.debugmsg(" * Armbinder found: " + tmp)
      setFollowerFoundItem(actorRef, 8, libs.zad_DeviousArmbinder, containerArray[i], armorArray[i])
      return true
      
    elseif itemDDKeyword == libs.zad_DeviousGag
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousGag) == 0
        PlayerMon.debugmsg(" * Gag found but NPCs not available")
      elseif MCM.iWeightSingleGag == 0
        PlayerMon.debugmsg(" * Gag found but player has set that item weight 0")
      endif
      PlayerMon.debugmsg(" * Gag found: " + tmp)
      setFollowerFoundItem(actorRef, 13, libs.zad_DeviousGag, containerArray[i], armorArray[i])
      return true

    elseif itemDDKeyword == libs.zad_DeviousHarness
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousHarness) == 0
        PlayerMon.debugmsg(" * Harness found but NPCs not available")
      elseif MCM.iWeightSingleHarness == 0
        PlayerMon.debugmsg(" * Harness found but player has set that item weight 0")
      endif
      PlayerMon.debugmsg(" * Harness found: " + tmp)
      setFollowerFoundItem(actorRef, 17, libs.zad_DeviousHarness, containerArray[i], armorArray[i])
      return true
      
    elseif itemDDKeyword == libs.zad_DeviousBelt
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousBelt) == 0
        PlayerMon.debugmsg(" * Belt found but NPCs not available")
      elseif MCM.iWeightSingleBelt == 0
        PlayerMon.debugmsg(" * Belt found but player has set that item weight 0")
      endif
      PlayerMon.debugmsg(" * Belt found: " + tmp)
      setFollowerFoundItem(actorRef, 25, libs.zad_DeviousBelt, containerArray[i], armorArray[i])
      return true

    elseif itemDDKeyword == libs.zad_DeviousSuit
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousSuit) == 0
        PlayerMon.debugmsg(" * Suit found but NPCs not available")
      elseif MCM.iWeightMultiRubber == 0
        PlayerMon.debugmsg(" * Suit found but player has set that item weight 0")
      endif
      PlayerMon.debugmsg(" * Suit found: " + tmp)
      setFollowerFoundItem(actorRef, 14, libs.zad_DeviousSuit, containerArray[i], armorArray[i])
      return true      
      
    elseif itemDDKeyword == libs.zad_DeviousPiercingsNipple
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousPiercingsNipple) == 0
        PlayerMon.debugmsg(" * Nipple pierce found but NPCs not available")
      elseif MCM.iWeightSingleNipplePiercings == 0
        PlayerMon.debugmsg(" * Nipple pierce found but player has set that item weight 0")
      endif
      PlayerMon.debugmsg(" * Nipple pierce found: " + tmp)
      setFollowerFoundItem(actorRef, 21, libs.zad_DeviousPiercingsNipple, containerArray[i], armorArray[i])
      return true      
      
    elseif itemDDKeyword == libs.zad_DeviousPiercingsVaginal
      if checkItemAddingAvailability(actorRef, libs.zad_DeviousPiercingsVaginal) == 0
        PlayerMon.debugmsg(" * Vaginal pierce found but NPCs not available")
      elseif MCM.iWeightSingleVagPiercings == 0
        PlayerMon.debugmsg(" * Vaginal pierce found but player has set that item weight 0")
      endif
      PlayerMon.debugmsg(" * Vaginal pierce found: " + tmp)
      setFollowerFoundItem(actorRef, 22, libs.zad_DeviousPiercingsVaginal, containerArray[i], armorArray[i])
      return true      

    endIf
    i += 1
  endWhile
  
  ; if we reach this far, then none of the items met the specific criteria... 
  ; lets have random selection of items from the pool, if the user allows for it
  if MCM.bFollowerContainerSearchUnknown
    PlayerMon.debugmsg("No specific items found, randomly picking some unknown items ...")
    int rand = 1
    ;while rand > 0
      rand  = Utility.RandomInt(0, last)
      armor arm = armorArray[rand]
      keyword kw = libs.GetDeviceKeyword(arm)
      setFollowerFoundItem(actorRef, 0, kw, containerArray[rand], arm)
    ;endWhile
    ;rand  = Utility.RandomInt(0, 1)
    return true
  else
    PlayerMon.debugmsg("No specific items found, leaving at [" + i + "]")
  endif
  
  return false 
endFunction


; In order for our dialogue to be specific, and in order for our weights and percentages to work
;  we have to roll this stuff before dialogue starts, and hope users don't hack the parts they want
; contains a number for different combos
;   last edited: 2018-1-29 , there is another list in crdePlayerMonitorScript with the same info
; -------------------------------------------------------------------------------------------------
;   0 is random single item, 1 is random collar
;-  2 is plug and extra, 3 is belt and extra                 DEPRECATED
;   4 is gloves and boots, 5 is other boots, 6 cuffs
;   7 is blindfold, 8 is armbinder, 9 is yoke
;   10 is random ringgag, 11 is random ball gag, 12 is random panel gag, 13 is random any gag
;   14 is rubber suit, 15 is red suit, 16 is pony suit, 
;   21 nipple piercings, 22 vag/cock piercing, 23 random, 24 both
;   30 is random unique collar
;   31 is pet collar
;   40 is random CDx items
;   50 is random plug, 51 is random plug and more, 52 is random gem plug and more
;   55 is random belt and more, 56 is random harness and more
; where "and more" is optional
;getFollowerFoundItems
function rollFollowerFoundItems(actor actorRef)
  
  ; as good of a place to reset this stuff as anywhere
  ;followerFoundArmorBuffer = new Armor[10]
  followerFoundArmorBuffer[0] = None
  followerFoundArmorBuffer[1] = None
  followerFoundArmorBuffer[2] = None
  followerFoundArmorBuffer[3] = None
  followerFoundArmorBuffer[4] = None
  
  
  ;int random          = 1 ;MCM.iWeightBeltPadded  * (player.WornHasKeyword(libs.zad_Devious) as int)
  int collar          = MCM.iWeightSingleCollar       * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar)     > 0) as int)  
  int randomPlug      = MCM.iWeightPlugs              * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousPlug)       > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousBelt)) as int)
  int belt            = MCM.iWeightSingleBelt         * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousBelt)       > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousBelt)) as int)
  int glovesandboots  = MCM.iWeightSingleGlovesBoots  * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousBoots)      > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousBoots)) as int)
  int cuffs           = MCM.iWeightSingleCuffs        * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousArmCuffs)   > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousArmCuffs)) as int)
  int randomGag       = MCM.iWeightSingleGag          * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousGag)        > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousGag)) as int)
  int harness         = MCM.iWeightSingleHarness      * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousHarness)    > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousHarness)) as int)
  int armbinder       = MCM.iWeightSingleArmbinder    * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousArmbinder)  > 0) as int)
  int randomCD        = MCM.iWeightRandomCD           * ( Mods.modLoadedCD ) as int
  int nipplePiercings = MCM.iWeightSingleNipplePiercings * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousPiercingsNipple)  > 0) as int)
  int petCollar       = MCM.iWeightPetcollar          * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar)     > 0) as int)  
  int uniqueCollar    = MCM.iWeightUniqueCollars      * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar)     > 0) as int)  
  
  int elbowbinder     = MCM.iWeightSingleElbowbinder  * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousArmbinder)  > 0 && Mods.modLoadedDD4) as int)
  int hobbledress     = MCM.iWeightSingleElbowbinder  * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousSuit)  > 0 && Mods.modLoadedDD4) as int)
  ;int gemplugandmore  = gemPlugAvailable * MCM.iWeightPlugs * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousPlug)  > 0) as int) / 2
  
  ;int rubberSuit      = MCM.iWeightSingleBelt   * (( ! player.WornHasKeyword(libs.zad_DeviousSuit)) as int) ; not here, lets do this as tier 2 items adding
  
  int total       = collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder \
                  + randomCD + nipplePiercings + petCollar + uniqueCollar + elbowbinder ;+ gemplugandmore
  
  int roll = Utility.RandomInt(1,total)
  keyword armorKeyword = None
  
  if     roll < collar 
    PlayerMon.followerItemsCombination = 1
    armorKeyword = libs.zad_DeviousCollar
  elseif roll < collar + randomPlug 
    ; roll for a gem plug or regular plug
    ; I SHOULD make the roll based on gem plug vs total (both) but I'm lazy
    int gemPlugAvailable  = (MCM.iWeightPlugSoulGem > 0 || MCM.iWeightPlugCharging > 0 || MCM.iWeightPlugShock > 0 \
                          || (MCM.iWeightPlugCDEffect > 0 || MCM.iWeightPlugCDSpecial > 0 && Mods.modLoadedCD)) as int
    if  gemPlugAvailable && Utility.RandomInt(0, 100) > 50
      PlayerMon.followerItemsCombination = 52
      armorKeyword = libs.zad_DeviousPlug
    else
      PlayerMon.followerItemsCombination = 50
      armorKeyword = libs.zad_DeviousPlug
    endif
  elseif roll < collar + randomPlug + belt 
    PlayerMon.followerItemsCombination = 3
    armorKeyword = libs.zad_DeviousBelt
  elseif roll < collar + randomPlug + belt + glovesandboots 
    PlayerMon.followerItemsCombination = 4
    armorKeyword = libs.zad_DeviousBoots
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs
    PlayerMon.followerItemsCombination = 6
    armorKeyword = libs.zad_DeviousArmCuffs
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag 
    PlayerMon.followerItemsCombination = 13
    armorKeyword = libs.zad_DeviousGag
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness 
    PlayerMon.followerItemsCombination = 56
    armorKeyword = libs.zad_DeviousHarness
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder 
    PlayerMon.followerItemsCombination = 8
    armorKeyword = libs.zad_DeviousArmbinder
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD 
    PlayerMon.followerItemsCombination = 40
    armorKeyword = libs.zad_DeviousBelt ; TODO this should be changed
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings
    PlayerMon.followerItemsCombination = 21
    armorKeyword = libs.zad_DeviousPiercingsNipple
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings + petCollar
    PlayerMon.followerItemsCombination = 31
    armorKeyword = libs.zad_DeviousCollar
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings + petCollar + uniqueCollar 
    PlayerMon.followerItemsCombination = 30
    armorKeyword = libs.zad_DeviousCollar
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings + petCollar + uniqueCollar + elbowbinder
    PlayerMon.followerItemsCombination = 8
    armorKeyword = libs.zad_DeviousArmbinder 
  ;else;if roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings + petCollar + uniqueCollar + elbowbinder + gemplugandmore
  ;  PlayerMon.followerItemsCombination = 52
  ;  armorKeyword = libs.zad_DeviousPlug 
  endif     
  
  if armorKeyword
    PlayerMon.followerItemsWhichOneFree = checkItemAddingAvailability(actorRef, armorKeyword)
    ;PlayerMon.debugmsg("for keyword: " + armorKeyword + " availability is " + PlayerMon.followerItemsWhichOneFree)
    PlayerMon.debugmsg("collar/randomPlug/belt/glovesandboots/cuffs/randomGag/harness/armbinder/randomCD/nipplePiercings/petcollar/uniqueCollar/elbowbinder/gemplug(" \
                      + collar + "/" + randomPlug + "/" + belt + "/" + glovesandboots + "/" + cuffs + "/" \
                      + randomGag + "/"  + harness + "/"  + armbinder + "/"  + randomCD + "/" + nipplePiercings \
                      + "/" + petCollar + "/" + uniqueCollar + "/" + elbowbinder \
                      +  ")")
    PlayerMon.debugmsg("roll/total/avail/ic/kw:(" + roll + "/" + total + "/" + PlayerMon.followerItemsWhichOneFree + "/" + PlayerMon.followerItemsCombination + "/ " + armorKeyword + ")", 2)
                        
  else
    PlayerMon.debugmsg("ERR: no armor keyword")
    PlayerMon.followerItemsWhichOneFree = -1 ; last second error, should never happen
  endif
  
endFunction

function equipFollowerFoundItems(actor actorRef)

  armor[] items = getFollowerFoundItems(actorRef)
    
  int ic = PlayerMon.followerItemsCombination ; shorter, also avoiding the compiler asking PlayerMon for the property over and over again
  if ic == 1 || ic == 5 || ic == 7 || ic == 13 || ic == 30
    ; don't need to remove chest, can just put on player
  else
    actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the belt
  endif

  PlayerMon.debugmsg("items to add:" + items)
  
  int i = 0
  string name = None
  armor tmp = none
  while i < items.length
    name = None
    tmp = items[i]
    if tmp !=None
      name = tmp.GetName()
      PlayerMon.debugmsg(" equipping " + tmp + " on actor "+ actorRef, 2)
      equipRegularDDItem(actorRef, tmp, None)
      Utility.Wait(0.25)
    ;else
      ;i = 100 ; end early, added in 13.9
    endif
    i += 1
  endWhile
  
endFunction

; this is to apply follower items, and from player if they exist, onto the player from the follower context
function equipFollowerAndPlayerItems(actor follower, bool forceBelt = false, bool forceGag = false, bool forceCollar = false, bool forceArmbinder = false, bool forceHarness = false)
  ; for now, the "and player items if they have it" isn't implemented, instead pulling items out of thin air
  
  ; at least 3: armbinder/blindfold/gag/belt/naked with collar
  ; follower borrows your keys
  ; roll 25% we use what the player or follower has, else we make something new
  
  ; XXX
  ;getRandomMultipleDD(player)
  ; because getRandomMultipleDD equips them too, due to outfits, we have to do all we want here instead
  
  int requiredMin = (forceBelt as int) + (forceGag as int) + (forceCollar as int) + (forceArmbinder as int)
  ;int roll = ; 
  int icount = Utility.RandomInt(requiredMin ,4) ; for now, 4 is max because it seems reasonable
  ; this is equal chance, which leans toward 4 too heavily when we don't need 4
  ; TODO swap to a system that swings heavier toward the other direction
  PlayerMon.debugmsg("minimum items: " + requiredMin + ", count roll: " + icount)
  
  armor[] items = new armor[6] ; assuming 3 for belt, 1 collar, 1 armbinder, 1 gag, 2 for cuffs, 5 should be enough but lets do 6
  int itemsptr = 0
  armor[] tmp = new armor[1] ; just declaring, ignore the size
  
  ; for items we DONT specify, get randomly
  ; right now this is only single items, no outfits or combos
  int remainingitems = icount - requiredMin
  while remainingitems > 0 
    tmp = getRandomSingleDD(player)
    if tmp[1] != None
      items[itemsptr] = tmp[0]
      items[itemsptr + 1] = tmp[1]
      itemsptr += 2
    else ; tmp[1] != None ; else will be shorter compiler code
      items[itemsptr] = tmp[0]
      itemsptr += 1
    endif
    remainingitems -= 1
  endWhile
  
  ; specific items we need to add
  if forceBelt  && !player.WornHasKeyword(libs.zad_DeviousBelt)  ; *** BELT ***
    tmp = getRandomBeltAndStuff(player, forceStuff = true)
    int i = 0
    while i < tmp.length
      if tmp[i] == None
        i = 100
      else
        items[itemsptr] = tmp[i]
        itemsptr += 1
      endif
      i += 1
    endWhile
  endif
  if forceHarness
    tmp = getRandomHarnessAndStuff(player, force_stuff = true) 
    int i = 0
    while i < tmp.length
      if tmp[i] == None
        i = 100
      else
        items[itemsptr] = tmp[i]
        itemsptr += 1
      endif
      i += 1
    endWhile
  endif
  if forceGag && ! player.WornHasKeyword(libs.zad_DeviousGag)
    items[itemsptr] = getRandomGag()
    itemsptr += 1  
  endif
  if forceArmbinder && ! player.WornHasKeyword(libs.zad_DeviousArmbinder)
    items[itemsptr] = getRandomDDArmbinders()
    itemsptr += 1  
  endif
  if forceCollar && ! player.WornHasKeyword(libs.zad_DeviousCollar)
    items[itemsptr] = getRandomGag()
    itemsptr += 1  
  endif

  int i = 0
  armor t
  while i < items.length
    t = items[i]
    if t != None
      ;name = tmp.GetName()
      ;PlayerMon.debugmsg(" equipping " + tmp + " on actor "+ actorRef, 2)
      equipRegularDDItem(player, t, None)
      Utility.Wait(0.25)
    endif
    i += 1
  endWhile
  
  ; set the follower's containers to zero, 
  ;  because it would be weird if the follower ties the player up then turns around and adds more
  PlayerMon.resetFollowerContainerCount(follower)  
  
endFunction

function swapFollowerFoundItems(actor actorRef)

  armor[] items = getFollowerFoundItems(actorRef)
  int ic = PlayerMon.followerItemsCombination ; shorter, also avoiding the compiler asking PlayerMon for the property over and over again
  if ic == 1 || ic == 5 || ic == 7 || ic == 13 || ic == 30
    ; don't need to remove chest, can just put on player
  else
    actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the belt
  endif

  ; remove all devices already worn on actor that have the same keywords as items we want to put on 
  int i = 0
  Keyword tmpkw
  armor dd 
  armor rndrd ; these are both needed to remove through DDi interface
  ; for all devices in our list
  while i < items.length && items[i] != NONE
    tmpkw = libs.GetDeviceKeyword(items[i])
    dd    = libs.GetWornDevice(actorRef, tmpkw)
    if dd != None
      rndrd = libs.GetRenderedDevice(dd)
      if !dd.HasKeyword(libs.zad_BlockGeneric)
        libs.removeDevice(actorRef, dd, rndrd, tmpkw)
        if dd != None && dd.haskeyword(libs.zad_DeviousBelt)
          previousBelt = dd
        endif
      else
        PlayerMon.debugmsg("Could not remove because blocking kwd: " + dd + " " + tmpkw)
      endif 
    endif
    i += 1
  endWhile
  
  ; put on new items
  i = 0
  string name = None
  armor tmp = none
  while i < items.length
    name = None
    tmp = items[i]
    if tmp !=None
      name = tmp.GetName()
      PlayerMon.debugmsg(" equipping " + tmp + " on actor "+ actorRef, 2)
      equipRegularDDItem(actorRef, tmp, None)
      Utility.Wait(0.25)
    ;else
      ;i = 100 ; end early, added in 13.9
    endif
    i += 1
  endWhile

endFunction

; search "0 is random single item" to find the list of these combinations
; sets IC: rollFollowerFoundItems
armor[] Function getFollowerFoundItems(actor actorRef)
  armor[] items = new armor[8]
  if followerFoundArmorBuffer[0] != None
    items[0] = followerFoundArmorBuffer[0]
    items[1] = followerFoundArmorBuffer[1]
    items[2] = followerFoundArmorBuffer[2]
    PlayerMon.debugmsg("items: " + items)
  else
    int ic = PlayerMon.followerItemsCombination ; shorter, also avoiding the compiler asking PlayerMon for the property over and over again
    if ic     == 0
      items = getRandomSingleDD(actorRef)
    elseif ic == 1
      items[0] = getRandomDDCollars(actorRef)
    elseif ic == 2 ; DEPRECATED
      items = getRandomBeltAndStuff(actorRef, forceStuff = true)
    elseif ic == 3 ; DEPRECATED
      items = getRandomBeltAndStuff(actorRef)
    elseif ic == 4
      items = getRandomDDxRGlovesBoots()
    elseif ic == 6
      items = getRandomDDCuffs() ;equipRandomDDCuffs
    elseif ic == 13
      items[0] = getRandomGag()
    elseif ic == 8
      items[0] = getRandomDDArmbinders()    
    elseif ic == 17 
      items = getRandomHarnessAndStuff(actorRef)
    elseif ic == 21 
      items[0] = getRandomNipplePiercings(actorRef)
    elseif ic == 24 
      ;items[0] = getRandomAssortedPiercings(actorRef)
    elseif ic == 30 
      items[0] = getRandomUniqueCollar(actorRef)
    elseif ic == 31
      items[0] = Mods.petCollar
    elseif ic == 40 
      items = getRandomCDItems(actorRef)
    
    ; using harness body for now, because not sure which item has both closed for both plugs
    elseif ic == 50
      items = getRandomBeltStuff(actorRef, libs.harnessBody, forceGem = true)
    elseif ic == 52
      items = getRandomBeltStuff(actorRef, libs.harnessBody, forceGem = true)
    elseif ic == 56
      items = getRandomHarnessAndStuff(actorRef)
    else
      PlayerMon.debugmsg("Err: Unexpected value for followerItemsCombination: " + ic)
    endif     
  endif
  
  return items

endFunction

; gives items to actor
function giveFollowerFoundItems(actor actorRef)

  if actorRef == None
    actorRef = player
  endif

  armor[] items = getFollowerFoundItems(actorRef)

  int i = 0
  while i < items.length && items[i] != None
    actorRef.addItem(items[i])
    i += 1
    Utility.Wait(0.1)
  endWhile

endFunction



; detects what theme of items the player is already PlayerMon.wearing
; use bit masks, 32 should be waaaay more than enough for all themes
; reg(s/w/r) ebonite(e/w/r) cd(g/s)
int function detectActiveThemes()
  ; Crap, this might not be cheap AT ALL
endFunction

; returns ONE random theme taken from PlayerMon.knownThemes, in the range of the themeRangeMask
int function pickATheme(int knownThemes, int themeRangeMask)
  ;if PlayerMon.knownThemes 
  ;make list of 2 power's that are active, pick one at random?
  ;int i = leftshift(89,2) ;need math
endFunction

; for now, might as well use this
function stripPlayer()
    unequipAllNonImportantSlow()  
endFunction

; length is passed because the passed array is oversized, and papyrus doesn't allow for subarray passing
; array returned is the original size
armor[] function shuffleArmor(armor[] providedArmor, objectReference[] containerArray, int len)
  int i = 0
  int randomPick = 0
  armor tmpArm
  objectReference tmpRef
  while i < len
    randomPick = Utility.RandomInt(0,len - 1)
    tmpArm = providedArmor[i]
    providedArmor[i] = providedArmor[randomPick]
    providedArmor[randomPick] = tmpArm
    tmpRef = containerArray[i]
    containerArray[i] = containerArray[randomPick]
    containerArray[randomPick] = tmpRef
    i += 1
  endWhile
  return providedArmor
endFunction

; this is loose, we're ignoring count here, if the player put it back, ect
bool function itemStillInContainer(form f, objectReference c)
  if c == NONE
    PlayerMon.debugmsg("Err: container passed is NONE",4)
    return false
  endif
  int containerComplement = c.GetNumItems()
  if containerComplement > 0 
    int remaining = c.GetItemCount(f)
    return remaining >= 1
  endif
  return false
endFunction

; my war to remove WornHasKeyword for specific item keywords
; at least call this to preempt the big rolling functions
function updateActorWearingDD(actor actorRef)
  PlayerMon.debugmsg("checking follower items ...",3)
  actorKnownArmbinder = actorRef.GetWornForm(0x00010000) as armor ; 46
  actorWearingArmbinder = actorKnownArmbinder != None &&  actorKnownArmbinder.HasKeyword(libs.zad_DeviousArmbinder)
  
  actorKnownBlindfold = actorRef.GetWornForm(0x02000000) as armor ; 55
  actorWearingBlindfold = actorKnownBlindfold != None &&  actorKnownBlindfold.HasKeyword(libs.zad_DeviousBlindfold)
  
  actorKnownCollar = actorRef.GetWornForm(0x00008000) as armor ; 45
  actorWearingCollar = actorKnownCollar != None && actorKnownCollar.HasKeyword(libs.zad_DeviousCollar)
  
  actorKnownGag = actorRef.GetWornForm(0x00004000) as armor ; 44
  actorWearingGag = actorKnownGag != None && actorKnownGag.HasKeyword(libs.zad_DeviousGag)
  
  actorKnownBelt = actorRef.GetWornForm(0x00080000) as armor ; 49
  actorWearingBelt = actorKnownBelt != None && actorKnownBelt.HasKeyword(libs.zad_DeviousBelt)
  
  armor tmp  = actorRef.GetWornForm(0x00100000) as armor ; 50 nipple
  armor tmp2 = actorRef.GetWornForm(0x00200000 ) as armor ; 51 vag
  actorWearingPiercings = (tmp != None && tmp.HasKeyword(libs.zad_DeviousPiercingsNipple)) || (tmp2 != None &&tmp2.HasKeyword(libs.zad_DeviousPiercingsVaginal))
  
  actorKnownHarness = actorRef.GetWornForm(0x10000000 ) as armor ; 58
  actorWearingHarness = actorKnownHarness != None && actorKnownHarness.HasKeyword(libs.zad_DeviousHarness)
  
  actorKnownSlaveBoots = actorRef.GetWornForm(0x00000080) as armor ; 37
  actorWearingSlaveBoots = actorKnownSlaveBoots != None && actorKnownSlaveBoots.HasKeyword(libs.zad_DeviousBoots)

  actorKnownAnkleChains = actorRef.GetWornForm(0x00000080) as armor ; 53
  actorWearingAnkleChains = actorKnownAnkleChains


endFunction