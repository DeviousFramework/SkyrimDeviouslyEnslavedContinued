Scriptname crdePlayerMonitorScript extends Quest  Conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Player Monitor
;
; This is the main script for handling most events.  It monitors the status of the player,
; determines when she should be assaulted, and begins each individual assault.
;
; Many thanks to Chase Roxand and Verstort for all of their original work on this mod.
;
; � Copyright 2017 legume-Vancouver of GitHub
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

import GlobalVariable ; we need to import to use object functions, even though object is included without statement
import Math
;crdeDebugScript Property DebugOut Auto
crdeMCMScript             Property MCM Auto
crdeSlaverunScript        Property SlaverunScript Auto
crdeModsMonitorScript     Property Mods Auto
crdeDistantEnslaveScript  Property DistanceEnslave Auto
crdePlayerScript          Property PlayerScript Auto; initialized in init from playerScriptAlias
crdeSlaveTatsScript       Property SlavetatsScript Auto

crdeNPCMonitorScript      Property NPCMonitorScript Auto
crdeNPCSearchingScript    Property NPCSearchScript Auto
crdeItemManipulateScript  Property ItemScript Auto
import crdeSlaveTatsScript
sslThreadLibrary          Property ThreadLib Auto ; for bed finding, maybe other too

Actor                     Property player             Auto
ReferenceAlias            Property attackerRefAlias   Auto  
ReferenceAlias            Property playerScriptAlias  Auto 
ReferenceAlias            Property masterRefAlias     Auto  
ReferenceAlias            Property followerRefAlias01 Auto  
ReferenceAlias            Property followerRefAlias02 Auto  
ReferenceAlias            Property followerRefAlias03 Auto  
ReferenceAlias            Property slaveRefAlias      Auto  

Actor                     Property master             auto
Actor                     Property previousSDMaster   auto
Actor                     Property previousMEMaster   auto
Actor                     Property previousAttacker   auto
Location                  Property previousPlayerHome auto
bool                               masterIsSlaver    ; what was I going to do with this agaim?

int                       Property localBounty        Auto   ; need for dialogue fragments to start jail (how much does player owe caesar? no point calling this function twice

Faction                   Property CurrentFollowerFaction Auto
Faction                   Property slaNaked Auto

;GlobalVariable Property crdeFGreetStatus auto
;GlobalVariable Property crdeInvChange auto     ; this is really frackin hairy, why do I need to use a damn global??

int Property enslaveDialogue        Auto Conditional ; 0 : any, 1 : Local, 2 : Given, 3 : Sold, 4 : Slaverun, 5+ for other mods later
int Property enslavedLevel          Auto Conditional ; 0 : free, 1 : enslaved/always useable, 2 : enslaved/use if vuln, 3 : enslaved/freedom unavailable
int lastEnslavedLevel = 0                   ; not used?
int Property playerVulnerability          Auto Conditional ; 0 : free, 1 : collar, 2 : collar+gag/blindfold, 3 : armbinder
int Property clothingPlayerVulnerability  Auto Conditional
; these notes are out of date

; here so we can look htem up easier in dialogue condition?
Package Property SexApproachPackage Auto
Package Property EnslaveApproachPackage Auto

int  Property frameworkFame          Auto 
bool Property isNude                 Auto Conditional
bool Property isIndecent             Auto Conditional; used if player is nude in big 'moral' city (illegal)
bool Property slaverunInEnforcedLoc  Auto Conditional ; vulnerable in slaverun
bool Property isLocallyWanted        Auto Conditional; if player has a bounty in local area
bool Property isArrestable           Auto Conditional; is POx installed? because fuck you skyrim for not letting me directly referen
;bool Property wasGivenSexItem        Auto
bool Property wasInCombat            Auto
bool Property hasMetIntimidateReq    Auto Conditional
bool Property hasMetPersuasionReq    Auto Conditional
bool Property hasFollowers           Auto Conditional
bool Property hasSlaveFollowers      Auto Conditional

bool Property weaponProtected          Auto Conditional
bool Property wearingArmbinder       Auto Conditional
bool Property wearingBlindfold       Auto
bool Property wearingCollar          Auto Conditional
bool Property wearingGag             Auto Conditional
bool Property wearingPiercings       Auto ; visible, takes nudity into account
bool Property wearingHarness         Auto Conditional
bool Property wearingSlaveBoots      Auto
bool Property wearingBukkake         Auto Conditional; visible, takes nudity into account
bool Property wearingAnkleChains     Auto Conditional

; Keyword     Property SexlabAnalCum  Auto
; Keyword     Property SexlabVaginalCum Auto 
; Keyword     Property SexlabOralCum Auto  
MagicEffect Property SexLabCumOralEffect Auto   
MagicEffect Property SexLabCumVaginalEffect Auto   
MagicEffect Property SexLabCumAnalEffect Auto   
bool        Property sexFromDEC Auto ; was DEC what called this sexlab session?
bool        Property sexFromDECWithoutAfterAttacks Auto ; but do we not want attackers afterwards? (friendly?)
bool        Property sexFromDECWithBeltReapplied Auto

int   Property playerContainerOpenCount Auto

; temporary, loaded from the follower through storage util when we want to be approached
Float Property  follower_enjoys_dom         Auto Conditional      
Float Property  follower_enjoys_sub         Auto Conditional   
Float Property  follower_thinks_player_dom  Auto Conditional   
Float Property  follower_thinks_player_sub  Auto Conditional
Float Property  follower_frustration        Auto Conditional
bool property   follower_can_remove_belt    Auto Conditional
bool property   follower_attack_cooldown    Auto Conditional
int  property   follower_attack_type        Auto Conditional

; how many times has sex been denied?

; we should probably reduce these to conditions, since they are faster
bool wearingBlockingGag     = false Conditional
bool wearingBlockingAnal    = false Conditional
bool wearingBlockingVaginal = false Conditional
bool wearingBlockingBra     = false Conditional
bool wearingBlockingFull    = false Conditional

armor knownArmbinder
armor knownBlindfold
armor knownCollar
armor knownGag

bool    Property forceGreetIncomplete   Auto Conditional
int     Property forceGreetSlave        Auto Conditional
int     Property forceGreetSex          Auto Conditional
int     Property forceGreetWanted       Auto Conditional
; 1 is items, 10 is being hit by player and wanting to talk to them
int     Property forceGreetFollower     Auto Conditional

form[] Property followerFoundDDItems Auto
objectReference[] Property followerFoundDDItemsContainers Auto
bool followerItemsArraySemaphore
int followerFoundDDItemsIndex

FormList property permanentFollowers Auto 

;   last edited: 2018-1-29 , there is another list in ItemScript with the same info
; -------------------------------------------------------------------------------------------------
;   0 is random single item, 1 is random collar
;-  2 is plug and extra, 3 is belt and extra                 DEPRECATED
;   4 is gloves and boots, 5 is other boots, 6 cuffs
;   7 is blindfold, 8 is armbinder,  
;   10 is random ringgag, 11 is random ball gag, 12 is random panel gag, 13 is random any gag
;   14 is rubber suit, 15 is red suit, 16 is pony suit,
;   21 nipple piercings, 22 vag/cock piercing, 23 random, 24 both
;   30 is random unique collar
;   31 is pet collar
;   40 is random CDx items
;   50 is random plug, 51 is random plug and more, 52 is random gem plug and more
;   55 is random belt and more, 56 is random harness and more

int Property followerItemsCombination   Auto Conditional
int Property followerItemsWhichOneFree  Auto Conditional

Float           CurrentGameTime         = 0.0
Float Property  timeoutGameTime         = 0.0 Auto  ; used if we need a temporary time out
Float Property  busyGameTime            = 0.0 Auto  ; used to timeout dhlp suspend in the event something happens
Float Property  timeoutEnslaveGameTime  = 0.0 auto
Float           timeoutSexGameTime      = 0.0
Float           timeoutFollowerApproach = 0.0
float Property  timeoutFollowerNag      = 0.0 Auto Conditional

float           timeExtraVulnerableEnd  = 0.0   ; if the player is extra vulnerable for a certain amount of time, this is when it should end for the area
location        timeExtraVulnerableLoc  = None

ImageSpaceModifier property LightFade auto ; fade back to light, to counter the simpleslavery bug for now

bool threadBusy   = false
bool isPlayerBusy = false ; checking for other mods

Event OnUpdate()
  if(MCM.gCRDEEnable.GetValueInt() == 0) ; mod is off
  
    clear_force_variables() 
    RegisterForSingleUpdate(MCM.fEventInterval * 2)
  else
    if player.IsInCombat() 
      if forceGreetIncomplete
        debugmsg("player in combat, was being approached, cancelling", 1)
        clear_force_variables()
      endif
      if !wasInCombat
        debugmsg("player in combat, busy...", 1) ; only show this once, no need to spam
        wasInCombat = true
        Utility.Wait(MCM.fEventInterval)
      endif
      RegisterForSingleUpdate(MCM.fEventInterval)
    elseif wasInCombat == true ;&& not in combat, but we can't get here if this is false anyway
      wasInCombat = false
      debugmsg("player has left combat, DEC will resume next cycle ...", 1)
      RegisterForSingleUpdate(5)
      ; while we wait, lets check if player has a master and hit them at all
      if masterRefAlias != None
      ; TODO
      endif
      
    else ; not a combat situation
      float onupdatetimeteststart = Utility.GetCurrentRealTime()
      CurrentGameTime             = Utility.GetCurrentGameTime() ; use gametime, since realtime gets reset per game session, cannot work through game saves
      ; approach is already active, test for reset
      if forceGreetIncomplete    
        if busyGameTime < CurrentGameTime ; took too long, reset
          Mods.dhlpResume()
          ;attackerRefAlias.ForceRefTo(previousAttacker)
          if MCM.bDebugLoudApproachFail && (forceGreetSex || forceGreetSlave) ; these should get cleared at the first dialogue entrance
            Debug.Messagebox("DEC/CRDE: Approach failed, you were being approached by (" + previousAttacker.GetDisplayName() + ") for " + MCM.iApproachDuration + " in-game minutes")
          endif
          debugmsg("force greet failed, ran out of time", 1)
          clear_force_variables(true)
        endif
      endif
      
      ; no approach active, lets attempt a new one
      bool completedApproach = false ; this was used for debugging, to detect when a thread gets stuck
      ; and papyrus complains if we don't store the value of a function return
      ; thread semephore, attempt to keep only one instance running at once, TODO remove, all instances get their own variable
      if threadBusy == false
        threadBusy   = true
        ;debugmsg("global search range: " + MCM.gSearchRange.GetValueInt()) 
        completedApproach = attemptApproach() ; roll and everything else moved into this one function, simplifies this onUpdate
        threadBusy = false
      endif
      
      debugmsg("OnUpdate time:" + (Utility.GetCurrentRealTime() - onupdatetimeteststart)) ; measuring time for searching
      
      if forceGreetIncomplete
        RegisterForSingleUpdate(2) ; boosted to 2 seconds in 13.10; 5 seconds, faster because we want to catch conditions, for now static
      else
        RegisterForSingleUpdate(MCM.fEventInterval)
      endif

      ; has the user set any debug options? these run after we've already set the schedule for next run
      tryDebug()
      
    endif
    
    ; removed in 13.13.7, hasn't been seen in months/years, just a waste of CPU cycles
    ; TODO this seems to not fire, but I need to double check
    ; it SHOULDN'T fire, but that's 90% of error code for ya
    ;actor tmpActor = Game.GetPlayer()
    ;if tmpActor != player
    ;  debugmsg("Player alias has changed! Resetting ...", 5) ; good to know this doesn't seem to change, still
    ;  player = tmpActor
    ;endif
    
  endif
   
EndEvent

Event OnInit()
  player = Game.GetPlayer()
  PlayerScript = (playerScriptAlias as crdePlayerScript) ; hopefully, this will reduce papyrus load
  Utility.wait(6)
  while Mods.finishedCheckingMods == false
    Debug.Trace("[crde]in player:mods not finished yet", 1)
    Utility.wait(2) ; in seconds
  endWhile
  Maintenance() 
  RegisterForSingleUpdate(3)
EndEvent

function Maintenance()
  PlayerScript.equipmentChanged = true ; start out checking equipment regardless of what it could be
  ;cdGeneralFactionAlias = Mods.cdGeneralFaction as Alias
  RegisterForModEvent("HookAnimationStart", "crdeSexStartCatch")
  RegisterForModEvent("HookAnimationEnd", "crdeSexHook")
  RegisterForModEvent("DeviceActorOrgasm", "playerOrgasmsFromDD") ; orgasm
  RegisterForModEvent("DeviceEdgedActor", "playerEdgedFromDD") ; edged? meaning halfway?
  RegisterForModEvent("DeviceEvent", "playerHornyFromDD")
  followerFoundDDItems = new form[32]
  followerFoundDDItemsContainers = new objectReference[32]
  ;settings.resetValues()
endFunction

; if we start sex, call clear force variables so we can stop an approach
; also catch all sex if user specifices for rape/device/ect
Event crdeSexStartCatch(int tid, bool HasPlayer);(string eventName, string argString, float argNum, form sender)
  debugmsg("crdeSexStartCatch :AnimationStart ...", 1)
  if forceGreetIncomplete ; should keep the checking to a minimum, at least less often
    Actor[] actorList = SexLab.HookActors(tid as string)
    if actorList != None && actorList.Length >= 2 && (actorList[0] == player  || actorList[1] == player)
      debugmsg("Sexlab started after approach, resetting ...", 1)
      clear_force_variables()
    elseif actorList.Length == 1 && PlayerScript.isZazSexlabFurniture && PlayerScript.sittingInZaz
      debugmsg("player is busy alone in sexlab furniture, resetting approach ...", 1)
      clear_force_variables() ; player is getting tentacled or milked, count this as busy instead of vulnerable
    elseif actorList == None
      debugmsg("Err: sexlabstartcatch has NONE actors", 4) ; shouldn't get this far
    endif
  endif
EndEvent

Event playerOrgasmsFromDD(String eventname, string character_name, float argNum, Form Sender)
  ;DeviceActorOrgasm
  debugmsg("dd orgasm from belt detected: " + character_name)
  if character_name == player.GetDisplayName()
    ; mod arousal for all nearby NPCs
    actor[] a = NPCSearchScript.getNearbyFollowers() ;getNearbyActors() 
    ; increment all thinks sub by two
    adjustPerceptionPlayerSub( a,8)
    timeExtraVulnerableEnd = Utility.GetCurrentGameTime() + (1/48) ; in days, 24 hours half hour (30 minutes)
    timeExtraVulnerableLoc = player.GetCurrentLocation()
    ; increase nearby NPC arousal?
    adjustActorsArousal(a, 20)
  endif
  
EndEvent

Event playerEdgedFromDD(String eventname, string character_name, float argNum, Form Sender)
  debugmsg("dd edge from belt detected: " + character_name)
  if character_name == player.GetDisplayName()
    ; mod arousal for all nearby NPCs
    actor[] a = NPCSearchScript.getNearbyFollowers() ;getNearbyActors() 
    ; increment all thinks sub by two
    adjustPerceptionPlayerSub( a,2,8)
    timeExtraVulnerableEnd = Utility.GetCurrentGameTime() + (1/48) ; in days, 24 hours half hour (30 minutes)
    timeExtraVulnerableLoc = player.GetCurrentLocation()
    ; increase nearby NPC arousal?
    adjustActorsArousal(a, 15)

  endif
  
endEvent

Event playerHornyFromDD(String eventname, string character_name, float argNum, Form Sender)
  debugmsg("dd horny event detected: " + character_name)
  if character_name == player.GetDisplayName()
    ; mod arousal for all nearby NPCs
    actor[] a = NPCSearchScript.getNearbyFollowers() ;getNearbyActors() 
    ; increment all thinks sub by two
    adjustPerceptionPlayerSub( a, 2 , 8)
    timeExtraVulnerableEnd = Utility.GetCurrentGameTime() + (1/48) ; in days, 24 hours half hour (30 minutes)
    timeExtraVulnerableLoc = player.GetCurrentLocation()
    adjustActorsArousal(a, 10)

  endif
  
endEvent

Function clear_force_variables(bool resetAttacker = false)
  ;crdeFGreetStatus.SetValue(0)
  if MCM.bDebugLoudApproachFail && (forceGreetSex || forceGreetSlave)
    debugmsg("cancel approach called, resetting",1)
  endif
  forceGreetSex         = 0 ; just in case we get back in this update while the previous attack is still underway, 
  forceGreetSlave       = 0 ; and player is NOW busy, try using these variables as a cancel
  isIndecent            = false
  isLocallyWanted       = false
  ;sexFromDEC            = false ; removed in 13.13.1 because it would flush at "player busy with sexlab"
  ;debugmsg("resetting sexFromDEC @ 3")

  if forceGreetIncomplete
    Mods.dhlpResume()
    forceGreetIncomplete  = false;
    ;attackerRefAlias.ForceRefTo(player)
    attackerRefAlias.Clear()
    setCRDEBusyVariable(false)  
  endif
  
  if resetAttacker
    ;attackerRefAlias.ForceRefTo(player)
    if attackerRefAlias != None
      attackerRefAlias.Clear()
    endif
    ; removed in 13.11.5, we don't want to reset followers they aren't for approaches anymore
  ;  if followerRefAlias01 != None
  ;    followerRefAlias01.Clear()
  ;  endif
    ;if followerRefAlias02 != None ; we might want to leave these full actually
    ;  followerRefAlias02.Clear()
    ;endif
    ;if followerRefAlias03 != None
    ;  followerRefAlias03.Clear()
    ;endif

    forceGreetFollower    = 0

  endif
  
endfunction

; returns true if busy, else false
bool function isPlayerBusy()
  ;debugmsg("dcur detect:" + Mods.dcurMisogynyDetect.GetValueInt() + ", Cooldown:" + Mods.dcurMisogynyCooldown.GetValueInt() )

  ; removed, reduced approach len
  ;if forceGreetSex || forceGreetSlave ; DEC is busy
  ;  ;debugmsg("dhlp suspend is active, a mod is busy", 1)
  ;  return true
  ;elseif Mods.dhlpSuspendStatus == true && forceGreetIncomplete == false; Deviously helpess suspend status is set
  ;  debugmsg("dhlp suspend is active, a mod is busy", 1)
  ;  return true
  
  if( player.GetCurrentScene() != none )
    debugmsg("Player is in scene, busy", 1)
    return true
    ; disabled in 13.10 as experiment
  elseif   UI.IsMenuOpen("Dialogue Menu")  ;UI.IsMenuOpen("InventoryMenu") |||| UI.IsMenuOpen("ContainerMenu")
     debugmsg("Player is in UI, busy", 1)
    return true
  elseif  SexLab.IsActorActive(player)  
    debugmsg("Player is busy with Sexlab", 1)
    return true
  elseif (!player.getplayercontrols()) ; placed last because I bet it's the slowest response
    debugmsg("Player's controls are locked, busy", 1)
    return true
  endif
  bool boundInFurniture = NPCMonitorScript.checkActorBoundInFurniture(player)
  ;debugmsg("bound status:" + boundInFurniture + " sexlab furn status:" + PlayerScript.isZazSexlabFurniture)
  if MCM.iVulnerableFurniture == 0 && boundInFurniture
    debugmsg("Player is bound in furniture, busy", 1)
    return true
  elseif boundInFurniture && PlayerScript.isZazSexlabFurniture
    debugmsg("Player is bound in sexlab furniture, busy", 1)
    return true
  elseif StorageUtil.GetIntValue(player, "DCUR_SceneRunning") == 1
    debugmsg("Cursed loot scene is running, busy", 1)
    return true
  elseif StorageUtil.GetIntValue(player, "crdeBusyLock") == 1
    debugmsg("CRDE Busy Lock is ON, busy", 1)
    return true
  elseif isBusyDefeat(player) 
    debugmsg("Player is busy: defeat", 1)
    return true
  elseif isBusyMDevious(player)  
    debugmsg("Player is busy: More devious quest", 1)
    return true
  elseif Mods.isPlayerInJail()
    debugmsg("Player is in jail, busy", 1)
    return true
  ;elseif Mods.dcurMisogynyDetect != None && Mods.dcurMisogynyDetect.GetValueInt() == 1 && Mods.dcurMisogynyCooldown.GetValueInt() == 1 ; ZZZ
  ;  debugmsg("Cursed loot Misogyny is active", 1)
  ;  return true
  elseif Mods.modLoadedMariaEden
    if Mods.meWhoresJob == None 
      debugmsg("Maria has no whore job, huh?", 0)
    elseif Mods.meWhoresJob.isRunning()
      debugmsg("Player is whore (ME), busy", 1)
      return true
    endif
  elseif Mods.modLoadedWorkingGirl && player.GetItemCount(Mods.workingGirlJobToken) > 0
    debugmsg("Player is whore (SLWG), busy", 1)
    return true
  elseif Mods.dawnguardLordForm != None && player.HasMagicEffect(Mods.dawnguardLordForm)
    debugmsg("Player is vampire lord/lady, busy", 1)
    return true
  elseif player.GetRace() == WerewolfBeastRace
    debugmsg("Player is Werewolf currently, busy", 1)
    return true
  endif
  return false ; for now
endfunction

; check if the player has visible (nudity) Bukakke
function CheckBukkake()
  if isNude  && (player.HasMagicEffect(SexLabCumAnalEffect) || player.HasMagicEffect(SexLabCumVaginalEffect))
    wearingBukkake = true
    return none
  endif
  if Player.HasMagicEffect(SexLabCumOralEffect)
    wearingBukkake = true
    return none
  endif
  wearingBukkake = false
endFunction

; moving chastity checking here, since it fits the function name and they both have to be checked at the same time
; moving maria collar check here, not sure why it was in vulnerability check, should have been here all along
; this is for vulnerability, not for enslave status
; fuck the keyword array, I can't seem to change it on my end, and unless you add comments, it's hard to know what each one is
Function CheckDevices()
  debugmsg("checking devices ...", 1)
  updateWornDD()
  isWearingChastity()  ; ignore result, it's legacy, saving as local variable makes the stack heavier
  
  ; testing, is MUCH smaller, not that much harder to read
  ; keywords = armbinder, blindfold, collar, worncollar, devious gag, worn gag[5]
  wearingArmbinder  = player.WornHasKeyword(libs.zad_DeviousArmbinder) || player.wornHasKeyword(libs.zad_DeviousYoke); || player.WornHasKeyword(Mods.zazKeywordAnimWrists)
  wearingBlindfold  = player.WornHasKeyword(libs.zad_DeviousBlindfold)
  wearingCollar     = player.WornHasKeyword(libs.zad_DeviousCollar)  || (Mods.modLoadedMariaEden && player.WornHasKeyword(Mods.meCollarKeyword)) || (Mods.modLoadedParadiseHalls && player.WornHasKeyword(Mods.paradiseSlaveRestraintKW))
  wearingGag        = player.WornHasKeyword(libs.zad_DeviousGag) || player.WornHasKeyword(Mods.zazKeywordWornGag)
  wearingSlaveBoots = player.WornHasKeyword(libs.zad_DeviousBoots)
  wearingHarness    = player.WornHasKeyword(libs.zad_DeviousHarness)
  wearingPiercings  = player.WornHasKeyword(libs.zad_DeviousPiercingsNipple) || player.WornHasKeyword(libs.zad_DeviousPiercingsVaginal)
  wearingAnkleChains = player.WornHasKeyword(libs.zad_BoundCombatDisableKick) || player.WornHasKeyword(Mods.zazSlowMove) ; todo get ankle chains
  
  PlayerScript.equipmentChanged = false
  
  ; || player.WornHasKeyword(deviceKeywords[3]) <<- this was under collar detection, what was this keyword again? really wish I had a better IDE
  
EndFunction

; called from the loop, but assume other locations can call
; guard chat also checks vulnerability, but that's handled separately because we only need to check when the equipment changes
function CheckGuardApproachable()
  if Mods.modLoadedPrisonOverhaul && MCM.bGuardDialogueToggle
    ; get user hold location, bounty
    ;Faction localFac    = (Mods.xazMain as xazpEscortToPrison).FindCurrentHoldFaction()
    ;localBounty = localFac.GetInfamy() 
    ;localBounty = (Mods.xazMain as xazpEscortToPrison).FindCurrentHoldFaction().GetInfamy()  ; greeeeeat this was stopping creation kit from loading variables 
    ;isLocallyWanted = (localBounty > 0 && playerVulnerability > 0) || localBounty > 99 
    ;if  (localBounty > 0 && playerVulnerability > 0) || localBounty > 99 
    ;  isLocallyWanted = true
    ;  ;return true
    ;else
    ;  isLocallyWanted = false 
    ;endif
    ; if user is nude in big city (moral city with stick up their butt)
    WorldSpace curSpace = player.GetWorldSpace() 
    isIndecent = isNude && ( curSpace == solitudeSpace || curSpace == windhelmSpace ); player is in certain cities )
    ;if  isNude && ( curSpace == solitudeSpace || curSpace == windhelmSpace ); player is in certain cities )
    ;  isIndecent = true
    ;else
    ;  isIndecent = false
    ;endif
   
    ; faction.GetCrimeGold() or faction.GetInfamy()
    ; if bounty is > 
  else  
    isLocallyWanted = false ; for now, we do nothing, but we need to reset these so that they don't stick to false
    isIndecent      = false
  endif
  
