Scriptname crdeNPCMonitorScript extends Quest  Conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: NPC Monitor
;
; Manages NPCs the player could be attacked by.
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
;
; Pre 14.00
; This class was forked from Player Monitor script.
;***********************************************************************************************

zadLibs         Property libs Auto
SexLabFramework Property SexLab Auto
slaUtilScr      Property Aroused Auto ; remains because just checking the faction doesn't init the arousal level
crdeNPCSearchingScript Property NPCSearchScript Auto

import GlobalVariable     ; needed for global variable functions (doesn't come with the object?!?!)
;import crdeDebugScript
;crdeDebugScript           Property DebugOut Auto
crdePlayerMonitorScript   Property PlayerMonScript Auto
crdeMCMScript             Property MCM Auto
;crdeSlaverunScript        Property SlaverunScript Auto
crdeModsMonitorScript     Property Mods Auto
;crdeDistantEnslaveScript  Property DistanceEnslave Auto
crdePlayerScript          Property PlayerScript Auto; initialized in init from playerScriptAlias
;crdeSlaveTatsScript       Property SlavetatsScript Auto
;import crdeSlaveTatsScript

Keyword Property ActorTypeNPC Auto ;: 00013794


Actor          Property player Auto
;ReferenceAlias Property playerScriptAlias Auto  ; this is deprecated because it causes save load detection to double, use the one in playermon

; might be a touch cheaper than GetRandomNearbyNPC

ReferenceAlias Property ValidAttacker1 Auto 
ReferenceAlias Property ValidAttacker2 Auto 
ReferenceAlias Property ValidAttacker3 Auto 
ReferenceAlias Property ValidAttacker4 Auto 
ReferenceAlias Property ValidAttacker5 Auto 
ReferenceAlias Property ValidAttacker6 Auto 
ReferenceAlias Property ValidAttacker7 Auto 
ReferenceAlias Property ValidAttacker8 Auto 
ReferenceAlias Property ValidAttacker9 Auto 

Faction        Property CurrentFollowerFaction Auto

Faction Property  slaNaked Auto
Quest             meTools                 ; MariaEdensTools

; moral cities
Worldspace Property solitudeSpace Auto 
Worldspace Property windhelmSpace Auto
Worldspace Property whiterunSpace Auto ; used with slaverun

import GlobalVariable
;GlobalVariable Property crdeFGreetStatus auto
;GlobalVariable Property crdeInvChange auto  
GlobalVariable Property crdeSearchRange auto

;int lastEnslavedLevel = 0                   ; not used?
;int Property vulnerability Auto Conditional ; 0 : free, 1 : collar, 2 : collar+gag/blindfold, 3 : armbinder
; these notes are out of date

actor master
actor previousAttacker
bool  masterIsSlaver    ; what was I going to do with this agaim?

event OnInit()
  player = Game.GetPlayer()
  Utility.wait(7)
  PlayerScript = (PlayerMonScript.playerScriptAlias as crdePlayerScript) 
  while Mods.finishedCheckingMods == false
    Debug.Trace("[crde]in npc:mods not finished yet", 1)
    Utility.wait(2) ; in seconds
  endWhile

endEvent

event OnUpdate()
  ;PreviousFollowers.revert()
endEvent

;tests if actor is in a zaz bondage device
bool function checkActorBoundInFurniture(actor actorRef)
  ;if(actorRef.WornHasKeyword(Keyword.GetKeyword("zbfEffectRefreshAnim")))
  ;if Mods.modLoadedZazAnimations ; should always be true
  if Mods.zazKeywordEffectRefresh == None
    debugmsg("zazKeywordEffectRefresh is not loaded, are you sure you installed zaz?", 5)
  elseif Mods.zazKeywordFurniture == None
    debugmsg("zazKeywordFurniture is not loaded, are you sure you installed zaz?", 5)

  elseif actorRef.WornHasKeyword(Mods.zazKeywordEffectRefresh)
    debugmsg("debug: " + actorRef.GetDisplayName() + " has zbf refresh keyword", 3)
    return true
  ;elseif (actorRef.WornHasKeyword(Keyword.GetKeyword("zbfFurniture")) ) ; sitting in furniture and tied up
  elseif Mods.zazKeywordFurniture != None && actorRef == player && PlayerScript.sittingInZaz ; player only
    int sitting = player.GetSitState()
    
    if (sitting >= 1 || sitting <= 3) && !PlayerScript.releasedFromZaz; still sitting
      debugmsg("debug: player is sitting in furniture with zazFurniture keyword, sitting lvl:" + sitting, 3)
      return true
    else
      debugmsg("debug: furniture no longer valid, canceling", 3)
      PlayerScript.sittingInZaz = false
    endif
  elseif Mods.zazKeywordFurniture != None && actorRef.HasKeyword(Mods.zazKeywordFurniture) ; sitting in furniture and tied up
    debugmsg("debug: " + actorRef.GetDisplayName() + " has zbf furniture keyword", 0)
    return true
  elseif Mods.zazKeywordFurniture != None && actorRef.WornHasKeyword(Mods.zazKeywordFurniture) ; sitting in furniture and tied up
    debugmsg("debug: " + actorRef.GetDisplayName() + " has zbf furniture keyword", 0)
    return true
  endif
  return false
  ; other keywords http://www.loverslab.com/topic/17062-zaz-animation-pack-2015-02-10/?p=1123366
  ;endif
endFunction

; this uses SKSE NPC search instead, which is honestly faster but I'm too lazy to prove it to fishburger
; we need a different NPC invalid function because the quest reset checks in conditions if an NPC is invalid to some extent
;  for this we have to check those conditions in papyrus
actor[] function getClosestActor(actor actorRef, bool skipSlavers = false)
  
  int searchIndex   = 0
  int npcIndex      = 0
  actor npcActor    = none
  Actor[] validNpcs = new Actor[10]
  Cell c = actorRef.GetParentCell()
  int foundActorCount = c.GetNumRefs(43) 
  
  while searchIndex < foundActorCount && npcIndex < MCM.iNPCSearchCount
    ;Debug.Trace("checking " + npcActor.GetDisplayName())
    ;npcActor = Game.FindRandomActorFromRef(actorRef, MCM.iSearchRange) ;200.0)  ; old method, full of holes (lots of actor=player and actor=follower most of the time)
    npcActor = c.GetNthRef(searchIndex, 43) as actor
    if npcActor == None ; if we get a none, then there are no actors nearby, might as well quit early
      return validNpcs
    elseif isActorIneligable(npcActor, skipSlavers) == false 
      validNpcs[npcIndex] = npcActor ; elegible, return now, we don't need anything more from this function
      npcIndex += 1
    endif
    searchIndex += 1
  endWhile
  return validNpcs ; passed through the whole loop, no valid actors
  
