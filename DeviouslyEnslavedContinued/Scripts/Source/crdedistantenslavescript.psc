Scriptname crdeDistantEnslaveScript extends Quest conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Attacker
;
; Manages all long range enslavement behaviour.
; This is done in one script for easier access to features specific to long range enslavement:
; Equip light weight bindings/gag/hood/blindfold, Fade to black, Stagger, or Hogtie.
;
; Mods that will eventually be used long distance:
;  Captured Dreams
;  SD (many possible options(not really))
;  Could always make a second entry into slaverun here, sent through the mail as it were
;  Direct mail to maria's house?
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

;crdeDebugScript Property DOut Auto
crdeMCMScript Property MCM Auto
crdeModsMonitorScript Property Mods Auto
crdePlayerMonitorScript Property PlayerMon Auto
crdeMariaEdenScript Property MariaEdenScript Auto
crdeWolfclubScript Property WolfclubScript Auto
crdeSlaverunScript Property SlaverunScript Auto
crdeItemManipulateScript  Property ItemScript Auto

ReferenceAlias Property masterAlias Auto; in this case, I'm using it to load LEON because I can't just move his actor for some reason


; sd enslave master's to attempt
Actor Property  SDPreviousMaster Auto ; should start as player, then change from NPC to NPC
Actor Property  SDNextMaster Auto     ; if none, search, if player then we have exhausted possible options

Actor Property player auto
Actor[] Property SDMasters auto
Actor[] Property MariaMasters auto

Actor Property Drelas auto
Actor Property LakeVampire auto
;bool Property canRunWC auto conditional
;bool Property canRunCD auto conditional

bool Property canRunSold auto conditional
bool Property canRunGiven auto conditional

bool Property hasRunBeforeCD auto conditional
bool Property hasRunBeforeSS auto conditional

Event OnInit()
  ; kinda need this, since MCM variables are needed for canRun*()
  Utility.Wait(15)
  if Mods == None
    Debug.Trace("[CRDE] distant:Mods is NONE!!! What the fuck")
    Utility.Wait(2)
    Mods = Quest.GetQuest("crdeModsMonitor") as crdeModsMonitorScript
    if Mods == None
      Debug.Trace("[CRDE] distant:Mods is still NONE!!! what in tarnation")
    endif
    
  endif
  if Mods == None
    Debug.Trace("[CRDE] distant:Mods is NONE!!! What the fuck")
  endif
  while Mods.finishedCheckingMods == false
    Debug.Trace("[CRDE] distant:mods not finished yet")
    Utility.Wait(1)
	endwhile
  RegisterForSingleUpdate(1)
EndEvent

Event OnUpdate()
  player = Game.GetPlayer()
  if SDPreviousMaster == None
    SDPreviousMaster = player
  endif
EndEvent

; enslave without specific framework mod or situation given, random based on weights
; this uses almost identical logic to Playermonitor::rolldialogue, if you change something here keep that in mind
bool function enslavePlayer(actor attacker = None)
  int newLocalWeight    = Mods.canRunLocal() as int * MCM.iEnslaveWeightLocal 
  int newGivenWeight    = canRunGiven() as int * MCM.iEnslaveWeightGiven 
  int newSoldWeight     = canRunSold() as int * MCM.iEnslaveWeightSold 
  ;int newTrainingWeight = (DistanceEnslave.canRunTraining() * 50)
  int weightTotal       = newLocalWeight + newGivenWeight + newSoldWeight 
  if weightTotal == 0 
    debugmsg("enslvePlayer ERR: weightTotal is 0, no mods?")
    return false
  endif
  int roll = Utility.RandomInt(1, weightTotal )
  debugmsg("enslavePlayer loc/give/sold(" + newLocalWeight + "/" + newGivenWeight + "/" + newSoldWeight + ")roll/total:(" + roll + "/" + weightTotal + ")", 2)
  if roll <= newLocalWeight
    ; just slaverun, because slaverun has limitations
    if SlaverunScript.canRun() && roll < ((MCM.iEnslaveWeightSlaverun / (MCM.iEnslaveWeightSlaverun + MCM.iEnslaveWeightMaria + MCM.iEnslaveWeightSD) ) * MCM.iEnslaveWeightLocal)
      Debug.Messagebox("You are now property of Zaid, slaver in whiterun.")
      SlaverunScript.enslave()
    else
      PlayerMon.attemptEnslavement(attacker) ; comes with it's own enslavement already
    endif
  elseif roll <= (newLocalWeight + newGivenWeight) ; given
    if attacker == None
      Debug.Messagebox("Seeing you so helpless, your attacker decided to enslave you and send you to be their friend's slave.")
    else 
      Debug.Messagebox("Seeing you so helpless, " + attacker.GetDisplayName() + " decided to enslave you and send you to be their friend's slave.")
    endif
    enslaveGiven()
  else  ; Sold ; roll <= (MCM.iEnslaveWeightLocal + MCM.iEnslaveWeightGiven + )
    if attacker == None
      Debug.Messagebox("Seeing you so helpless, your attacker decided to try to sell you on the market as a slave.")
    else 
      Debug.Messagebox("Seeing you so helpless, " + attacker.GetDisplayName() + " decided to try to sell you on the market as a slave.")
    endif
    enslaveSold()
  endif
  
  return true