endFunction

; why? because beth didn't bother with ternary
int function largestInt(int a ,int b)
  if a > b
   return a
  else
   return b
  endif
endFunction

; only checks the vulnerability of the player on part of what they wear, 
;  we can separate this part because we can detect when the player's clothes change dynamically
; TODO this needs to be updated after we switched from vulnerability toggle to levels
function updateEquippedPlayerVulnerability(bool isSlaver = false)
  debugmsg("updating clothing vulnerability ...", 1) ; too often used, spam; not anymore, less used
  
  CheckDevices()
      
      
  ; regular first, then non-naked sensitive
  int[] vulnerableValues = new int[16] ; depends on how many we have
  vulnerableValues[0] = MCM.iVulnerableNaked * ((isNude || isSlaver) as int) 
  vulnerableValues[1] = MCM.iVulnerableCollar * (wearingCollar as int)          
  vulnerableValues[2] = MCM.iNakedReqCollar * (wearingCollar && (isNude || isSlaver)) as int
  vulnerableValues[3] = MCM.iVulnerableGag * (wearingGag as int)                
  vulnerableValues[4] = MCM.iNakedReqGag * (wearingGag && (isNude || isSlaver)) as int
  vulnerableValues[5] = MCM.iVulnerableBukkake * (wearingBukkake as int)
  vulnerableValues[6] = MCM.iNakedReqBukkake * (wearingBukkake && (isNude || isSlaver)) as int
  vulnerableValues[7] = MCM.iVulnerableHarness * (wearingHarness as int)
  vulnerableValues[8] = MCM.iNakedReqHarness * (wearingHarness && (isNude || isSlaver)) as int
  vulnerableValues[9] = MCM.iVulnerablePierced * (wearingPiercings as int)
  vulnerableValues[10] = MCM.iNakedReqPierced * (wearingPiercings && (isNude || isSlaver)) as int
  vulnerableValues[11] = MCM.iVulnerableAnkleChains * (wearingAnkleChains as int)
  vulnerableValues[12] = MCM.iNakedReqAnkleChains * (wearingAnkleChains && (isNude || isSlaver)) as int
  vulnerableValues[13] = MCM.iVulnerableSlaveBoots * (wearingSlaveBoots as int)
  vulnerableValues[14] = MCM.iVulnerableArmbinder * (wearingArmbinder as int)
  vulnerableValues[15] = MCM.iVulnerableBlindfold * (wearingBlindfold as int)
  
  int largest = 0
  int num2    = 0
  int num3    = 0
  int i = 0
  while i < vulnerableValues.length
    if vulnerableValues[i] > 0
      if vulnerableValues[i] == 2
        num2 += 1
      elseif vulnerableValues[i] == 3
        num3 += 1
      endif
      debugmsg ("vul #" + i + " is currently:" + vulnerableValues[i])
      if vulnerableValues[i] > largest
        largest = vulnerableValues[i]
        debugmsg ("new big: " + vulnerableValues[i])
      endif
    endif
    i += 1
  endWhile
   
  if num3 + 2*(num2) >= 5
    clothingPlayerVulnerability = 4
    ;return
  else
    clothingPlayerVulnerability = largest
    ;return
  endif
   
  ; int heavyItemCount =  (((wearingArmbinder == true && MCM.iVulnerableArmbinder) as int) * 2) + \
                        ; ((wearingBlindfold && MCM.iVulnerableBlindfold) as int) + \
                        ; (( wearingGag && MCM.iVulnerableGag  ) as int) +\
                        ; ((wearingBlockingFull && isNude) as int) +\
                        ; ((MCM.iVulnerableSlaveBoots && wearingSlaveBoots)as int) +\
                        ; (player.HasKeyword(Mods.zazKeywordEffectOffsetAnim) as int) +\
                        ; ((isTattooVulnerable && (isNude || !MCM.iNakedReqSlaveTattoo || isSlaver)) as int) +\
                        ; (wearingAnkleChains as int) 

  ;if heavyItemCount >= 3
  ;  clothingPlayerVulnerability = 4
  ;  return 
  ;endif
 
endFunction 

; 0 not vulnerable, range: 1 - 4 are levels of vulnerable for clothing, where several factors can make it rise
function updatePlayerVulnerability(bool isSlaver = false) 
  isNude(player)            ; sets the class scope variable
  
  ; TODO are we sure everything is here and not in equipped check function?
  
  ; where positive fame is 1 for having an INCREASE for each of the three fields
  ; and negative if 
  
  int furnitureLocked             = (MCM.iVulnerableFurniture && NPCMonitorScript.checkActorBoundInFurniture(player)) as int
  int temporaryVulnerableIncrease = (CurrentGameTime < timeExtraVulnerableEnd && player.GetCurrentLocation() == timeExtraVulnerableLoc) as int
  int nightAddition               = ((isNight() as int) * (MCM.bNightAddsToVulnerable as int))
  ; ZZZ
  
  int frameworkFameIncrease = 0
  int frameworkFameAlways   = 0 
  if Mods.modLoadedFameFramework ; && Mods.metReqFrameworkMakeVuln() >= 1
    frameworkFameIncrease   = ((Mods.metReqFrameworkIncreaseVuln() > 1) as int)
    frameworkFameAlways     = Mods.metReqFrameworkMakeVuln()
  endif
  
  if Mods.modLoadedSlaverunR || Mods.modLoadedSlaverun
    slaverunInEnforcedLoc = SlaverunScript.PlayerIsInEnforcedLocation()
  endif
  
  ;if PlayerScript == none
  ;  debugmsg("playerscript is none")
  ;endIf ; shouldn't happen anymore, has been long enough most users shouldn't run into this error anymore
  if PlayerScript.equipmentChanged == true ; equipment has changed
    updateEquippedPlayerVulnerability(isSlaver)
    ;CheckGuardApproachable() 
    
  ; the following can happen now in THIS function without checking equippment 
  ;elseif PlayerScript.sittingInZaz ; else if because we don't need to check if gear was already checked. will get caught regardless
  elseif PlayerScript.releasedFromZaz
    PlayerScript.releasedFromZaz = false
  
  ; this was commented out because slaver no longer counts for vulnearbility function until I go back and fix it
  ;elseif isSlaver && playerVulnerability < 2
  ;  ; ??? confused, did we want to increase vulnerability if they are a slaver and they are only lvl 1? shouldn't this be MCM dependant instead of static?
  ;  debugmsg("slaver found, double checking playerVulnerability" , 3)
  ;  updateEquippedPlayerVulnerability(isSlaver)
  endif
    
  
  ; equipped vulnerability should be updated by this point, lets check tattos
  int tempClothingPlayerVulnerability = clothingPlayerVulnerability
  if Mods.modLoadedSlaveTats
    int[] tatVulLvls = new int[4]
    tatVulLvls[0] = MCM.iVulnerableSlaveTattoo * (SlavetatsScript.wearingSlaveTattoo as int)
    tatVulLvls[1] = MCM.iNakedReqSlaveTattoo * (SlavetatsScript.wearingSlaveTattoo && isNude) as int
    tatVulLvls[2] = MCM.iVulnerableSlutTattoo * (SlavetatsScript.wearingSlutTattoo as int)
    tatVulLvls[3] = MCM.iNakedReqSlutTattoo * (SlavetatsScript.wearingSlutTattoo && isNude) as int
    int i = 0
    while i < 4
      if tempClothingPlayerVulnerability < tatVulLvls[i]
        debugmsg("Slavetats vul discovered: " + tatVulLvls[i], 3)
        tempClothingPlayerVulnerability = tatVulLvls[i]
      endif
      i += 1
    endWhile
  endif
  
  CheckBukkake()  ; was originally called AFTER this updatePlayerVulnerability, but always only after an equippment change
                  ; (old assumption:) player would undress and dress for/after sex
                  ; I think we can leave this running all the time now
  int bukkakeVulnerable   = (MCM.iVulnerableBukkake && wearingBukkake && !(MCM.iNakedReqBukkake && !isNude)) as int

  int situationalIncrease = frameworkFameIncrease + nightAddition + temporaryVulnerableIncrease + bukkakeVulnerable


  playerVulnerability = tempClothingPlayerVulnerability + situationalIncrease
  if situationalIncrease > 0
    debugmsg("situational(sex fame/night/temporary event/bukkake): (" + frameworkFameIncrease + "/" + nightAddition + ":" + temporaryVulnerableIncrease + ":" + bukkakeVulnerable + ")")
  endif
  debugmsg("vuln lvl(clothing/situation/total): (" + tempClothingPlayerVulnerability + ":" + situationalIncrease + ":" + playerVulnerability + ")")
  
  
  ; extra cases, to compensate for not being in clothing detection anymore:
  if playerVulnerability > 4
    playerVulnerability = 4 ; not sure if this is n
  elseif playerVulnerability == 0 && frameworkFameAlways == 1
    playerVulnerability = 1
  endif
  
endFunction

; This gets called by fragments after the approach and dialogue
; after the npc has already reached you
; attemptLocalEnslavement / enslaveLocal <- better names, but changing might break fragments, too much work, fuck CK
; it doesn't actually look like we need to return bool here, since it always gets called by fragments it seems
bool function attemptEnslavement(actor masterRef, bool skipMsg = false)
  clear_force_variables(true)
  Mods.dhlpResume() ; approach is over, for now we'll leave this up here
  ;debugmsg("Entered attemptLocalEnslavement", 1) ; <- shouldn't be needed
  
  if masterRef == None
    debugmsg("Err: attemptEnsl::masterRef is None" ,5) ; TODO: how can this happen? maybe the fragments are broken...
    return false
  endif
  
  if PlayerScript.sittingInZaz ; if player is tied up in furniture, move the player to the attacker, avoids sex/scene clipping into furniture
    player.moveTo(masterRef)
  endif

  if(attackerRefAlias.GetActorReference() != player && masterRef.isDead() == false && masterRef.isChild() == false && \
    masterRef.isPlayerTeammate() == false && masterRef.isAIEnabled() == true); && masterRef.getRace().isPlayable() == true)
    ; shouldn't most of these checks be taken care of by the time we get here, since we should already have checked this stuff by now?
    if(masterRef.getDistance(player) < 500)
      ;timeoutEnslaveGameTime = CurrentGameTime + MCM.fEventTimeout 
      if(skipMsg == false)
        debugmsg("Seeing you so helpless, " + masterRef.getDisplayName() + " decides to keep you as their slave.", 5)
      endif
      ;totalWeight = MCM.iEnslaveWeightSD + MCM.iEnslaveWeightMaria
      ;int roll = Utility.RandomInt(0,totalWeight)
      ; left these here in case we get a third option, but for now keeping it dymanic means fewer stack variables
      int newSD     = MCM.iEnslaveWeightSD * ((Mods.modLoadedSD && MCM.bSDEnslaveToggle) as int)
      int newMaria  = MCM.iEnslaveWeightMaria * ((Mods.modLoadedMariaEden && MCM.bMariaEnslaveToggle) as int)
      int roll      = Utility.RandomInt(1, newSD + newMaria ) 
      int total     = newSD + newMaria
      debugmsg("local roll SD , Maria / Total: " + newSD + " , " + newMaria + " / " + total, 2)
      if total == 0
        debugmsg("enslave local: total is zero, no SD + Maria?", 4)
        ItemScript.equipRandomDD(player)
        return false
      endif
      if  roll <= MCM.iEnslaveWeightSD  
        debugmsg("Starting SD", 1)
        Mods.clearHelpless()
        Mods.enslaveSD(masterRef)
        return true
      else ;maria       ;masterRef.GetActorValue("Aggression") <= 1)
        ItemScript.removeDDs()
        debugmsg("Starting ME", 1)
        Mods.clearHelpless()
        Mods.enslaveME(masterRef)
        return true
      ;else
        ;debugmsg("enslave local: roll is out of range", 4) ; shouldn't get this far, might explain why I haven't seen this error yet
        ; No known enslavement mod, just going to add items (or not)
        ;ItemScript.equipRandomDD(player)
      endif
    else
      debugmsg("attemptEnslavement err: master is too far away", 5)
    endif
  else
    debugmsg("attemptEnslavement err: master is dead/child/teammate", 5)
  endif
  return false
endFunction

; does this really only just take your stuff/add items? 
; bad function name, describes where it's used not what it does
function tryNonEnslaveSexEnding(actor actorRef)
  int rollKeys = Utility.RandomInt(1,100)
  int rollDevices = Utility.RandomInt(1,100)

  ;string msgRoll = "keys: " + rollKeys + " / devices: " + rollDevices
  ;debugmsg("keys: " + rollKeys + " / devices: " + rollDevices, 2)
  debugmsg(("post sex: stealkeys/devices: (" + rollKeys + "/" + rollDevices \
           +") needed (under): (" + MCM.iSexEventKey+ "/" + MCM.iSexEventDevice +" )"), 2)

  ;timeoutEnslaveGameTime = Utility.GetCurrentGameTime() + MCM.fEventTimeout
  
  if(rollKeys < MCM.iSexEventKey)
    Debug.Notification(actorRef.getDisplayName() + " searches you for any keys and removes them.")
    ItemScript.stealKeys(actorRef)
  endif
  if rollDevices < MCM.iSexEventDevice ; && enslavedLevel == 0) was I asleep when I decided you need to be un-enslaved to get items?
    ;ItemScript.equipRandomDD(actorRef) ; hang on, actorRef is the attacker, not the player
    ItemScript.equipRandomDD(player)
  endif
endFunction