endFunction

; searches through the the quest ReferenceAlias' for a match
; should be faster than above since we can let the engine run some of these basic checks for us
actor[] function getClosestRefActor(actor actorRef)
  Actor closest = None
  Actor[] valid = new Actor[10]
  int index     = 0
  int invalids  = 0
  
  resetActors()
  ;Utility.Wait(2) ; <- 3 is too slow in bannered mare

  ;I don't like having so much redundant code, but I know of no other way to index through a series of references. Moving the minor code to a funciton would just thrash the stack since no inlining
  closest = ValidAttacker1.GetActorRef()
  if closest == None ; no need to check the rest if the first one is none, since they all load sequentially
    ;PlayerMonScript.debugmsg("No nearby NPC, nothing to do here",1)
    return new Actor[1] ; 
  elseif !isActorRefIneligable(closest, false)
    valid[index] = closest
    ValidAttacker1.Clear()
    index += 1
  endif
  closest = ValidAttacker2.GetActorRef()
  if closest == None 
    return valid
  elseif !isActorRefIneligable(closest, false)
    ;return closest
    valid[index] = closest
    ValidAttacker2.Clear()
    index += 1
  endif
  closest = ValidAttacker3.GetActorRef()
  if closest == None 
    return valid
  elseif !isActorRefIneligable(closest, false) 
    ;return closest
    valid[index] = closest
    ValidAttacker3.Clear()
    index += 1
  endif
  closest = ValidAttacker4.GetActorRef()
  if closest == None 
    return valid
  elseif !isActorRefIneligable(closest, false) 
    ;return closest
    valid[index] = closest
    ValidAttacker4.Clear()
    index += 1
  endif
  closest = ValidAttacker5.GetActorRef()
  if closest == None 
    return valid
  elseif !isActorRefIneligable(closest, false)
    ;return closest
    valid[index] = closest
    ValidAttacker5.Clear()
    index += 1
  endif
  closest = ValidAttacker6.GetActorRef()
  if closest == None 
    return valid
  elseif !isActorRefIneligable(closest, false) 
    ;return closest
    valid[index] = closest
    ValidAttacker6.Clear()
    index += 1
  endif
  closest = ValidAttacker7.GetActorRef()
  if closest == None
    return valid
  elseif !isActorRefIneligable(closest, false) 
    ;return closest
    valid[index] = closest
    ValidAttacker7.Clear()
    index += 1
  endif
  closest = ValidAttacker8.GetActorRef()
  if closest == None
    return valid
  elseif !isActorRefIneligable(closest, false) 
    ;return closest
    valid[index] = closest
    ValidAttacker8.Clear()
    index += 1
  endif
  closest = ValidAttacker9.GetActorRef()
  if closest == None
    return valid
  elseif !isActorRefIneligable(closest, false) 
    ;return closest
    valid[index] = closest
    ValidAttacker9.Clear()
    index += 1
  endif
  
  return valid
