Scriptname crdeNPCSearchingScript extends Quest  Conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: NPC Searching
;
; This quest exists solely to grab the nearest N actors.
; We can't use the NPC Monitor script for this because we search for conditions that we can't
; ignore at will.
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
crdePlayerMonitorScript Property PlayerMon Auto

ReferenceAlias Property nearest00 Auto ; using 00 because creation kit is stupid 
ReferenceAlias Property nearest01 Auto
ReferenceAlias Property nearest02 Auto
ReferenceAlias Property nearest03 Auto
ReferenceAlias Property nearest04 Auto
ReferenceAlias Property nearest05 Auto
ReferenceAlias Property nearest06 Auto
ReferenceAlias Property nearest07 Auto
ReferenceAlias Property nearest08 Auto
ReferenceAlias Property nearest09 Auto
ReferenceAlias Property nearest10 Auto
ReferenceAlias Property nearest11 Auto
ReferenceAlias Property nearest12 Auto
ReferenceAlias Property nearest13 Auto
ReferenceAlias Property nearest14 Auto
ReferenceAlias Property nearest15 Auto
;ReferenceAlias Property NearestFollower01 Auto

actor player

; because calling the property from playermon might take longer
Faction Property CurrentFollowerFaction Auto 
Faction Property crdeNeverFollowerFaction Auto;
Faction Property crdeFormerFollowerFaction Auto

event OnInit()
  player = Game.GetPlayer()
endEvent

function refreshForActors()
  ; stop and restart, to allow the actors to reset
  if IsRunning()
    stop()
  endif
  ;Utility.Wait(2) ; this works, but removing in case it's not necessary
  while IsStopping() 
    debugmsg("NPCSearch is still waiting to stop ...")
    Utility.Wait(1)
  endWhile
  start()

endFunction

Actor[] function getNearbyActors(int specificDistance = 0)

  int searchDistance = 1024 ;
  if specificDistance != 0
    searchDistance = specificDistance
  endif
  
  refreshForActors()

  ; for each alias, add them to the array and return
  Actor[] a = new Actor[16]
  a[0]  =  nearest00.GetActorRef()
  nearest00.clear()
  a[1]  =  nearest01.GetActorRef()
  nearest01.clear()
  a[2]  =  nearest02.GetActorRef()
  nearest02.clear()
  a[3]  =  nearest03.GetActorRef()
  nearest03.clear()
  a[4]  =  nearest04.GetActorRef()
  nearest04.clear()
  a[5]  =  nearest05.GetActorRef()
  nearest05.clear()
  a[6]  =  nearest06.GetActorRef()
  nearest06.clear()
  a[7]  =  nearest07.GetActorRef()
  nearest07.clear()
  a[8]  =  nearest08.GetActorRef()
  nearest08.clear()
  a[9]  =  nearest09.GetActorRef()
  nearest09.clear()
  a[10]  =  nearest10.GetActorRef()
  nearest10.clear()
  a[11]  =  nearest11.GetActorRef()
  nearest11.clear()
  a[12]  =  nearest12.GetActorRef()
  nearest12.clear()
  a[13]  =  nearest13.GetActorRef()
  nearest13.clear()
  a[14]  =  nearest14.GetActorRef()
  nearest14.clear()
  a[15]  =  nearest15.GetActorRef()
  nearest15.clear()

  return a
  
endFunction

Actor[] function getNearbyActorsLinear(int distance = 1024)
  Cell c = player.GetParentCell()
  Actor[] followers = new actor[15]
  actor currentTest
  int index = 0
  Int NumRefs = c.GetNumRefs(43)
  While NumRefs > 0  && index < 15
    NumRefs -= 1
    currentTest = c.GetNthRef(NumRefs, 43) as Actor
    if distance >= currentTest.GetDistance(player)
      followers[index] = currentTest
      index += 1
    endif
  EndWhile 
  Return followers 
endFunction