bool function tryEnslavableSexEnd(actor actorRef)
  float rollEnslave = Utility.RandomInt(1,100) * ((Mods.canRunLocal() || DistanceEnslave.canRunSold() || DistanceEnslave.canRunGiven()) as int) * (( enslavedLevel == 0 ) as int)
  float rollDevice  = Utility.RandomInt(1,100)

  if(Mods.isSlaveTrader(actorRef)) 
    rollEnslave = rollEnslave / MCM.fModifierSlaverChances 
    rollDevice  = rollDevice  / MCM.fModifierSlaverChances
  endif

   debugmsg(("post rape: enslave/devices: (" + rollEnslave + "/" + rollDevice \
           +") needed (under): (" + MCM.iRapeEventEnslave+ "/" + MCM.iRapeEventDevice +" )"), 2)
  
  ;bool attempt = false
  if(rollEnslave != 0 && rollEnslave < MCM.iRapeEventEnslave )
    debugmsg("post rape: enslave roll won, attempting enslavement", 2)
    ; decide what kind of enslavement we want
    if DistanceEnslave.enslavePlayer(actorRef) ; attempt was successful
      timeoutEnslaveGameTime = Utility.GetCurrentGameTime() + MCM.fEventTimeout
      return true
    endif
    ; otherwise keep going, maybe items?
  endif
  
  if(rollDevice < MCM.iRapeEventDevice && enslavedLevel == 0)
    debugmsg("post rape: device roll was high enough, adding items to player", 2)
    ItemScript.equipRandomDD(player) ; this used to be actorRef
    return true
  endif
  ;debugmsg("post rape: roll out of range, no rape", 2) ; not an error, this just means no enslave today
  return false
endFunction

; I know this function is huge, but since papyrus doesn't likely inline functions...
; TODO: move follower to a different subfunction, I think that at least is reasonable
bool function attemptApproach()
  ; isbusy -> enslavelvl -> nearest -> (follower chance) -> roll(need nearest for slave trader modifier) -> vulnerability check -> attempts
  ; roll is fastest, busy is second fastest. nearest is slowest. Nearest before roll only because we need nearest for follower,
  ; this function should be reorganized so that roll is first or second, it's massively faster, no point searching for NPCs if we roll too low.
  
  if( CurrentGameTime <= timeoutGameTime) ; TODO: Move this further up, we shouldn't check if the player is timed out AFTER doing everything that is expensive
    debugmsg("dec is in timeout, going back to sleep for " + (timeoutGameTime - CurrentGameTime) + " mins",1)
    return false
  endif
  
  ; test if player is busy
  isPlayerBusy  = isPlayerBusy()
  if isPlayerBusy ; lets test this sooner, fewer moot cycles
    clear_force_variables(true) 
    return false ; if busy, nothing else to do here, leave
  ; while being approached, look for stuff to make sure we haven't broken approach
  elseif forceGreetIncomplete ;&&  attackerRefAlias != None && attackerRefAlias.GetActorRef() != player ; removed in 13.10
    ; recheck vulnerability here too for weapons
    actor tmp = attackerRefAlias.GetActorRef()
    float timeLeft = (busyGameTime - CurrentGameTime) * 1400
    if tmp 
      if playerIsWeaponDrawnProtected() || isWeaponProtected()
        debugmsg("player spooked off the attacker with weapon: " + tmp.GetDisplayName() ,1)
        clear_force_variables(true)
        return false 
      else
        debugmsg("ForceGreet incomplete, " + timeLeft + " GMins remaining, approached by " + tmp.GetDisplayName() ,1)
      endif
    elseif followerRefAlias01.GetActorRef()
      debugmsg("ForceGreet incomplete, " + timeLeft + " GMins remaining, approached by " + followerRefAlias01.GetActorRef().GetDisplayName() ,1)
    else
      debugmsg("ForceGreet incomplete, " + timeLeft + " GMins remaining, approached by NULL actor???"  ,1)
    endif
    return false ; approach in progress, just don't do anything else here, but no reset
  endif
  
  bool isNight        = isNight()
  float rollModifier  = 1
  if isNight              
    rollModifier      = MCM.fNightChanceModifier    ; this is why god made ternary operators bethesuda
  endif 
  
  ; ROLL for enslave/sex, maybe later I'll re-use the roll for follower? It's still a random number if I don't modify
  float rollEnslave  = Utility.RandomInt(1,100) / rollModifier
  ;float rollTalk    = Utility.RandomInt(1,100) 
  float rollSex      = Utility.RandomInt(1,100) / rollModifier
  
  ; pre-check if the roll with slaver modifier still has 0 percent chance, 
  ;  worth checking early because it would save us lots of CPU time for the cost of very minor math and a few compares
  if  ( (rollEnslave  / MCM.fModifierSlaverChances) > MCM.iChanceEnslavementConvo || playerVulnerability < MCM.iMinEnslaveVulnerable )  \
     && (rollSex     / MCM.fModifierSlaverChances) > MCM.iChanceSexConvo 
    debugmsg("Rolled too low (pre-check with modifier), stopping",3)
  endif
  
  enslavedLevel  = Mods.isPlayerEnslaved() ; run this early so we know to quit early, without resetting the NPC quest so no aliases hopefully
  if enslavedLevel >= 3
    debugmsg("Player is busy slave, cannot be approached, leaving early",1)
    ; maybe stop the NPC quest if this happens? but we only want to stop it once, which means detecting it the first time only
    return false
  endif

  ;clear_force_variables(); not sure this is needed anymore
  forceGreetSex     = 0
  forceGreetSlave   = 0
  
  follower_attack_cooldown = (CurrentGameTime >= timeoutFollowerApproach + (120 * (1.0/1400.0))) ; this is the cooldown release
  
  if (playerScriptAlias as crdePlayerScript).weaponChanged == true 
    isWeaponProtected() ; save it for later
    (playerScriptAlias as crdePlayerScript).weaponChanged == false
    ;CheckGuardApproachable()
  endif
  
  ; moved this later, since it takes a long time
  actor[] nearest
  if MCM.bAlternateNPCSearch
    nearest = NPCMonitorScript.getClosestActor(player)
    debugmsg("closest npcs: " + nearest) 
  else
    NPCMonitorScript.printNearbyValidActors() 
    nearest = NPCMonitorScript.getClosestRefActor(player)
  endif
  actor[] followers = NPCSearchScript.getNearbyFollowers()
  
  location player_loc = player.GetCurrentLocation()
  ; if player has followers
  if  MCM.bFollowerDialogueToggle.GetValueInt() == 1 \
    && followers[0] != None && timeoutFollowerNag < CurrentGameTime \
    && (nearest.length <= 1 || player_loc && player_loc.haskeyword(LocTypePlayerHouse)) 

    return attemptFollowerApproach(followers)
    
    ; changed in 13.12
  elseif followers[0] == None ; no followers nearby
    if forceGreetFollower
      clear_force_variables(true)
      ;forceGreetFollower = 0 ; forceclear instead
    endif
    playerContainerOpenCount = 0 ; no followers, nobody saw anything
  else ; if follower and alone or at home  
    ; STOP the item approach, probably sex approach too
    forceGreetFollower = 0
  endif  
    
  int i = 0
  hasFollowers = false
  actor tmp = None
  while i < followers.length && hasFollowers == false
    tmp = followers[i]
    if tmp != None && tmp.IsInFaction(CurrentFollowerFaction) && \
     !NPCMonitorScript.isWearingSlaveDD(tmp) && !Mods.isSlave(tmp) ; 13.11: we don't count followers if they are slaves
      hasFollowers = true
    endif
    i += 1
  endWhile
  ;hasFollowers  = NPCSearchScript.getNearbyFollowersInFaction(followers) ; unnecessary, we aren't saving variables here
  
  ; TODO move this up to the nearest and side checks, no reason to let it sit here this long when we can leave earlier
  if nearest[0] == None
    debugmsg("No nearby NPCs, leaving early", 3)
    return false
  endif

  bool isSlaver = Mods.isSlaveTrader(nearest[0]) ; moved up so we can 
      
  ; we're modifying the roll result, making it smaller so it's more likely to fit inside of the line,
  ;  rather than confuse the user with a moving goal post that won't match their input
  if isSlaver
    rollEnslave   = (rollEnslave      / MCM.fModifierSlaverChances)
    ;rollTalk       = (rollTalk          / MCM.fModifierSlaverChances)
    rollSex       = (rollSex          / MCM.fModifierSlaverChances)
  endif
  
  updatePlayerVulnerability(isSlaver)

  ; if wearingPartialChasity
  ; use two variables set by the full check function, then you can test either or
  ; partial results in some increase?
  ; bool isWearingChastity = isWearingChastity()
  if MCM.bChastityToggle
    ; if attacker has keys, increase all chances
    ; else, no keys, sex = 0
    debugmsg("Checking chastity ...", 3)
    debugmsg("chastity:" + wearingBlockingFull + ": a:" + wearingBlockingAnal + " b:" + wearingBlockingBra + " g:" + wearingBlockingGag, 3)
    if wearingBlockingFull 
      ; all items
      if (nearest[0].GetItemCount(libs.chastityKey) > 0 && !libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousBelt).HasKeyword(libs.zad_BlockGeneric)) \
      || (nearest[0].getItemCount(libs.restraintsKey) > 0 && !libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousGag).HasKeyword(libs.zad_BlockGeneric))
        rollSex     = rollSex     /  MCM.fChastityCompleteModifier
      else 
        rollSex     = 101         ; impossible, put the needed number out of reach
      endif
      ;rollTalk       = rollTalk    /  MCM.fChastityCompleteModifier
      rollEnslave   = rollEnslave /  MCM.fChastityCompleteModifier
    elseif wearingBlockingAnal || wearingBlockingVaginal || wearingBlockingBra; || wearingBlockingGag
      ; partial chastity, but not complete
        rollSex       = rollSex     /  MCM.fChastityPartialModifier
        ;rollTalk       = rollTalk    /  MCM.fChastityPartialModifier
        rollEnslave   = rollEnslave /  MCM.fChastityPartialModifier
    endif
    ; do nothing, not wearing chastity
  endif

  debugmsg("approachroll enslave: " + rollEnslave + " / sex: " + rollSex + " / a: " + nearest[0].GetDisplayName(), 2)
  
  
  ;old isplayerenslaved location
  debugmsg("slave lvl: " + enslavedLevel + " weapon: " + weaponProtected as int , 3) 
  
  if weaponProtected
    debugmsg("Player is holding weapon or robed, protected", 3)  
    return false
  elseif playerIsWeaponDrawnProtected()
    debugmsg("Player is waving a weapon or spell, protected", 3)  
    return false
  endif
  
  ;     (weaponProtected == false || (weaponProtected && MCM.iWeaponHoldingProtectionLevel < playerVulnerability)) && \
  ;   (isWeaponProtected()) && \

  if enslavedLevel != 3 && (playerVulnerability > 0 || enslavedLevel == 1) && \
     forceGreetIncomplete == false 
    
    ;updateMaster()
    float actorMorality   
    float reqConfidence
    float actorConfidence
    int isNightReduction  = (isNight as int) * MCM.iNightReqConfidenceReduction
    ; second NPC check, confidence requires knowing player vulnerability so we have to check late or waste cpu
    i = 0
    while i < nearest.length && nearest[i] != None
      actorConfidence   = nearest[i].GetActorValue("Confidence")
      actorMorality     = nearest[i].GetActorValue("Morality") 
      isSlaver          = Mods.isSlaveTrader(nearest[i])
      
      ; reasons confidence can be lower: Actor is really aroused, player has reputation as local whore
      reqConfidence   = 4 - playerVulnerability - isNightReduction
                          ;- ( nearest[i].GetFactionRank(Mods.sexlabArousedFaction) > 80 ) as int
    
      if ( !MCM.bConfidenceToggle || (actorConfidence >= reqConfidence) || isSlaver \
           || nearest[0].GetFactionRank(Mods.sexlabArousedFaction) >= MCM.iWeightConfidenceArousalOverride) ;|| ( isNight && actorConfidence >= reqConfidence - MCM.iNightReqConfidenceReduction ) 
        debugmsg("Found NPC confident enough: " + nearest[i].GetDisplayName(),3)
        nearest[0] = nearest[i] ; lazy hack
        i = 1000
      else
        debugmsg(nearest[i].GetDisplayName() + " is not slaver and Confidence isn't high enough for the vulnerability, Attacker:" + (actorConfidence as int) + ", Req:" + (reqConfidence as int), 3)
        i += 1
      endif
    endwhile
    if i != 1000
      ; no need for debug here, since the log will be full of "is not slaver and not confident" we can infer
      return false; didn't find a confident actor, leaving
    endif

    float approach_duration = MCM.iApproachDuration

    ; enslave attempt
    if( rollEnslave <= MCM.iChanceEnslavementConvo) ; some of this should have been detected earlier
      if !Mods.hasAnySlaveMods 
        debugmsg("No slave mods, cannot enslave", 3)
      elseif CurrentGameTime < timeoutEnslaveGameTime 
        debugmsg("Not enough time has passed since the last enslave attempt: now:" + CurrentGameTime + " t.o.:" + timeoutEnslaveGameTime, 3)    
      elseif MCM.iEnslaveWeightLocal + MCM.iEnslaveWeightGiven + MCM.iEnslaveWeightSold <= 0
        debugmsg("All enslavement sliders are set to zero", 3)  
      elseif playerVulnerability < MCM.iMinEnslaveVulnerable 
        debugmsg(("Player is not vulnerable enough for enslave, MCM:" + MCM.iMinEnslaveVulnerable + ", Player:" + playerVulnerability), 3)
      elseif ((actorMorality > MCM.iMaxEnslaveMorality) && isSlaver == false)
        debugmsg("Attacker is not slaver and Morality is not low enough, Attacker:" + actorMorality + ", Req:" + MCM.iMaxEnslaveMorality, 3)
      ;elseif isWeaponProtected() == true && isSlaver == false ; moved further up
      ;  debugmsg("Player is protected by weapon (has weapon and MCM option is selected)", 3)    
      elseif enslavedLevel > 0
        debugmsg("Player is un-enslaveable, cannot re-enslave yet: level " + enslavedLevel, 3)
      elseif MCM.bEnslaveFollowerLockToggle && hasFollowers  
        debugmsg("player protected from enslave by follower " + followers, 3)
      elseif !(Mods.canRunLocal() as int) && !(DistanceEnslave.canRunGiven() as int) && !(DistanceEnslave.canRunSold() as int)
        debugmsg("Cannot run any enslavement options, no enslave mods found?", 3) 
      else  
        busyGameTime = CurrentGameTime + ( approach_duration * (1.0/1400.0)) ; 24 * 60 minutes in a day
        ;1.0/48.0 ;(24 hours 2 half hours per hour); 30 in-game minutes
        checkPersuationIntimidateRequirements()
        attemptEnslavementConvo(nearest[0])
        return true ; TODO change attemptEnslave to a true/false return, so we can return that
      endif
    endif  

    ; sex attempt
    ;if(playerVulnerability > 0   && CurrentGameTime >= timeoutEnslaveGameTime) && \
    if (actorMorality > MCM.iMaxSolicitMorality) && !isSlaver
      debugmsg("Attacker is not slaver and Morality is not low enough, Attacker:" + actorMorality + ", Req:" + MCM.iMaxEnslaveMorality, 3)
    ;elseif  nearest[0].GetFactionRank(Mods.sexlabArousedFaction) < MCM.iMinApproachArousal && !isSlaver
    elseif rollSex > MCM.iChanceSexConvo
      debugmsg("rolled too low for sex or enslavement, exiting...", 3)
    elseif MCM.bSexFollowerLockToggle && hasFollowers
      debugmsg("player protected from sex approach by follower " + followers, 3)
    else
      ;busyGameTime = Utility.GetCurrentRealTime() + 20 ;(20 * 24) ; 20 seconds? give it some time to work
      busyGameTime = CurrentGameTime + (approach_duration * (1.0/1400.0)) ; in-game minutes
      checkPersuationIntimidateRequirements()
      trySexConvo(nearest[0]) 
      ;endif
      return true ;  TODO change attemptEnslave to a true/false return, so we can return that
    endif

  endif 

  return false ; if we made it this far, than neither sex nor enslave worked
endFunction