endFunction

; sooo need to make this follower AND slave optimized, if we have a slave, then we want a non-slave too, maybe
Actor function getclosestfollower() 
  
  actor[] a = NPCSearchScript.getNearbyActors(500)
  int i = 0
  actor testActor
  while i < a.length
    testActor = a[i]
    if testActor == None
      i += 100 ; list is empty from here on out, time to leave
    elseif testActor.IsInFaction(CurrentFollowerFaction) || testActor.IsInFaction(Mods.paradiseFollowingFaction)
      Mods.PreviousFollowers.addForm(testActor)
      return testActor
    endif
    i += 1
  endWhile    
endfunction

; why? because the MCM can't call quest status code while the game is paused, so we can't use NPCSearch in the menu
actor[] function getClosestFollowersLinear()
  Cell c = libs.playerref.GetParentCell()
  Actor[] followers = new actor[6]
  actor currentTest
  int index = 0
  Int NumRefs = c.GetNumRefs(43)
  While (NumRefs > 0) 
    NumRefs -= 1
    currentTest = c.GetNthRef(NumRefs, 43) as Actor
    If currentTest.IsInFaction(CurrentFollowerFaction) ; or is pah slave..?
      followers[index] = currentTest
      index += 1
    endIf            
  EndWhile 
  Return followers 
endFunction

; so that we can skip the follower protection in the future
function clearFollowers()
  ; get closeset followers until empty
  ; dismiss all of them (move from faction?)

endFunction

; moved to separate because it got complicated when playable race wasn't enough
bool function isInvalidRace(actor actorRef)
  Race actorRace =  actorRef.getRace()
  if actorRace == None || actorRace.isPlayable() == true
    return false
  endif
  race current_race_test
  int i = 0
  int range = PlayerMonScript.alternateRaces.Length
  while i < range
    current_race_test = PlayerMonScript.alternateRaces[i]
    if actorRace == current_race_test
      return false
    endif
    i += 1
  endwhile
  
  range = Mods.pointedValidRaces.length
  i = 0
  while i < range
    current_race_test = Mods.pointedValidRaces[i]
    if current_race_test == None
      i = 1000  ; rest of the list is empty, don't bother checking the rest
    elseif actorRace == current_race_test
      debugmsg("race was found in pointedvalidRaces", 1)
      return false
    endif
    i += 1
  endWhile
  
  ;if Mods.temptressVixenRace != None && actorRace == Mods.temptressVixenRace ; BAD, grabs the prob twice
  current_race_test = Mods.temptressVixenRace
  if current_race_test != None && actorRace == current_race_test
    return false
  endif
  return true
endFunction