endFunction

function enslaveSold(actor actorRef = none)
  Mods.dhlpResume()
  PlayerMon.clear_force_variables()
  ; if we take the boolean toggle, and conver it to int, we can use it to convert the roll to roll OR zero
  ; boolean isn't as pretty but since it's just simple math it should run faster than control structures.
  int SS          = MCM.iDistanceWeightSS             * (Mods.modLoadedSimpleSlavery && MCM.bSSAuctionEnslaveToggle ) as int
  int Maria       = MCM.iDistanceWeightMariaK         * (Mods.modLoadedMariaEden && MCM.bMariaKhajitEnslaveToggle ) as int
  int CD          = MCM.iDistanceWeightCD             * (Mods.modLoadedCD && MCM.bCDEnslaveToggle ) as int
  int SLUTS       = MCM.iDistanceWeightSLUTSEnslave   * (Mods.modLoadedSLUTS ) as int
  int SRR         = MCM.iDistanceWeightSlaverunRSold  * (Mods.modLoadedSlaverunR ) as int
  int DCBandits   = MCM.iDistanceWeightDCBandits      * (Mods.modLoadedDeviousCidhna ) as int

  int total = SS + Maria + CD + SLUTS + SRR + DCBandits
  if total == 0 ; stop gap, you shouldn't get this far
    debugmsg("enslaveSold: max roll is zero, no enslave mods?", 4)
    return
  endif
  int roll = Utility.RandomInt(1, total ) ; keep it off zero, since that's a non-case DCVampires
  debugmsg("Sold:khajit/cd/SS/Sluts/SRR("  + Maria + "/" + CD + "/" + SS + "/" + SRR + "/" + DCBandits +")roll/total:(" + roll + "/" + total + ")", 2)
  if roll <= Maria
    if Mods.modLoadedMariaEden == false
      debugmsg("Err: reached Maria Eden enslave, but mod is not loaded", 4)
    else
      ; enslave khajit
      defeatKhajit(actorRef)
    endif
  elseif roll <= (Maria + CD)
    if Mods.modLoadedCD == false
      debugmsg("Err: reached CD enslave, but mod is not loaded", 4)
    else
      ; enslave cd
      enslaveCD()
    endif
  elseif roll <= Maria + CD + SS
    ; enslave simple slavery auction
    enslaveSS()
  elseif roll <= Maria + CD + SS + SLUTS
    enslaveSLUTS()
  elseif roll <= Maria + CD + SS + SLUTS +  SRR 
    enslaveSlaverunRSold()
  else ; roll <= Maria + CD + SS + SLUTS +  SRR + DCBandits
    enslaveDCBandits()
  endif
endFunction