; moved in 13.13, because it was getting huge, separate for organization and stack size
bool function attemptFollowerApproach(actor[] followers)
    
  actor[] valid_followers   = new actor[15]
  actor[] current_followers = new actor[15]
  actor follower
  int follower_count      = 0
  timeoutFollowerNag      = 0
  actor slave             = None
  actor tmp_follower      = None
  
  ; look for slave followers
  int i = 0
  while i < followers.length
    tmp_follower = followers[i]
    if tmp_follower != None && ( NPCMonitorScript.isWearingSlaveDD(tmp_follower) || Mods.isSlave(tmp_follower))
      slave = tmp_follower
      slaveRefAlias.ForceRefTo(tmp_follower)
      i += 100 ; done, stop looking
    endif
    i += 1
  endWhile
  if i == followers.length ; slave wasn't count, player is the slave (maybe)
    slaveRefAlias.ForceRefTo(player)
  endif
  
  if slave
    debugmsg("slave follower found: " + slave.GetDisplayName())
  endif 
  

  ; narrow the followers that we want to be able to interact with
  ; TODO flesh this out so that follower can have partner preference with slaves
  i = 0
  int current_count = 0
  while i < followers.length
    tmp_follower = followers[i]
    ; if follower is tied up at CDx
    if tmp_follower == None ; TODO if we can't remove the main follower showing up twice, remove them here
      ; do nothing, we can avoid
      
    elseif Mods.modLoadedCD && Mods.cdFollowerTiedUp.GetValueInt() == 1 && Mods.isTiedUpCDFollower(tmp_follower)
      debugmsg("follower " + tmp_follower.GetDisplayName() + " is tied up in CDx")
    elseif tmp_follower.WornHasKeyword(libs.zad_DeviousGag)
      debugmsg("follower " + tmp_follower.GetDisplayName() + " is gagged and will not approach")
    elseif tmp_follower.WornHasKeyword(libs.zad_DeviousHeavyBondage)
      debugmsg("follower " + tmp_follower.GetDisplayName() + " is bound in heavy bondage and cannot approach")
    elseif NPCMonitorScript.checkActorBoundInFurniture(tmp_follower)
      debugmsg("follower " + tmp_follower.GetDisplayName() + " is bound in zaz furniture and cannot appraoch")
    elseif SexLab.HadPlayerSex(tmp_follower) || StorageUtil.GetFloatValue(tmp_follower, "crdeThinksPCEnjoysSub") > 0 || follower_count == 0 
      valid_followers[follower_count] = tmp_follower
      follower_count += 1
      if tmp_follower.IsInFaction(CurrentFollowerFaction) \
       || tmp_follower.IsInFaction(crdeFormerFollowerFaction) \
       || tmp_follower.IsInFaction(Mods.paradiseFollowingFaction) 
       
        current_followers[current_count] = tmp_follower
        current_count += 1
        ; while we're here lets update our current followers container counts, 
        ;  instead of making a completely separate loop
        StorageUtil.AdjustIntValue(tmp_follower, "crdeFollContainersSearched", playerContainerOpenCount)
        debugmsg("follower chosen: " + tmp_follower.GetDisplayName() + " and:" + NPCMonitorScript.checkActorBoundInFurniture(tmp_follower))
      endif
    endif
    i += 1
  endWhile
  playerContainerOpenCount = 0 ; reset
  
  ; and then we pick ONE at random (for sex)
  ; TODO: consider searching for one that is horny enough
  if follower_count > 0
    follower = valid_followers[Utility.RandomInt(0, follower_count - 1)]
    debugmsg("Follower chosen randomly is " + follower.GetDisplayName() + " out of " + follower_count , 1)
  endif
  
  if follower == None 
    ;debugmsg("No nearby enemies, Follower exists, but busy or slave", 1) ; old but looks wrong
    debugmsg("No nearby followers", 1)
    return false
  endif

  hasSlaveFollowers = (slave != None) && (slave != follower)
  
  Mods.PreviousFollowers.AddForm(follower) ; maybe you can just add a NONE and let their own logic handle it
  if hasSlaveFollowers
    Mods.PreviousFollowers.AddForm(slave)
  endif
  
  ; attempt follower sex approach
  follower_thinks_player_sub    = StorageUtil.GetFloatValue(follower, "crdeThinksPCEnjoysSub")
  if SexLab.HadPlayerSex(follower) || follower_thinks_player_sub >= 5
    keyword blocking_keyword      = libs.zad_BlockGeneric
    armor belt                    = libs.GetWornDeviceFuzzyMatch(player, blocking_keyword)
    int aroused_level             = follower.GetFactionRank(Mods.sexlabArousedFaction)
    goal                          = (Math.Pow(aroused_level, MCM.fFollowerSexApproachExp) * MCM.sexApproachParabolicModifier) + 10 * ((follower_thinks_player_sub >= 3) as int)
    int max = MCM.fFollowerSexApproachChanceMaxPercentage ; bad papyrus
    if goal > max
      goal = max
    endif
    float roll                    = Utility.RandomFloat(100)
    debugmsg("follower aroused roll:" + roll + " need below " + goal, 3)
    ; moved this out so that we can detect it in the conversations even if not sex roll
    follower_can_remove_belt      = belt != None && !belt.HasKeyword(blocking_keyword) && follower.getItemCount(libs.GetDeviceKey(belt)) > 0
    if aroused_level >= MCM.gFollowerArousalMin.GetValueInt() && roll < goal && !Mods.isSlave(follower)
      if !(MCM.gForceGreetItemFind.GetValueInt() as bool)
        Debug.Notification( follower.GetDisplayName() + " looks aroused.")
      endif
      forceGreetSex = 10
      forceGreetIncomplete = true
      busyGameTime = CurrentGameTime + ( MCM.iApproachDuration * (1.0/1400.0)) ; 24 * 60 minutes in a day
      reshuffleFollowerAliases(follower);

      return true
    endif
  endif
  
  if current_count == 0
    debugmsg("not high enough for sex approach, and the current friendlies aren't followers so no item possible",3)
    return false
  endif
  
  ; search through the follower list looking for a follower that has found items
  int  follower_item_count  = StorageUtil.GetIntValue(follower, "crdeFollContainersSearched") 
  int  randomStart          = Utility.RandomInt(0, current_count - 1)
  int  followerRemaining    = current_count 
  while  followerRemaining >= 0 && follower_item_count <= 0 ; while we haven't found a good follower yet
    follower = current_followers[(current_count + randomStart - followerRemaining) % current_count] ; circle around the buffer
    follower_item_count  = StorageUtil.GetIntValue(follower, "crdeFollContainersSearched")
    followerRemaining -= 1
  endWhile
  if followerRemaining == -1 ; we searched until the end
    debugmsg("No present followers have seen the player open any containers, exiting early")
    return false
  endif
  debugmsg("Follower re-chosen randomly is " + follower.GetDisplayName() + \
           " out of " + current_count  + \
           " after " + (current_count - followerRemaining) + " rechecks", 1)
  

  int validItemsFound = 0
  i = 1 ; start at present index -1, the last location written.
  int absoluteIndex
  armor[]           armorArray      = new armor[32]
  objectReference[] containerArray  = new objectReference[32]
  ;debugmsg("past items: " + followerFoundDDItems )
  ;debugmsg("and their contianers: " + followerFoundDDItemsContainers )
  
  ; check the containers we found for DD itmems and keys still there
  followerItemsArraySemaphore = true
  form testForm
  objectReference testContainer
  bool alreadyFoundOneKey = false
  actor randomFoll
  while i < 32
    ; we need to count how many items we have, and calculate additional chance of item being found for this one cycle
    absoluteIndex = (followerFoundDDItemsIndex + 32 - i) % 32
    testForm = followerFoundDDItems[absoluteIndex] 
    if testForm != NONE
      Key keyTest = testForm as Key
      testContainer = followerFoundDDItemsContainers[absoluteIndex]
      if alreadyFoundOneKey == false && keytest != None
        ; for now, randomly give to a follower if the last follower, assuming they weren't too submissive
        ; TODO add a way for the follower to bring you the key if they aren't dom
        ;followers[0]
        randomFoll = followers[Utility.RandomInt(0, (follower_count - 1))]
        debugmsg("Follower " + randomFoll.GetDisplayName() + " found a key:" + testForm.GetName(), 3)
        randomFoll.additem(keyTest)
        alreadyFoundOneKey = true
      elseif ItemScript.itemStillInContainer(testForm, testContainer)
      
        ;debugmsg("Adding to armor short list " + testForm.GetName(), 3)
        armorArray[validItemsFound] = testForm as armor
        containerArray[validItemsFound] = testContainer
        validItemsFound += 1
      endif
      i += 1
    else ; testForm == NONE
      ; if they didn't find a key, give them a 10% chance of finding one but not telling the player
      if alreadyFoundOneKey == false && Utility.RandomInt(0,100) > 90      
        randomFoll = followers[Utility.RandomInt(0, (follower_count - 1))]
        if randomFoll == None
          debugmsg("ERR randomFoll was NONE")
        endif
        Key k = deviousKeys[Utility.RandomInt(0,2)]
        if k == None
          debugmsg("ERR key was NONE")
        endif
        randomFoll.additem(k)
      endif
      i = 100 ; end loop
    endif
  endWhile
  followerItemsArraySemaphore = false

  debugmsg("Items found by follower :" + validItemsFound, 3)
  
  float item_approach_roll      = Utility.RandomFloat(0,100) - validItemsFound * 5 ; for now, 5% per item, need something better TODO
  float goal                    = MCM.fFollowerFindChanceMaxPercentage
  if follower_item_count < MCM.iFollowerFindChanceMaxContainers
    goal = ( Math.pow(follower_item_count, MCM.fFollowerItemApproachExp) * MCM.itemParabolicModifier) 
  endif
  debugmsg("Follower item adding roll:" + item_approach_roll + " need under " + goal + ", containers: " + follower_item_count, 3)

  ; if we roll low enough, lets do an item approach
  if item_approach_roll < goal
    
    updateFollowerOpinions(follower); Need updated opinions here
    ; add 10 points if player has a slave/follower with collar
    follower_thinks_player_sub   += ((Mods.metReqFrameworkMakeVuln() as int) * 10)
    
    debugmsg("thinks sub: " + follower_thinks_player_sub \
      + ", thinks dom: " + follower_thinks_player_dom \
      + ", enjoys sub: " + follower_enjoys_sub \
      + ", enjoys dom: " + follower_enjoys_dom \
      + ", frust: " + follower_frustration \
      + ", availablility: " + followerItemsWhichOneFree)
    ; also test for relationship and arousal and stuff

    ;debugmsg("pre-shuffle: " + armorArray)
    ;armor[] shuffledArmor = ItemScript.shuffleArmor( armorArray, containerArray, validItemsFound)
    if armorArray[0] != None
      ItemScript.shuffleArmor( armorArray, containerArray, validItemsFound)
      debugmsg("Shuffled: " + armorArray)
    endif
    if armorArray[0] == None || ItemScript.checkFollowerFoundItems(follower, armorArray, containerArray) == false
      debugmsg("Follower found items invalid, rolling random items")
      ItemScript.rollFollowerFoundItems(follower)
    endif
    
    if !(MCM.gForceGreetItemFind.GetValueInt() as bool)
      ; force greet is off, we just want to notify player but not appraoch
      Debug.Notification( follower.GetDisplayName() + " wants to talk to you.")
    else 
      ; force greet is on, setup cancel timeout
      forceGreetIncomplete = true
      busyGameTime = CurrentGameTime + ( MCM.iApproachDuration * (1.0/1400.0)) ; 24 * 60 minutes in a day
    endif

    forceGreetFollower = 1
    reshuffleFollowerAliases(follower)
    return true
  endif
  return false
endFunction

; update
function updateFollowerOpinions(actor actorRef)
  follower_enjoys_dom           = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysDom")
  follower_enjoys_sub           = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysSub") 
  follower_thinks_player_sub    = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysSub")
  follower_thinks_player_dom    = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysDom") 
  follower_frustration          = StorageUtil.GetFloatValue(actorRef, "crdeFollowerFrustration")
endFunction

; don't forget you have updateSDMaster as well
; We should probably reorder this at some point
function updateMaster()
  master = none
  masterIsSlaver = false
  ;if Mods.modLoadedSD == true && Mods.enslavedSD == true
  if Mods.enslavedSD 
    setMaster(StorageUtil.GetFormValue(player, "_SD_CurrentOwner") as actor)
  ;elseif Mods.modLoadedMariaEden == true && Mods.enslavedME == true
  elseif Mods.enslavedME 
    ;meTools = Mods.meSlaveQuest
    ReferenceAlias masterRA = (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).getMaster(); TODO: Move this to the mods for faster use
    ;master = masterRA.GetActorRef()
    setMaster(masterRA.GetActorRef())
  elseif Mods.enslavedSlaverun ; does this work for both versions?
    setMaster(Mods.slaverunZaidActor)
  elseif Mods.enslavedLola ; lola
    setMaster(Mods.LolaScript.GetOwner()) ;(Quest.GetQuest("vkjMQ") as vkjMQ).Owner.GetReference() as Actor ; too much java
  elseif Mods.enslavedCD
    ;SetMaster() ; reminder to set it to CDx master
  ;elseif Mods.enslavedSlaverun
  ;  master = Mods.slaverunZaidActor
  ;elseif  player is at least a littl sub, Follower put something on then, didn't complain
  endif ; any other mods where there is a master?
  ; add  slaverunR, CDx and 

endFunction

function setMaster(actor masterRef)
  master = masterRef
  masterRefAlias.forceRefto(master)
  masterIsSlaver = Mods.isSlaveTrader(master); was this ever used?
endFunction

; if I had known these 5 functions would all be the same I would have just made one with a string parameter to differentiate them, but now I'm fat and lazy

; does the follower like being sub/dom? positive is yes, negative is no, 0 is don't care
function modFollowerLikesDom(actor actorRef , float value, float max = 30.0)
  float current_value = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysDom")
  if current_value > max && value > 0 
    ; we're already too high for us to be affected by this adjustment
  elseif value + current_value > max && value > 0 
    StorageUtil.SetFloatValue(actorRef, "crdeFollEnjoysDom", max)
  else
    StorageUtil.AdjustFloatValue(actorRef, "crdeFollEnjoysDom", value)
  endif
endFunction

function modFollowerLikesSub(actor actorRef, float value, float max = 30.0)
  float current_value = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysSub")
  if current_value > max && value > 0 
    ; we're already too high for us to be affected by this adjustment
  elseif value + current_value > max && value > 0 
    StorageUtil.SetFloatValue(actorRef, "crdeFollEnjoysSub", max)
  else
    StorageUtil.AdjustFloatValue(actorRef, "crdeFollEnjoysSub", value)
  endif
endFunction

function modThinksPlayerDom(actor actorRef , float value, float max = 30.0)
  float current_value = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysDom")
  if current_value > max && value > 0 
    ; we're already too high for us to be affected by this adjustment
  elseif value + current_value > max && value > 0 
    StorageUtil.SetFloatValue(actorRef, "crdeThinksPCEnjoysDom", max)
  else
    StorageUtil.AdjustFloatValue(actorRef, "crdeThinksPCEnjoysDom", value)
  endif
endFunction

function modThinksPlayerSub(actor actorRef , float value, float max = 30.0)
  float current_value = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysSub")
  if current_value > max && value > 0 
    ; we're already too high for us to be affected by this adjustment
  elseif value + current_value > max && value > 0 
    StorageUtil.SetFloatValue(actorRef, "crdeThinksPCEnjoysSub", max)
  else
    StorageUtil.AdjustFloatValue(actorRef, "crdeThinksPCEnjoysSub", value)
  endif
endFunction

function modFollowerFrustration(actor actorRef, float value, float max = 40.0)
  float current_value = StorageUtil.GetFloatValue(actorRef, "crdeFollowerFrustration")
  if current_value > max && value > 0 
    ; we're already too high for us to be affected by this adjustment
  elseif value + current_value < 0 
    ; shouldn't go negative, lets set at zero
    StorageUtil.SetFloatValue(actorRef, "crdeFollowerFrustration", 0)
  elseif value + current_value > max && value > 0 
    StorageUtil.SetFloatValue(actorRef, "crdeFollowerFrustration", max)
  else
    StorageUtil.AdjustFloatValue(actorRef, "crdeFollowerFrustration", value)
  endif
endFunction

; eliminate these entirely, calling directly from crdeitemmanipulatescript
bool function removeCurrentCollar()
  ;redirect
  ItemScript.removeCurrentCollar(player)
endFunction

function equipRandomDD(actor actorRef, actor attacker = None, bool canEnslave = false)
  ItemScript.equipRandomDD(actorRef, attacker, canEnslave)
endFunction

function updateWornDD(bool collarOnly = false)

  if(wearingArmbinder == true && collarOnly == false)
    knownArmbinder = libs.GetWornDevice(player, libs.zad_DeviousArmbinder)
  endif
  if(wearingBlindfold == true && collarOnly == false)
    knownBlindfold = libs.GetWornDevice(player, libs.zad_DeviousBlindfold)
  endif
  if(wearingCollar == true)  
    knownCollar = libs.GetWornDevice(player, libs.zad_DeviousCollar)
  endif
  if(wearingGag == true && collarOnly == false)
    knownGag = libs.GetWornDevice(player, libs.zad_DeviousGag)
  endif
endFunction

; 0 is nothing, 1 is local, 2 is given, 3 is sold, 4 is slaverun (old version, and new when I can get detection working)
; this is where we decide, before conversation, what kind of enslavement we get, so we can control the randomness of the dialogue to match the weights
; rolldialogueroute <- tag for searching
function rollEnslaveDialogue()
  ; 0 * anything is 0, 1 * anything is anything, arithmetic is fairly fast in the CPU
  ;debugmsg("local(sd:" + MCM.bSDEnslaveToggle + ",mar:" + MCM.bMariaEnslaveToggle + ")", 2)
  ; alright, maybe this is getting a touch crazy
  int newLocalWeight    = MCM.iEnslaveWeightLocal * (Mods.canRunLocal() as int)  ;((Mods.canRunLocal() && (MCM.bSDEnslaveToggle || MCM.bMariaEnslaveToggle) && ((MCM.iEnslaveWeightSD + MCM.iEnslaveWeightMaria) >= 1 )) as int) * MCM.iEnslaveWeightLocal 
  int newGivenWeight    = MCM.iEnslaveWeightGiven * (DistanceEnslave.canRunGiven() as int)
  int newSoldWeight     = MCM.iEnslaveWeightSold * (DistanceEnslave.canRunSold() as int) 
  ;int newTrainingWeight = (DistanceEnslave.canRunTraining() * 50)
  int weightTotal       = newLocalWeight + newGivenWeight + newSoldWeight 
  if weightTotal != 0 
    int roll = Utility.RandomInt(1, weightTotal )
    debugmsg("loc/give/sold(" + newLocalWeight + "/" + newGivenWeight + "/" + newSoldWeight + ")roll/total:(" + roll + "/" + weightTotal + ")", 2)
    if roll <= newLocalWeight
      ; just slaverun, because slaverun has limitations
      ;debugmsg("slaverun check (whiterun, enforceable): " + SlaverunScript.isPlayerInWhiterun() + " " + SlaverunScript.PlayerIsInEnforcedLocation() )
      if SlaverunScript.isPlayerInWhiterun() && SlaverunScript.PlayerIsInEnforcedLocation() ;&& roll < ((MCM.iEnslaveWeightSlaverun / (MCM.iEnslaveWeightSlaverun + MCM.iEnslaveWeightMaria + MCM.iEnslaveWeightSD) ) * MCM.iEnslaveWeightLocal)
        ;debugmsg("slaverun roll chosen")
        enslaveDialogue = 4
      else
        enslaveDialogue = 1
      endif
    elseif roll <= (newLocalWeight + newGivenWeight) ; given
      enslaveDialogue = 2
    else  ; Sold ; roll <= (MCM.iEnslaveWeightLocal + MCM.iEnslaveWeightGiven + )
      enslaveDialogue = 3
    endif
    debugmsg("enslave dialogue type chosen: " + enslaveDialogue, 1)
  else
    debugmsg("enslave dialogue weight total is zero, no enslave options? ", 4)
  endif
endFunction

; starts approach, ends up in "attemptEnslavement" if local, in crdedistantenslave or modsmonitor otherwise
function attemptEnslavementConvo(actor actorRef)
  if MCM.bSecondBusyCheckWorkaround && isPlayerBusy()
    debugmsg("Player was busy at approach start, cancelling ...")
  endif
  Mods.dhlpSuspend()
  forceGreetSlave = 1
  forceGreetSex = 0
  forceGreetIncomplete = true
  setCRDEBusyVariable(true)
  previousAttacker = actorRef
  ;crdeFGreetStatus.SetValue(2)
  
 ;getClosestFollower()
  rollEnslaveDialogue() ; setting the enslavement dialogue type before we actually start the dialogue options
  debugmsg("doing enslave convo with " + actorRef.getDisplayName(), 1)

  attackerRefAlias.ForceRefTo(actorRef)
endFunction

function trySexConvo(actor actorRef)
  if MCM.bSecondBusyCheckWorkaround && isPlayerBusy()
    debugmsg("Player was busy at approach start, cancelling ...")
  endif
  Mods.dhlpSuspend()
  forceGreetSex = 1
  forceGreetSlave = 0
  forceGreetIncomplete = true
  setCRDEBusyVariable(true)
  previousAttacker = actorRef
  ;crdeFGreetStatus.Setvalue(1)

  debugmsg("doing sex convo with " + actorRef.getDisplayName(), 1)
  
  attackerRefAlias.ForceRefTo(actorRef)
endFunction

; just gonna borrow this from Cursed Loot
; needs notes
;Actor function getClosestFollower() 
  ; moved to NPCMonitor
    
;endfunction

; so that we can skip the follower protection in the future
; this was going to be used back when users complained that followers got in the way of enslavement, instead they complained to the slave mod authors ¯\_(ツ)_/¯
function clearFollowers()
  ; get closeset followers until empty
  ; dismiss all of them (move from faction?)
endFunction

; actorRef = attacker
function doFollowerRapeSlave(actor actorRef)
  ; if slave not saved from last time, or too far away, search again, and if not found rape player
  actor slave = slaveRefAlias.GetActorRef()
  if ! slave
    slave = player
  endif

  string animationTags = "";
  string supressTags   = "Footjob, Cuddle, Breastfeeding, Solo, Petting";
  actor[] sexActors = new actor[2] ; only 3 if we ever decide to have threesomes and such
  sexActors[0] = slave
  sexActors[1] = actorRef
  sslBaseAnimation[] animations = SexLab.GetAnimationsByTag(2, animationTags, TagSuppress = supressTags)
  SexLab.StartSex(sexActors, animations)

