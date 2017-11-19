Scriptname crdeFollowerMonitorScript extends Quest  Conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Follower Monitor
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

zadLibs         Property libs Auto
SexLabFramework Property SexLab Auto
;slaUtilScr      Property Aroused Auto ; deprecated, calling the function is faster

;import GlobalVariable ; we need to import to use object functions, even though object is included without statement

;crdeDebugScript Property DebugOut Auto
crdeMCMScript             Property MCM Auto
crdeModsMonitorScript     Property Mods Auto
crdePlayerMonitorScript   Property PlayerMon Auto

;2-6 follower aliases
ReferenceAlias Property FollowerAlias1 Auto
ReferenceAlias Property FollowerAlias2 Auto
ReferenceAlias Property FollowerAlias3 Auto

Faction        Property CurrentFollowerFaction Auto

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

; properties on follower
; these are in storageutil, since it's per-actor, just listing here
; disposition toward player
; likesBeingTied
; likesTyingOthers
; likesBeingSub
; likesBeingDom

; int   Property forceGreetSlave Auto Conditional
; bool   Property forceGreetIncomplete Auto Conditional
; int   Property forceGreetSex Auto Conditional
; int   Property forceGreetWanted Auto Conditional


Event OnUpdate()
  ; right now we do nothing
   
EndEvent

Event OnInit()
  
  ;while Mods.finishedCheckingMods == false
  ;  Debug.Trace("[crde]in player:mods not finished yet", 1)
  ;  Utility.wait(2) ; in seconds
  ;endWhile
  
  RegisterForSingleUpdate(1) ; in seconds
EndEvent

function Maintenance()
  RegisterForSingleUpdate(3) ; is this right?
  ;settings.resetValues()
endFunction


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

Actor function getClosestFollower()
  return None
endFunction

; we need to check if the followers watched the player have sex, helps the follower determine if they should talk to player about becoming slave
; potential conditions: Player is victim, Player is Wearing items, Player came, Player is sucking,anal?
Function checkFollowersSawPlayerSex(int tif)
    ;  StorageUtil.SetFloatValue(actorRef, "crdeLastEval", Utility.GetCurrentRealTime()) float lastEval = StorageUtil.GetFloatValue(actorRef, "crdeLastEval")
  actor player = PlayerMon.player ; might as well, since we check like 3 times
  if player.WornHasKeyword(Mods.zazKeywordWornCollar) || player.WornHasKeyword(Mods.zazKeywordWornGag) ; todo: offer alternative zbfWornStuff, all zbf or all DD
    actor ourFollower = getclosestfollower() ; TODO: expand this for all followers
    if ourFollower != None && ourFollower.HasLOS(player)
      PlayerMon.debugmsg("Follower " + ourFollower.GetDisplayName() + " saw us having sex while wearing devious gear!", 2)
      ;store storageutil for that character
      ;ourFollower ;ZZZ
      ; crdeFollowerWitnessSubSex?
    endif
  endif
    
endFunction


function modifyFollowerDisposition(actor follower)
  ;follower.
endFunction
