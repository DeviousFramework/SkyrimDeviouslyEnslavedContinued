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
SexLabFramework Property SexLab Auto

crdePlayerMonitorScript   Property PlayerMon Auto
crdeMCMScript             Property MCM Auto
crdeModsMonitorScript     Property Mods Auto

actor Property player auto

; these are armors to be equipped on the player or other, 
;Formlist Property followerArmorFormList Auto ; don't think I'll end up using this... 
; Armor Property FollowerArmor1 Auto
; Armor Property FollowerArmor2 Auto
; Armor Property FollowerArmor3 Auto
; Armor Property FollowerArmor4 Auto
; Armor Property FollowerArmor5 Auto
; Armor Property FollowerArmor6 Auto

Armor Property previousBelt Auto ; for reapplication
Armor Property previousGag Auto ; for reapplication

;Armor[] Property PlayerMon.petGear  Auto  ; ebonite collar should be in the back

Outfit Property BallandChainRedOutfit Auto
Outfit Property BlackPonyMixedOutfit Auto



crdeVars Property Vars Auto ; still not sure what this thing was for


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
; punishment version
Armor[] Property randomDDPunishmentVagPlugs  Auto  
Armor[] Property randomDDPunishmentAnalPlugs  Auto  
Armor[] Property randomDDPunishmentVagPiercings  Auto 



Race[] Property alternateRaces Auto

; todo, break this into individual keywords, since the creation kit is a fickle bitch
Keyword[] Property deviceKeywords  Auto 

; just from player, was meant to clear armor quickly, not sure if it's even still being used 
function removeDDs()
	
	PlayerMon.updateWornDD(); good idea
  ; TODO add other items that we might want to remove, like cuffs/belts
  ;TODO add specifics for specialty colars later
	if PlayerMon.wearingCollar; && !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric))
		removeDDbyKWD(PlayerMon.player, libs.zad_DeviousCollar)
	endif
	if PlayerMon.wearingArmbinder ;&& !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric))
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousArmbinder)
		;removeDDbyArmor(PlayerMon.knownArmbinder)
	endif
	if PlayerMon.wearingGag; && !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric))
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousGag)
		;removeDDbyArmor(PlayerMon.knownGag)
	endif
	if PlayerMon.wearingBlindfold; && !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric))
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousBlindFold)
		;removeDDbyArmor(PlayerMon.knownBlindfold)
	endif
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
	armor dd    = libs.GetWornDeviceFuzzyMatch(actorRef, keywordRef)
	armor rndrd = libs.GetRenderedDevice(dd)
	libs.removeDevice(actorRef, dd, rndrd, keywordRef)
  if dd != None && dd.haskeyword(libs.zad_DeviousBelt)
    previousBelt = dd
  endif
endFunction

function removeDDArmbinder(actor actorRef)
  ;removeDDbyKWD(Mods.zazKeywordAnimWrists) ; if this works this should take care of all hands locking items
  ;removeDDbyKWD(libs.zad_DeviousYoke)      ; maybe this was a touch reckless, we have the item from earlier
  ;removeDDbyKWD(libs.zad_DeviousArmbinder)
  if actorRef.Wornhaskeyword(libs.zad_DeviousArmbinder) ;&& actorRef.knownArmbinder != None
    removeDDbyKWD(actorRef, libs.zad_DeviousArmbinder)
  elseif actorRef.Wornhaskeyword(libs.zad_DeviousArmbinder)
    if actorRef.WornHasKeyword(libs.zad_DeviousYoke)
      removeDDbyKWD(actorRef, libs.zad_DeviousYoke)      ; maybe this was a touch reckless, we have the item from earlier
    elseif actorRef.WornHasKeyword(libs.zad_DeviousArmbinder)
      removeDDbyKWD(actorRef, libs.zad_DeviousArmbinder)
    else
      PlayerMon.debugmsg("removeDDArmbinder: wearingArmbinder is true but armor unPlayerMon.known: " + actorRef.GetWornForm(0x2E));(46)
    endif
  endif
endFunction