function enslaveGiven(actor actorRef = none)
  Mods.dhlpResume()
  PlayerMon.clear_force_variables()
  int Maria       = MCM.iDistanceWeightMaria          * (Mods.modLoadedMariaEden && MCM.bMariaDistanceToggle ) as int
  int WC          = MCM.iDistanceWeightWC             * (Mods.modLoadedWolfClub && MCM.bWCDistanceToggle) as int
  int SD          = MCM.iDistanceWeightSD             * (Mods.modLoadedSD && MCM.bSDDistanceToggle) as int
  int DC          = MCM.iDistanceWeightDCPirate       * (Mods.modLoadedDeviousCidhna && MCM.bDCPirateEnslaveToggle ) as int
  int DCLDamsel   = MCM.iDistanceWeightDCLDamsel      * (Mods.modLoadedCursedLoot ) as int
  int IOM         = MCM.iDistanceWeightIOMEnslave     * (Mods.modLoadedIsleofMara ) as int
  int DCLBADV     = MCM.iDistanceWeightDCLBondageAdv  * (Mods.modLoadedCursedLoot ) as int
  int DCLLeon     = MCM.iDistanceWeightDCLLeon        * (Mods.modLoadedCursedLoot ) as int
  int DCVampires  = MCM.iDistanceWeightDCVampire      * (Mods.modLoadedDeviousCidhna ) as int
  
  int total = Maria + WC + SD + DC + DCLDamsel + IOM + DCLBADV + DCLLeon + DCVampires
  if total == 0 ; stop gap, you shouldn't get this far
    debugmsg("enslaveGiven: max roll is zero, no enslave mods?", 4)
    return
  endif
  int roll = Utility.RandomInt(1, total) ; going to assume weights are zero if not enabled, yeah? DCVampires
  debugmsg("Given:maria/wc/sd/dc/damsel/IOM/Badv/leon(" + Maria + "/" + WC + "/" + SD + "/" + DC + "/" + DCLDamsel + "/" + IOM + "/" + DCLBADV + "/" + DCLLeon + "/" + DCVampires + ")roll/total:(" + roll + "/" + (total) + ")", 2)
  if roll <= Maria
    if Mods.modLoadedMariaEden == false
      debugmsg("Err: reached MariasEden enslave, but mod is not loaded", 4)
    else
      ; enslave khajit
      enslaveMaria(actorRef)
    endif
  elseif roll <= Maria + WC
    if Mods.modLoadedWolfClub == false
      debugmsg("Err: reached Wolfclub enslave, but mod is not loaded", 4)
    else
      ; enslave cd
      enslaveWC()
    endif
  elseif roll <= Maria + WC + DC
    if Mods.modLoadedDeviousCidhna == false
      debugmsg("Err: reached Devious Cidhna Pirate enslave, but mod is not loaded", 4)
    else
      ; enslave cd
      enslaveDCPirate()
    endif
  elseif roll <= Maria + WC + DC + SD 
    if Mods.modLoadedSD == false
      debugmsg("Err: reached SD enslave, but mod is not loaded", 4)
    else
      distantSD() ; enslave SD to distance master
    endif 
  elseif roll <= Maria + WC + DC + SD + DCLDamsel
    if Mods.modLoadedCursedLoot == false
      debugmsg("Err: reached DCL enslave, but mod is not loaded", 4)
    else
      enslaveDCLDamsel() ; "enslave" the player by putting them in the woods to learn not to talk back to people
    endif
  elseif roll <= Maria + WC + DC + SD + DCLDamsel + IOM
    if Mods.modLoadedIsleofMara == false
      debugmsg("Err: reached IOM enslave, but mod is not loaded", 4)
    else
      enslaveIsleOfMara() 
    endif
  elseif roll <= Maria + WC + DC + SD + DCLDamsel + IOM + DCLBADV
    if Mods.modLoadedCursedLoot == false
      debugmsg("Err: reached DCLBADV enslave, but mod is not loaded", 4)
    else
      enslaveDCURBondageAdv() 
    endif
  elseif roll <= Maria + WC + DC + SD + DCLDamsel + IOM + DCLBADV + DCLLeon 
    if Mods.modLoadedCursedLoot == false
      debugmsg("Err: reached DCLLeon enslave, but mod is not loaded", 4)
    else
      enslaveLeon() 
    endif
  else ; roll <= Maria + WC + DC + SD + DCLDamsel + IOM + DCLBADV + DCLLeon + DCVampires
    if Mods.modLoadedDeviousCidhna == false
      debugmsg("Err: reached cidna vampires enslave, but mod is not loaded", 4)
    else
      enslaveDCVampires() 
    endif
  endif   
endFunction

function enslaveWC(actor actorRef = none)
  ; looks like we don't need the quest anymore we can just call the event, assuming it works? it works
  Utility.wait(2)
  debugmsg(" Starting Wolfclub ... " , 1)
  SendModEvent("crdeStartWolflcubQuest") ;doesn't work yet
  ;Quest wolfclub = (Quest.getQuest("crdeModsMonitor") as crdeModsMonitorScript).wolfclubQuest
  ;(wolfclub as pchsWolfclubDAYMOYL).QuestStart(none, none, none)
	;(Mods.wolfclubQuest as pchsWolfclubDAYMOYL).QuestStart(none, none, none)
  ;WolfclubScript.enslave()
 ; SendModEvent("WolfClubEnslavePlayer") ; Does not work
endFunction