; used by main loop for follower approach
Actor[] function getNearbyFollowers(int specificDistance = 0)
  int searchDistance = 768 ; TODO set this in the MCM
  if specificDistance != 0
    searchDistance = specificDistance
  endif
  
  int min_relationship = MCM.iFollowerRelationshipLimit.GetValueInt() ; explicit because compiler will check it every loop iteration otherwise
  ;debugmsg("min_relationship is " + min_relationship)
  
  refreshForActors() 

  ; for each alias, add them to the array and return
  int i = 0 ; array index
  Actor[] a = new Actor[25] ; we're acounting previous followers now too
  
  actor testActor = nearest00.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest00.clear()
    i += 1
  endif
  testActor = nearest01.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest01.clear()
    i += 1
  endif
  testActor = nearest02.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest02.clear()
    i += 1
  endif
  testActor = nearest03.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest03.clear()
    i += 1
  endif
  testActor = nearest04.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest04.clear()
    i += 1
  endif
  testActor = nearest05.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest05.clear()
    i += 1
  endif
  testActor = nearest06.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest06.clear()
    i += 1
  endif
  testActor = nearest07.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest07.clear()
    i += 1
  endif
  testActor = nearest08.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest08.clear()
    i += 1
  endif
  testActor = nearest09.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest09.clear()
    i += 1
  endif
  testActor = nearest10.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest10.clear()
    i += 1
  endif
  testActor = nearest11.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest11.clear()
    i += 1
  endif
  testActor = nearest12.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest12.clear()
    i += 1
  endif
  testActor = nearest14.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest14.clear()
    i += 1
  endif
  testActor = nearest15.GetActorRef()
  if testActor != None && testActor.GetDistance(player) <= searchDistance && actorIsFollower(testActor, min_relationship)
    a[i]  =  testActor
    nearest15.clear()
    i += 1
  endif
  
  int f = 0
  FormList previousFollowers = PlayerMon.permanentFollowers ; sure, why wouldn't it fail to work for such a stupid reason, right?
  While f < previousFollowers.GetSize()
    Actor tmp = previousFollowers.GetAt(f) as Actor
    if tmp.IsDead()
      previousFollowers.RemoveAddedForm(tmp as Form)
    elseif tmp.GetDistance(player) <= searchDistance
      a[i] = tmp
      i += 1
    endif
    f += 1
  endWhile  
    
  return a
  
endFunction

; min relationship is because I think passing another function parameter, even with the thrashing
;  is probably faster than asking for a property in papyrus, could be wrong though...
bool function actorIsFollower(actor actorRef, int min_relationship = 3)
  ; so it doesn't get pulled from the game's engine twice, bad compiler
  ;   heck, he base actor needs to get pulled twice too 
  ;   so does the preference
  int actor_sex     = actorRef.GetActorBase().getSex()
  int gender_pref   = MCM.iGenderPref
  return !(( actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)) \
         && ((actorRef.IsInFaction(CurrentFollowerFaction) || (actorRef.GetRelationShipRank(player) >= min_relationship) || actorRef.IsInFaction(crdeFormerFollowerFaction) ) \
         && !actorRef.IsInFaction(crdeNeverFollowerFaction) \
         || (Mods.modLoadedParadiseHalls && actorRef.IsInFaction(Mods.paradiseFollowingFaction) \
         && !actorRef.WornHasKeyword(Mods.paradiseSlaveRestraintKW) && !(Mods.PAHETied && actorRef.IsInFaction(Mods.PAHETied))) \
         || (Mods.modLoadedSlaveTrainer && actorRef.IsInFaction(Mods.sltSlaveFaction)) \
           )
endFunction

bool function getNearbyFollowersInFaction(actor[] allies)
  int i = 0
  while i < allies.length
    actor a = allies[i]
    if a != None && a.IsInFaction(CurrentFollowerFaction)
      return true
    endif
    i += 1
  endWhile
  return false
endFunction

;debug: todo move to shared lib
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