; TODO rewrite this to work with any direction player and NPC, not just one direction
function stealKeys(actor actorRef)
  if actorRef == None
    PlayerMon.Debugmsg("stealKeys err: none reference")
    return
  endif
  if player == None
    player = Game.GetPlayer() ; needs refreshing? sometimes none at this point
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
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousArmCuffs)
    Utility.Wait(1)
  endif
  if player.WornHasKeyword(libs.zad_DeviousLegCuffs) ; LEG CUFFS
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousLegCuffs)
    Utility.Wait(1)
  endif
  ;Utility.Wait(1)
  ; followed by Restrictive boots, arms
  if player.WornHasKeyword(libs.zad_DeviousGloves) ; GLOVES
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousGloves) ; 33
    Utility.Wait(1)
  endif
  if player.WornHasKeyword(libs.zad_DeviousBoots) ; LEGGINGS
    removeDDbyKWD(PlayerMon.player, libs.zad_DeviousBoots) ; 37
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
  ;Armor collar  = player.GetWornForm( 0x00008000 ) as Armor ;maybe this doesn't always work?
  armor collar   = libs.GetWornDeviceFuzzyMatch(actorRef, libs.zad_DeviousCollar)
	;armor rndrd = libs.GetRenderedDevice(collar)
	if collar != None && actorRef.WornHasKeyword(libs.zad_DeviousCollar) && !collar.HasKeyword(libs.zad_BlockGeneric) 
    PlayerMon.debugmsg("Trying to remove: " + collar.GetName())
		;PlayerMon.updateWornDD(true) ; lets assume this is a waste of time, 
    ;removeDDbyKWD(libs.zad_DeviousCollar)
		removeDDbyArmor(actorRef, collar)
    Utility.Wait(1)
    return true
  ;elseif actorRef.WornHasKeyword(libs.zad_DeviousHarness) ;&& !PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric)
  ;  ; lets assume there are no blocking harnesses, I'm sure this won't come back and bite me in the ass one day...
	;	removeDDbyArmor(PlayerMon.knownCollar)
  ;  return true
    
  elseif actorRef.WornHasKeyword(Mods.zazKeywordWornCollar)
    PlayerMon.debugmsg("removecurrentcollar called but actorRef has collar but blocking keyword present")
    return false
  else 
    PlayerMon.debugmsg("removecurrentcollar called but actorRef is not wearing collar")
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
	PlayerMon.CheckDevices()
  Armor collar          = actorRef.GetWornForm( 0x00008000 ) as Armor 
  bool collarBlocked    = collar != None && actorRef.WornHasKeyword(libs.zad_DeviousCollar) && collar.HasKeyword(libs.zad_BlockGeneric) ;PlayerMon.knownCollar != None && PlayerMon.knownCollar.HasKeyword(libs.zad_BlockGeneric)
  bool isCollarable     = !(actorRef.WornHasKeyword(Mods.zazKeywordWornYoke) || collarBlocked || Mods.iEnslavedLevel > 0)
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
	PlayerMon.CheckDevices()
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