; actual code setup for enslavement with possibly hostile enemy, includes trim/polish
function enslaveSD(actor masterRef = none) ; Sanguine's Debaunchery+
  
  debugmsg(" Starting SD distance" , 1)
  StorageUtil.SetFormValue( Game.getPlayer() , "_SD_TempAggressor", masterRef)
  StorageUtil.SetIntValue(masterRef, "_SD_iPersonalityProfile", 2) ; for now lock it to perverted type
  ; put character moving details here, including screen fade, items, position, dialogue
  
  ;Debug.SendAnimationEvent(player, "ZazAPC057")
  ;LightFade.ApplyCrossFade(3)
  ;utility.wait(3.5)
  ;Utility.wait(0.2)
  ;Debug.Notification("You wake up next to your new master")
  ;LightFade.Remove()  
  
  Game.DisablePlayerControls()
  Game.ForceThirdPerson()
  ;libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS01) 
  PlayerMon.playRandomPlayerDDStruggle()
  ;Debug.SendAnimationEvent(player, "bleedOutStart")
  
  BlackFade.ApplyCrossFade(3)
  ;remove items
  ItemScript.removeDDArmbinder(player) ;armbinder and friends
  ; additems
  player.equipitem(Mods.zazHood)
  player.equipitem(Mods.zazBindings)
  utility.wait(3)
  ; stop combat, not sure this works
  player.StopCombatAlarm()
  player.StopCombat()  
  Game.EnablePlayerControls()
  
  ;BlackFade.Remove()
 	Debug.MessageBox("You wake up next to your new master")
  ;(sdEnslavement as _SDQS_enslavement).SendStoryEvent( akLoc = masterRef.GetCurrentLocation(), akRef1 = masterRef, akRef2 = Game.GetPlayer(), aiValue1 = 0, aiValue2 = 0) ; reference
  Mods.sdEnslaveKeyword.SendStoryEvent( masterRef.GetCurrentLocation(),  masterRef,  player,  0, 0)
 	;masterRef.SendModEvent("PCSubEnslave") ; broken, if the actor was in combat first gets stuck in re-enslavement loop
  
  ; MOST of the time, we can set this here right after the above call and player will teleport to the actor, not the other way around
  player.MoveTo(masterRef) 
endFunction

; called by exterior
; for now, variation does nothing
function distantSD( actor masterRef = None) ;Int variation,
  ; not sure if I want the mod to remember who was previously the master
  ; if I keep just the last ONE, with a sufficiently large list of possible masters it should reduce the chances
  ; of getting the same master to 0 except for constant enslavement
  ;selectNextSDMaster(); for temporary use
  if SDNextMaster == Player
    debugmsg(" ERR: Next master is player, shouldn't get this far", 4)
  endIf
  if masterRef == none && SDNextMaster == None ; shouldn't happen either, but might as well put it here
    Actor result = selectNextSDMaster()
    if result == player || result == None
      debugmsg(" ERR: made it to distantSD without a valid master alive", 4)
      selectNextSDMaster(); for temporary use
      Utility.wait(5)
    endIf
  elseif masterRef != None ; we were given a specific master, assume it's good and use it
    SDNextMaster = masterRef
  elseif SDNextMaster.isDead();
    debugmsg(" ERR: NextSDMaster (" + SDNextMaster.GetDisplayName() +") DIED before we could reach them, researching ...", 4)
    selectNextSDMaster(); for temporary use
    Utility.wait(5)
  endIf
  debugmsg("master being used is: " + SDNextMaster.GetDisplayName(), 1)
  enslaveSD(SDNextMaster) ; just for now, testing
endFunction

; separating so I can call it per-game load and when needed
Actor function selectNextSDMaster()
  ; if master is none, we roll a new master from the list of possible
  Actor masterRef
  int count = 0
  int len   = SDMasters.length
  ; would be better if we could sort the array, or create a randomly sorted array of indexs
  ; but then it would be better if we had a real programming language, too.
  int actor_sex    
  int gender_pref   = MCM.iGenderPref
  while count < len ; loop over possible
    masterRef = SDMasters[Utility.RandomInt(0,(len - 1))] ; get random

    if MCM.bUseSexlabGender
      actor_sex     = PlayerMon.SexLab.GetGender(masterRef)
    else
      actor_sex     = masterRef.GetActorBase().getSex()
    endif   

    if masterRef != SDPreviousMaster && !masterRef.isDead() \
    && !((actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)) ;not fail cases
      SDNextMaster = masterRef
      return masterRef
    endIf
    count += 1
  endWhile
  ; if we searched through all possible masters and they are all dead, set Next master as player to show impossible
  ; we COULD also set to SDPreviousMaster, which should be player if none and *last master* if there is ONE available
  ;if masterRef == None 
  debugmsg("Could not find living SD Master, quiting", 4)
  SDNextMaster = player ; none of the NPCS we have are usable, use player as error condition, since player can't enslave player
  return player