; this might become obsolete if I can move some/al of them to the quest alias conditions
; I haven't changed this since I switched over to isActorRefIneligable, however I made fixes to isActorRefIneligable, keep that in mind
bool function isActorIneligable(actor actorRef, bool includeSlaveTraders = false)

  ; things checked by the ESP conditions for isActorRefIneligable:
  ; actor in scene
  ; has actor keyword
  ; is in distance
  ; child/teamate
  ; in slave faction
  ; follower faction
  ; has zbfeffectkeepoffsetanim
  ; has zbfeffectrefreshanim
  
  if actorRef == None || actorRef == player ; should be taken care of before this, but might as well play with save variables
    return true
  endif
  
  
  if(SexLab.IsActorActive(actorRef))
    debugmsg("invalid: " + actorRef.GetDisplayName() + " actor is 'sexlab active', busy", 3)
  ; don't need to check distance if the search function is based on search
  elseif(actorRef.isDisabled())
  ; in case they are disabled because player disabled them or quest NPC hidden until later
    return true
  elseif(actorRef.IsHostileToActor(player) || actorRef.IsInCombat() )
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is hostile or in combat", 3)
    return true
  elseif(actorRef.HasKeyword(ActorTypeNPC) == false)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is not an NPC actor", 3)
    return true
  elseif(actorRef.GetRelationshipRank(player) > MCM.iRelationshipProtectionLevel)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " has too high of relationship: " + actorRef.GetRelationshipRank(player), 3)
    return true
  elseif !MCM.bAttackersGuards && actorRef.IsGuard() ;actorRef.IsInFaction(Vars.isGuardFaction)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is in guards faction", 3)
    return true
  elseif(Mods.ModLoadedCD == true && actorRef.IsInFaction(Mods.cdGeneralFaction) || actorRef.IsInFaction(Mods.cdCustomerFaction)) 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is in a CD faction", 3)
    return true
  elseif(actorRef.HasLOS(player) == false && MCM.iVulnerableLOS )
    debugmsg("invalid: " + actorRef.GetDisplayName() + " has no los", 3)
    return true
  endif
  
  float arousal_modifier = (1 + ((PlayerMonScript.isNight() as int) * (MCM.fNightReqArousalModifier - 1)) )
  if !MCM.bArousalFunctionWorkaround
    int arousal = actorRef.GetFactionRank(Mods.sexlabArousedFaction)
    if arousal < MCM.gMinApproachArousal.GetValueInt() / arousal_modifier ;&& !isSlaver ;aroused enough?
      debugmsg("invalid: " + actorRef.GetDisplayName() + " arousal too low (faction): " + arousal + "/" + (MCM.gMinApproachArousal.GetValueInt() / arousal_modifier) as int + " Night:" + PlayerMonScript.isNight(), 3)
      return true
    Endif
  elseif MCM.bArousalFunctionWorkaround 
    int arousal = Aroused.GetActorArousal(actorRef) 
    if arousal < MCM.gMinApproachArousal.GetValueInt() / arousal_modifier  
      debugmsg("invalid: " + actorRef.GetDisplayName() + " arousal too low (function): " + arousal + "/" + (MCM.gMinApproachArousal.GetValueInt() / arousal_modifier) as int + " Night:" + PlayerMonScript.isNight(), 3)
      return true  
    Endif
  endif  
  
  float actorMorality = actorRef.GetAV("Morality") ; holy fuck this can hang the thread on some actors
  bool isSlaver = Mods.isSlaveTrader(actorRef)
  if isWearingSlaveDD(actorRef) && !isSlaver
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is wearing slave DD gear", 3)
    return true
  elseif isWearingSlaveXaz(actorRef) && !isSlaver
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is wearing slave ZAZ gear", 3)
    return true
  elseif(actorRef == master)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is your master", 3)
    return true
  elseif(actorRef.isDead() || actorRef.isChild())
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is dead, or child", 3)
    return true
  elseif isInvalidRace(actorRef) 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is not valid race", 3)
    return true
    
    
  elseif ((MCM.iMaxEnslaveMorality as float) < actorMorality) && ((MCM.iMaxSolicitMorality as float) < actorMorality) && !Mods.isSlaveTrader(actorRef)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " has too high of a morality ", 3)
    return true

  elseif(actorRef.IsPlayerTeammate())
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is your team mate (follower)", 3)
    return true
  elseif(actorRef.IsInFaction(CurrentFollowerFaction))
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is in currentfollowerfaction", 3)
    return true
  elseif player.IsSneaking() && !player.IsDetectedBy(actorRef)   
    debugmsg("invalid: player is sneaking, and " + actorRef.GetDisplayName() + " doesn't see them", 3)
    return true
  ;heavier
  elseif checkActorBoundInFurniture(actorRef) 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is locked in furniture", 3)
    return true
  
  endif
  
  int actor_sex = 0
  if MCM.bUseSexlabGender
    actor_sex     = SexLab.GetGender(actorRef)
  else
    actor_sex     = actorRef.GetActorBase().getSex()
  endif 
  int gender_pref   = MCM.iGenderPref
  if( actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is the wrong gender", 3) ; 0 is male, 1 is female
    return true
  elseif Mods.modLoadedAngrim && StorageUtil.GetIntValue( actorRef, "Angrim_iEnthralled" ) > 0
    debugmsg(actorRef.GetDisplayName() + " is an angrim's apprentice thrawl, and loves the player", 3)
    return true
  elseif Mods.isSlave(actorRef) 
     debugmsg("invalid: " + actorRef.GetDisplayName() + " is a slave", 3)
    return true
  elseif actorRef.GetCurrentScene() != None 
     debugmsg("invalid: " + actorRef.GetDisplayName() + " is in a scene", 3)
    return true

  elseif(actorRef.getAV("Aggression") > 2)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is aggressive? inactive", 3) ; this one might be needed for stealth after all
    return true
  elseif actorRef.IsDisabled()
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is disabled and does not exist", 3) ; this one might be needed for stealth after all
    return true
  endif
  
  return false
endFunction


bool function isActorRefIneligable(actor actorRef, bool includeSlaveTraders = false)
  ;debugmsg("invalid: ", 0)
  
  if actorRef == None ;|| actorRef.GetDisplayName().getsize() == 0; should be taken care of before this, but might as well catch here
    return false
  endif
  
  float actorMorality = actorRef.GetAV("Morality") ; might take long enough that saving it is desireable
  ; get actor is slaver, ignore certain things if he is, like arousal
  
  ;string actorName = actorRef.GetDisplayName() ; doesn't seem to be used by anyone
  if SexLab.IsActorActive(actorRef) ; || SexLab.IsActorActive(player); we check this twice otherwise already
    debugmsg("invalid: " + actorRef.GetDisplayName() + " actor is 'sexlab active', busy", 3)
    return true
  elseif ((actorRef.GetDistance(player) as float) > (crdeSearchRange.GetValue() * 1.25)) ;actor is too far away, needed because we're not just checking instantly anymore, now we're checking over time
    debugmsg("invalid: " + actorRef.GetDisplayName() + " actor is too far away from player now", 3)
    return true
  elseif(actorRef.GetRelationshipRank(player) > MCM.iRelationshipProtectionLevel)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " has too high of relationship", 3)
    return true

  elseif(actorRef.IsHostileToActor(player) || actorRef.IsInCombat()  )
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is hostile, combat", 3)
    return true
  elseif !MCM.bAttackersGuards && actorRef.IsGuard() ;actorRef.IsInFaction(Vars.isGuardFaction)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is in guards faction", 3)
    return true
  elseif(Mods.ModLoadedCD == true && actorRef.IsInFaction(Mods.cdGeneralFaction) || actorRef.IsInFaction(Mods.cdCustomerFaction)) 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is in a CD faction", 3)
    return true
    
  elseif Mods.modLoadedAngrim && StorageUtil.GetIntValue( actorRef, "Angrim_iEnthralled" ) > 0
    debugmsg(actorRef.GetDisplayName() + " is an angrim's apprentice thrawl, and loves the player", 3)
    return true
  elseif(MCM.iVulnerableLOS && actorRef.HasLOS(player) == false)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " has no los", 3)
    return true
  endif
  
  float arousal_modifier = (1 + ((PlayerMonScript.isNight() as int) * (MCM.fNightReqArousalModifier - 1)) )
  if !MCM.bArousalFunctionWorkaround
    int arousal = actorRef.GetFactionRank(Mods.sexlabArousedFaction)
    if arousal < MCM.gMinApproachArousal.GetValueInt() / arousal_modifier ;&& !isSlaver ;aroused enough?
      debugmsg("invalid: " + actorRef.GetDisplayName() + " arousal too low (faction): " + arousal + "/" + (MCM.gMinApproachArousal.GetValueInt() / arousal_modifier) as int + " Night:" + PlayerMonScript.isNight(), 3)
      return true
    Endif
  elseif MCM.bArousalFunctionWorkaround 
    int arousal = Aroused.GetActorArousal(actorRef) 
    if arousal < MCM.gMinApproachArousal.GetValueInt() / arousal_modifier  
      debugmsg("invalid: " + actorRef.GetDisplayName() + " arousal too low (function): " + arousal + "/" + (MCM.gMinApproachArousal.GetValueInt() / arousal_modifier) as int + " Night:" + PlayerMonScript.isNight(), 3)
      return true  
    Endif
  endif  
  
    ;heavier stuff, or less likely to trigger

  bool isSlaver = Mods.isSlaveTrader(actorRef)
  if isWearingSlaveDD(actorRef) && !isSlaver
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is wearing slave DD gear", 3)
    return true
  elseif isWearingSlaveXaz(actorRef) && !isSlaver
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is wearing slave ZAZ gear", 3)
    return true
  elseif(actorRef == master)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is your master", 3)
    return true
  elseif(actorRef.isDead() || actorRef.isChild())
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is dead, or child", 3)
    return true
  elseif isInvalidRace(actorRef) 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is not playable race", 3)
    return true
  endif 
  
  if ((MCM.iMaxEnslaveMorality as float) < actorMorality) && ((MCM.iMaxSolicitMorality as float) < actorMorality) && !isSlaver 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " has too high of a morality ", 3)
    return true
  
  elseif player.IsSneaking() && !player.IsDetectedBy(actorRef)   
    debugmsg("invalid: player is sneaking, and " + actorRef.GetDisplayName() + " doesn't see them", 3)
    return true
  elseif checkActorBoundInFurniture(actorRef) 
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is locked in furniture", 3)
    return true
  endif
 
  int actor_sex = 0
  if MCM.bUseSexlabGender
    actor_sex     = SexLab.GetGender(actorRef)
  else
    actor_sex     = actorRef.GetActorBase().getSex()
  endif   
  int gender_pref   = MCM.iGenderPref
  if( actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is the wrong gender", 3)
    return true
  elseif(actorRef.isUnconscious() ||  actorRef.GetSleepState() == 3 )
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is unconscious, or asleep", 3)
    return true
  elseif(actorRef.getAV("Aggression") > 2) ; upgrading to lvl 2, since combat is considered a different thing anyway
    debugmsg("invalid: " + actorRef.GetDisplayName() + " is too aggressive", 3) ; this one might be needed for stealth after all
    ; todo: replace with "is aggressive to player" check instead of this sillyness
    return true
  elseif Mods.isSlave(actorRef) ; needs cleaning with the faction upscale
     debugmsg("invalid: " + actorRef.GetDisplayName() + " is a slave", 3)
    return true
  ;elseif (PlayerMonScript.enslavedLevel > 1 || Mods.enslavedSD) && actorRef.IsInFaction(Mods.immersiveWenchGeneralFaction)
  ;  debugmsg("invalid: " + actorRef.GetDisplayName() + " is in immersive wench faction and already enslaved", 3) 
  ;  return true
  endif
  
  return false
endFunction

bool function isWearingSlaveXaz(actor actorRef)
  
  return !MCM.bIgnoreZazOnNPC && ( actorRef.WornHasKeyword(Mods.zazKeywordWornGag) || actorRef.WornHasKeyword(Mods.zazKeywordWornBlindfold) \
      || actorRef.WornHasKeyword(Mods.zazKeywordWornBelt) || actorRef.WornHasKeyword(Mods.zazKeywordWornYoke) \
      || actorRef.WornHasKeyword(Mods.zazKeywordAnimWrists)) \
      || (actorRef.WornHasKeyword(Mods.zazKeywordWornCollar) && !(actorRef.GetWornForm(0x00000004) != None || MCM.bIgnoreZazOnNPC)) ; must also be naked for collar to work
endFunction

bool function isWearingSlaveDD(actor actorRef)
  ; devicekeywords: armbinder, blindfold, collar, gag, everything else after that is zaz zbfgag
  return actorRef.WornHasKeyword(libs.zad_DeviousArmbinder) || actorRef.WornHasKeyword(libs.zad_DeviousBlindfold) \
      || actorRef.WornHasKeyword(libs.zad_DeviousGag) \
      || actorRef.WornHasKeyword(libs.zad_DeviousHarness) || actorRef.WornHasKeyword(libs.zad_DeviousHeavyBondage) || actorRef.WornHasKeyword(libs.zad_DeviousBelt)\
      || (actorRef.WornHasKeyword(libs.zad_DeviousCollar) && !(actorRef.GetWornForm(0x00000004) != None || MCM.bIgnoreZazOnNPC))
endFunction

; there's one in playermon, do we need this one here?
; markedfordelete
;bool function isNude(actor actorRef)
;  int index = 0
;  ;bool nude = true
;  While (index < PlayerMonScript.clothingKeywords.length)
;    if(actorRef.wornHasKeyword(PlayerMonScript.clothingKeywords[index]))
;      PlayerMonScript.isNude = false
;      return false
;    endif
;    index += 1
;  EndWhile
;  PlayerMonScript.isNude = true
;  return true
;endFunction

function printNearbyValidActors()

  ; experiment: move this to the fro
  
  if ValidAttacker1 != None
    string actorNames = ""  ; yell at me when you have a better way to text input than concat, until then...
    Actor a = ValidAttacker1.GetActorRef() ;GetActorRef GetDisplayName
    if a != None
      actorNames = actorNames + "1:" + a.GetDisplayName()
    endIf
    a = ValidAttacker2.GetActorRef()
    if a != None
      actorNames = actorNames + ", 2:" + a.GetDisplayName()
    endIf
    a = ValidAttacker3.GetActorRef()
    if a != None
      actorNames = actorNames + ", 3:" + a.GetDisplayName()
    endIf
    a = ValidAttacker4.GetActorRef()
    if a != None
      actorNames = actorNames + ", 4:" + a.GetDisplayName()
    endIf
    a = ValidAttacker5.GetActorRef()
    if a != None
      actorNames = actorNames + ", 5:" + a.GetDisplayName()
    endIf
    a = ValidAttacker6.GetActorRef()
    if a != None
      actorNames = actorNames + ", 6:" + a.GetDisplayName()
    endIf
    a = ValidAttacker7.GetActorRef()
    if a != None
      actorNames = actorNames + ", 7:" + a.GetDisplayName()
    endIf
    
    debugmsg("closest npc(s): " + actorNames) 
    ;debugmsg("arousal faction rank for player:" + player.GetFactionRank(Mods.sexlabArousedFaction) + " getarousal:" + Aroused.GetActorArousal(player))   
    
  else
    debugmsg("closest npc alias is empty")
  endif 
endFunction

; separated for clarity, since leaving it in printNearbyValidActors is a bad place to look for it
function resetActors()
  ; only refresh the aliases if none of them were filled, less stress on the engine
  if IsRunning()
    stop()
    Utility.Wait(2) ; this works, but removing in case it's not necessary
                    ; re-enabled since it might have broken for some users
    while IsStopping()
      debugmsg("NPCMon is still waiting to stop ...")
      Utility.Wait(1)
    endWhile
    start()
  endif
  
endFunction

; check if the followers are already in the list, if so
function addFollower(actor actorRef)
  ; int i = 0
  ; int j = 0
  ; int PreviousFollowersLength = .lPreviousFollowersength ; gets used too often, save it because papcompiler is stupid
  ; while i < actorRefs.length
    ; while j < PreviousFollowers.length
    
      ; if PreviousFollowers[PreviousFollowersIndex + j % PreviousFollowersLength] 
      ; if actorRefs[i] == 
      ; j += 1
     ; endWhile
    ; i += 1
  ; endWhile

  Mods.PreviousFollowers.AddForm(actorRef)
  
endFunction

function timeTestActorTraits(actor actorRef)

  bool throwaway = false
  string str = "Per Actor Test:" ; reset re/use 
  
  
  float timeTaken = Utility.GetCurrentRealTime()
  bool isSlaver = Mods.isSlaveTrader(actorRef)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " isSlaver: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  SexLab.IsActorActive(actorRef)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " SexlabActive: " + timeTaken
   
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (actorRef.GetDistance(player) as float) > (crdeSearchRange.GetValue() * 1.25)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " distance check: " + timeTaken 
   
  timeTaken = Utility.GetCurrentRealTime()
  float actorMorality = actorRef.GetAV("Morality") ; might take long enough that saving it is desireable   
  throwaway = ((MCM.iMaxEnslaveMorality as float) < actorMorality) && ((MCM.iMaxSolicitMorality as float) < actorMorality) && !isSlaver 
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " morality: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = MCM.iVulnerableLOS && actorRef.HasLOS(player) == false
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " LOS: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (actorRef.GetRelationshipRank(player) > MCM.iRelationshipProtectionLevel)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " relationship: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (actorRef.IsHostileToActor(player) || actorRef.IsInCombat() || actorRef.isChild() )
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " hostile/child/combat: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  throwaway = isWearingSlaveDD(actorRef) && !isSlaver
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " slaveDD: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = isWearingSlaveXaz(actorRef) && !isSlaver
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " slaveZaz: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  throwaway = player.IsSneaking() && !player.IsDetectedBy(actorRef)  
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " sneaking: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = StorageUtil.GetIntValue( actorRef, "Angrim_iEnthralled" ) > 0
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " angrim enthrall: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = Mods.isSlave(actorRef) 
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " isSlave: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = isInvalidRace(actorRef)   
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " invalidRace: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = checkActorBoundInFurniture(actorRef) 
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " furniture: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = !MCM.bAttackersGuards && actorRef.IsGuard() ;actorRef.IsInFaction(Vars.isGuardFaction)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " guard faction: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  float arousal_modifier = (1 + ((PlayerMonScript.isNight() as int) * (MCM.fNightReqArousalModifier - 1)) )
  if !MCM.bArousalFunctionWorkaround
    int arousal = actorRef.GetFactionRank(Mods.sexlabArousedFaction)
    throwaway =  arousal < MCM.gMinApproachArousal.GetValueInt() / arousal_modifier ;&& !isSlaver ;aroused enough?
  elseif MCM.bArousalFunctionWorkaround 
    int arousal = Aroused.GetActorArousal(actorRef) 
    throwaway =  arousal < MCM.gMinApproachArousal.GetValueInt() / arousal_modifier  
  endif  
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " arousal: " + timeTaken 
 
  timeTaken = Utility.GetCurrentRealTime()
  int actor_sex = 0
  if MCM.bUseSexlabGender
    actor_sex     = SexLab.GetGender(actorRef)
  else
    actor_sex     = actorRef.GetActorBase().getSex()
  endif   
  int gender_pref   = MCM.iGenderPref  
  throwaway = ( actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " valid gender: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (actorRef == master)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " isMaster: " + timeTaken

  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (Mods.ModLoadedCD == true && actorRef.IsInFaction(Mods.cdGeneralFaction)) 
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " cd faction1: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (Mods.ModLoadedCD == true && actorRef.IsInFaction(Mods.cdCustomerFaction))
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " cd faction1: " + timeTaken
  
  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (actorRef.isUnconscious() ||  actorRef.isDead() || actorRef.GetSleepState() == 3)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " dead/sleep/unconsious: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (actorRef.getAV("Aggression") > 2)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " aggressive: " + timeTaken

  timeTaken = Utility.GetCurrentRealTime()
  throwaway = (PlayerMonScript.enslavedLevel > 1 || Mods.enslavedSD) && actorRef.IsInFaction(Mods.immersiveWenchGeneralFaction)
  timeTaken = Utility.GetCurrentRealTime() - timeTaken 
  str += " immersive wench: " + timeTaken



  Debug.Trace(str)
  Debug.MessageBox(str)  

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