armor[] function getRandomSingleDD(actor actorRef)
  ; TODO check if player is already blocked, return with false
	bool success = false
  int glovesbootsChance   = MCM.iWeightSingleGlovesBoots * ((!actorRef.wornHasKeyword(libs.zad_DeviousGloves) && !actorRef.wornHasKeyword(libs.zad_DeviousBoots)) as int)
  int armbinderChance     = MCM.iWeightSingleArmbinder * ((!actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) && !actorRef.wornHasKeyword(libs.zad_DeviousYoke)) as int)
  int collarChance        = MCM.iWeightSingleCollar * ((!actorRef.wornHasKeyword(libs.zad_DeviousCollar)) as int) ; could do harness too
  int gagChance           = MCM.iWeightSingleGag * ((!actorRef.wornHasKeyword(libs.zad_DeviousGag)) as int)
  int harnessChance       = MCM.iWeightSingleHarness * ((!actorRef.wornHasKeyword(libs.zad_DeviousHarness) && !actorRef.wornHasKeyword(libs.zad_DeviousBelt)) as int) ; do I not need the keyword for corset
  int beltChance          = MCM.iWeightSingleBelt * ((!actorRef.wornHasKeyword(libs.zad_DeviousBelt)) as int) 
  int cuffsChance         = MCM.iWeightSingleCuffs * ((!actorRef.wornHasKeyword(libs.zad_DeviousLegCuffs) && !actorRef.wornHasKeyword(libs.zad_DeviousArmCuffs)) as int)
  int ankleChance         = MCM.iWeightSingleAnkleChains * ((!actorRef.wornHasKeyword(Mods.zazKeywordWornAnkles)) as int)
  
  int total = armbinderChance + glovesbootsChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance
  if total == 0
    PlayerMon.debugmsg("single: total is zero, no more items left to put on?")
    return None
  endif
  int roll  = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("single roll: gloveboot/armbind/collar/gag/harn/belt/cuffs/ankle (" +\
           glovesbootsChance + "/" +\
           armbinderChance + "/" +\
           collarChance + "/" +\
           gagChance + "/" +\
           harnessChance + "/" +\
           beltChance + "/" +\
           cuffsChance + "/" +\
           ankleChance + "/" +\
           ") roll:" + roll)
  armor[] items = new armor[3]     
  if roll <= glovesbootsChance
    ;success = equipRandomDDxRGlovesBoots(actorRef)
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " gave you some lovely boots and gloves before leaving!")
    endif 
    return getRandomDDxRGlovesBoots()
  elseif roll <= glovesbootsChance + armbinderChance
    ;success = equipRandomDDArmbinders(actorRef)
    items[0] = getRandomDDArmbinders()
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a armbinder on you before leaving!")
    endif
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance; Collars
    ;success = equipRandomDDCollars(actorRef)
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a collar on you before leaving!")
    endif
    items[0] = getRandomDDCollars()
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance ; gag
    ;success = equipRandomGag(actorRef)
    items[0] = getRandomGag() 
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " shoves a gag in your mouth before leaving!")
    endif
    return items
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance; harness and plug
    ;success = equipRandomHarnessAndStuff(actorRef)
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a harness on you before leaving!")
    endif
    return getRandomHarnessAndStuff(actorRef)
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance; belt and plug
    PlayerMon.debugmsg("attempting belt ...")
    ;success = equipRandomBeltAndStuff(actorRef, Utility.RandomInt(1, (MCM.iWeightBeltPunishment + MCM.iWeightBeltRegular)) <= MCM.iWeightBeltPunishment)
    ;if Utility.RandomInt(0, (MCM.iWeightBeltPunishment + MCM.iWeightBeltRegular)) <= MCM.iWeightBeltPunishment ;1/4 chance to return get punishment stuff instead
    ;  success = equipRandomBeltAndStuff(true)
    ;else
    ;  success = equipRandomBeltAndStuff()
    ;endif
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks a tight chastity belt on you before leaving!")
    endif ;ankleChance
    return getRandomBeltAndStuff(actorRef, Utility.RandomInt(1, (MCM.iWeightBeltPunishment + MCM.iWeightBeltRegular)) <= MCM.iWeightBeltPunishment)
  elseif roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance; legs and arm cuffs
    ;success = equipRandomDDCuffs(actorRef)
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks arm and leg cuffs to you before leaving!")
    endif
    return getRandomDDCuffs()
  else;if roll <= glovesbootsChance + armbinderChance + collarChance + gagChance + harnessChance + beltChance + cuffsChance + ankleChance; legs and arm cuffs
    ;success = equipRandomAnkleChains(actorRef)
    if success && actorRef != None && actorRef == player
      Debug.Notification(actorRef.GetDisplayName() + " locks ankle chains on you before leaving!")
    endif
    items[0] = getRandomAnkleChains()
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
           ") roll:" + roll)
    
  if roll <= ponyChance
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BlackPonyMixedOutfit) 
  elseif roll <= ponyChance + ballandchainChance 
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BallandChainRedOutfit) 
  elseif roll <= ponyChance + ballandchainChance + transparentChance
    equipDCURTransparentOutfit(actorRef)
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
           ") roll:" + roll)
    
  if roll <= ponyChance
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BlackPonyMixedOutfit) 
  elseif roll <= ponyChance + ballandchainChance 
    removeCurrentCollar(actorRef)
    actorRef.UnEquipItemSlot(32)
    actorRef.SetOutfit(BallandChainRedOutfit) 
  elseif roll <= ponyChance + ballandchainChance + transparentChance
    equipDCURTransparentOutfit(actorRef)
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
  bool isPlayer = actorRef == PlayerMon.player
  int weightPetCollar             = MCM.iWeightPetcollar * ( Mods.modLoadedPetCollar ) as int
  int weightDCURCursedCollar      = MCM.iWeightCursedCollar * ( Mods.modLoadedCursedLoot && (actorRef == PlayerMon.player) && isPlayer) as int
  int weightDCURSlave             = MCM.iWeightSlaveCollar * ( Mods.modLoadedCursedLoot && isPlayer) as int
  int weightDCURSlut              = MCM.iWeightSlutCollar * (Mods.modLoadedCursedLoot&& isPlayer ) as int
  int weightDCURRubberDollCollar  = MCM.iWeightRubberDollCollar * (  Mods.modLoadedCursedLoot && (actorRef == PlayerMon.player) && isPlayer) as int
  int weightFBanned               = MCM.iWeightdeviousPunishEquipmentBannnedCollar * (  Mods.deviousPunishEquipmentBannnedCollar != None ) as int
  int weightFProstituted          = MCM.iWeightdeviousPunishEquipmentProstitutedCollar * (  Mods.deviousPunishEquipmentProstitutedCollar != None ) as int
  int weightFNaked                = MCM.iWeightdeviousPunishEquipmentNakedCollar * (  Mods.deviousPunishEquipmentNakedCollar != None ) as int
  int weightStripTease            = mcm.iWeightStripCollar * (Mods.modLoadedCursedLoot ) as int
  
  ;int suits       = MCM.iWeightMultiDD * 
  int weightTotal = weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut \
                  + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked + weightStripTease
  if weightTotal == 0
    PlayerMon.debugmsg("equipPlayerMon.randomDD: weight is zero, equipping nothing", 4)
  endif	
  int   roll    = Utility.RandomInt(1, weightTotal)
  bool  removed = false
  ;PlayerMon.debugmsg("equipPlayerMon.randomDD: rolled " + roll, 2)
  PlayerMon.debugmsg("pet/cursed/slave/slut/rubber/banned/prostituted/naked/stripTease(" \
                     + weightPetCollar + "/" + weightDCURSlave + "/" + weightDCURSlut + "/" + weightPetCollar + "/"\
                     + weightDCURRubberDollCollar + "/" + weightFBanned + "/" + weightFProstituted + "/" \
                     + weightFNaked + "/" + weightStripTease \
                     +")roll/total:(" + roll + "/" + weightTotal + ")", 2)

  armor collar
  if (roll == 0)
    PlayerMon.debugmsg("equipPlayerMon.randomDD: nothing to equip?")
    return collar
  endif
  removed = removeCurrentCollar(actorRef)
  if roll <= weightPetCollar 
    if actorRef != None && actorRef != PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " puts a collar on the bitch.")
    else
      Debug.Notification("The bitch has earned a collar")
    endif
    ;ods.equipPetCollar(actorRef)
    return Mods.petCollar
  elseif roll <=  weightPetCollar + weightDCURCursedCollar 
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " puts a strange collar on you! What's this strange letter...?")
    else
      Debug.Notification("Suddenly you notice a strange collar around your neck. What's this letter...?")
    endif
    ;Mods.equipCursedCollar()
    return Mods.dcurCursedCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave 
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " puts a slave collar on you!")
    else
      Debug.Notification("The slave has been marked")
    endif
    return Mods.dcurSlaveCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " locks a collar on the slut.")
    else
      Debug.Notification("The slut has earned a collar")
    endif
    return Mods.dcurSlutCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " locks a rubbery collar around your neck!")
    else
      Debug.Notification("The rubbery collar locks around your neck")
    endif
    return Mods.dcurRubberCollar
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned 
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " locks a Banned collar around your neck!")
    else
      Debug.Notification("The slut has earned a collar")
    endif
    return Mods.deviousPunishEquipmentBannnedCollar 
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted 
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " locks a Banned collar around your neck!")
    else
      Debug.Notification("The slut has earned a collar")
    endif
    return Mods.deviousPunishEquipmentProstitutedCollar 
  elseif roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked   
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " locks a Banned collar around your neck!")
    else
      Debug.Notification("The slut has earned a new collar")
    endif
    return Mods.deviousPunishEquipmentNakedCollar 
  else;if roll <= weightPetCollar + weightDCURCursedCollar + weightDCURSlave + weightDCURSlut + weightDCURRubberDollCollar + weightFBanned + weightFProstituted + weightFNaked +weightStripTease
    if actorRef != None && actorRef == PlayerMon.player
      Debug.Notification(actorRef.GetDisplayName() + " locks a StripTease collar around your neck!")
    else
      Debug.Notification("The slut has earned a new collar")
    endif
    return Mods.dcurStripTeaseCollar 
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
  armor[] items = getRandomStuff(actorRef, belt, punishment, force)
  while i < items.length && items[i] != None
    equipRegularDDItem(actorRef, items[i], None)
    i += 1
  endWhile