endFunction

function   defeatKhajit(actor actorRef = none)
  ; fix: if version 1.2x, replace with scene where the player starts in the cage already, like new game start

  ;MariaEdenScript.defeat(actorRef)
  debugmsg(" Starting Maria defeat (khajit)" , 1)
  MariaEdenScript.defeat2(actorRef) ; actually works, but requires the quest
endFunction

; doesn't need to exist, just call the mariascript function
function   enslaveMaria(actor actorRef = none)
  ; basic scene pre-write
  ; disable player controls
  ; move player to zaz bondage somewhere, slaver is moved to nearby chair/waiting position.
  ; move/spawn maria, or other person, nearby but hidden, so we don't see them spawned
  ; have them walk up to slaver
  ; dialogue between the two
  ; player is handed over
  ; end
  
  debugmsg("[crde]Reached long distance Maria, not yet implemented", 4)
endFunction

; code was kanged from Simple Slavery, so I assume it works
function enslaveCD() ;Captured Dreams
  MCM.bCDEnslaveToggle = false ; turn off, since it makes less sense for the scene to happen more than once
  hasRunBeforeCD = true
  ; stop DE from working for 1 in-game out, should be enough time to stop it from working
  Playermon.timeoutGameTime = Utility.GetCurrentGameTime() + (1 * (1.0/24.0)) ; 24 * 60 minutes in a day
  ; do we need our own fade to black?

  ; utility.wait(3)
  debugmsg(" Starting CD" , 1)
  utility.wait(0.1)
  
  ; lock player, struggle, waiting
  Game.DisablePlayerControls()
  Game.ForceThirdPerson()
  Game.SetPlayerAIDriven(true)
  ;Debug.SendAnimationEvent(player, "ZazAPC054") ;back spread
  ;Debug.SendAnimationEvent(player, "DDZaZAPCArmBZaDS01") ;arms back struggling
  PlayerMon.playRandomPlayerDDStruggle()
  ;Debug.SendAnimationEvent(player, "bleedOutStart")

  ;remove all items except for belt/harness, since removing those sets off a "You're free" message
  ; which makes no sense here
  ItemScript.unequipAllNonImportantSlow()
  
  ;todo: move these to mods to speed up this entrance
    ; nah, we can just make the player struggle instead, so the wait is less annoying
  Quest           CDQuest  = Game.GetFormFromFile( 0x04E321, "Captured Dreams.esp" ) as Quest
  GlobalVariable  CDGlobal = Game.GetFormFromFile( 0x04FED4, "Captured Dreams.esp" ) as GlobalVariable

  CDGlobal.SetValue(14)
  CDQuest.SetStage(50)

  ; utility.wait(2)
  ;utility.wait()
  BlackFade.ApplyCrossFade(3)
  ;Debug.SendAnimationEvent(player, "IdleForceDefaultState") ; shouldn't be needed since CD should take care of it.
  ;Game.DisablePlayerControls()
  ;Game.ForceThirdPerson()
  ;Game.SetPlayerAIDriven(true)
endFunction

; simple slavery auction start
function enslaveSS()
  ; just for now, call the function without changing anything
  ; in the future we might want to rewrite the test so that the text makes more sense
  
  ;if Mods.modLoadedDeathAlternative == false ; deprecated, new DA doesn't require it anymore
  ;  debugmsg("WARNING: Simple slavery enslave without DA, should not work, turn off Simpleslavery toggle in MCM to stop this happening", 5)
  ;endif
  debugmsg(" Starting Simple slavery" , 1)
  ;Debug.SendAnimationEvent(Game.GetPlayer(), "ZazAPC057") ; bad: animation remains even through motion after the transfer
  ;add zaz bindings instead, lock controls?
  Game.DisablePlayerControls()
  Game.ForceThirdPerson()
  BlackFade.ApplyCrossFade(3)
  ; remove items from player
  ItemScript.unequipAllNonDD()
  ; additems
  player.equipitem(Mods.zazHood)
  player.equipitem(Mods.zazBindings)
  player.equipitem(Mods.zazCollar)
  utility.wait(3) 
  Debug.MessageBox("You're dragged off somewhere to be sold")
  BlackFade.Remove()
  Game.EnablePlayerControls()
  ; works in a different way, but not compatible with old SS versions, so for now, since not everyone has updated, use old code
  SendModEvent("SSLV Entry")
  ; works, but jfraser wants me to use modevent instead
  ;ObjectReference testingMark   = Game.GetFormFromFile(0x03025304 , "SimpleSlavery.esp") as ObjectReference  
  ;if testingMark != None
  ;  player.moveto(testingMark)
  ;else
  ;  debugmsg("ERROR: Cannot start simple slavery")
  ;endif
  ;utility.wait(3)
  ;player.unequipitem(Mods.zazHood)
  ;(Quest.getQuest("SSLV_DAInt") as SSLV_DAIntScript).QuestStart(none, none, none) ; deprecated, DA-less version doesn't have this
  ;Debug.Notification("[crde]Reached sold distance SimpleSlavery enslave, not yet implemented")
