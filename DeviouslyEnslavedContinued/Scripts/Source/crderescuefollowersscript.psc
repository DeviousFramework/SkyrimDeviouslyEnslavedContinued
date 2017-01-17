Scriptname crdeRescueFollowersScript extends Quest conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Rescue Follower
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

; old stuff, might not keep
crdeMCMScript Property MCM Auto
crdeNPCSearchingScript Property NPCSearch Auto
crdeModsMonitorScript Property Mods Auto
crdePlayerMonitorScript Property PlayerMonitor Auto
bool Property canRunQuest auto conditional

;new stuff
ReferenceAlias Property follower1 Auto
ReferenceAlias Property follower2 Auto
ReferenceAlias Property follower3 Auto
ReferenceAlias Property follower4 Auto
ReferenceAlias Property follower5 Auto

ReferenceAlias Property slave1 Auto
ReferenceAlias Property slave2 Auto
ReferenceAlias Property slave3 Auto
ReferenceAlias Property slave4 Auto
ReferenceAlias Property slave5 Auto

Faction Property CurrentFollowerFaction Auto

actor[] followers
actor[] slaves

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
; do something in frag 10
;END CODE
EndFunction
;END FRAGMENT


;used to calculate how long they were separated
int Property timeOfPlayerEnslavement Auto

; Function addFollower(actor a)
  ; if follower1 == None
    ; follower1.forceRefTo(a)
  ; elseif follower2 == None
    ; follower2.forceRefTo(a)
  ; elseif follower3 == None
    ; follower3.forceRefTo(a)
  ; elseif follower4 == None
    ; follower4.forceRefTo(a)
  ; elseif follower5 == None
    ; follower5.forceRefTo(a)
  ; endif
; endFunction

; Function addSlave(actor a)
  ; if slave1 == None
    ; slave1.forceRefTo(a)
  ; elseif slave2 == None
    ; slave2.forceRefTo(a)
  ; elseif slave3 == None
    ; slave3.forceRefTo(a)
  ; elseif slave4 == None
    ; slave4.forceRefTo(a)
  ; elseif slave5 == None
    ; slave5.forceRefTo(a)
  ; endif
; endFunction

Function addFollowersAndSlaves(actor[] f, actor[] s)
  followers = f
  slaves = s
endFunction

Function populateList()

  ; TODO sort through them to find the best canidates

  follower1.ForceRefTo(followers[0])
  follower2.ForceRefTo(followers[1])
  follower3.ForceRefTo(followers[2])
  follower4.ForceRefTo(followers[3])
  follower5.ForceRefTo(followers[4])

  slave1.ForceRefTo(slaves[0])
  slave2.ForceRefTo(slaves[1])
  slave3.ForceRefTo(slaves[2])
  slave4.ForceRefTo(slaves[3])
  slave5.ForceRefTo(slaves[4])

  ; TODO release the rest so that they don't run away

  ; gather all nearby player's followers and slaves
  ; can't use getNearbYFollowers because it assumes genders for attakc purposes, but here we ignore that.
  ;actor[] followers = NPCSearch.getNearbyActors()
         ;&& ((actorRef.IsInFaction(CurrentFollowerFaction) || (actorRef.GetRelationShipRank(player) >= min_relationship)) \
         ;|| (Mods.modLoadedParadiseHalls && actorRef.IsInFaction(Mods.paradiseFollowingFaction) \
         ;&& !actorRef.WornHasKeyword(Mods.paradiseSlaveRestraintKW) && !(Mods.PAHETied && actorRef.IsInFaction(Mods.PAHETied)))\
         ;  )
  ; actor tmp;
  ; int i = 0
  ; While(i < 16)
    ; tmp = followers[i]
    ; if tmp.IsInFaction(CurrentFollowerFaction) 
      ; addFollower(tmp)
    ; endif
    ; if follower5 != None
      ; i = 100
    ; else
      ; i += 1
    ; endif
  ; endWhile  
  ; i = 0
  ; While(i < 16)
    ; tmp = followers[i]
    ; if  (Mods.modLoadedParadiseHalls && tmp.IsInFaction(Mods.paradiseFollowingFaction) || tmp.WornHasKeyword(Mods.paradiseSlaveRestraintKW))
      ; addFollower(tmp)
    ; endif
    ; if slave5 != None
      ; i = 100
    ; else
      ; i += 1
    ; endif
  ; endWhile  

endFunction

Function setObjectiveComplete(actor speaker)
; called from the dialogue, can we detect which actor is in which spot and set the correct objective complete?

endFunction

Event OnStage_10()
  Debug.Trace("CRDE: Stage 10 reached...?")
  populateList()
  SetStage(10)
endEvent