endFunction

armor[] function getRandomStuff(actor actorRef, Armor belt, bool punishment = false, bool force = false)
  bool has_plug     = actorRef.WornHasKeyword(libs.zad_DeviousPlug) ;TODO extend to other plugs
  bool has_piercing = actorRef.WornHasKeyword(libs.zad_DeviousPiercingsVaginal)
  armor[] stuff = new armor[4]
  int stuff_index = 0
  ;PlayerMon.debugmsg("adding candy ... ")
  if !has_plug && (has_piercing || Utility.Randomint(1, 100) < MCM.iWeightPlugs || force)
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
    PlayerMon.debugmsg("soul/inflate/charging/shock/training/cdeff(" + newSoulGem + "/" + newInflate + "/" + newCharging + "/" + newShock + "/"\
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
  
  if !has_piercing && actorRef.HasPerk(libs.PiercedClit) && Utility.Randomint(1, 100) > MCM.iWeightPiercings
      ;player.additem(PlayerMon.randomDDVagPiercings[(Utility.Randomint(1, PlayerMon.randomDDVagPiercings.length) - 1)])
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

armor[] function getRandomHarnessAndStuff(actor actorRef)
  PlayerMon.debugmsg("checking if harness are worn already ...", 1)
  armor[] items = new armor[5]
  if actorRef.wornHasKeyword(libs.zad_DeviousHarness) == false 
    int offsetIndex = Utility.Randomint(0,2);0 ; 0 are ebonite, 1 are red, 2 are white
    ;offsetIndex     =
    Armor harness = randomDDxHarnesss[offsetIndex]
    ;PlayerMon.debugmsg("harness:" + harness)
    armor[] stuff = getRandomStuff(actorRef, harness)
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

armor[] function getRandomBeltAndStuff(actor actorRef, bool punishment = false, bool force_stuff = false)
  PlayerMon.debugmsg("checking if belt and stuff are already worn ...", 1)
  ; check what color the other items are, modify index
  
  int newPadded   = MCM.iWeightBeltPadded  / ((1 * (punishment as int)) + 1)
  int newIron     = MCM.iWeightBeltIron    / ((1 * (punishment as int)) + 1)
  int newImperial = MCM.iWeightBeltRegulationsImperial   * (Mods.modLoadedDeviousRegulations as int) / ((1 * (punishment as int)) + 1)
  int newSCloak   = MCM.iWeightBeltRegulationsStormCloak * (Mods.modLoadedDeviousRegulations as int) / ((1 * (punishment as int)) + 1)
  int newShame    = MCM.iWeightBeltShame                 * (punishment && Mods.modLoadedCursedLoot) as int
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
  armor[] items = getRandomStuff(actorRef, belt, punishment, force_stuff) ; now that we know which belt we're getting...
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



bool function equipArousingPlugAndBelt(actor actorRef, actor masterRef = None)
  if actorRef.wornhaskeyword(libs.zad_DeviousPlug) ; if wearing a plug already
    removeDDbyKWD(actorRef, libs.zad_DeviousPlug)
    if actorRef.wornhaskeyword(libs.zad_DeviousPlug) ; if wearing two
      removeDDbyKWD(actorRef, libs.zad_DeviousPlug)
    endif
  endif

  ; TODO set player's master as the follower who equipped this
  if actorRef == PlayerMon.player && masterRef != None
    PlayerMon.masterRefAlias.forceRefTo(masterRef)
  endif

  int i = 0
  actorRef.UnequipItemSlot(32) ; take off the body, we need to apply the harness

  armor[] items = getArousingPlugAndBelt(actorRef)
  while i < items.length && items[i] != None
    equipRegularDDItem(actorRef, items[i], None)
    i += 1
  endWhile
  return i > 0
endFunction


armor[] function getArousingPlugAndBelt(actor actorRef)
  armor[] items = new armor[3]
  items[0] = Mods.crdeTrainingPlug
  bool cdloaded = Mods.modLoadedCD
  if cdloaded
    items[1] = Mods.cdTeaserPlug
  endif
  
  items[1 + (cdloaded as int)] = libs.beltPadded
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
  int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDGags.length - 1);0 ; 01 are ebonite, 23 are red, 45 are white
  armor gag = PlayerMon.randomDDGags[offsetIndex]
  return gag