endFunction

; borrowed from Simple Slavery
function enslaveDCPirate()
  debugmsg(" Starting DC pirate quest" , 1)
  ; remove armor first?
  
  SendModEvent("dvcidhna_startpirates")
	LightFade.ApplyCrossFade(3)
	utility.wait(3)
	LightFade.Remove()
	;utility.wait(5) <- not really necessary?
endFunction 

function enslaveSLUTS()
  ; player should be naked, optional cuffs which will be removed when the player is made livery
  ; unequip major clothes
  Game.DisablePlayerControls()
  Game.ForceThirdPerson()
  ; if no collar, add one
  ; if no cuffs, add some
  ;player.equipitem(Mods.zazHood)
  player.equipitem(Mods.zazBindings)
  player.equipitem(Mods.zazCollar)
  ; tied up animated, fade to black
  LightFade.ApplyCrossFade(3)
  ;Game.EnablePlayerControls()
  SendModEvent("S.L.U.T.S. Enslavement")
endFunction

function enslaveDCLDamsel()
  ; flavor prepare
  Game.DisablePlayerControls()
  Game.ForceThirdPerson()
  ; hogtie?
  BlackFade.ApplyCrossFade(3)
  ; no waiting, this event takes a long time to start on its own
  ;Game.EnablePlayerControls() ;I don't think this is required at all, actually for damsel
  if Mods.modLoadedCursedLoot
    (Mods.dcurDamselQuest as dcur_lbquestScript).StartQuest()
  else
    debugmsg("Error: Cursed loot is not installed")
  endif
endFunction

function enslaveSlaverunRSold()
  Game.DisablePlayerControls()
  Game.ForceThirdPerson() ; good for this, since after teleport player is stuck in first person for the whole start
  BlackFade.ApplyCrossFade(3)
  ; remove items from player
  ;ItemScript.unequipAllNonDD()
  player.equipitem(Mods.zazHood)
  player.equipitem(Mods.zazCollar)
  player.equipitem(Mods.zazBindings)
  BlackFade.ApplyCrossFade(3)
  utility.wait(3)
  SendModEvent("SlaverunReloaded_ForceEnslavement")
endFunction

function enslaveIsleOfMara()
  Game.DisablePlayerControls()
  ;ItemScript.unequipAllNonDD()
  Game.ForceThirdPerson()
  BlackFade.ApplyCrossFade(3)
  utility.wait(3)
  if Mods.modLoadedIsleofMara
    Mods.isleOfMaraEnslaveQuest.SetStage(10)
    MCM.gCRDEEnable.SetValueInt(0) ; for now, just turn it off if we enter the place
  else
    debugmsg("Error: Isle of mara not installed")
  endif
endFunction

; both leon and leah, roll chance is 50/50 for now
function enslaveLeon()
  ; disable player controls
  ; teleport player to location
  ; start quest
  
  ;might need to do an auto save here, since it can crash the whole thing
  
  int roll          = Utility.RandomInt(1, 100)
  
  if MCM.iGenderPrefMaster == 2 || ( MCM.iGenderPrefMaster == 0 && roll < 50 )
    SendModEvent("dcur_triggerLeonSlavery")
  else
    SendModEvent("dcur_triggerLeahSlavery")
  endif
  ;enslaveLeon2() ; leon 2
endFunction