endFunction


function doPlayerSexAndReplaceBelt(actor actorRef)
  ; for now, just trigger an extra variable and call the regular function
  sexFromDECWithBeltReapplied = true
  ItemScript.removeDDbyKWD(player, libs.zad_DeviousBelt)
  
  ; our own sex start, since we know what's happening exactly
  string animationTags
  string supressTags

  if player.GetActorBase().GetSex() == 1 && Utility.RandomInt(0,100) < 65 
    animationTags = "vaginal"
  else   
    animationTags = "anal"
  endif
  supressTags += ",Breastfeeding,blowjob" ; for now, oral,mouth can't be supressed since it might be two women

  SendModEvent("crdePlayerSexConsentStarting")  
  
  sexFromDEC = true
  actor[] sexActors = new actor[2] ; only 3 if we ever decide to have threesomes and such
  sexActors[0] = player
  sexActors[1] = actorRef
  ;debugmsg("doPlayersex with belt actors: player " + player.GetDisplayName() +" and " + actorRef.GetDisplayName())
  sslBaseAnimation[] animations = SexLab.GetAnimationsByTag(2, animationTags, TagSuppress = supressTags)
  SexLab.StartSex(sexActors, animations, player, None, false)
endFunction

; remove blocking items if the NPC or player have keys
; return: 0 nothing, 1 gag, 2 belt, 3 both?
; for now, both doesn't work
int function prepareForDoPlayerSex(actor actorRef, bool both = false, bool skip_oral = false)
  knownGag = libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousGag) ; should be redundant, but fails for some reason
  ;debugmsg("gag we see: " + knownGag.GetName()) ; whoa! forget the none check did we?
  
  ; if the attacker is belted, and they have their own key, they should remove their belt.
  if actorRef.WornHasKeyword(libs.zad_DeviousBelt) && actorRef.getItemCount(libs.chastityKey) > 0
    ItemScript.removeDDbyKWD(actorRef, libs.zad_DeviousBelt)
  endif
  
  ; player is wearing gag
  if !skip_oral && player.WornHasKeyword(libs.zad_DeviousGag) && !knownGag.HasKeyword(libs.zad_BlockGeneric) 
    if player.WornHasKeyword(libs.zad_PermitOral) || player.WornHasKeyword(libs.zad_DeviousGagPanel)
      debugmsg("gag is panel or permiting",3)
    elseif actorRef.getItemCount(libs.restraintsKey) > 0
      Debug.Notification(actorRef.GetDisplayName() + " had a key to remove your gag!")
      ItemScript.removeDDbyKWD(player, libs.zad_DeviousGag)
      return 1; done, set var and leave?
    elseif player.getItemCount(libs.restraintsKey) > 0 ; for now no RNG
      ; for now, no stealing (key is around neck, free to leave)
      ; in the future: make it so that the chastity key stays on the player if armbound, belted slut with key out of their reach kind of thing
      Debug.Notification(actorRef.GetDisplayName() + " found a key on you and unlocks you!")
      ItemScript.removeDDbyKWD(player, libs.zad_DeviousGag)
      return 1; done, set var and leave?
    endif
  endif
  
  ; male attacker, check if they can unlock you
  ; skip oral was here, huh?
  if actorRef.GetActorBase().GetSex() == 0 && wearingBlockingVaginal \
    && !libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousBelt).HasKeyword(libs.zad_BlockGeneric)
    if actorRef.getItemCount(libs.chastityKey) > 0
      Debug.Notification(actorRef.GetDisplayName() + " had a chastity key to unlock you!")
      ItemScript.removeDDbyKWD(player, libs.zad_DeviousBelt)
      return 2; done, set var and leave?
    elseif player.getItemCount(libs.chastityKey) > 0 ; for now no RNG
      ; for now, no stealing (key is around neck, free to leave)
      ; in the future: make it so that the chastity key stays on the player if armbound, belted slut with key out of their reach kind of thing
      Debug.Notification(actorRef.GetDisplayName() + " found a key on you and unlocks you!")
      ItemScript.removeDDbyKWD(player, libs.zad_DeviousBelt)
      return 2; done, set var and leave?
    endif
  endif
  ; still here? so they couldn't remove your belt... if female lets lock to oral at least
  ;if actorRef.GetActorBase().GetSex() == 1
    ;if Utility.RandomInt(1,100) > 50
    ;  return 1
    ;else
    ;  return 2
    ;endif
  ;endif
  
  return 0  
EndFunction

; this exists because I don't want to recompile > 40 fragments to update to threesome.
; just keep this as a pointer to the other one, at least until I have another reason to change it then update it
function doPlayerSex(actor actorRef, bool rape = false, bool soft = false, bool oral_only = false)
  doPlayerSexFull(actorRef, none, rape, soft, oral_only )
endFunction


; soft specifies if the sex can allow for softer sexual animations, like cuddling
function doPlayerSexFull(actor actorRef, actor actorRef2, bool rape = false, bool soft = false, bool oral_only = false)
  float startingTime = Utility.GetCurrentGameTime() 
  Debug.SendAnimationEvent(actorRef, "IdleNervous") ; should work well enough; no longer works...what
  clear_force_variables() ; handles forceGreetIncomplete = false
  Mods.dhlpResume()
    
  String threesomeTag = ""
  actor[] sexActors
  if actorRef2 != None
   sexActors = new actor[3]
   threesomeTag = "FMM," ; we use this tag because the others put player in a non-sub position I think...
  else
   sexActors = new actor[2] 
  endif
  sexActors[0] = player
  sexActors[1] = actorRef
  if actorRef2 != none
    sexActors[2] = actorRef2
  endif
  int actorGender  = 0
  int playerGender = 0

  if MCM.bUseSexlabGender
    actorGender     = SexLab.GetGender(actorRef)
    playerGender    = SexLab.GetGender(player) ; we call these enough save as var
  else
    actorGender     = actorRef.GetActorBase().getSex()
    playerGender    = player.GetActorBase().GetSex() ; we call these enough save as var
  endif   
  
  if PlayerScript.sittingInZaz ; if player is tied up in furniture, move the player to the attacker, so sex doesn't clip
    player.moveTo(actorRef)
  endif
  
  string animationTags = "";
  int preSex = prepareForDoPlayerSex(actorRef, skip_oral = oral_only)
  debugmsg("prepare result: "+ preSex)
  ; if we removed something, we might as well sex in that area
  if preSex == 2 && Utility.RandomInt(0,100) < 65 
    animationTags = "Vaginal"
  elseif preSex== 2 ; roll failed  
    animationTags = "Anal"
  ;elseif actorGender == 1 && (preSex == 1 || oral_only)
  ;  animationTags = "Cunnilingus"
  elseif preSex == 1 || oral_only
    animationTags = "Oral"
  endif
  
  ; changed in 13
  ; lets try removing this, 13.13testing
  ;Utility.Wait(0.5) ; hopefully long enough for DD to work
  
  ; if both female, no aggressive req, too few animations, annoying
  ;debugmsg("genders are player,attacker: " + player.GetActorBase().GetSex() + "," + actorGender)
  if rape 
    if playerGender == 0 && actorGender == 1   
      ; user wanted animations where woman was not in male role, this might help with that
      animationTags += ",Cowgirl"
    elseif !(playerGender == 1 && actorGender == 1 && !MCM.bFxFAlwaysAggressive)
      animationTags += ",Aggressive"
    endif
    SendModEvent("crdePlayerSexRapeStarting")
  else
    SendModEvent("crdePlayerSexConsentStarting")
  endif 
  
  string supressTags = "Solo"
  if soft == false
    ;supressTags  += ",Cuddling,Acrobat,Petting,Foreplay"
    supressTags  += ",Cuddling,Acrobat,Petting,"
  endif
  
  if playerGender == 1 && actorGender == 1 ; both girls
    supressTags += ",handjob,footjob,boobjob" ; seriously now
    ; even oral on a dildo has some embarrassment value, but handjob on dildo is just silly, same with foot and boob, especially since they are kinda... woman focused
    ; TODO: remove this and check what animations are being dumped because 1/5 stages has one of these
  endif
  
  ; we can optimize this out with a variable, since we have to check this earlier when we start the dialogue anyway
  ;if player.wornHasKeyword(libs.zad_DeviousBelt) 
  ;  ; actor has a key, will use ;zzz key
  ; 
  ;  ; we know the player is belted, now check if their belt permits vag (are there even any?) and check for female attacker
  ;  ;  problem we're trying to avoid: suppress tags are both ways, we can't suppress vag for just player
  ;  ;  we don't want to block vag tag if the player can perform cunnilingus on female attacker though, so we can't block vag tag there or we block vag on both
  ;  ; preSex != 1 for now we're including the possibility of the player using strapon against attacker who needs service
  ;  if  (actorRef.WornHasKeyword(libs.zad_DeviousBelt) && !player.wornhaskeyword(libs.zad_PermitVaginal)) 
  ;    supressTags += ",Vaginal,Pussy,Tribadism,BlowJob"
  ;  elseif actorGender == 1
  ;    ; if they too are a woman, keep pussy it shows up on licking animations
  ;    supressTags += ",Vaginal"
  ;  endif
  ;  if !player.wornhaskeyword(libs.zad_PermitAnal) && actorGender == 0 || ( (actorRef.WornHasKeyword(libs.zad_DeviousBelt) && !actorRef.wornhaskeyword(libs.zad_PermitAnal)))
  ;    supressTags += ",Anal"
  ;  endif
  ;elseif player.wornHasKeyword(Mods.zazKeywordWornBelt) && actorGender == 0 || ( actorRef.wornHasKeyword(Mods.zazKeywordWornBelt))
  ;  supressTags += ",Vaginal,Anal"
  ;endif
  ;if (player.wornhaskeyword(libs.zad_DeviousGag) && !(player.wornhaskeyword(libs.zad_PermitOral) || player.wornhaskeyword(libs.zad_DeviousGagPanel) )) ||\
  ;    (!player.wornhaskeyword(libs.zad_DeviousGag) && player.wornHasKeyword(Mods.zazKeywordWornGag) && !player.wornHasKeyword(Mods.zazKeywordPermitOral))
  ;  if actorRef.wornhaskeyword(libs.zad_DeviousBra)
  ;    supressTags += ",Breastfeeding"
  ;  endif
  ;  supressTags += ",Oral,Mouth"
  ;  if actorGender == 0
  ;    supressTags += ",Blowjob"
  ;  endif
  ;endif
  ;if player.wornhaskeyword(libs.zad_DeviousBra) && actorGender == 0
  ;  supressTags += ",Boobjob"
  ;endif
  
  ; this whole slaw is here to help us find enough animations to throw into sexlab
  ; but should really be re-thought a bit..
  String newAnimationTags = threesomeTag + animationTags
  bool DDi3 = ! Mods.modLoadedDD4 ; probably break the game if you tried to use a function like that on the older DDI
  sslBaseAnimation[] animations = new sslBaseAnimation[1] ; ignore this, this is just a declare for papyrus compiler
  if actorRef2 != None || DDi3
    animations = SexLab.GetAnimationsByTag(2 + ((actorRef2 != None) as int), newAnimationTags, TagSuppress = supressTags)
  else
    animations = libs.SelectValidDDAnimations(sexActors, 2 + ((actorRef2 != None) as int), forceaggressive = !soft, includetag = newAnimationTags, suppresstag = supressTags )
  endif
  
  debugmsg(("anim:'" + animationTags +"',supp:'" + supressTags+ "',animsize:" + animations.length), 3)
  
  ; if I'm only getting 8 animations with these tags, most users probably get near enough to zero to be a problem
  ; TODO: break suppress tags into two parts so we can keep the above more intact without dropping all of it
  if animations.length == 0 
    if actorRef2 != None
      debugmsg("No animations for FMM, reducing ... ", 4)
      if DDi3
        animations = libs.SelectValidDDAnimations(sexActors, 3, forceaggressive = !soft, includetag = animationTags, suppresstag = supressTags )
      else
        animations = SexLab.GetAnimationsByTag(3, animationTags, TagSuppress = supressTags)
      endif
    else
      debugmsg("No animations available with given tags, reducing ...", 4)
      supressTags = "Solo,Breastfeeding,Acrobat"
      if DDi3
        animations = libs.SelectValidDDAnimations(sexActors, 2, forceaggressive = !soft, includetag = animationTags, suppresstag = supressTags )
      else
        animations = SexLab.GetAnimationsByTag(2, animationTags, TagSuppress = supressTags)
      endif
    endif
    if animations.length == 0
      debugmsg("we got no animations ever, leaving early", 5)
      return
    endif
  endif
  
  ; just debug, printing what we got
  if MCM.bDebugRollVis
    int anim = 0
    sslBaseAnimation tmp 
    String total = "\n"
    while anim < animations.length
      tmp = animations[anim]
      total += " > A: " + tmp.name + " tags:" + tmp.GetRawTags() + "\n"
      anim += 1
    endwhile
    debugmsg(total, 3) ; thrashes the log less
  endif
  
  ; if both player and attacker are female, we want the player to take the 'reciever' or 'female' position
  ;  why does sorting the actors do this? no fucking clue. this code was used in petcollar, maybe it's placebo who knows ¯\_(ツ)_/¯
  ;  unless oral was chosen, then we want the player to 'give' oral, rather than recieve
  ; TODO: does the oral thing work for oral on strapon AND oral on vag? if not, we should move this after the following animation test and sort there
  if (playerGender == 1 && actorGender == 1 && preSex != 1)
    sexActors = SexLab.SortActors(sexActors)
  endif
  
  
  ;this was removed in 13.13.9 because I'm tired of only having one animation that I can't change through sexlab
  ;and we shouldn't need to get around the filter anymore since we now USE the filter
  ; attempting to get around DDi animation filter based on kimy's advice
  ;sslBaseAnimation[]  single_animation = new sslBaseAnimation[1]
  ;int l = animations.length - 1
  ;single_animation[0] = animations[Utility.RandomInt(0,l)]
  ;debugmsg("Animation chosen is: " + single_animation[0].name, 3)
  
  ; if player is male, and female attacker, don't use aggressive because we want cowgirl animations
  if rape == true && !(playerGender == 0 && actorGender == 1 ) 
    sexFromDEC = true
    ;SexLab.StartSex(sexActors, single_animation, player);, None, false);
    SexLab.StartSex(sexActors, animations, player);, None, false);
  else
    if soft
      sexFromDECWithoutAfterAttacks = true
    endif
    sexFromDEC = true
    ;SexLab.StartSex(sexActors, single_animation);
    SexLab.StartSex(sexActors, animations);
  endif
  debugmsg("doPlayerSex finshed, time: " + (Utility.GetCurrentGameTime() - startingTime), 1)
endFunction

; this is the hook called after sexlab is finished
; now called always after all sexlab, so we must check if it was started by CRDE or not
; tag:postsex <- for searching 
Event crdeSexHook(int tid, bool HasPlayer);(string eventName, string argString, float argNum, form sender)
  ;debugmsg("crdeSexHook reached, running post-sex", 1)
  sslThreadController Thread = SexLab.GetController(tid)
  
  ; mod must be active, 
  ;  sex must have come from DEC or we don't care,
  ;  and the player must be involved in sex from this side
  if MCM.gCRDEEnable.GetValueInt() != 1 
    ; do nothing, mod is off lets not flood the log
    debugmsg("err: sex ended but DEC is turned off")
  elseif !(sexFromDEC || MCM.bHookAnySexlabEvent) 
    debugmsg("err: sex ended but DEC was not the starting mod, and override is not set, ignoring")
  elseif !Thread.HasPlayer() 
    Actor[] a = SexLab.HookActors(tid as string)
    debugmsg("err: sex ended but the sexlab thread that finished does not have player as an participant, actors:" + a)
   
  else 
  
    setPreviousPlayerHome() ; here because we want the last home the player wanted to have sex in
    
    follower_attack_cooldown = false
    timeoutFollowerApproach = Utility.GetCurrentGameTime() ; huh?
  
    if victim == None && sexFromDECWithBeltReapplied
      ; put the player back into their belt
      ItemScript.equipRegularDDItem(player, ItemScript.previousBelt, libs.zad_DeviousBelt)
      return
    endif
    if ( sexFromDEC && sexFromDECWithoutAfterAttacks  ) ; specific case
      debugmsg("sexlabhook: sex was specified no attack, leaving", 3)
      return 
    endif
    
    ;debugmsg("testing debug, sex from DEC: " + sexFromDEC + " MCM: " + MCM.bHookAnySexlabEvent)
    Actor[] actorList = SexLab.HookActors(tid as string)
    actor victim = Thread.getVictim()
    
    if Thread.ActorCount <= 1  && player.WornHasKeyword(libs.zad_DeviousBelt)  ; we know the player was involved to get this far, lets increase reputation and temporary vulnerability
      debugmsg("sexlabhook: masterbation detected while belted", 3)
      ; mod arousal for all nearby NPCs
      actor[] a = NPCSearchScript.getNearbyFollowers() ;getNearbyActors() 
      ; increment all thinks sub by two
      adjustPerceptionPlayerSub( a, 3 )
      timeExtraVulnerableEnd = Utility.GetCurrentGameTime() + (1/48) ; in days, 24 hours half hour (30 minutes)
      timeExtraVulnerableLoc = player.GetCurrentLocation()
      ; increase nearby NPC arousal?
      adjustActorsArousal(a, 20)
      return
    endif
    
    ; if the player does not have to be a victim, and they aren't, set them to keep going
    if victim == None && !MCM.bHookReqVictimStatus
      victim = player 
      debugmsg("sexlabhook: setting player as victim", 3)
    endif
    bool vicIsPlayer = (victim == player)
    if ! (vicIsPlayer || victim != None)
      debugmsg("sexlabhook: player not victim, not started by DEC, mcm override is off, ignoring...", 3)
      return
    endif

    if sexFromDEC || MCM.bHookAnySexlabEvent; no error, keep going

      int playerPos = Thread.GetPlayerPosition()
      actor otherPerson = none
      if(playerPos == 1)
        otherPerson = actorList[0]
      else
        otherPerson = actorList[1]
      endif

      ;debugmsg("victim is " + victim.getDisplayName(), 0)
      CheckBukkake()
      ;updatePlayerVulnerability() 
      ; reasons why removed: if player is already wearing items then the last playerVulnerability should suffice except in false neg case, where we don't care as much
      ; rechecking item and playerVulnerability is too slow, this code already takes a long time to work
      ; assumption: no other mod will add items to player at end of sex and before this code (false negative)
      
      ; assumption: cannot rape player without going through isActiveInvalid already
      ; yeah but this is now the general event catch, not just for CRDE called
      if NPCMonitorScript.isInvalidRace(otherPerson) == false 
        if enslavedLevel < 1
          bool enslave_attempt_result = tryEnslavableSexEnd(otherPerson)
          if enslave_attempt_result
            ;debugmsg("resetting sexFromDEC @ 1")
            sexFromDEC = false 
            return
          endif
          ;tryNonEnslaveSexEnding(otherPerson) ; This is for non-enslavable only
        else
          tryNonEnslaveSexEnding(otherPerson)
        endif
      else  
        debugmsg("crdeSexhook ERR: sex was with invalid race", 2) 
      endif
      ;endif
    endif
    
    sexFromDEC                    = false 
    sexFromDECWithoutAfterAttacks = false
    ;debugmsg("resetting sexFromDEC @ 2")

    ; did nearby npc, who might one day be your follower, see you have sex and/or bondage (check if they are in LOS I guess...)
    modifyNearbyNPCPerception(actorList, vicIsPlayer)
    
  ;else
    ;debugmsg("crdeSexhook ERR: sexlab doesn't have player controller or mod is turned off", 2)
  endif
  