endFunction

;PlayerMon.randomDDCollars
bool function equipRandomDDCollars(actor actorRef)
  PlayerMon.debugmsg("checking if collar is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousCollar) == false 
    armor collar = getRandomDDCollars()
    if collar
      return equipRegularDDItem(actorRef, collar, None)
    endif
  endif

  return false
endFunction

armor function getRandomDDCollars()
  armor collar
  ; check what color the other items are, modify index
  int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDCollars.length - 1)
  collar = PlayerMon.randomDDCollars[offsetIndex]
  return collar 
endFunction

;PlayerMon.randomDDArmbinders
bool function equipRandomDDArmbinders(actor actorRef)
  PlayerMon.debugmsg("checking if armbinder is already worn ...", 1)
  if actorRef.wornHasKeyword(libs.zad_DeviousArmbinder) == false && actorRef.wornHasKeyword(libs.zad_DeviousYoke) == false 
    armor armbinder = getRandomDDArmbinders()
    if armbinder
      return equipRegularDDItem(actorRef, armbinder, None)
        else
      PlayerMon.debugmsg("Err: Random armbinder returned nothing")

    endif
  endif
  return false
endFunction

armor function getRandomDDArmbinders()
  armor armbinder = None
  ; check what color the other items are, modify index
  int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDArmbinders.length - 1);0 ; 0 are ebonite, 1 are red, 2 are white
  armbinder = PlayerMon.randomDDArmbinders[offsetIndex]
  return armbinder