function enslaveLeon2()
  Mods.dcurLeonQuest.Stop()
  ; teleport player to house ;0x7A078A51: front doorish area
  ObjectReference movingMark   = Game.GetFormFromFile(0x7A078A52, "Deviously Cursed Loot.esp") as ObjectReference 
  player.MoveTo(movingMark) 
  ; summon leon
  Utility.wait(3)
  Actor ll
  int roll          = Utility.RandomInt(1, 100)
  if MCM.iGenderPrefMaster == 2 || ( MCM.iGenderPrefMaster == 0 && roll < 50 )
    ll = Game.GetFormFromFile(0x0802FD2A, "Deviously Cursed Loot.esp") as Actor 
  else
    ll = Game.GetFormFromFile(0x0802FD2A, "Deviously Cursed Loot.esp") as Actor 
  endif 
  ll.MoveTo(movingMark)
  
  ;Mods.dcurLeonActor.enable()
  ;start quest?
  Mods.dcurLeonGGQuest.Start()
  Utility.wait(4)
  Debug.MessageBox("You are a slave to leon (deviously cursed loot) (TODO: write better intro)")
  ;do we need to copy/summon leon?
  
  ; oooooor we could make something of our own?
    ; soft mod, use marker in cell, teleport player there, animate, leon walks up to player and stuff
endFunction

function enslaveDCURBondageAdv()
  ; add animation to smooth over the transition
  Game.DisablePlayerControls()
  Game.ForceThirdPerson()
  Game.SetPlayerAIDriven(true)
  ;Debug.SendAnimationEvent(player, "ZazAPC054") ;back spread
  ;Debug.SendAnimationEvent(player, "DDZaZAPCArmBZaDS01") ;arms back struggling
  PlayerMon.playRandomPlayerDDStruggle()  

  ; BE ADVISED: This start takes a long time after you send the mod event, assume 5-10 second gap after you call it before anything happens
  Playermon.timeoutGameTime = Utility.GetCurrentGameTime() + (1 * (1.0/24.0)) ; 24 * 60 minutes in a day
  SendModEvent("dcur-triggerbondageadventure")
endFunction

function enslaveSDDream()
  
endFunction

function enslaveDCBandits()
  Utility.Wait(2)
  SendModEvent( "DvCidhna_StartBandits" )
endFunction

function enslaveDCVampires()
  Utility.Wait(4)
  SendModEvent( "DvCidhna_StartVampires" )
endFunction


; determines if the player can be sold into slavery
;((DistanceEnslave.canRunGiven() && (MCM.bMariaDistanceToggle || MCM.bWCDistanceToggle || MCM.bSDDistanceToggle || MCM.bDCPirateEnslaveToggle) && (MCM.iDistanceWeightMaria + MCM.iDistanceWeightDCPirate + MCM.iDistanceWeightWC + MCM.iDistanceWeightSD + MCM.iDistanceWeightDCLDamsel >= 1)) as int) * MCM.iEnslaveWeightGiven
bool function canRunSold()
  ; ss, maria, cd
  ; new in 11.0: SLUTS, slaverunR
  if Mods.modLoadedSimpleSlavery && MCM.bSSAuctionEnslaveToggle && (MCM.iDistanceWeightSS > 0)
    canRunSold = true
    return true
  
  elseif Mods.modLoadedMariaEden && MCM.bMariaDistanceToggle && (MCM.iDistanceWeightMariaK > 0) 
  ; we only need is loaded, since you are either a slave or not, and checked before we get here
    canRunSold = true
    return true
  elseif canRunCD()
    canRunSold = true
    return true
  elseif Mods.modLoadedDeviousCidhna && MCM.bDCPirateEnslaveToggle && (MCM.iDistanceWeightDCBandits > 0) 
    canRunSold = true
    return true
  elseif Mods.modLoadedSLUTS && (MCM.iDistanceWeightSLUTSEnslave > 0) ; sluts
    canRunSold = true
    return true
  elseif Mods.modLoadedSlaverunR && (MCM.iDistanceWeightSlaverunRSold > 0) ; slaverunR
    canRunSold = true
    return true
  endif
  canRunSold = false
  return false
endFunction