endEvent

; check if player is in player house, if so, set last player house
function setPreviousPlayerHome()
  Location current_loc = player.GetCurrentLocation()
  if current_loc != None && current_loc.haskeyword(LocTypePlayerHouse) ; we check here because we don't just want the last house but the last house the player had sex in
    previousPlayerHome = current_loc
  endif
endFunction

; looks for nearby NPCs who might have seen you having sex
; changes their opinion of you as a result
; can I just hope that the actors we're sexing are in this list by default as well? If yes,then we don't need to treat them special
function modifyNearbyNPCPerception(actor[] sexActors, bool playerIsVictim = false)
  
  ; get nearby NPCs, get first because this might be slowish, get them NOW before they run away
  actor[] a = NPCSearchScript.getNearbyFollowers() ;getNearbyActors() 
  keyword zazCollar = Mods.zazKeywordWornCollar
  bool playerLooksLikeSlave = playerIsVictim || player.WornHasKeyword(zazCollar) || player.WornHasKeyword(libs.zad_InventoryDevice) ; ||  lets be lazy
  bool allPartnersLookLikeSlaves = true
  actor testActor
  int i = 0
  if !playerLooksLikeSlave 
    while i < sexActors.length && allPartnersLookLikeSlaves == true
      testActor = sexActors[i]
      if testActor != player
        allPartnersLookLikeSlaves = Mods.isSlave(testActor) ; this was once notcollar and notslave
      endif
      i += 1
    endWhile
    if allPartnersLookLikeSlaves
      adjustPerceptionPlayerDom( a, 2 , 10) ; TODO switch these for player set values
    endif
  else
    ; increment all thinks sub by two
    adjustPerceptionPlayerSub( a, 2 , 12)
  endif

endFunction

function adjustPerceptionPlayerSub(actor[] actors, float diffValue, float max = 10.0)
  int i = 0
  actor testActor = None
  while i < actors.length 
    testActor = actors[i]
    if testActor != None
      modThinksPlayerSub(testActor, diffValue, max)
    endif
    i += 1
  endWhile
endFunction

function adjustPerceptionPlayerDom(actor[] actors, float diffValue, float max = 10.0)
  int i = 0
  actor testActor = None
  while i < actors.length 
    testActor = actors[i]
    if testActor != None
      modThinksPlayerDom(testActor, diffValue, max)
    endif
    i += 1
  endWhile
endFunction

function adjustActorsArousal(actor[] actors, int diffValue)
  int i = 0
  int arousal = 0
  actor testActor = None
  while i < actors.length 
    testActor = actors[i]
    if testActor != None
      arousal = testActor.GetFactionRank(Mods.sexlabArousedFaction)    
      testActor.SetFactionRank(Mods.sexlabArousedFaction, (arousal + diffValue) as int)
    endif  
    i += 1
  endWhile
endFunction

; allows us to catch the calm caused by defeat, so we don't step on defeat
bool function isBusyDefeat(actor actorRef)
  ;if(Mods.modLoadedDefeat && (actorRef.HasMagicEffect(Mods.defeatCalmEffect) || \
  ;              actorRef.HasMagicEffect(Mods.defeatCalmAltEffect) ||\
  ;              actorRef.IsInFaction(Mods.defeatFaction) ) ) ; not sure why we need all three, but there it is
  ;  return true
  ;endif 
  ;return false
  if Mods.modLoadedDefeat
    return (actorRef.HasMagicEffect(Mods.defeatCalmEffect) || \
            actorRef.HasMagicEffect(Mods.defeatCalmAltEffect) ||\
            actorRef.IsInFaction(Mods.defeatFaction) ) 
  endif 
  return false
endFunction

; need specifics first
bool function isBusyMaria(actor actorRef)
  ; several quest stages should go here
  ;return ( player.&& &&)
  return false ; for now
endfunction

bool function isBusyMDevious(actor actorRef)
  return Mods.modLoadedMoreDevious && actorRef.IsInFaction(Mods.mdeviousBusyFaction)
endFunction

; for testing if the player is locked in chasity items
;  might apply to the attacker too later, 
; xaz detection incomplete
; we don't check for visibility of items here, we do that up above in the vulnerability detection
; remember, blocking needs to be true if MCM is off, since we test here
bool function isWearingChastity();actor actorRef)
  wearingBlockingGag      = false 
  wearingBlockingAnal     = false 
  wearingBlockingVaginal  = false 
  wearingBlockingBra      = false 
  wearingBlockingFull     = false 

  if player.wornHasKeyword(libs.zad_DeviousBelt) 
    if !player.wornhaskeyword(libs.zad_PermitVaginal)
      wearingBlockingVaginal  = true
    endif
    if !player.wornhaskeyword(libs.zad_PermitAnal)
      wearingBlockingAnal     = true
    endif 
  elseif player.wornHasKeyword(Mods.zazKeywordWornBelt) && MCM.bChastityZazBelt; make a MCM option for this one later
    wearingBlockingAnal       = true
    wearingBlockingVaginal    = true
  endif
  
  if  !MCM.bChastityBra || (player.wornHasKeyword(libs.zad_DeviousBra)); && MCM.bChastityBra)  ; bra
    wearingBlockingBra        = true
  endif
  
  if   (MCM.bChastityGag && (player.wornhaskeyword( libs.zad_DeviousGag ) && !(player.wornhaskeyword( libs.zad_PermitOral ) || player.wornhaskeyword( libs.zad_DeviousGagPanel )))) || \ 
     (MCM.bChastityZazGag && (player.wornHasKeyword( Mods.zazKeywordWornGag ) && !player.wornhaskeyword( libs.zad_DeviousGag ) && !player.wornHasKeyword( Mods.zazKeywordPermitOral ) ))
      
    wearingBlockingGag        = true
  endif   
  
  wearingBlockingFull = wearingBlockingAnal && wearingBlockingVaginal && wearingBlockingBra && wearingBlockingGag
  return                wearingBlockingAnal || wearingBlockingVaginal || wearingBlockingBra || wearingBlockingGag ; why did you cut out wearingBlockingGag?
endfunction

; we need to do more here bIsArmorNaked
bool function isNude(actor actorRef)
  ; Chest piece first, nothing else matters
  Form chest = player.GetWornForm(4)
  if   chest != None && (chest.HasKeyword(clothingKeywords[0]) || chest.HasKeyword(clothingKeywords[1])) \
    && StorageUtil.GetIntValue(chest, "SLAroused.IsNakedArmor", 0) == 0  ;32
    isNude = false
    return false
  endif

  ; checking armor on other sockets
  if MCM.bIsNonChestArmorIgnoredNaked 
    int index = 2 ; the light and heavy keywords
    While (index < clothingKeywords.length)
      if(actorRef.wornHasKeyword(clothingKeywords[index]))
        isNude = false
        return false
      endif
      index += 1
    EndWhile
  endif
  
  ; we need to make sure the armored curias thing isn't on a 3rd party armor from a different mod
  ; do this LAST, it's the slowest is why
  if player.WornHasKeyword(clothingKeywords[0]) || player.WornHasKeyword(clothingKeywords[1]) ; assumed 0 is armored, double check
    if MCM.bAltBodySlotSearchWorkaround == false
      debugmsg("WARNING: Player has Non-nude chest keywords, but on a non-chest item! Ignoring: alt search is off", 4)
    else  
      ;Float exp = 0
      int exp = 1
      Form armor_form = None
      Armor tmp_armor = None
      ; body is 0x04, so since we've already checked that, lets ignore it again
      ; 0x80X is FX01? Huh?
      ;Int[] slot_masks = [ 0x00000001 , 0x00000002 , 0x00000008 , \
      ;                     0x00000010 , 0x00000020 , 0x00000040 , 0x00000080 , \
      ;                     0x00000100 , 0x00000200 , 0x00000400 , 0x00000800 , \
      ;                     0x00001000 , 0x00002000 , 0x00004000 , 0x00008000 , \
      ;                     0x00010000 , 0x00020000 , 0x00040000 , 0x00080000 , \
      ;                     0x00100000 , 0x00200000 , 0x00400000 , 0x00800000 , \
      ;                     0x01000000 , 0x02000000 , 0x04000000 , 0x08000000 , \
      ;                     0x10000000 , 0x20000000 , 0x40000000 ] 
      ;while exp < 32.0
      ;  ; if the form has the keyword, and doesn't have the aroused protection
      ;  armor_form = player.getWornForm(pow(2.0,exp) as int)
      ;  if armor_form != None
      while exp < 2147483648 
        armor_form = player.getWornForm(exp)
        if armor_form != None 
          tmp_armor = armor_form as Armor
          if (tmp_armor.HasKeyword(clothingKeywords[0]) || tmp_armor.HasKeyword(clothingKeywords[1])) \
             && StorageUtil.GetIntValue(tmp_armor, "SLAroused.IsNakedArmor", 0) == 0  ;32
            isNude = false
            return false
          endif
        endif
        exp = exp * 2
      endwhile
    endif
  endif
  
  isNude = true
  return true
endFunction
  
; need to wait until vulnerability is done before we test weapon because of playerVulnerability setting
bool function isWeaponProtected()
  ; so long as we are not hands out while armed, and we do not have
  ;debugmsg("Rechecking weapon protection")
  bool notArmed = playerIsNotArmed()
  bool notRobed = playerIsNotWearingWizRobes()
  if (MCM.iWeaponHoldingProtectionLevel < playerVulnerability || notArmed) && \
      ( notRobed ) 
    weaponProtected = false
    return false
  endif 
  weaponProtected = true
  return true
endFunction
  
; is the player armed? can't remember why I set it to default negative
;  food for thought: the papyrus compiler can't rectify a double negative
bool function playerIsNotArmed()
  return player.GetEquippedWeapon() == None && player.GetEquippedWeapon(true) == None
  ;if  player.GetEquippedWeapon() != None || player.GetEquippedWeapon(true) != None ;||\
      ;player.GetEquippedSpell(0) != None || player.GetEquippedSpell(1) != None
      ; for now, we'll ignore shouts
    ;debugmsg("pina: Player is armed")
  ;  return false
  ;endif 
  ;return true
endFunction
  
bool function playerIsWeaponDrawnProtected()
  return  ( MCM.iWeaponWavingProtectionLevel >= playerVulnerability && player.IsWeaponDrawn() && \
            (( ! playerIsNotArmed() ) || \
            ( player.GetEquippedSpell(0) != NONE || player.GetEquippedSpell(1) != NONE )))
           
endFunction
  
; detects if the player is wearinga wizard robe, and is therefor dangerous like having a weapon
  ; two options: search against all possible robe models (double the gender, string search)
  ; or search through formlists for all robes
bool function playerIsNotWearingWizRobes()
  ; add necromancer robes here too
  ; and DLC robes, and blue/black robes
  if isNude == true
    return true
  endif
  Form wornForm = player.getWornForm(0x00000004)
  ; todo clean to return statement
  if WICommentCollegeRobesList.hasform(wornForm)
    return false
  endif
  return true
endFunction

; is the player weapon ready and holding weapons that you can see
; IE not just fists
;bool function playerIsNotWeaponDrawn()
;  if player.IsWeaponDrawn()
;    form f = player.
;  endif
;  return true
;endFunction


; pre-check on if the player is intimidating or presuasent enough to pass dialogue checks, 
;  downside: if a user knows how to use SQV they can look this result up in console before and know the result
;  advantage: one less dialogue fragment to call last second, we can run this before the approach even starts so no script lag interferance
function checkPersuationIntimidateRequirements()
  ; are we protected by intimidation
  if MCM.bIntimidateToggle
    ; using bollean modifiers because the math is faster than a bunch of condition checks if we have a lot of these
    float roll = Utility.RandomInt(1, 100) as float ; where < 50 is safe
    float oroll = roll as int
    if playerIsNotArmed() == false && MCM.bIntimidateWeaponFullToggle ; for now, can always intimidate with weapon
      hasMetIntimidateReq = true
    elseif playerVulnerability >= 4 || (wearingGag && MCM.bIntimidateGagFullToggle) 
      hasMetIntimidateReq = false
    else
      if wearingGag        
        roll -= (player.GetActorValue("Speechcraft") - 25) ; every point above 25 speech skill increases the chance intimidation is possible
      else 
        roll -= ((player.GetActorValue("Speechcraft") - 25) as float) / 2
      endif
      ; also if the player has speech perks
      ;roll = roll / (1 + (3  * (isWeaponProtected as int)))  ; if the player has weapon: chance * 4
      roll = roll * (1 + (0.5 * isNude as int))  ; if the player has no clothes on: chance is / 1.5
      ; we still need to modify the chance with gag presence here because there will be two possibilities
      
      
      if playerVulnerability == 2 ; if the player has playerVulnerability 2, / 2
        roll = roll * 2
      elseif playerVulnerability > 2 ; if player has playerVulnerability 3, / 3 ; we want more than that, but without the weapon protection...
        roll = roll * 3
      endif 
      debugmsg("initimidation roll: " + roll + " original: " + oroll, 2)
      hasMetIntimidateReq = (roll < 50)
    endif
  ;else 
    ;we don't need to unflag here because the dialogue won't show up anyway without the toggle
  endif
  ; are we protected by persuation?
  ; for now, I'll leave this blank since I'm not sure what conditions we should use
endFunction

function setCRDEBusyVariable(bool status = true)
  StorageUtil.SetFloatValue(player, "crdeBusyStatus", status as int)
endFunction
 
 ; --- debug and testing functions

; Plays a random DD bound animation, 
; BUG one of these won't reset on the player on certain enslavement events, IE CDx -> player keeps struggling during opening
function playRandomPlayerDDStruggle(int r = 0)
  ;if r <= -1 || r >= 7
  ;  r = Utility.Randomint(1,6)
  ;endif
  debugmsg("animations are broken right now, waiting for response from DDi dev team", 4)
  ; if r == 1
    ; libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS01) 
  ; elseif r == 2
    ; libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS02)   
  ; elseif r == 3
    ; libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS03)  
  ; elseif r == 4
    ; libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS04)  
  ; elseif r == 5
    ; libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS05)  
  ; elseif r == 6
    ; libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS06) 
  ; Endif
EndFunction

; debug, prints what animations we would get from sexlab given tags, based on what the player is wearing
; this is very old, hasn't been kept uptodate with the sex function so I doubt it still works correctly
function printPermitStatus()
  string animationTags = "aggressive"
  string supressTags   = "solo"
  
  ; we can optimize this out with a variable, since we have to check this earlier when we start the dialogue anyway
  if player.wornHasKeyword(libs.zad_DeviousBelt) 
  
    if !player.wornhaskeyword(libs.zad_PermitVaginal)
      supressTags += ",vaginal"
    endif
    if !player.wornhaskeyword(libs.zad_PermitAnal)
      supressTags += ",anal"
    endif
  endif
  if player.wornhaskeyword(libs.zad_DeviousGag) && !player.wornhaskeyword(libs.zad_PermitOral)
    supressTags += ",oral"
  endif
  sslBaseAnimation[] animations = SexLab.GetAnimationsByTag(2, animationTags, TagSuppress = supressTags)
  Debug.MessageBox(("animations:'" + animationTags +"',suppress tags:'" + supressTags+ "',animations available:" + animations.length))
  MCM.bPrintSexlabStatus = false
endFunction

function printVulnerableStatus()
  MCM.bPrintVulnerabilityStatus = false
  updatePlayerVulnerability()
  bool isNight = isNight()
  debugmsg("slave lvl: " + enslavedLevel + " vuln lvl: " + playerVulnerability, 3)
  debugmsg("Nude: " + isNude + " playerVulnerability: " + playerVulnerability,5)
  ;Debug.MessageBox("Wornboots: (" + wearingSlaveBoots + ") WornHarness: (" + wearingHarness + ") WornBukkake: (" + wearingBukkake + ")" )
 
  debugmsg("Worngag: (" + wearingGag + ") DDi armbinder: (" + player.WornHasKeyword(libs.zad_DeviousArmbinder) + \
  ") DDi yoke: (" + player.wornHasKeyword(libs.zad_DeviousYoke) + ") ZAZ animationoffset: (" +  player.wornHasKeyword(Mods.zazKeywordEffectOffsetAnim) + ") WornCollar: (" + wearingCollar +")", 5)
  debugmsg("Furniture: (" + NPCMonitorScript.checkActorBoundInFurniture(player) + ") Nudity: (" + isNude + ") MCM furniture: (" + MCM.iVulnerableFurniture +")",5)
  ; print worn stuff
  ; print playerVulnerability
  bool iswearingblockinggag = (!MCM.bChastityGag || (player.wornhaskeyword( libs.zad_DeviousGag ) && !(player.wornhaskeyword( libs.zad_PermitOral ) || player.wornhaskeyword( libs.zad_DeviousGagPanel ))))
  debugmsg("gag: (" + player.wornhaskeyword( libs.zad_DeviousGag ) \
       + ") permitoral: (" + player.wornhaskeyword( libs.zad_PermitOral ) \
       + ") permitoral: (" + player.wornhaskeyword( libs.zad_DeviousGagPanel )  \
       + ") MCM chastgag: (" + MCM.bChastityGag +") expr result: (" + iswearingblockinggag  \
       +") actual gag var: (" + wearingBlockingGag + ")",5)
  debugmsg("is NOT wizrobes: " + playerIsNotWearingWizRobes() + ", is nighttime: " + isNight() ,5)
endFunction

; searches for local NPCs and allows the player to pick one to count as valid race for future approaches
function appointValidRace()

  actor[] a = NPCSearchScript.getNearbyActorsLinear()
  
  UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
  
  int index = 0
  while index < a.length
    if a[index] != None
      menu.AddEntryItem(a[index].GetDisplayName())
    endif
    index += 1
  endWhile
  
  menu.AddEntryItem(" ** cancel **")
  menu.OpenMenu()
  int result = UIExtensions.GetmenuResultInt("UIListMenu")
  
  if result >= 0 && result < a.length
    if Mods.pointedValidRaces[9] != None ; race list is full
      Debug.Messagebox("ERROR: Your appointed valid race list is full, seriously?")
      return
    endif
    if a[result] == None
    Debug.Messagebox("ERROR: none race, nothing was added")
    endif
    Mods.addPointedValidRace(a[result].GetRace())
    Debug.Trace(a[result].GetDisplayName() + " is of race type: " + a[result].GetRace().GetName() + " and has been added to the DEC valid race list.")
  elseif result == a.length
    ; do nothing, was the cancel button
    debugmsg("cancel button pushed")
  else
    Debug.Messagebox("ERROR: returning index was the wrong size")
  endif
endFunction