endFunction

bool function equipRandomDDBlindfolds(actor actorRef)
  PlayerMon.debugmsg("checking if blindfold is already worn ...", 1)
  keyword blindfold_kw = libs.zad_DeviousBlindFold
  if actorRef.wornHasKeyword(blindfold_kw) == false && actorRef.wornHasKeyword(libs.zad_DeviousHood) == false 
    armor blindfold = getRandomDDBlindfolds()
    if blindfold
      return equipRegularDDItem(actorRef, blindfold, None)
    endif
  endif
  return false
endFunction

armor function getRandomDDBlindfolds()
  ;keyword blindfold = libs.zad_DeviousBlindFold
  ;armor  b = libs.blindfold
  
  return libs.blindfold ;b
endFunction

; not finished
; should replace all of the redundant code from up above
; where item_random_width is the range of items after the theme_offset
; keyword check happens above
; theme width is the distance in the array between theme changes, so if there are 2 items before a theme shift, the width is 2
;bool function equipRandomSingleDDFromArray(actor actorRef, Armor[] item_array, Keyword type_kw, Keyword type_kw2 = None, int theme_width , int type_width = 1)
;  armor[] items = getRandomDDCuffs()
;  int i = 0
;  while i < items.length && items[i] != None
;    equipRegularDDItem(actorRef, items[i], None)
;    i += 1
;  endWhile
;
;
;armor[] equipRandomSingleDDFromArray(actor actorRef, Armor[] item_array, Keyword type_kw, Keyword type_kw2 = None, int theme_width , int type_width = 1)
;  if(actorRef.wornHasKeyword(type_kw) == false && !(type_kw2 != None && actorRef.wornHasKeyword(type_kw) == true))
;    
;    int offsetIndex
;    offsetIndex = Utility.RandomInt(0,2) * theme_width
;    ;int offsetIndex = Utility.Randomint(0,PlayerMon.randomDDGags.length - 1);0 ; 01 are ebonite, 23 are red, 45 are white
;    offsetIndex = offsetIndex + Utility.Randomint(0, theme_width - 1)
;    armor rndrd = libs.GetRenderedDevice(item_array[offsetIndex])
;    libs.equipDevice(actorRef, item_array[offsetIndex], rndrd, type_kw)
;    return true
;  endif
;  return 
;endFunction

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
  SendModEvent("dcur_triggerRubberSuit")