; determines if player can be given away as slave
;((MCM.bSSAuctionEnslaveToggle || MCM.bMariaKhajitEnslaveToggle || MCM.bCDEnslaveToggle) && (MCM.iDistanceWeightSS + MCM.iDistanceWeightMariaK + MCM.iDistanceWeightCD + MCM.iDistanceWeightSlaverunRSold + MCM.iDistanceWeightSLUTSEnslave  >= 1)) as int) * MCM.iEnslaveWeightSold
bool function canRunGiven()
  ; maria, wc, sd, pirates
  ; new in 11.0: DLC and IOM
  if Mods.modLoadedSD && MCM.bSDDistanceToggle && (MCM.iDistanceWeightSD > 0) ; can always be re-enslaved with SD
    if SDNextMaster == None
      selectNextSDMaster()
    endIf
    if SDNextMaster != player 
      canRunGiven = true
      return true
    endif
  ;elseif Mods.modLoadedMariaEden && MCM.bMariaDistanceToggle && (MCM.iDistanceWeightMaria > 0)
  ; we only need is loaded, since you are either a slave or not, and checked before we get here
  ;  canRunGiven = true
  ;  return true
  elseif canRunWC()
    canRunGiven = true
    return true
  elseif Mods.modLoadedDeviousCidhna && (MCM.bDCPirateEnslaveToggle && (MCM.iDistanceWeightDCPirate > 0) \ 
                                      || (MCM.iDistanceWeightDCVampire > 0))
  
    canRunGiven = true
    return true
  elseif Mods.modLoadedCursedLoot && (MCM.iDistanceWeightDCLDamsel > 0); DLC
    canRunGiven = true
    return true
  elseif Mods.modLoadedIsleofMara && (MCM.iDistanceWeightIOMEnslave > 0); IOM
    canRunGiven = true
    return true
  endif
  canRunGiven = false
  return false
endFunction

; we need to handle all of the conditions we can't test for at dialog time here
; we no longer need to test for WC alone at time, we call canRunGiven
bool function canRunWC()
  if Mods.modLoadedWolfClub == false || MCM.bWCDistanceToggle == false || (MCM.iDistanceWeightWC <= 0) || Mods.wolfclubQuest == None
    ;canRunWC = false 
    return false
	endif
	Quest wolfclub = (Quest.getQuest("crdeModsMonitor") as crdeModsMonitorScript).wolfclubQuest
	
	if wolfclub.getStage() > 0 || wolfclub.isRunning() == false
		;canRunWC = false
		return false
	else
		;canRunWC = true
		return true
  endif
endFunction

; need at least three "training" mods, slaverunR, Leon? SD, what else...
bool function canRunTraining()

  return false
endFunction

; we need to handle all of the conditions we can't test for at dialog time here
bool function canRunCD()
  ; check for conditions where CD is being run?
  if Mods.modLoadedCD && MCM.bCDEnslaveToggle && hasRunBeforeCD == false && (MCM.iDistanceWeightCD > 0)
    ;canRunCD = true
    return true
  endif
  ;canRunCD = false
  return false
endFunction

bool function canRunSD()
  return true ; not sure if there's anything here I can or should add
endFunction

; same for simple slavery, is there anything I need to check for?

function debugmsg(string msg, int level = 0)
  msg = "[CRDE] " + msg
    if level == 0                              ; debug. print in console so we can see it as needed
      if MCM.bDebugMode == true 
        if MCM.bDebugConsoleMode
          MiscUtil.PrintConsole(msg)
        else
          Debug.Notification(msg)
        endif
        Debug.Trace(msg)
      endif
    elseif level == 1 && MCM.bDebugStateVis    ; states/stages, shows up in trace IF debug is set
      if MCM.bDebugMode == true 
        if MCM.bDebugConsoleMode
          MiscUtil.PrintConsole(msg)
        else  
          Debug.Notification(msg)
        endif
        Debug.Trace(msg)
      endif
    elseif level == 2 && MCM.bDebugRollVis    ; rolling information
      if MCM.bDebugMode == true 
        if MCM.bDebugConsoleMode
          MiscUtil.PrintConsole(msg)
        else  
          Debug.Notification(msg)
        endif
      endif
      Debug.Trace(msg) 
    elseif level == 3 && MCM.bDebugStatusVis    ; enslave reason
      if MCM.bDebugMode == true 
        if MCM.bDebugConsoleMode
          MiscUtil.PrintConsole(msg)
        else  
          Debug.Notification(msg)
        endif
      endif
      Debug.Trace(msg)
    elseif(level == 4)     ; important: record if debug is off, notify user if on as well
      Debug.Trace(msg)
      MiscUtil.PrintConsole(msg)
      if(MCM.bDebugMode == true)
        Debug.Notification(msg)
      endif
    elseif(level == 5)     ; very important, errors
      Debug.Trace(msg)
      if(MCM.bDebugMode == true)
        MiscUtil.PrintConsole(msg)
        Debug.MessageBox(msg)
      endif
    endif
endFunction

; at the end only because notepad's syntax parser thinks there's an "if" in "Mod if ier"
ImageSpaceModifier property BlackFade auto 
ImageSpaceModifier property BlackFadeSudden auto 
ImageSpaceModifier property LightFade auto

