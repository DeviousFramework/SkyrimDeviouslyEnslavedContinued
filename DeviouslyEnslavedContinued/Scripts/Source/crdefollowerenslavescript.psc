Scriptname crdeFollowerEnslaveScript extends Quest conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Follower Enslave
;
; Manages features related to the follower enslaving the player directly.
; Enslavements where the follower sends the player to a new location are handled as Distance
; Enslavement.
;
; Mods that should be usable
;  Maria eden (when 2.0X beta comes out maybe)
;  Pet Collar
;  Lola
;  Devious Cidhna
;  Sanguine Debauchery+ (maybe if the follower is annoyed?)
;  Maybe one day Deviously Cursed Loot will work?
;     
;  Training:
;   Slaverun Reloaded
;   Prison Overhaul
;   Deviously Cursed Loot?
;   Captured Dreams training?
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

ImageSpaceModifier property BlackFade auto 
ImageSpaceModifier property LightFade auto

;crdeDebugScript Property DOut Auto
crdeMCMScript Property MCM Auto
crdeModsMonitorScript Property Mods Auto
crdePlayerMonitorScript Property PlayerMon Auto
;crdeMariaEdenScript Property MariaEdenScript Auto
;crdeWolfclubScript Property WolfclubScript Auto
;crdeSlaverunScript Property SlaverunScript Auto

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

;bool Property canRunSold auto conditional
;bool Property canRunGiven auto conditional

;bool Property hasRunBeforeCD auto conditional
;bool Property hasRunBeforeSS auto conditional

Event OnInit()
  ; kinda need this, since MCM variables are needed for canRun*()
  while Mods.finishedCheckingMods == false
    Debug.Trace("[CRDE] distant:mods not finished yet")
    Utility.Wait(2)
	endwhile
  RegisterForSingleUpdate(1)
EndEvent

Event OnUpdate()
  player = Game.GetPlayer()
  if SDPreviousMaster == None
    SDPreviousMaster = player
  endif
EndEvent


bool function enslavePlayer(actor attacker = None)
;  int newLocalWeight    = Mods.canRunLocal() as int * MCM.iEnslaveWeightLocal 
;  int newGivenWeight    = canRunGiven() as int * MCM.iEnslaveWeightGiven 
;  int newSoldWeight     = canRunSold() as int * MCM.iEnslaveWeightSold 
;  ;int newTrainingWeight = (DistanceEnslave.canRunTraining() * 50)
;  int weightTotal       = newLocalWeight + newGivenWeight + newSoldWeight 
;  if weightTotal == 0 
;    debugmsg("enslvePlayer ERR: weightTotal is 0, no mods?")
;    return false
;  endif
;  int roll = Utility.RandomInt(1, weightTotal )
;  debugmsg("enslavePlayer loc/give/sold(" + newLocalWeight + "/" + newGivenWeight + "/" + newSoldWeight + ")roll/total:(" + roll + "/" + weightTotal + ")", 2)
;  if roll <= newLocalWeight
;    ; just slaverun, because slaverun has limitations
;    if SlaverunScript.canRun() && roll < ((MCM.iEnslaveWeightSlaverun / (MCM.iEnslaveWeightSlaverun + MCM.iEnslaveWeightMaria + MCM.iEnslaveWeightSD) ) * MCM.iEnslaveWeightLocal)
;      Debug.Messagebox("You are now property of Zaid, slaver in whiterun.")
;      SlaverunScript.enslave()
;    else
;      PlayerMon.attemptEnslavement(attacker) ; comes with it's own enslavement already
;    endif
;  elseif roll <= (newLocalWeight + newGivenWeight) ; given
;    if attacker == None
;      Debug.Messagebox("Seeing you so helpless, your attacker decided to enslave you and send you to be their friend's slave.")
;    else 
;      Debug.Messagebox("Seeing you so helpless, " + attacker.GetDisplayName() + " decided to enslave you and send you to be their friend's slave.")
;    endif
;    enslaveGiven()
;  else  ; Sold ; roll <= (MCM.iEnslaveWeightLocal + MCM.iEnslaveWeightGiven + )
;    if attacker == None
;      Debug.Messagebox("Seeing you so helpless, your attacker decided to try to sell you on the market as a slave.")
;    else 
;      Debug.Messagebox("Seeing you so helpless, " + attacker.GetDisplayName() + " decided to try to sell you on the market as a slave.")
;    endif
;    enslaveSold()
;  endif
;  
;  return true
endFunction

;this probably doesn't need to exist unless we get some additional context
function enslavePetCollar(actor actorRef = none)
  Utility.wait(2)
  debugmsg(" Putting PetCollar on player ... " , 1)

;  PlayerMon.equipPetCollar()

endFunction

; actual code setup for enslavement with possibly hostile enemy, includes trim/polish
function enslaveLola(actor masterRef = none) ; Sanguine's Debaunchery+
  ; need the quest, we need to trigger it without the dialogue, we're creating the dialogue here
endFunction

function distantME( actor masterRef = None) ;Int variation,
endFunction



;********************   Player needs slave training *********************************


function trainingCD() 
  ; do thing
endFunction


Function trainingSD()
  ; do thing
EndFunction

Function trainingLeon()
  ; given to leon for meaningful
EndFunction

Function trainingLola()
  ; lola but your master is a different person, someone good at teaching?
EndFunction

Function trainingPO()
  ; is inte still working on this?
EndFunction

Function trainingSlaverun()
  ; SRR training, no way back really, needs custom entrance
EndFunction

;*********************** Enslaved by follower directly *******************************
; Already defined above (and below).  Why is this function defined three times?
;Function enslaveLola()
;  ; do thing
;EndFunction

;Function enslavePetCollar()
  ; do thing
;EndFunction

Function enslaveSD()
  ; do thing
EndFunction

; Already defined above (twice).  Why is this function defined three times?
;Function enslaveLola() ; one day, maybe leon?
;  ; do thing
;EndFunction

;***********************     "Given" to good master      *******************************

Function givenSD()
  ; Given to asshole, because your follower has some shady friends
EndFunction

Function givenLeon()
  ; given to leon because he's a good guy
EndFunction

Function givenLola()
  ; lola to good master, need NPC list
EndFunction






; is the follower upset at the player enough to enslave
bool function hasWrongedFollower()

  return false
endFunction

; if follower is submissive, do not enslave role play
; must be non-agressive, enjoy being sex by MC, MC is dom
bool function isFollowerSubmissive()

  return false
endFunction

; need at least three "training" mods, slaverunR, Leon? SD, what else...
bool function canRunTraining()
  ; are the mods installed? 
  ; SRR, CD, SlaveTown, 

  return false
endFunction

bool function canEnslavePlayerLocal()
  ; are the mods installed?
  ; PetCollar, Lola, ME (almost too agressive)
endFunction

bool function canEnslavePlayerDistance()
  ; are the mods installed?
  ; SS, SRR, SD, CD, 
endFunction

; we need to handle all of the conditions we can't test for at dialog time here
bool function canRunCD()

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