endFunction

function equipDCURTransparentOutfit(actor actorRef)
  ; assuming cursed loot checking happens before we get this far
  PlayerMon.debugmsg("trying out transparent suit",3)
  if Mods.modLoadedCursedLoot
    ; if player is PlayerMon.wearing items on top of the suit, take them off, keep them, put them back on?
    SendModEvent("dcur-triggerExhibitionistSuit")

  else
    PlayerMon.debugmsg("Err: equipDCURTransparentOutfit called but cursed loot isn't installed")
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
  ;zzz randomDDNipplePiercings
  return randomDDNipplePiercings[Utility.RandomInt(randomDDNipplePiercings.length)]
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

int function checkItemAddingAvailability(actor actorRef, keyword keywordRef)
  if keywordRef == None
    PlayerMon.debugmsg("Err: keyword provided is none",1)
    return 0
  endif
  bool playerAlreadyWearing  = PlayerMon.player.WornHasKeyword(keywordRef)
  bool actorAlreadyWearing   = actorRef.WornHasKeyword(keywordRef)
  if playerAlreadyWearing && actorAlreadyWearing
    ;PlayerMon.followerItemsWhichOneFree = 3
    return 0
  elseif playerAlreadyWearing
    return 1
  elseif actorAlreadyWearing
    return 2
  else
    return 3
  endif
endFunction