; manually add followers to permanent list
;  "permanent" list is still reset on mods refresh though, might want to change that...
function addPermanentFollower()
  actor[] a = NPCSearchScript.getNearbyActorsLinear(500) ; range should be reasonably short
  
  UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
  
  int index = 0
  while index < a.length
    if a[index] != None && a[index].GetDisplayName() != ""
      menu.AddEntryItem(a[index].GetDisplayName())
    endif
    index += 1
  endWhile
  
  menu.AddEntryItem(" ** cancel **")
  menu.OpenMenu()
  int result = UIExtensions.GetmenuResultInt("UIListMenu")
  
  if result >= 0 && result < a.length
    actor tmp = a[result]
    if tmp == none
      Debug.Trace("ERR: Manual add failed because actor is NONE.")
      return 
    endif
    permanentFollowers.addForm(tmp)
    Mods.PreviousFollowers.addForm(tmp)
    tmp.addToFaction(crdeFormerFollowerFaction)
    reshuffleFollowerAliases(tmp)
    Debug.Trace(a[result] + " -> " + tmp.GetDisplayName() +" has been added to the DEC manually marked list of followers.")
  elseif result == a.length
    ; do nothing, was the cancel button
    debugmsg("cancel button pushed")
  else
    Debug.Messagebox("ERROR: returning index was the wrong size")
  endif
endFunction

; resets DHLP Suspend status
; ignores DEC set it in the first place, this can interfere with other mods 
;  (unlikely if the user is manually setting it to go off)
function resetDHLPSuspend()
  Mods.dhlpResume()
  debugmsg("resetDHLPSuspend called",1)
  clear_force_variables(true)
endFunction

function resetFollowerContainerCount(actor follower)
  if follower != None
    StorageUtil.SetIntValue(follower,"crdeFollContainersSearched", 0)
  else
    debugmsg("Err: follower to container reset is none")
  endif
endFunction
 
; deprecated, was used for ME but this function no longer exists in ME 2.0 anyway
;function testAbduction()
;  ; get nearby actor (maybe)
;  debugmsg("looking for actor")
;  Actor valid = NPCMonitorScript.getClosestActor(player)
;  ; start quest with new actor
;  if valid != None
;    debugmsg("Actor found, trying")
;    (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat2(valid)
;    MCM.bAbductionTest = false
;  endif
;    
;endFunction

; previously maria's eden init
; currently SD Sanguine's teleport test
function testInit()
  ;debugmsg("looking for actor")
  ;Actor valid = getClosestActor(player)
  ; start quest with new actor
  ;if valid != None
  ;  debugmsg("Actor found, trying")
  ;  (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat2(valid)
  ;  MCM.bAbductionTest = false
  ;endif
  ;Actor valid = NPCMonitorScript.getClosestActor(player)
  ;if valid != None
  ;  debugmsg("Actor found, trying")
  ;  (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat(valid)
  ;  MCM.bInitTest = false;
  ;endif

  if Mods.sdDreamQuest != None
    ;Mods.sdDreamQuest.StartQuest() ; ever thing about an event, or something else?
    ;SendModEvent("SDDreamworldPull", 100) ; doesn't work, maybe the dream sequence needs to be init first?
    SendModEvent("SDDreamworldPull") ; doesn't work, maybe the dream sequence needs to be init first?
    ;SendModEvent("SDDreamworldStart")
  endif
  
  MCM.bInitTest = false  
endFunction

; slaverun test
; deprecated, not longer used
;function testSlaverun()
;  if ( Mods.modLoadedSlaverunR ) ; might be redundant
;    MCM.bTestButton4 = false
;    ;(Quest.getQuest("crdeSlaverun") as crdeSlaverunScript).enslave()
;    ; put the next test here
;  endif
;endFunction

; test how far chase got with his pony function
function testPonyOutfit()
  ;equipPonygirlOutfit(player)
  player.SetOutfit(BlackPonyMixedOutfit)
  ;SlavetatsScript.testSlaveTats()
  MCM.bAbductionTest = false
endFunction

; now testing factions status
function testCD()
  ; for faction, add to string, print string
  
  string s = "Factions zbfslave:" + player.GetFactionRank(Mods.zazFactionSlave) \
           + " slavestate:" + player.GetFactionRank(Mods.zazFactionSlaveState)
  
  debugmsg(s,5)
  
endFunction

; generic test button
; testing: if we can remove blocking dcur items
function testTestButton1()
  
  player.unequipall()
  MCM.bTestButton1 = false

endFunction

; generic test button
; currently outfit test
; changed to nearest NPC AI reset test
; changed to animation test
function testTestButton2()
  
  ;equipPetGirlOutit(player)
  ;BallandChainRedOutfit.addform(Mods.zazBitGag) ; testing
  ;player.SetOutfit(BallandChainRedOutfit)
  ;MCM.bTestButton2 = false
  ; cursed loot tie me up function
 
  
  ;libs.PlayThirdPersonAnimation(player, libs.DDZaZAPCArmBZaDS01, 5)
  
  ;if libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS01)
  ;  debugmsg("Success")
  ;else
  ;  debugmsg("Failure")
  ;endif
  ;Utility.Wait(2)
  ;debugmsg("testing ZazAPCAO304",4)
  ;Debug.SendAnimationEvent(player, "ZazAPCAO304") ;arms back struggling
  ;Utility.Wait(2)
  ;Debug.SendAnimationEvent(player, "ZaZAPCSHFOFF")  ; shame cover up animation
  ;Utility.Wait(3)
  ;debugmsg("testing IdleForceDefaultState",4)
  ;Debug.SendAnimationEvent(player, "IdleForceDefaultState")
  
  UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
  actor[] a = NPCSearchScript.getNearbyActors()
  int index = 0
  while index < a.length
    if a[index] != None
      ;Debug.Messagebox(a[index].GetDisplayName() + " is of race type: " + a[index].GetRace().GetName() + " do you want to add to the list?")
      menu.AddEntryItem(a[index].GetDisplayName())
      ;debugmsg("     actor "+ a[index].GetDisplayName() + " was index " + index)
    endif
    index += 1
  endWhile
  menu.AddEntryItem(" ** cancel **")
  menu.OpenMenu()

  int result = UIExtensions.GetmenuResultInt("UIListMenu")
  
  if result >= 0 && result < (a.length - 1)
    actor target = a[result]
    ActorUtil.ClearPackageOverride(target)
    Debug.Notification("attempting to reset AI package of target: " + target.GetDisplayName())
  elseif result == a.length - 1
    ; do nothing, was the cancel button
    debugmsg("cancel button pushed")
  else
    Debug.Messagebox("ERROR: returning index was the wrong size")
  endif
  
endFunction

  
; generic test button
function testTestButton3()
  ;Armor test = libs.GetGenericDeviceByKeyword(libs.zad_DeviousCollar)
  ;if test == None
  ;  debugmsg("Item was None")
  ;else
  ;  debugmsg("Item received: " + test.GetName())
  ;  player.additem(test)
  ;endif
  
  ;    debugmsg("Key received for transparent: " + test.GetName()) restraints
  ;    debugmsg("Key received chains: " + test.GetName()) restraints
  ;    debugmsg("Key received for rubber slave: " + test.GetName()) body restraints
  ;    debugmsg("Key received belt of shame: " + test.GetName()) law enforcement
  ;    debugmsg("Key received for sasha belt: " + test.GetName()) sasha belt key
  ;    debugmsg("Key received protection belt: " + test.GetName()) None

  ;71049ABE ;280B31A3 
  
  ; lets convert this to check every item
  int exp = 1
  Form armor_form = None
  Armor tmp_armor = None
  Key tmp_key = None
  while exp < 2147483648 
    armor_form = player.getWornForm(exp)
    if armor_form != None 
      tmp_armor = armor_form as Armor
      if (tmp_armor.HasKeyword(libs.zad_InventoryDevice) || tmp_armor.HasKeyword(libs.zad_BlockGeneric)) 
        tmp_key = libs.GetDeviceKey(tmp_armor)
        debugmsg("Key needed for " + tmp_armor.GetName() + " is:" + tmp_key.GetName())
        ;player.additem(tmp_key)
      endif
    endif
    exp = exp * 2
  endwhile
  
  ; Key test = libs.GetDeviceKey(Game.GetFormFromFile(0x7109F2C9, "Deviously Cursed Loot.esp") as Armor)
  ; if test == None
    ; debugmsg("Item was None")
  ; else
    ; debugmsg("Key received for sasha belt: " + test.GetName())
    ; player.additem(test)
  ; endif
  
  ; test = libs.GetDeviceKey(Game.GetFormFromFile(0x280B31A5 , "Captured Dreams.esp") as Armor)
  ; if test == None
    ; debugmsg("Item was None")
  ; else
    ; debugmsg("Key received protection belt: " + test.GetName())
    ; player.additem(test)
  ; endif

endFunction

; generic test button
; testing a blackout leading to a multi-item stage
function testTestButton4()

  ; disable player controls
  ;Game.DisablePlayerControls()
  ;Game.ForceThirdPerson()
  ; player is knocked to the ground animation
  ;Debug.SendAnimationEvent(player, "bleedOutStart")
  ; sudden black 
  ;DistanceEnslave.BlackFade.ApplyCrossFade(0.5) ; testing if instant
  ;DistanceEnslave.BlackFadeSudden.Apply()
  ;player.SetActorValue("Paralysis",1)
  ;player.PushActorAway(Game.GetPlayer(), 0)
  ;Utility.Wait(3)
  ;maybe steal some items, or something
  
  ;add items
  ;ItemScript.equipRandomMultipleDD(player)
  
  ; time skip
  
  ; fade back to clear
  ;Utility.Wait(2)
  ;DistanceEnslave.LightFade.ApplyCrossFade(3)
  ; getting up animation
  ; messagebox
  ;Utility.Wait(7)
  ;player.SetActorValue("Paralysis",0)
  ;Utility.Wait(3)
  ;Debug.Messagebox("You wake up with a headache, and find yourself in bondage! Who could have done this?") ; TODO: this needs more clarity
  ;re-enable controls
  ; Utility.Wait(4)
  ;Game.EnablePlayerControls()

  movePlayerToBed(player)
  
  MCM.bTestButton4 = false
endFunction

;test random DD
function testTestButton5()
  ;DistanceEnslave.enslaveIsleOfMara()
  ItemScript.equipRandomDD(player)
  Debug.Notification("Testing add item ...")
  ;MCM.bTestButton4 = false
endFunction

; sixth test function currently "SD distance start"
function testTestButton6()
  debugmsg("resetting approach before SD+", 1)
  clear_force_variables()
  DistanceEnslave.distantSD()
  MCM.bTestButton6 = false
  ;Mods.dhlpSuspend()
endFunction

; old:test PO arrest
; generic test button function 7
function testTestButton7()  
  ;  (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat(valid)
  ;akSpeaker.
  ;SendModEvent("xpoArrestPC", "", 700)
  
  ;endif
  ;(Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat(valid)
  ;DistanceEnslave.enslaveDCURBondageAdv()
  ; Chest piece first, nothing else matters
  ;Form f = player.GetWornForm(32)
  ;int i =2
  ;Armor a
  ;while i < 60
  ;  a = None
  ;  a = player.GetWornForm(i) as Armor
  ;  int status = StorageUtil.GetIntValue(a, "SLAroused.IsNakedArmor", 0)
  ;  debugmsg("isNude: item in slot " + i +": " + a.getName() + " and the status is " + status )
  ;  i += 1
  ;endwhile
  
  ; if Mods.modLoadedCursedLoot
    ;equipPunishmentBeltAndStuff()
    ; DistanceEnslave.enslaveLeon2()
    ;debugmsg("", 5)
  ; else
    ; debugmsg("Cursed loot is not installed", 5)
  ; endif
  
  ; test if spell casting can work


  ;if a.length > 0
  ;  ;debug.Notification("will test actor " + a[0] + " casting spell " + s + " at player")
  ;  ;Spell s = Game.GetFormFromFile(0x0004DEE9, "Skyrim.esm") as Spell ; calm
  ;  Spell s = Game.GetFormFromFile(0x0004d3f2, "Skyrim.esm") as Spell
  ;  if s
  ;    debug.Notification("will test actor " + a[0] + " casting spell " + s + " at player")
  ;    s.Cast(a[0], player)
  ;  else
  ;    debugmsg("spell did not load")
  ;  endif
  ;endif
  
    
  ;actor[] a = NPCSearchScript.getNearbyFollowers() ;getNearbyActors
  ;int min_relationship = MCM.iFollowerRelationshipLimit.GetValueInt() ; explicit because compiler will check it every loop iteration otherwise
  ;int i = 0
  ;while i < a.length
  ;  actor actorRef = a[i]
  ;  if actorRef != None && NPCSearchScript.actorIsFollower(actorRef, min_relationship)
  ;    debugmsg("follower " + actorRef.GetDisplayName() + " is " + NPCSearchScript.actorIsFollower(actorRef, min_relationship))
  ;    int actor_sex     = actorRef.GetActorBase().getSex()
  ;    int gender_pref   = MCM.iGenderPref
  ;    debugmsg("results: gender: " + (!( actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)) as string \
  ;            + " current faciton: " + actorRef.IsInFaction(CurrentFollowerFaction) as string \
  ;            + " relationship: " + (actorRef.GetRelationShipRank(player) >= min_relationship) as string \
  ;            + " actual/limit: " + actorRef.GetRelationShipRank(player) as string + "/" + min_relationship as string \
  ;            + " PAH following: " + actorRef.IsInFaction(Mods.paradiseFollowingFaction) as string \
  ;            + " PAH not restaints: " + !(actorRef.WornHasKeyword(Mods.paradiseSlaveRestraintKW)) as string \
  ;            + " PAH not tied: " + !(Mods.PAHETied && actorRef.IsInFaction(Mods.PAHETied)) as string \
  ;            + " special: " + ((actorRef.IsInFaction(CurrentFollowerFaction) || (actorRef.GetRelationShipRank(player) >= min_relationship)) \
  ;               || (Mods.modLoadedParadiseHalls && actorRef.IsInFaction(Mods.paradiseFollowingFaction) \
  ;               && !actorRef.WornHasKeyword(Mods.paradiseSlaveRestraintKW) && !(Mods.PAHETied && actorRef.IsInFaction(Mods.PAHETied)))\
  ;                ) as string )      

  ;  endif

  ;  i += 1
  ;endWhile
  ;;;;;;;;;;;;;;;;;;;;;;;;;;; old test ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; actor[] nearby = NPCSearchScript.getNearbyFollowers()
  ; actor[] followers = new actor[15]
  ; actor[] slaves = new actor[15]
  ; int s = 0
  ; int f = 0
  
  ; int i = 0
  ; While i < nearby.length
    ; if nearby[i] != None
      ; if nearby[i].IsInFaction(NPCSearchScript.CurrentFollowerFaction)
        ; followers[f] =  nearby[i]
        ; f += 1
      ; else
        ;can we assume slaves from just this? Might need to reeval code
        ; slaves[s] =  nearby[i]
        ; s += 1
      ; endif
    ; endif
    ; i += 1
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;; old test ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
      
  ; crdeRescueFollowersScript getback = Quest.GetQuest("crdeRescueFollowers") as crdeRescueFollowersScript
  ; getback.addFollowersAndSlaves(followers, slaves)
  ; getback.Start()
  
  ; MCM.bTestButton7 = false
  ; int i = 0
  ; while true
    ; playRandomPlayerDDStruggle(i)
    ; debugmsg("Playing animation number: " + i, 4)
    ; if i >= 6
      ; i = 0
    ; else
      ; i += 1   
    ; endif
    ; Utility.Wait(5)
  ; endWhile
  
  ;Cell c = player.GetParentCell()
  ; ObjectReference [] containers = new ObjectReference [15]
  ; ObjectReference  test_form
  ; int index = 0
  ; int booknum = 0
  ; Int NumRefs = c.GetNumRefs(28)
  ; String output = ""
  ; Keyword bookshelf = Game.GetFormFromFile(0x000d5abe, "Skyrim.esm" ) as Keyword
  ; Book deviousbook = Game.GetFormFromFile(0x09029ADC, "Devious Devices - Integration.esm" ) as Book
  ; debugmsg("stuff: " + bookshelf.GetName() + " " + deviousbook.GetName() )
  ; While NumRefs > 0  && index < 15
    ; NumRefs -= 1
    ; test_form = c.GetNthRef(NumRefs, 28) as ObjectReference 
    ; output = output + test_form.GetDisplayName() + " +"
    ;; test_form.AddItem(deviousbook) ; works fine
    ;; Container testc = (test_form as Form) as Container
    ; if test_form.HasKeyword(bookshelf)
      ; booknum += 1
    ; endif
  ; EndWhile 
  ; debugmsg("Containers: " + output)
  ; debugmsg("Books: " + booknum)
  
  ; search for nearby npc check if they are in scene
  ;actor[] nearby = NPCMonitorScript.getClosestActor(player)
  
  ; int searchIndex   = 0
  ; int npcIndex      = 0
  ; actor npcActor    = none
  ; Actor[] nearby = new Actor[40]
  ; Cell c = player.GetParentCell()
  ; int foundActorCount = c.GetNumRefs(43) 
  
  ; while searchIndex < foundActorCount 
    ; npcActor = c.GetNthRef(searchIndex, 43) as actor
    ; nearby[npcIndex] = npcActor ; elegible, return now, we don't need anything more from this function
    ; npcIndex += 1
    ; searchIndex += 1
  ; endWhile

  ; int i = 0
  ; while i < searchIndex ;&& nearby[i] != None
    ; if nearby[i] == None
      ; debugmsg("NPC is none: " + i)
    ; else
      ; package p = nearby[i].GetCurrentPackage()
      ; if p
        ; String  pn = ""
        ; quest q = p.GetOwningQuest()
        ; String  qn = ""
        ; if q
          ; qn = q.GetName()
        ; endif

        ; String st = " <no scene>"
        ; scene s = nearby[i].GetCurrentScene()
        ; if s 
          ; st = " and is in scene: " + s
        ; endif
        ; debugmsg("NPC " + nearby[i].GetDisplayName() +\
                 ; " has AI package:" + p +\
                 ; " from quest:"  + q + " " + qn +\
                 ; st )
        ; endif
    ; endif
    ; i += 1
  ; endWhile
  
  ; look for nearby pillory and try to lock player to it
  ; Cell c = player.GetParentCell()
  ; Int NumRefs = c.GetNumRefs(28)
  ; ObjectReference test_form
  ; ObjectReference[] available_furn = new ObjectReference[15]
  ; Int       furn_position = 0
  ; Keyword furn = Game.GetFormFromFile(0x0000762b, "ZaZAnimationPack.esm") as Keyword
  ; While NumRefs > 0 && furn_position < 15
    ; test_form = c.GetNthRef(NumRefs, 40) as ObjectReference 
    ; if test_form && test_form.HasKeyword(furn)
      ; debugmsg("Found zaz furniture: " + test_form)
      ; available_furn[furn_position] = test_form
      ; furn_position += 1
    ; endif
     ; NumRefs -= 1
  ; EndWhile 
  ; if furn_position == 0 
    ; debugmsg("no nearby furniture found")
  ; else
    ; ObjectReference randomly_chosen = available_furn[Utility.RandomInt(0, furn_position - 1)] 
    ; debugmsg("setting as vehicle: " + randomly_chosen)
    ; player.SetVehicle(randomly_chosen)
  ; endif

  ;ItemScript.equipArousingPlugAndBelt(player)
  doPlayerSexFull(followerRefAlias02.GetActorRef(), followerRefAlias01.GetActorRef())

  
  Debug.Notification("Test has completed.")
  MCM.bTestButton7 = false
endFunction

; debug for checking if DEC can detect present tattoes on the player's body
function testTattoos()
  if Mods.modLoadedSlaveTats
    SlavetatsScript.detectTattoos()
    debugmsg("tattoo status detected: slave:[" + SlavetatsScript.wearingSlaveTattoo +\
              "], with face:[" + SlavetatsScript.wearingSlaveTattooFace+\
              "], slut:["  + SlavetatsScript.wearingSlutTattoo +\
              "], with face:[" + SlavetatsScript.wearingSlutTattooFace + "]", 4) 
  endif
endFunction  

; prints a debug message, where level determines where it gets printed
function debugmsg(string msg, int level = 0)
  msg = "[CRDE] " + msg
    
    if level == 1 && MCM.bDebugStateVis         ; states/stages, shows up in trace IF debug is set
      if MCM.bDebugMode == true 
        if MCM.bDebugConsoleMode
          MiscUtil.PrintConsole(msg)
        else  
          Debug.Notification(msg)
        endif
        Debug.Trace(msg)
      endif
    elseif level == 2 && MCM.bDebugRollVis      ; rolling information
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
    elseif(level == 4)                          ; important: record if debug is off, notify user if on as well
      Debug.Trace(msg, 1)
      MiscUtil.PrintConsole(msg)
      if(MCM.bDebugMode == true)
        Debug.Notification(msg)
      endif
    elseif(level == 5)                          ; very important, errors
      Debug.Trace(msg, 2)
      if(MCM.bDebugMode == true)
        MiscUtil.PrintConsole(msg)
        Debug.MessageBox(msg)
      endif
    else  ; if level == 0 || else               ; debug. print in console so we can see it as needed
      if MCM.bDebugMode == true 
        if MCM.bDebugConsoleMode
          MiscUtil.PrintConsole(msg)
        else
          Debug.Notification(msg)
        endif
        Debug.Trace(msg)
      endif
    endif
endFunction

; contains extra functionality that should be performed in OnUpdate() but infrequently/low volume
; proposed rename to tryExtra, or something to reflect that it's not just for debug anymore
function tryDebug()

  if MCM.bAddFollowerManually
    addPermanentFollower()
    MCM.bAddFollowerManually = false
  endif
  if MCM.bPrintSexlabStatus
    printPermitStatus()
  endif
  if MCM.bPrintVulnerabilityStatus
    printVulnerableStatus()
  endif
  if MCM.bResetDHLP
    resetDHLPSuspend()
  endif
  if MCM.bRefreshSDMaster
    refreshSDMaster()
  endif
  ;if Mods.bRefreshModDetect
  ;  debugmsg("Resetting mod detection ...", 4)
  ;  Mods.finishedCheckingMods = false
  ;  Mods.updateForms()
  ;  Mods.checkStatuses()
  ;  debugmsg("Finished resetting mod detection.", 4)
  ;  Mods.bRefreshModDetect = False
  ;endif
  if MCM.bSetValidRace
    appointValidRace()
    MCM.bSetValidRace = false
  endif
  if MCM.bTestTimeTest
    timeTest()
  endif  
  if MCM.bAbductionTest
    ;testAbduction()
    testPonyOutfit()
  endif  
  if MCM.bInitTest
    testInit()
  endif  
  if MCM.bTestTattoos
    testTattoos()
  endif
  if MCM.bTestButton1
    testTestButton1()
  endif
  if MCM.bTestButton2
    testTestButton2()
  endif
  if MCM.bTestButton3
    testTestButton3()
  endif
  if MCM.bTestButton4
    testTestButton4()
    ;testSlaverun()
    ;testPonyOutfit()
    
  endif  
  if MCM.bCDTest
    testCD()
  endif  
  if MCM.bTestButton5
    testTestButton5()
  endif
  if MCM.bTestButton6
    testTestButton6()
  endif
  if MCM.bTestButton7
    testTestButton7()
  endif

endFunction

; tests the speed of various critical components of the main loop (Onupdate())
; this hasn't been updated in a long time (version 9?) keep that in mind if you actually use this for testing
function timeTest()
  ;timePlayerBusy timeGetClosestActor timeCheckDevices timeUpdateVulnerabiltiy timeCheckBukkake timePlayerEnslaved timeRollingWithModifiers
  
  MCM.bTestTimeTest = false 
  Debug.Messagebox("Starting time test, please remain static, and don't open menus or console while this runs, to keep times as accurate as possible")
  
  float timePlayerBusy = Utility.GetCurrentRealTime()
  isPlayerBusy()
  timePlayerBusy = Utility.GetCurrentRealTime() - timePlayerBusy
  
  float timeGetClosestActor = Utility.GetCurrentRealTime()
  actor[] nearest = NPCMonitorScript.getClosestActor(player)
  timeGetClosestActor = Utility.GetCurrentRealTime() - timeGetClosestActor
  
  float timeGetClosestRefActor = Utility.GetCurrentRealTime()
  actor[] nearest2 = NPCMonitorScript.getClosestRefActor(player)
  timeGetClosestRefActor = Utility.GetCurrentRealTime() - timeGetClosestRefActor
  
  float timeCheckDevices = Utility.GetCurrentRealTime()
  CheckDevices()
  timeCheckDevices = Utility.GetCurrentRealTime() - timeCheckDevices
  
  float timeUpdateVulnerabiltiy = Utility.GetCurrentRealTime()
  updatePlayerVulnerability()
  timeUpdateVulnerabiltiy = Utility.GetCurrentRealTime() - timeUpdateVulnerabiltiy
  
  float timeCheckBukkake = Utility.GetCurrentRealTime()
  CheckBukkake() 
  timeCheckBukkake = Utility.GetCurrentRealTime() - timeCheckBukkake
  
  float timePlayerEnslaved = Utility.GetCurrentRealTime()
  Mods.isPlayerEnslaved()
  timePlayerEnslaved = Utility.GetCurrentRealTime() - timePlayerEnslaved
  
  ;;;; rolling copy paste (because abstracting three floats to global hurts the compiler spilling
  float timeRollingWithModifiers = Utility.GetCurrentRealTime()
  if nearest[0] == none ;|| isActorIneligable(nearest[0]) == false ; already called in the search
    nearest[0] = player
    ;return
  endif
  
  float rollEnslave  = Utility.RandomInt(1,100)
  ;float rollTalk    = Utility.RandomInt(1,100)
  float rollSex      = Utility.RandomInt(1,100) 
    
  bool isSlaveTrader = Mods.isSlaveTrader(nearest[0]) 
  if(isSlaveTrader)
    ;rollEnslave  = 1
    ;rollTalk     = 1
    ;rollSex       = 1
    rollEnslave   = (rollEnslave      / MCM.fModifierSlaverChances)
    ;rollTalk       = (rollTalk          / MCM.fModifierSlaverChances)
    rollSex       = (rollSex          / MCM.fModifierSlaverChances)
  endif
  
  ; if wearingPartialChasity
  ; use two variables set by the full check function, then you can test either or
  ; partial results in some increase?
  ;bool isWearingChastity = isWearingChastity()
  if MCM.bChastityToggle
    ; if attacker has keys, increase all chances
    ; else, no keys, sex = 0
    debugmsg("chastity:" + wearingBlockingFull + ": a:" + wearingBlockingAnal + " b:" + wearingBlockingBra + " g:" + wearingBlockingGag, 3)
    if wearingBlockingFull 
    ; all items
      if (nearest[0].GetItemCount(libs.restraintsKey) > 0) || (nearest[0].GetItemCount(libs.chastityKey) > 0)
        rollSex     = rollSex     /  MCM.fChastityCompleteModifier
      else 
        rollSex     = 101         ; impossible
      endif
      ;rollTalk       = rollTalk    /  MCM.fChastityCompleteModifier
      rollEnslave   = rollEnslave /  MCM.fChastityCompleteModifier
    elseif wearingBlockingAnal || wearingBlockingVaginal || wearingBlockingBra || wearingBlockingGag
    ; partial chastity, but not complete
      rollSex       = rollSex     /  MCM.fChastityPartialModifier
      ;rollTalk       = rollTalk    /  MCM.fChastityPartialModifier
      rollEnslave   = rollEnslave /  MCM.fChastityPartialModifier
    
    endif
    ; do nothing, not wearing chastity
  endif
  timeRollingWithModifiers = Utility.GetCurrentRealTime() - timeRollingWithModifiers
  ;;; rolling copy paste end
  
  float timeSlavetats = Utility.GetCurrentRealTime()
  if MCM.iVulnerableSlaveTattoo || MCM.iVulnerableSlutTattoo 
    SlavetatsScript.detectTattoos(); for now
  endif
  bool isTattooVulnerable = (MCM.iVulnerableSlaveTattoo && (SlavetatsScript.wearingSlaveTattoo && (isNude || !MCM.iNakedReqSlaveTattoo || isSlaveTrader))) || \
                            (MCM.iVulnerableSlutTattoo && (SlavetatsScript.wearingSlutTattoo && (isNude || !MCM.iNakedReqSlutTattoo || isSlaveTrader))) ; and for slave
  timeSlavetats = Utility.GetCurrentRealTime() - timeSlavetats
  
  
  ;moved out because easier to read spread out like this
  String str = "Time results (seconds) isPlayerBusy: " + timePlayerBusy +\
               " GetClosestActor: " + timeGetClosestActor +\
               " GetClosestRefActor: " + timeGetClosestRefActor +\
               " CheckDevices: " + timeCheckDevices  +\
               " updatePlayerVulnerability: " + timeUpdateVulnerabiltiy  +\
               " CheckBukkake: " + timeCheckBukkake  +\
               " isPlayerEnslaved: " + timePlayerEnslaved  +\
               " Enslave/sex rolling: " + timeRollingWithModifiers +\
               " Time checking slavetats: " + timeSlavetats
  ;debugmsg(str, 5)
  Debug.Trace(str)
  Debug.MessageBox(str) 
   
  Utility.Wait(1) 
  if  nearest2[0] == None
    debugmsg("no nearby attackable NPCs")
  else
    NPCMonitorScript.timeTestActorTraits(nearest2[0])
  endif
   
  ;debugmsg("player busy:" + (Utility.GetCurrentRealTime() - timePlayerBusy))
endFunction
 
function resetCameraFadeout()
endFunction
 
; make sure they aren't dead, and the next one needs to match gender restrictions
function refreshSDMaster()
  Debug.Notification("Reseting next distance SD master ...");

  actor previous = DistanceEnslave.SDNextMaster 
  
  actor[] a = DistanceEnslave.SDMasters
  int a_index = 0 ; if we need to rebuild list
  
  UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu

  int gender_pref   = MCM.iGenderPrefMaster
  int actor_sex     = 0
  bool usesexlabgender = MCM.bUseSexlabGender
  int old_length = DistanceEnslave.SDMasters.length ; less property fetching
  if gender_pref != 0 ; we need to rebuild the potential master list to match genders
    a = new actor[32] ; old length
    int old_position = 0
    actor tmp = None
    while old_position < old_length
      tmp = DistanceEnslave.SDMasters[old_position]
      if usesexlabgender
        actor_sex     = SexLab.GetGender(tmp)
      else
        actor_sex     = tmp.GetActorBase().getSex()
      endif   
      if( actor_sex == 0 && gender_pref == 2) || (actor_sex == 1 && gender_pref == 1)
        ; wrong gender
      else
        a[a_index] = tmp
        a_index += 1
        menu.AddEntryItem(tmp.GetDisplayName())
      endif
      old_position += 1
    endWhile
    menu.AddEntryItem(" * reminder: gender restriction is on*")

  else ; no gender restriction, just use the list we already have
    int index = 0
    while index < a.length
      if a[index] != None
        menu.AddEntryItem(a[index].GetDisplayName())
      endif
      index += 1
    endWhile
    a_index = a.length
  endif
      
  menu.AddEntryItem(" ** random **")
  menu.AddEntryItem(" ** cancel **")
  
  menu.OpenMenu() ; kinda a weird way to do this, wouldn't you just open teh menu and grab the result, not open menu, return, then wait for a response?
  int result = UIExtensions.GetmenuResultInt("UIListMenu")
  
  if a[result].isDead() 
    Debug.MessageBox("The actor you selected: " + a[result] + " is dead, and cannot be used")
  elseif result >= 0 && result < a_index
    ; valid choice
    DistanceEnslave.SDNextMaster = a[result]  
    Debug.MessageBox("Next distance SD master set is " + a[result].GetDisplayName() +", wasPreviously:" + previous.GetDisplayName() + ", Last master:" + DistanceEnslave.SDPreviousMaster.GetDisplayName())
  elseif result <= a_index + 1
    debugmsg("random button pushed, selecting at random ...", 0) 
    Debug.Notification("Random SD Master assigned")
    DistanceEnslave.SDNextMaster = a[Utility.RandomInt(0, a_index)] 
  elseif result <= a_index + 2
    ; do nothing, was the cancel button
    debugmsg("cancel button pushed, quitting") 
  else
    Debug.Messagebox("ERROR: returning index was the wrong size")
  endif
  
  ; open list with all known masters
  ;DistanceEnslave.selectNextSDMaster()
  ;string name = "*None"
  ;if next != None
  ;  name = next.GetDisplayName()
  ;endif 
  ;Debug.MessageBox("Next distance SD master set is " + DistanceEnslave.SDNextMaster.GetDisplayName() +", wasPreviously:" + name + ", Last master:" + DistanceEnslave.SDPreviousMaster.GetDisplayName())
  MCM.bRefreshSDMaster = false
endFunction

bool function isNight()
  float Time = Utility.GetCurrentGameTime()
  Time -= Math.Floor(Time); Remove "previous in-game days passed" bit
  Time = (Time * 24) ; Convert from fraction of a day to number of hours
  return (Time >= 20 || Time < 5)
endFunction

; this exists here so that we can start combat from dialogue with the same function
; also StartCombat() wouldn't compile in a fragment according to my old comments, odd.
function StartCombat(actor Attacker)
  ; works, but we want brawl rather than actual combat since they die from guards alot
  ;Attacker.StartCombat(player)
  
  ; testing 
  ; taken from mod: Fighting words
  ;BrawlKeyword.SendStoryEvent(None, pTarget, pTargetFriend)
  BrawlKeyword.SendStoryEvent(None, Attacker, None)
  
  
endFunction

; was going to be used for stalker and follower-drags-you-home concepts, both stalled
function movePlayerToBed(actor other)
  ; find bed
  ; move player to top/middle of bed

  ; disable player controls?
  
  ; ThreadModel.CenterOnBed(false, 4096) ; doesn't work without the thread being active it seems
  ObjectReference FoundBed = Sexlab.FindBed(player, 4096) 
  debugmsg("found bed returned:" + FoundBed)
  if FoundBed 
    player.MoveTo(FoundBed)
  endif
  
  Utility.wait(1)
  player.equipItem(Mods.zazBitGag) 
  player.equipItem(Mods.zazCollar) 
  
  Debug.SendAnimationEvent(player, "ZazAPC054") ;back spread

  Game.DisablePlayerControls()
  
  ; teleport in attacker
  actor attacker = Mods.dcurLeonActor
  attackerRefAlias.forceRefTo(attacker)
  attacker.moveto(player)
  
  ;attacker says stuff
  
  ;sex
  
  ;catch postsex and make him disappear or do more stuff
  
endFunction

; assuming we want more than one follower, but we don't want to populate all aliases everytime, just use them as a buffer
function reshuffleFollowerAliases(actor mostRecent)
  
  if followerRefAlias01 == None
    followerRefAlias01.forceRefTo(mostRecent)
  else
    actor tmp = followerRefAlias01.GetActorRef()    
    if tmp == None
      ; do nothing
    elseif followerRefAlias02 == None || mostRecent == tmp
      followerRefAlias02.forceRefTo(tmp)
    else
      ; we need to shift whether the last one is free or not, additional logic only hurts us
      followerRefAlias03.forceRefTo(followerRefAlias02.GetActorRef())
      followerRefAlias02.forceRefTo(tmp)
    endif
    followerRefAlias01.forceRefTo(mostRecent)
  endif

  if ! mostRecent.IsInFaction(crdeFormerFollowerFaction)
    mostRecent.addToFaction(crdeFormerFollowerFaction)
  endif

endFunction

; form rather than armor because we use this same function for keys
; this is called by the container perk
; TODO: if this is too heavy, turn it into a modevent, which offloads it onto a different thread, might be nicer to the engine
;       OR shove everything into a list and check everything at cycle time
function addToFollowerFoundItems(form[] foundItems, objectReference itemContainer)
  if itemContainer == None
    debugmsg("error adding items because container is NONE: " + itemContainer)
    return NONE
  endif

  while followerItemsArraySemaphore ; locked, another process is busy with this, we can't add items right now
    ; if this gets stuck at weird places, we COULD make this a timestamp instead, where > 0 is active, and then count when it was set and reset if taking too long
    Utility.Wait(0.3)
  endWhile 
  ; not locked (anymore), our turn
  followerItemsArraySemaphore = true
  ;debugmsg("locking semiphore")

  int len = 0
  form tmp = None
  while len < foundItems.length
    tmp = foundItems[len]
    ;debugmsg("Checking item: " + tmp.GetName() + " in container: " + itemContainer)
    ; if it's a key, roll for chance to add it to follower's inventory
    
    if tmp != None && ! tmp.HasKeyword(libs.zad_BlockGeneric)
      followerFoundDDItems[followerFoundDDItemsIndex] = tmp
      followerFoundDDItemsContainers[followerFoundDDItemsIndex] = itemContainer
      debugmsg("adding item: " + tmp.GetName() );+ " in container: " + itemContainer)
      followerFoundDDItemsIndex = (followerFoundDDItemsIndex + 1) % 32 ; wraparound, lets just keep a full list of previous items as a circular array
    endif
    len += 1
  endWhile
  
  followerItemsArraySemaphore = false  
  ;debugmsg("releasing semiphore")

endFunction

Armor[] Property ponyGearDD  Auto 
Armor[] Property ponyGearZaz  Auto 

Armor[] Property petGear  Auto  ; ebonite collar should be in the back

Outfit Property BallandChainRedOutfit Auto
Outfit Property BlackPonyMixedOutfit Auto

Key[] Property deviousKeys  Auto  

Keyword[] Property clothingKeywords  Auto  

Armor[] Property randomDDs  Auto  

Keyword[] Property randomDDs_keywords  Auto  

Armor[] Property randomDDxCuffs  Auto  
Armor[] Property randomDDxRGlovesBoots  Auto 
Armor[] Property randomDDxHarnesss  Auto  
Armor[] Property randomDDVagPlugs  Auto  
Armor[] Property randomDDVagPiercings  Auto 
Armor[] Property randomDDGags  Auto  
Armor[] Property randomDDCollars  Auto  
Armor[] Property randomDDArmbinders  Auto  
; punishment version
Armor[] Property randomDDPunishmentVagPlugs  Auto  
Armor[] Property randomDDPunishmentVagPiercings  Auto 

;Int[] Property slot_masks Auto

Keyword[] Property ponyGear_keywords  Auto  

Race[] Property alternateRaces Auto

; todo, break this into individual keywords, since the creation kit is a fickle bitch
Keyword[] Property deviceKeywords  Auto 

Formlist Property WICommentCollegeRobesList Auto

Keyword Property LocTypePlayerHouse Auto

; moral cities
Worldspace Property solitudeSpace Auto 
Worldspace Property windhelmSpace Auto
; dawnstar is too cold

;immoral cities
Worldspace Property whiterunSpace Auto ; used with slaverun
Worldspace Property markarthSpace Auto ; used with slaverun
;Worldspace Property riftenSpace Auto ; used with slaverun

Race Property WerewolfBeastRace Auto

Keyword Property BrawlKeyword  Auto  

Faction Property crdeFormerFollowerFaction Auto