; In order for our dialogue to be specific, and in order for our weights and percentages to work
;  we have to roll this stuff before dialogue starts, and hope users don't hack the parts they want
; contains a number for different combos
;   0 is random single item, 1 is random collar
;   2 is plug and extra, 3 is belt and extra
;   4 is gloves and boots, 5 is other boots, 6 cuffs
;   7 is blindfold, 8 is armbinder,  
;   10 is random ringgag, 11 is random ball gag, 12 is random panel gag, 13 is random any gag
;   14 is rubber suit, 15 is red suit, 16 is pony suit, 17 is harness
;   21 nipple piercings, 22 vag/cock piercing, 23 random, 24 both
;   30 is random unique collar
;   31 is pet collar
;   40 is random CDx items
; this list is up above as well
; that one needs to sync
function rollFollowerFoundItems(actor actorRef)
  
  ; check what color the other items are, modify index
  ; we should probably check the NPC to see if they can wear it too
  ;int random          = 1 ;MCM.iWeightBeltPadded  * (player.WornHasKeyword(libs.zad_Devious) as int)
  int collar          = MCM.iWeightSingleCollar       * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar)     > 0) as int)  
  int randomPlug      = MCM.iWeightPlugs              * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousBelt)       > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousBelt)) as int)
  int belt            = MCM.iWeightSingleBelt         * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousBelt)       > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousBelt)) as int)
  int glovesandboots  = MCM.iWeightSingleGlovesBoots  * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousBoots)      > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousBoots)) as int)
  int cuffs           = MCM.iWeightSingleCuffs        * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousArmCuffs)   > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousArmCuffs)) as int)
  int randomGag       = MCM.iWeightSingleGag          * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousGag)        > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousGag)) as int)
  int harness         = MCM.iWeightSingleHarness      * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousHarness)    > 0) as int) ; (( ! player.WornHasKeyword(libs.zad_DeviousHarness)) as int)
  int armbinder       = MCM.iWeightSingleArmbinder    * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousArmbinder)  > 0) as int)
  int randomCD        = MCM.iWeightRandomCD           * ( Mods.modLoadedCD ) as int
  int nipplePiercings = MCM.iWeightPiercings          * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousPiercingsNipple)  > 0) as int)
  int petCollar       = MCM.iWeightPetcollar          * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar)     > 0) as int)  
  int uniqueCollar    = MCM.iWeightPetcollar          * ((checkItemAddingAvailability(actorRef, libs.zad_DeviousCollar)     > 0) as int)  
  
  ;int rubberSuit      = MCM.iWeightSingleBelt   * (( ! player.WornHasKeyword(libs.zad_DeviousSuit)) as int) ; wrong, do this later
  
  int total       = collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD
  
  int roll = Utility.RandomInt(1,total)
  PlayerMon.debugmsg("collar/randomPlug/belt/glovesandboots/cuffs/randomGag/harness/armbinder/randomCD/petcollar/uniqueCollar(" + collar + "/" + randomPlug + "/" + belt + "/"\
                                    + glovesandboots + "/" + cuffs + "/"  + randomGag + "/"  + harness + "/"  + armbinder + "/"  + randomCD +  "/" + petCollar + "/" + uniqueCollar +")roll/total:(" + roll + "/" + total + ")", 2)
  ;if roll < random
  ;  PlayerMon.followerItemsCombination = 0
    
  keyword armorKeyword
  if roll < collar 
    PlayerMon.followerItemsCombination = 1
    armorKeyword = libs.zad_DeviousCollar
  elseif roll < collar + randomPlug 
    PlayerMon.followerItemsCombination = 2
    armorKeyword = libs.zad_DeviousBelt
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
    PlayerMon.followerItemsCombination = 17
    armorKeyword = libs.zad_DeviousHarness
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder 
    PlayerMon.followerItemsCombination = 8
    armorKeyword = libs.zad_DeviousArmbinder
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD 
    PlayerMon.followerItemsCombination = 40
    armorKeyword = libs.zad_DeviousBelt
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings
    PlayerMon.followerItemsCombination = 21
    armorKeyword = libs.zad_DeviousPiercingsNipple
  elseif roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings + petCollar
    PlayerMon.followerItemsCombination = 31
    armorKeyword = libs.zad_DeviousCollar
  else;if roll < collar + randomPlug + belt + glovesandboots + cuffs + randomGag + harness + armbinder + randomCD + nipplePiercings + petCollar + uniqueCollar
    PlayerMon.followerItemsCombination = 30
    armorKeyword = libs.zad_DeviousCollar
  endif     
  
  if armorKeyword
    PlayerMon.followerItemsWhichOneFree = checkItemAddingAvailability(actorRef, armorKeyword)
    PlayerMon.debugmsg("for keyword: " + armorKeyword + " availability is " + PlayerMon.followerItemsWhichOneFree)
  else
    PlayerMon.followerItemsWhichOneFree = -1
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

  int i = 0
  string name = None
  armor tmp = none
  while i < items.length
    name = None
    tmp = items[i]
    if tmp !=None
      name = tmp.GetName()
    endif
  
    if tmp != None
      PlayerMon.debugmsg(" equipping " + tmp + " on actor "+ actorRef, 2)
      equipRegularDDItem(actorRef, tmp, None)
      Utility.Wait(0.25)
    endif
    i += 1
  endWhile
  
endFunction

armor[] Function getFollowerFoundItems(actor actorRef)
  armor[] items = new armor[8]
  int ic = PlayerMon.followerItemsCombination ; shorter, also avoiding the compiler asking PlayerMon for the property over and over again
  if ic     == 0
    items = getRandomSingleDD(actorRef)
  elseif ic == 1 
    ; todo: allow for rregular collars too
    items[0] = getRandomUniqueCollar(actorRef)
  elseif ic == 2 
    items = getRandomBeltAndStuff(actorRef, force_stuff = true)
  elseif ic == 3 
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
  elseif ic == 40 
    items = getRandomCDItems(actorRef)
  elseif ic == 21 
    items[0] = getRandomNipplePiercings(actorRef)
  elseif ic == 24 
    ;items[0] = getRandomAssortedPiercings(actorRef)
  elseif ic == 31
    items[0] = Mods.petCollar
  elseif ic == 30 
    items[0] = getRandomUniqueCollar(actorRef)

  else
    PlayerMon.debugmsg("ERR: Unexected value for followerItemsCombination")
  endif     
  
  return items

endFunction

; gives items to actor
function giveFollowerFoundItems(actor actorRef)

  if actorRef == None
    actorRef = PlayerMon.player
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
