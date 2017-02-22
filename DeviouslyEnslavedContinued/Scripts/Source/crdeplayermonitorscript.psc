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
int Property vulnerability          Auto Conditional ; 0 : free, 1 : collar, 2 : collar+gag/blindfold, 3 : armbinder
int Property clothingVulnerability  Auto Conditional
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

bool Property wearingWeapon          Auto Conditional
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

bool 	Property forceGreetIncomplete   Auto Conditional
int 	Property forceGreetSlave        Auto Conditional
int 	Property forceGreetSex          Auto Conditional
int   Property forceGreetWanted       Auto Conditional
; 1 is items, 10 is being hit by player and wanting to talk to them
int 	Property forceGreetFollower     Auto Conditional


FormList property permanentFollowers Auto 

; contains a number for different combos
;   0 is random single item, 1 is random collar
;   2 is plug and extra, 3 is belt and extra
;   4 is gloves and boots, 5 is other boots, 6 cuffs
;   7 is blindfold, 8 is armbinder,  
;   10 is random ringgag, 11 is random ball gag, 12 is random panel gag, 13 is random any gag
;   14 is rubber suit, 15 is red suit, 16 is pony suit, 17 is harness
;   21 nipple piercings, 22 vag/cock piercing, 23 both
;   25 is CD Belt and plug, 26 is CD Belt and Harness, 27 is full CD chastity set, 28 is full gold or silver set, with plug (reward)

; there's another comment section like this in ItemScript
int Property followerItemsCombination   Auto Conditional
int Property followerItemsWhichOneFree  Auto Conditional

Float           CurrentGameTime         = 0.0
Float Property  timeoutGameTime         = 0.0 Auto  ; used if we need a temporary time out
Float Property  busyGameTime            = 0.0 Auto  ; used to timeout dhlp suspend in the event something happens
Float Property  timeoutEnslaveGameTime  = 0.0 auto
Float           timeoutSexGameTime      = 0.0
Float           timeoutFollowerApproach = 0.0
float Property  timeoutFollowerNag      = 0.0 Auto Conditional

ImageSpaceModifier property LightFade auto ; fade back to light, to counter the simpleslavery bug for now

bool threadBusy = false
bool isPlayerBusy = false ; checking for other mods

Event OnUpdate()
	if(MCM.gCRDEEnable.GetValueInt() == 0) ; mod is off
  
		clear_force_variables() 
		;Vars.crdeisBusy.SetValue(0)
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
        Utility.Wait(MCM.fEventInterval*2)
      endif
      RegisterForSingleUpdate(MCM.fEventInterval + 5)
    elseif wasInCombat == true ;&& not in combat, but we can't get here if this is false anyway
      wasInCombat = false
      debugmsg("player has left combat, do nothing and wait 10 seconds before returning to normal", 1)
      RegisterForSingleUpdate(10)
      ; while we wait, lets check if player has a master and hit them at all
      if masterRefAlias != None
      ; TODO
      endif
      
    else ; not a combat situation
      float onupdatetimeteststart = Utility.GetCurrentRealTime()
      CurrentGameTime 	          = Utility.GetCurrentGameTime() ; use gametime, since realtime gets reset per game session, cannot work through game saves
      if forceGreetIncomplete
        debugmsg("force greet is Incomplete, " + ((busyGameTime - CurrentGameTime)*1400) + " GMin remain", 1) ; game minute
        
        ; debug
        if attackerRefAlias== None
          debugmsg("attackerRefAlias empty!",5)
        ;else
        ;  debugmsg("attackerRefAlias currently: " + attackerRefAlias.GetActorReference().GetDisplayName(),1)
        endif
        
        ;if busyGameTime + (24 * MCM.iApproachTimeout) < CurrentGameTime ; took too long, reset
        if MCM.bResetDHLP ; debug option to release the lock, might remove since this wasn't really a good idea anymore
          Mods.dhlpResume()
          ;attackerRefAlias.ForceRefTo(previousAttacker)
          debugmsg("reset MCM on, resetting", 1)
          clear_force_variables(true)
          MCM.bResetDHLP = false
        endif

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
      
      bool completedApproach = false
      if threadBusy == false
        threadBusy 	= true
        ;debugmsg("global search range: " + MCM.gSearchRange.GetValueInt()) 
        completedApproach = attemptApproach() ; roll and everything else moved into this one function, simplifies this onUpdate
        threadBusy = false
      endif
      
      debugmsg("OnUpdate time:" + (Utility.GetCurrentRealTime() - onupdatetimeteststart)) ; measuring time for searching
      
      ;debugmsg("Calling isPlayerinjail ...")
      ;Mods.isPlayerInJail()
      if forceGreetIncomplete
        RegisterForSingleUpdate(5) ; 5 seconds, faster because we want to catch conditions, for now static
      else
        RegisterForSingleUpdate(MCM.fEventInterval)
      endif

      ; moving these to AFTER the other stuff, since it takes so fracking long
      tryDebug() ; moved to save space
      if !completedApproach ; we only want to print actors when actor approaches, since we reset actors in this
        NPCMonitorScript.printNearbyValidActors()
      endif
      
    endif
    
    ; TODO this seems to not fire, but I need to double check
    ; it SHOULDN'T fire, but that's 90% of error code for ya
    actor tmpActor = Game.GetPlayer()
    if tmpActor != player
      debugmsg("Player alias has changed! Resetting ...", 5) ; good to know this doesn't seem to change, still
      player = tmpActor
    endif
    
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
  ;cdGeneralFactionAlias = Mods.cdGeneralFaction as Alias
  RegisterForModEvent("HookAnimationStart", "crdeSexStartCatch")
  RegisterForModEvent("HookAnimationEnd", "crdeSexHook")
  RegisterForModEvent("DeviceActorOrgasm", "playerOrgasmsFromDD")
	RegisterForSingleUpdate(1) ; in seconds
EndEvent

function Maintenance()
	RegisterForSingleUpdate(3) ; is this right?
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
    adjustPerceptionPlayerSub( a, 2 )
  endif
  
EndEvent


Function clear_force_variables(bool resetAttacker = false)
	;crdeFGreetStatus.SetValue(0)
  if MCM.bDebugLoudApproachFail && (forceGreetSex || forceGreetSlave)
    debugmsg("cancel approach called, resetting",1)
  endif
	forceGreetSex         = 0 ; just in case we get back in this update while the previous attack is still underway, 
	forceGreetSlave       = 0 ; and player is NOW busy, try using these variables as a cancel
  isIndecent            = false
  isLocallyWanted       = false
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
    if followerRefAlias01 != None
      followerRefAlias01.Clear()
    endif
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
	;	return true
  ;elseif Mods.dhlpSuspendStatus == true && forceGreetIncomplete == false; Deviously helpess suspend status is set
  ;  debugmsg("dhlp suspend is active, a mod is busy", 1)
	;	return true
  
	if( player.GetCurrentScene() != none )
		debugmsg("Player is in scene, busy", 1)
		return true
	elseif   UI.IsMenuOpen("Dialogue Menu")  ;UI.IsMenuOpen("InventoryMenu") |||| UI.IsMenuOpen("ContainerMenu")
 		debugmsg("Player is in UI, busy", 1)
		return true
  ;elseif( player.IsSneaking()  ) ; moved up, since detection catching requires knowing if the other user can see the player, adding to player detection
  elseif  SexLab.IsActorActive(player)  
    debugmsg("Player is busy with Sexlab", 1)
		return true
  elseif (!player.getplayercontrols()) ; placed last because I bet it's the slowest response
		debugmsg("Player's controls are locked, busy", 1)
		return true
  endif
  bool boundInFurniture = NPCMonitorScript.checkActorBoundInFurniture(player)
  ;debugmsg("bound status:" + boundInFurniture + " sexlab furn status:" + PlayerScript.isZazSexlabFurniture)
  if !MCM.bVulnerableFurniture && boundInFurniture
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
  ;if isNude  && (player.WornHasKeyword(SexlabAnalCum) || player.WornHasKeyword(SexlabVaginalCum))
  if isNude  && (player.HasMagicEffect(SexLabCumAnalEffect) || player.HasMagicEffect(SexLabCumVaginalEffect))
    wearingBukkake = true
    return none
  endif
  ;if player.WornHasKeyword(SexlabOralCum)
  if Player.HasMagicEffect(SexLabCumOralEffect)
    wearingBukkake = true
    return none
  endif
  ;SexLabCumOralEffect Auto   
  ;SexLabCumVaginalEffect Auto   
  ;SexLabCumAnalEffect
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
  wearingCollar     = player.WornHasKeyword(libs.zad_DeviousCollar) || player.WornHasKeyword(deviceKeywords[3]) || (Mods.modLoadedMariaEden && player.WornHasKeyword(Mods.meCollarKeyword)) || (Mods.modLoadedParadiseHalls && player.WornHasKeyword(Mods.paradiseSlaveRestraintKW))
  wearingGag        = player.WornHasKeyword(libs.zad_DeviousGag) || player.WornHasKeyword(Mods.zazKeywordWornGag)
  wearingSlaveBoots = player.WornHasKeyword(libs.zad_DeviousBoots)
  wearingHarness    = player.WornHasKeyword(libs.zad_DeviousHarness)
  wearingPiercings  = player.WornHasKeyword(libs.zad_DeviousPiercingsNipple) || player.WornHasKeyword(libs.zad_DeviousPiercingsVaginal)
  wearingAnkleChains= player.WornHasKeyword(libs.zad_BoundCombatDisableKick); zzzz) ; todo get ankle chains
  
EndFunction

; called from the loop, but assume other locations can call
; guard chat also checks vulnerability, but that's handled separately because we only need to check when the equipment changes
function CheckGuardApproachable()
  if Mods.modLoadedPrisonOverhaul && MCM.bGuardDialogueToggle
    ; get user hold location, bounty
    ;Faction localFac    = (Mods.xazMain as xazpEscortToPrison).FindCurrentHoldFaction()
    ;localBounty = localFac.GetInfamy() 
    localBounty = (Mods.xazMain as xazpEscortToPrison).FindCurrentHoldFaction().GetInfamy() 
    isLocallyWanted = (localBounty > 0 && vulnerability > 0) || localBounty > 99 
    ;if  (localBounty > 0 && vulnerability > 0) || localBounty > 99 
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

; 0 not vulnerable, 1 - 4 are levels of vulnerable
function updateVulnerability(bool isSlaver = false) 
	debugmsg("updating vulnerability", 1) ; too often used, spam; not anymore, less used
  isNude(player)            ; sets the script wide variable
  ; deprecated in 13.4.5, we can now check when the tattos change hands
  ;if MCM.bVulnerableSlaveTattoo || MCM.bVulnerableSlutTattoo 
  ;  SlavetatsScript.detectTattoos(); for now
  ;endif
  
  ; where positive fame is 1 for having an INCREASE for each of the three fields
  ; and negative if 
  int frameworkFameIncrease = 0
  int frameworkFameAlways   = 0 
  int nightAddition         = ((isNight() as int) * (MCM.bNightAddsToVulnerable as int))
  int totalIncrease = frameworkFameIncrease + nightAddition
  
  
  if Mods.modLoadedFameFramework
    frameworkFameIncrease = ((Mods.metReqFrameworkIncreaseVuln() > 1) as int)
    frameworkFameAlways   = Mods.metReqFrameworkMakeVuln()
    ; might need two functions with different things
    ; since bitwise is a bitch to work with in this program
  endif
  
  if Mods.modLoadedSlaverunR || Mods.modLoadedSlaverun
    slaverunInEnforcedLoc = SlaverunScript.PlayerIsInEnforcedLocation()
  endif
  
	; this is seperated because we can now disable certain items, and all items need to be autonomous
	;elseif(( wearingGag && MCM.bVulnerableGag  ) || (wearingBlindfold && MCM.bVulnerableBlindfold)) && !(MCM.bNakedReqGag && !isNude) ;isNude(player) == true)
	;	vulnerability = 2
		;;return None
  bool isTattooVulnerable = (MCM.bVulnerableSlaveTattoo && (SlavetatsScript.wearingSlaveTattoo)); && (isNude || !MCM.bNakedReqSlaveTattoo || isSlaver))) || \
                            (MCM.bVulnerableSlutTattoo && (SlavetatsScript.wearingSlutTattoo)); && (isNude || !MCM.bNakedReqSlutTattoo || isSlaver))) ; and for slave
    
  int heavyItemCount =  (((wearingArmbinder == true && MCM.bVulnerableArmbinder) as int) * 2) + \
                        ((wearingBlindfold && MCM.bVulnerableBlindfold) as int) + \
                        (( wearingGag && MCM.bVulnerableGag  ) as int) +\
                        ((wearingBlockingFull && isNude) as int) +\
                        ((MCM.bVulnerableSlaveBoots && wearingSlaveBoots)as int) +\
                        ((MCM.bVulnerableFurniture && NPCMonitorScript.checkActorBoundInFurniture(player)) as int *2) +\
                        (player.HasKeyword(Mods.zazKeywordEffectOffsetAnim) as int) +\
                        ((isTattooVulnerable && (isNude || !MCM.bNakedReqSlaveTattoo || isSlaver)) as int) +\
                        (frameworkFameIncrease > 0) as int +\
                        (wearingAnkleChains as int)
  if heavyItemCount >= 3
    clothingVulnerability = 4
    vulnerability = 4 + totalIncrease
    return 
  endif
  ; TODO: Bug here, try to figure out how we got to this point
  if((wearingArmbinder == true && MCM.bVulnerableArmbinder) || (MCM.bVulnerableFurniture && NPCMonitorScript.checkActorBoundInFurniture(player)) || player.wornHasKeyword(Mods.zazKeywordEffectOffsetAnim))
    clothingVulnerability = 3
		vulnerability = 3 + totalIncrease
    return 
  endif
  if((MCM.bVulnerableCollar && wearingCollar  ) && (MCM.bIsVulNaked == true && isNude) && (!(MCM.bNakedReqCollar && !isNude) || isSlaver)) ||\
    (MCM.bVulnerableHarness && wearingHarness && (!(MCM.bNakedReqHarness && !isNude) || isSlaver)) ||\
    (MCM.bVulnerablePierced && wearingPiercings && (!(MCM.bNakedReqPierced && !isNude) || isSlaver)) ||\
    (MCM.bVulnerableSlaveBoots && wearingSlaveBoots)  ||\
    (MCM.bVulnerableGag && wearingGag && (!(MCM.bNakedReqGag && !isNude) || isSlaver)) ||\
    ((wearingCollar && wearingBlockingVaginal && wearingBlockingBra ) && isNude) || \
    (MCM.bVulnerableBukkake && wearingBukkake && !(MCM.bNakedReqBukkake && !isNude)) ||\
    (isTattooVulnerable && (isNude || !MCM.bNakedReqSlaveTattoo || isSlaver)) ||\
    (wearingAnkleChains)
    
    clothingVulnerability = 2
		vulnerability = 2	+ totalIncrease
		return 
	endif 
	if(MCM.bVulnerableCollar && wearingCollar == true && !(MCM.bNakedReqCollar && !isNude)) \
   || (MCM.bIsVulNaked == true && isNude) 
		clothingVulnerability = 1
    vulnerability = 1 + totalIncrease
		return 
	endif
  
  clothingVulnerability = 0
	vulnerability = 0 + ((frameworkFameAlways) as int) + totalIncrease ; moved to last since we need to get down here to know anyway, one less step if v >= 1, 
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
  ; if roll enslave
    ; set enslveaftersex var
    ; moveactor to player, again, since we have the actor
  ; similarly, if pimp start  
    ; ...
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

; does returning true or false mean completed with/without error? You can return None if you don't have anything to return you know
; previously named bool tryEnslaveEvent, renamed because it didn't mention the sex approach and other approaches that should be handled here
;   also not event, don't put event in the function name unless it's an event
; I know this function is huge, but since papyrus doesn't likely inline functions...
bool function attemptApproach()
  ; nearest ->  isbusy -> check equip -> roll(need nearest for slave trader modifier) -> enslavelvl -> attempts ->
  
  if( CurrentGameTime <= timeoutGameTime) ; TODO: Move this further up, we shouldn't check if the player is timed out AFTER doing everything that is expensive
    debugmsg("dec is in timeout, going back to sleep for " + (timeoutGameTime - CurrentGameTime) + " mins",1)
    return false
  endif
  
  ; test if player is busy
  isPlayerBusy  = isPlayerBusy()
  if isPlayerBusy ; lets test this sooner, fewer moot cycles
  ;GetActorRef GetDisplayName
    ;string name = "<master name>"
    ;if attackerRefAlias != None
    ;  name = attackerRefAlias.GetActorRef().GetDisplayName()
    ;endif
    ;debugmsg("last npc: " + name, 1) ; moved busy debug to the debug function
    ;debugmsg("Player is busy ... last npc: " + name + " incomplete status: " + forceGreetIncomplete, 1)
    ;debugmsg("player became busy during approach, resetting",1) ; commented out because this is now the ONLY check
    clear_force_variables(true) 
    return false ; if busy, nothing else to do here, leave
  elseif forceGreetIncomplete &&  attackerRefAlias != None && attackerRefAlias.GetActorRef() != player  ;forceGreetSex || forceGreetSlave
    debugmsg("player is being approached by " + attackerRefAlias.GetActorRef().GetDisplayName() ,1)
    return false ; approach in progress, just don't do anything else here, but no reset
  endif
  
  enslavedLevel  = Mods.isPlayerEnslaved() ; run this early so we know to quit early, without resetting the NPC quest so no aliases hopefully
  if enslavedLevel >= 3
    debugmsg("Player is busy slave, cannot be approached, leaving early",1)
    ; maybe stop the NPC quest if this happens? but we only want to stop it once, which means detecting it the first time only
    return false
  endif
  
  ;clear_force_variables(); not sure this is needed anymore
  forceGreetSex = 0
  forceGreetSlave = 0
  bool isNight = isNight()
  
  ;if Mods.modLoadedFameFramework
    
  ;endif
  if PlayerScript == none
    debugmsg("playerscript is none")
  endIf
  if PlayerScript.equipmentChanged == true ; equipment has changed
    debugmsg("equipment changed: " + PlayerScript.equipmentChanged , 3);debugmsg("New armor detected", 3)
    CheckDevices()
    updateVulnerability(isSlaver)
    CheckBukkake() ; require isNude, called in updateVulnerability()
    PlayerScript.equipmentChanged = false
    ;CheckGuardApproachable() 
  elseif PlayerScript.sittingInZaz ; else if because we don't need to check if gear was already checked. will get caught regardless
    updateVulnerability(isSlaver)
  elseif PlayerScript.releasedFromZaz
    PlayerScript.releasedFromZaz = false
    updateVulnerability(isSlaver)
  elseif isSlaver && vulnerability < 2
    debugmsg("slaver found, double checking vulnerability" , 3)

    updateVulnerability(isSlaver)
  elseif Mods.modLoadedFameFramework && Mods.metReqFrameworkMakeVuln() >= 1
    debugmsg("rechecking vulnerability because fame is high enough to always be vulnerable" , 3)
    updateVulnerability(isSlaver) 
  endif
  
  follower_attack_cooldown = (CurrentGameTime >= timeoutFollowerApproach + (120 * (1.0/1400.0))) ; this is the cooldown release
  
  if (playerScriptAlias as crdePlayerScript).weaponChanged == true
    isWeaponProtected()
    ;CheckGuardApproachable()
  endif
  
  ; moved this later, since it takes a long time
  actor[] nearest = NPCMonitorScript.getClosestRefActor(player)
  actor[] followers = NPCSearchScript.getNearbyFollowers()
  
  location player_loc = player.GetCurrentLocation()
  ; if player has followers
  if  MCM.bFollowerDialogueToggle.GetValueInt() == 1 \
    && followers[0] != None && timeoutFollowerNag < CurrentGameTime \
    && ( nearest.length == 1 || (player_loc && player_loc.haskeyword(locationTypePlayerhome))) 
    ; special case, alone with followers[0] in the woods or some shit, lets do something

    ; are we alone with followers in a dungeon?
    ; for now screw the dungeon, lets just make it random and let the roll decide
    
    actor[] valid_followers   = new actor[15]
    actor[] current_followers = new actor[15]
    actor follower
    int valid_count         = 0
    int current_count       = 0
    timeoutFollowerNag      = 0
    actor slave             = None
    actor tmp_follower      = None
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
    
    ; TODO flesh this out so that follower can have partner preference with slaves
    i = 0
    ; what this does is gives us the nearest generic follower, and
    ;  all the followers we've previously had sex with, ignoring jimmy
    while i < followers.length
      tmp_follower = followers[i]
      ; if follower is tied up at CDx
      if tmp_follower == None ; TODO if we can't remove the main follower showing up twice, remove them here
        ; do nothing, we can avoid
        
      elseif Mods.modLoadedCD && Mods.cdFollowerTiedUp.GetValueInt() == 1 && Mods.isTiedUpCDFollower(tmp_follower)
        debugmsg("follower " + tmp_follower.GetDisplayName() + " is tied up in CDx")
      elseif tmp_follower != None && !tmp_follower.WornHasKeyword(libs.zad_DeviousGag) && !tmp_follower.WornHasKeyword(libs.zad_DeviousArmbinder)
        
        if SexLab.HadPlayerSex(tmp_follower) || StorageUtil.GetFloatValue(follower, "crdeThinksPCEnjoysSub") > 0 || valid_count == 0 
          valid_followers[valid_count] = tmp_follower
          valid_count += 1
          if tmp_follower.IsInFaction(CurrentFollowerFaction) || tmp_follower.IsInFaction(Mods.paradiseFollowingFaction)
            current_followers[current_count] = tmp_follower
            current_count += 1
            ; might as well add the continer counts here
            ;int old_container_count = StorageUtil.GetIntValue(tmp_follower, "crdeFollContainersSearched")
            StorageUtil.AdjustIntValue(tmp_follower, "crdeFollContainersSearched", playerContainerOpenCount)
          endif
        endif
      endif
      i += 1
    endWhile
    playerContainerOpenCount = 0 ; reset
    
    ; and then we pick ONE at random
    if valid_count > 0
      follower = valid_followers[Utility.RandomInt(0, valid_count - 1)]
      debugmsg("Follower chosen randomly is " + follower.GetDisplayName() + " out of " + valid_count , 1)
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
      endif
    endif

    ; deprecated, this is where the separate follower valid check was before I merged it above
    ;i = 0
    ;while i < valid_count
    ;  follower = valid_followers[i]
    ;  i += 1
    ;endWhile
    
    if current_count == 0
      debugmsg("not high enough for sex appraoch, and the current friendlies aren't followers so no item possible",3)
    elseif follower 
      follower = current_followers[Utility.RandomInt(0, current_count - 1)]
      debugmsg("Follower re-chosen randomly is " + follower.GetDisplayName() + " out of " + current_count , 1)
    endif

    
    float item_approach_roll      = Utility.RandomFloat(0,100)
    float goal                    = MCM.fFollowerFindChanceMaxPercentage
    int   follower_item_count     = StorageUtil.GetIntValue(follower, "crdeFollContainersSearched") ;playerContainerOpenCount)
    if follower_item_count < MCM.iFollowerFindChanceMaxContainers
      goal = ( Math.pow(follower_item_count, MCM.fFollowerItemApproachExp) * MCM.itemParabolicModifier) 
    endif
    debugmsg("Follower item adding roll:" + item_approach_roll + " need under " + goal + ", containers: " + follower_item_count, 3)

    if item_approach_roll < goal; 5 or something low at some point
      
      ; we need to grab the dispositions from the followers[0] here, too, so that we can properly detect which kind of outcomes are possible
      ; OR, we move this to a different function, and call it after we get that far into the dialogue, risky?
      
      follower_enjoys_dom           = StorageUtil.GetFloatValue(follower, "crdeFollEnjoysDom")
      follower_enjoys_sub           = StorageUtil.GetFloatValue(follower, "crdeFollEnjoysSub") 
      follower_thinks_player_sub    = StorageUtil.GetFloatValue(follower, "crdeThinksPCEnjoysSub")
      follower_thinks_player_dom    = StorageUtil.GetFloatValue(follower, "crdeThinksPCEnjoysDom") 
      follower_thinks_player_sub    = StorageUtil.GetFloatValue(follower, "crdeFollowerFrustration")
      ; add 10 points if player has a slave/follower with collar
      follower_thinks_player_sub   += ((Mods.metReqFrameworkMakeVuln() as int) * 10)
      
      
      debugmsg("follower thinks player sub: " + follower_thinks_player_sub + " ")      
      ; also test for relationship and arousal and stuff

      ItemScript.rollFollowerFoundItems(follower) ; for now, roll as we need to, but later lets roll even if we don't need to and only roll once, print it out instead
      if !(MCM.gForceGreetItemFind.GetValueInt() as bool)
        Debug.Notification( follower.GetDisplayName() + " wants to talk to you.")
      else ; force greet is on, setup cancel timeout
        forceGreetIncomplete = true
        busyGameTime = CurrentGameTime + ( MCM.iApproachDuration * (1.0/1400.0)) ; 24 * 60 minutes in a day
      endif

      forceGreetFollower = 1
      reshuffleFollowerAliases(follower)
      ;playerContainerOpenCount = 0 ; this is here because it's the easiest way to reset it for followers[0] dialogue, in the future it should be moved to the dialogue
      
      
      return true
    endif
  elseif followers[0] != None
    ;no followers was the specific reason we're skipping the above
    playerContainerOpenCount = 0 ; no followers, nobody saw anything
    forceGreetFollower = 0

  else ; if follower and alone or at home  
    ; STOP the item approach, probably sex approach too
    forceGreetFollower = 0
  endif  ; EXIT follower approach code
    
  int i = 0
  hasFollowers = false
  actor tmp = None
  while i < followers.length && hasFollowers == false
    tmp = followers[i]
    if tmp != None && tmp.IsInFaction(CurrentFollowerFaction)
      hasFollowers = true
    endif
    i += 1
  endWhile
  ;hasFollowers  = NPCSearchScript.getNearbyFollowersInFaction(followers) ; unnecessary, we aren't saving variables here
  
  if nearest[0] == None
    debugmsg("No nearby NPCs, leaving early", 3)
    return false
  ;elseif followers[0] != None && MCM.bEnslaveFollowerLockToggle ; moved down to enslave only
  ;  debugmsg("Nearby NPCs found, but cannot approach with nearby follower", 3)
  ;  ;forceGreetFollower = 0
  ;  return false
  ;else nothing here
  endif

  bool isSlaver = Mods.isSlaveTrader(nearest[0]) ; moved up so we can 
  
  float rollModifier = 1
  if isNight              
    rollModifier     = MCM.fNightChanceModifier    ; this is why god made ternary operators bethesuda
  endif 
  
  float rollEnslave	= Utility.RandomInt(1,100) / rollModifier
  ;float rollTalk		= Utility.RandomInt(1,100) ; reimplement when you put in the actual feature
  float rollSex		  = Utility.RandomInt(1,100) / rollModifier
    
  if isSlaver
    rollEnslave   = (rollEnslave	    / MCM.fModifierSlaverChances)
    ;rollTalk 	    = (rollTalk		      / MCM.fModifierSlaverChances)
    rollSex 	    = (rollSex		      / MCM.fModifierSlaverChances)
  endif
  
  ; if wearingPartialChasity
  ; use two variables set by the full check function, then you can test either or
  ; partial results in some increase?
  ; bool isWearingChastity = isWearingChastity()
  if MCM.bChastityToggle
    ; if attacker has keys, increase all chances
    ; else, no keys, sex = 0
    debugmsg("chastity:" + wearingBlockingFull + ": a:" + wearingBlockingAnal + " b:" + wearingBlockingBra + " g:" + wearingBlockingGag, 3)
    if wearingBlockingFull 
      ; all items
      if (nearest[0].GetItemCount(libs.chastityKey) > 0 && !libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousBelt).HasKeyword(libs.zad_BlockGeneric)) \
      || (nearest[0].getItemCount(libs.restraintsKey) > 0 && !libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousGag).HasKeyword(libs.zad_BlockGeneric))
        rollSex     = rollSex     /  MCM.fChastityCompleteModifier
      else 
        rollSex 	  = 101         ; impossible, put the needed number out of reach
      endif
      ;rollTalk 	    = rollTalk    /  MCM.fChastityCompleteModifier
      rollEnslave   = rollEnslave /  MCM.fChastityCompleteModifier
    elseif wearingBlockingAnal || wearingBlockingVaginal || wearingBlockingBra; || wearingBlockingGag
      ; partial chastity, but not complete
        rollSex       = rollSex     /  MCM.fChastityPartialModifier
        ;rollTalk 	    = rollTalk    /  MCM.fChastityPartialModifier
        rollEnslave   = rollEnslave /  MCM.fChastityPartialModifier
    endif
    ; do nothing, not wearing chastity
  endif

  debugmsg("approachroll enslave: " + rollEnslave + " / sex: " + rollSex + " / a: " + nearest[0].GetDisplayName(), 2)
  
  ; TODO: combine these into faster return sequence, once this is confirmed to be working as intended
  ; if roll for all posible outcomes are too low, leave early
  ; roll moved to first since arithmatic should be many times faster than checking if the player is busy and looking for acceptable NPC
  if rollEnslave > MCM.iChanceEnslavementConvo \
     && rollSex > MCM.iChanceSexConvo
    debugmsg("Rolled too low, stopping",3)
    return false
  endif
  
  ;old isplayerenslaved location
  debugmsg("slave lvl: " + enslavedLevel + " vuln lvl: " + vulnerability, 3) 
  
  if wearingWeapon 
    debugmsg("Player is armed, protected", 3)  
    return false
  endif
  
  debugmsg(("dhlp: " + Mods.dhlpSuspendStatus + " weapon: " + wearingWeapon), 1)
  if enslavedLevel != 3 && (vulnerability > 0 || enslavedLevel == 1) && \
     (wearingWeapon == false || (wearingWeapon && MCM.iWeaponProtectionLevel < vulnerability)) && \
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
      reqConfidence   = 4 - vulnerability - isNightReduction
                          ;- ( nearest[i].GetFactionRank(Mods.sexlabArousedFaction) > 80 ) as int
    
      if ( !MCM.bConfidenceToggle || (actorConfidence >= reqConfidence) || isSlaver \
           || nearest[0].GetFactionRank(Mods.sexlabArousedFaction) >= MCM.iWeightConfidenceArousalOverride) ;|| ( isNight && actorConfidence >= reqConfidence - MCM.iNightReqConfidenceReduction ) 
        debugmsg("Found NPC confident enough: " + nearest[i].GetDisplayName(),3)
        nearest[0] = nearest[i] ; lazy hack
        i = 1000
      else
        debugmsg(nearest[i].GetDisplayName() + " is not slaver and Confidence isn't high enough for the vulnerability, Attacker:" + actorConfidence + ", Req:" + reqConfidence, 3)
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
      elseif vulnerability < MCM.iMinEnslaveVulnerable 
        debugmsg(("Player is not vulnerable enough for enslave, MCM:" + MCM.iMinEnslaveVulnerable + ", Player:" + vulnerability), 3)
      elseif ((actorMorality > MCM.iMaxEnslaveMorality) && isSlaver == false)
        debugmsg("Attacker is not slaver and Morality is not low enough, Attacker:" + actorMorality + ", Req:" + MCM.iMaxEnslaveMorality, 3)
      elseif isWeaponProtected() == true && isSlaver == false
        debugmsg("Player is protected by weapon (has weapon and MCM option is selected)", 3)    
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
    ;if(vulnerability > 0   && CurrentGameTime >= timeoutEnslaveGameTime) && \
    if (actorMorality > MCM.iMaxSolicitMorality) && !isSlaver
      debugmsg("Attacker is not slaver and Morality is not low enough, Attacker:" + actorMorality + ", Req:" + MCM.iMaxEnslaveMorality, 3)
    ;elseif  nearest[0].GetFactionRank(Mods.sexlabArousedFaction) < MCM.iMinApproachArousal && !isSlaver
    elseif rollSex > MCM.iChanceSexConvo
      debugmsg("rolled too low for sex or enslavement, exiting...", 3)

    else
      ;if(rollSex <= MCM.iChanceSexConvo)
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

;follower_enjoys_dom           = StorageUtil.GetIntValue(follower, "crdeFollEnjoysDom")
; follower_enjoys_sub           = StorageUtil.GetIntValue(follower, "crdeFollEnjoysSub") 
; follower_thinks_player_dom    = StorageUtil.GetIntValue(follower, "crdeThinksPCEnjoysDom") 
; follower_thinks_player_sub    = StorageUtil.GetIntValue(follower, "crdeThinksPCEnjoysSub")

; does the follower like being sub/dom? positive is yes, negative is no, 0 is don't care
function modFollowerLikesDom(actor actorRef , float value)
  ;float current_value = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysDom")
  ; for now do standard mod, no oddity
  ;StorageUtil.SetFloatValue(actorRef, "crdeFollEnjoysDom", current_value + value)
  StorageUtil.AdjustFloatValue(actorRef, "crdeFollEnjoysDom", value)
  
endFunction

function modFollowerLikesSub(actor actorRef, float value)
  ;float current_value = StorageUtil.GetFloatValue(actorRef, "crdeFollEnjoysSub") ; our local value is temp, modified, do not use it
  ;StorageUtil.SetFloatValue(actorRef, "crdeFollEnjoysSub", current_value + value)
  StorageUtil.AdjustFloatValue(actorRef, "crdeFollEnjoysSub", value)

endFunction

function modThinksPlayerDom(actor actorRef , float value)
  ;float current_value = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysDom")
  ;debugmsg("adjusting " + actorRef + " thinks player is dom " +current_value+ " by " + value)
  ;StorageUtil.SetFloatValue(actorRef, "crdeThinksPCEnjoysDom", current_value + value)
  StorageUtil.AdjustFloatValue(actorRef, "crdeThinksPCEnjoysDom", value)

endFunction

function modThinksPlayerSub(actor actorRef , float value)
  ;float current_value = StorageUtil.GetFloatValue(actorRef, "crdeThinksPCEnjoysSub")
  ;debugmsg("adjusting " + actorRef + " thinks player is sub "+current_value+ " by " + value)
  ;StorageUtil.SetFloatValue(actorRef, "crdeThinksPCEnjoysSub", current_value + value)
  StorageUtil.AdjustFloatValue(actorRef, "crdeThinksPCEnjoysSub", value)

endFunction

function modFollowerFrustration(actor actorRef, float value)
  ;float current_value = StorageUtil.GetFloatValue(actorRef, "crdeFollowerFrustration")
  ;StorageUtil.SetFloatValue(actorRef, "crdeFollowerFrustration", current_value + value)
  StorageUtil.AdjustFloatValue(actorRef, "crdeFollowerFrustration", value)

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
	;CheckDevices() ; otherway around, this is called separately now

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


; I might not use this, but for now
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
  
  if player.WornHasKeyword(libs.zad_DeviousGag) && !knownGag.HasKeyword(libs.zad_BlockGeneric) 
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
  
  ; if we haven't left already... ;!knownGag.HasKeyword(libs.zad_BlockGeneric)
  if !skip_oral && actorRef.GetActorBase().GetSex() != 1 && player.WornHasKeyword(libs.zad_DeviousBelt) && !libs.GetWornDeviceFuzzyMatch(player, libs.zad_DeviousBelt).HasKeyword(libs.zad_BlockGeneric);&& and the belt doesn't have a blocking keyword

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
  return 0  
EndFunction


function doPlayerSex(actor actorRef, bool rape = false, bool soft = false, bool oral_only = false)
	;timeoutEnslaveGameTime = Utility.GetCurrentGameTime() + MCM.fEventTimeout
  ;debugmsg("Resetting approach at start of doSex",1)
  Debug.SendAnimationEvent(actorRef, "IdleNervous") ; should work well enough
	clear_force_variables() ; handles forceGreetIncomplete = false
  Mods.dhlpResume()
  
  ; start some animations while we wait
  
  ;if MCM.bAggresiveAnimations
  actor[] sexActors = new actor[2] ; only 3 if we ever decide to have threesomes and such
  sexActors[0] = player
  sexActors[1] = actorRef
  int actorGender = 0
  if MCM.bUseSexlabGender
    actorGender     = SexLab.GetGender(actorRef)
  else
    actorGender     = actorRef.GetActorBase().getSex()
  endif   
  int playerGender = player.GetActorBase().GetSex() ; we call these enough save as var
  
  if PlayerScript.sittingInZaz ; if player is tied up in furniture, move the player to the attacker, so sex doesn't clip
    player.moveTo(actorRef)
  endif
  
  string animationTags = "";
  int preSex = prepareForDoPlayerSex(actorRef, skip_oral = oral_only)
  debugmsg("prepare result: "+ preSex)
  ; if we removed something, we might as well sex in that area
  if preSex == 2 && Utility.RandomInt(0,100) < 65 
    animationTags = "vaginal"
  elseif preSex== 2 ; roll failed  
    animationTags = "anal"
  elseif preSex == 1 || oral_only
    animationTags = "oral"
  endif
  
  ; changed in 13
  Utility.Wait(0.5) ; hopefully long enough for DD to work
  
  ; if both female, no aggressive req, too few animations, annoying
  ;debugmsg("genders are player,attacker: " + player.GetActorBase().GetSex() + "," + actorGender)
  if rape 
    if playerGender == 0 && actorGender == 1   
      ; user wanted animations where woman was not in male role, this might help with that
      animationTags += ",Cowgirl"
    elseif !(playerGender == 1 && actorGender == 1 && !MCM.bFxFAlwaysAggressive)
      animationTags += ",aggressive"
    endif
    SendModEvent("crdePlayerSexRapeStarting")
  else
    SendModEvent("crdePlayerSexConsentStarting")
  endif 
  
  string supressTags = "solo"
  if soft == false
    supressTags  += ",Cuddling,acrobat,Petting,Foreplay"
  endif
  
  if playerGender == 1 && actorGender == 1
    supressTags += ",handjob,footjob,boobjob" ; seriously now
    ; even oral on a dildo has some embarrassment value, but handjob on dildo is just silly, same with foot and boob, especially since they are kinda... woman focused
  endif
  
	; we can optimize this out with a variable, since we have to check this earlier when we start the dialogue anyway
  if player.wornHasKeyword(libs.zad_DeviousBelt) 
    ; actor has a key, will use ;zzz key
    
    
    if !player.wornhaskeyword(libs.zad_PermitVaginal) && actorGender == 0 || ( actorRef.WornHasKeyword(libs.zad_DeviousBelt))
      supressTags += ",vaginal,pussy,tribadism"
    endif
    if !player.wornhaskeyword(libs.zad_PermitAnal) && actorGender == 0 || ( (actorRef.WornHasKeyword(libs.zad_DeviousBelt) && !actorRef.wornhaskeyword(libs.zad_PermitAnal)))
      supressTags += ",anal"
    endif
  elseif player.wornHasKeyword(Mods.zazKeywordWornBelt) && actorGender == 0 || ( actorRef.wornHasKeyword(Mods.zazKeywordWornBelt))
    supressTags += ",vaginal,anal"
  endif
  if (player.wornhaskeyword(libs.zad_DeviousGag) && !(player.wornhaskeyword(libs.zad_PermitOral) || player.wornhaskeyword(libs.zad_DeviousGagPanel) )) ||\
      (!player.wornhaskeyword(libs.zad_DeviousGag) && player.wornHasKeyword(Mods.zazKeywordWornGag) && !player.wornHasKeyword(Mods.zazKeywordPermitOral))
    if actorRef.wornhaskeyword(libs.zad_DeviousBra)
      supressTags += ",Breastfeeding"
    endif
    supressTags += ",oral,mouth"
    if actorGender == 0
      supressTags += ",blowjob"
    endif
  endif
  if player.wornhaskeyword(libs.zad_DeviousBra) && actorGender == 0
    supressTags += ",Boobjob"
  endif
  
  ;if player is wearing gag
  
  ; get array of animations based on which items the player has
  ;int actorCount = 2; number of actors in sex
  ; add limit for aggressive here
  ;sslBaseAnimation[] animations = SexLabUtil.GetAnimationsByTags(2, animationTags, supressTags)
  sslBaseAnimation[] animations = SexLab.GetAnimationsByTag(2, animationTags, TagSuppress = supressTags)
  
  debugmsg(("anim:'" + animationTags +"',supp:'" + supressTags+ "',animsize:" + animations.length), 3)
  ;String s = ""
  ;int i = 0
  ;while i < animations.length
  ;  s = s + animations[i] ; hope this doesn't bug out
  ;endwhile
  
  if (playerGender == 1 && actorGender == 1 )
    ; if both player and attacker are female, we want the player to take the 'reciever' or 'female' position
    ;  why does sorting the actors do this? no fucking clue. this code was used in petcollar, maybe it's placebo who knows ¯\_(ツ)_/¯
    sexActors = SexLab.SortActors(sexActors)
  endif
  
	if rape == true && !(playerGender == 0 && actorGender == 1 ) 

    ;actor victim = player
    sexFromDEC = true
    SexLab.StartSex(sexActors, animations, player);, None, false);
	else
    if soft
      sexFromDECWithoutAfterAttacks = true
    endif
    sexFromDEC = true
    SexLab.StartSex(sexActors, animations);
	endif
endFunction

; this is the hook called after sexlab is finished
; now called always after all sexlab, so we must check if it was started by CRDE or not
; tag:postsex
Event crdeSexHook(int tid, bool HasPlayer);(string eventName, string argString, float argNum, form sender)
  debugmsg("crdeSexHook reached, running post-sex", 1)
  sslThreadController Thread = SexLab.GetController(tid)
  
  ; mod must be active, controller must have player, 2 partners (otherwise, noone to add items and enslave
  if (MCM.gCRDEEnable.GetValueInt() == 1 && Thread.HasPlayer() )
    Actor[] actorList = SexLab.HookActors(tid as string)
    actor victim = Thread.getVictim()
    bool vicIsPlayer = (victim == player)
    
    setPreviousPlayerHome() ; here because we want the last home the player wanted to have sex in
    
    follower_attack_cooldown = false
    timeoutFollowerApproach = Utility.GetCurrentGameTime()
    
    ; check for errors, if errors skip the post sex and leave
    if victim == None && (sexFromDEC || !MCM.bHookReqVictimStatus)
      victim = player ; assumed player was submissive (Yes, Master) or we don't care (overrride)
    elseif victim == None && sexFromDECWithBeltReapplied
      ; put the player back into their belt
      ItemScript.equipRegularDDItem(player, ItemScript.previousBelt, libs.zad_DeviousBelt)
    elseif victim == None
      debugmsg("sexlabhook: player not victim, not started by DEC, mcm override is off, ignoring...", 3)
      return
    endif

    if ( sexFromDEC && sexFromDECWithoutAfterAttacks  )
      debugmsg("sexlabhook: sex was specified no attack", 3)
    ;elseif ( sexFromDEC && !MCM.bHookAnySexlabEvent)
    ;  debugmsg("sexlabhook: sexlab wasn't started by DEC or ALL not set", 3)
    elseif Thread.ActorCount <= 1 ; masterbation or machine rape, either way noone to enslave or add items
      debugmsg("sexlabhook: not enough actors", 3)
    else ; no error, keep going

      int playerPos = Thread.GetPlayerPosition()
      actor otherPerson = none
      if(playerPos == 1)
        otherPerson = actorList[0]
      else
        otherPerson = actorList[1]
      endif

      ;debugmsg("player is " + plyr.getDisplayName(), 0)
      StorageUtil.SetFloatValue(otherPerson, "crdeLastSexEval", Utility.GetCurrentGameTime())
      otherPerson.removeFromFaction(Vars.WantsSex)
      ;debugmsg("victim is " + victim.getDisplayName(), 0)
      CheckBukkake()
      ;updateVulnerability() 
      ; reasons why removed: if player is already wearing items then the last vulnerability should suffice except in false neg case, where we don't care as much
      ; rechecking item and vulnerability is too slow, this code already takes a long time to work
      ; assumption: no other mod will add items to player at end of sex and before this code (false negative)
      
      ; assumption: cannot rape player without going through isActiveInvalid already
      ; yeah but this is now the general event catch, not just for CRDE called
      ;if  sexFromDEC ;|| (vulnerability >= MCM.iMinEnslaveVulnerable) ; NONslaveending dumbass
      if NPCMonitorScript.isInvalidRace(otherPerson) == false 
        if enslavedLevel < 1 
          bool enslave_attempt_result = tryEnslavableSexEnd(otherPerson)
          if enslave_attempt_result
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
    
    ; did people who might one day be your follower see you have sex and/or bondage (check if they are in LOS I guess...)
    ; this kinda needs to happen later, since it's slow and less important
    modifyNearbyNPCPerception(actorList, vicIsPlayer)
    sexFromDEC                    = false 
    sexFromDECWithoutAfterAttacks = false
    
  else
    debugmsg("crdeSexhook ERR: sexlab doesn't have player controller or mod is turned off", 2)
  endif

  
endEvent

; check if player is in player house, if so, set last player house
function setPreviousPlayerHome()
  Location current_loc = player.GetCurrentLocation()
  if current_loc != None && current_loc.haskeyword(locationTypePlayerhome) ; we check here because we don't just want the last house but the last house the player had sex in
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
      adjustPerceptionPlayerDom( a, 2 ) ; TODO switch these for player set values
    endif
  else
    ; increment all thinks sub by two
    adjustPerceptionPlayerSub( a, 2 )
  endif

endFunction

function adjustPerceptionPlayerSub(actor[] actors, float diffValue)
  int i = 0
  actor testActor = None
  while i < actors.length 
    testActor = actors[i]
    if testActor != None
      modThinksPlayerSub(testActor, diffValue)
    endif
    i += 1
  endWhile
endFunction

function adjustPerceptionPlayerDom(actor[] actors, float diffValue)
  int i = 0
  actor testActor = None
  while i < actors.length 
    testActor = actors[i]
    if testActor != None
      modThinksPlayerDom(testActor, diffValue)
    endif
    i += 1
  endWhile
endFunction

; allows us to catch the calm caused by defeat, so we don't step on defeat
bool function isBusyDefeat(actor actorRef)
	;if(Mods.modLoadedDefeat && (actorRef.HasMagicEffect(Mods.defeatCalmEffect) || \
	;							actorRef.HasMagicEffect(Mods.defeatCalmAltEffect) ||\
	;							actorRef.IsInFaction(Mods.defeatFaction) ) ) ; not sure why we need all three, but there it is
	;	return true
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
;	might apply to the attacker too later, 
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
	
; need to wait until vulnerability is done before we test weapon because of level setting
bool function isWeaponProtected()
  if (MCM.iWeaponProtectionLevel < vulnerability || playerIsNotArmed()) && \
      ( playerIsNotWearingWizRobes() ) ;MCM.iWeaponProtectionLevel < vulnerability) ; robe variant added to MCM later
    wearingWeapon = false
    return false
  endif 
  wearingWeapon = true
  return true
endFunction
  
; is the player armed? can't remember why I set it to default negative
;  food for thought: the papyrus compiler can't rectify a double negative
bool function playerIsNotArmed()
  if  player.GetEquippedWeapon() != None || player.GetEquippedWeapon(true) != None ;||\
      ;player.GetEquippedSpell(0) != None || player.GetEquippedSpell(1) != None
      ; for now, we'll ignore shouts
    ;debugmsg("pina: Player is armed")
    return false
  endif 
  return true
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
  if WICommentCollegeRobesList.hasform(wornForm)
    return false
  endif
  return true
endFunction

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
    elseif vulnerability == 4 || (wearingGag && MCM.bIntimidateGagFullToggle) 
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
      
      
      if vulnerability == 2 ; if the player has vulnerability 2, / 2
        roll = roll * 2
      elseif vulnerability > 2 ; if player has vulnerability 3, / 3 ; we want more than that, but without the weapon protection...
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

 
; this is never called?, zombie function?
; made by chase ignored by verstort
function evalActor(actor actorRef)
	clearActorFactions(actorRef)
	if(Mods.isSlave(actorRef))
		actorRef.setFactionRank(Vars.Slave, 0)
	elseif(Mods.isSlaveTrader(actorRef))
		actorRef.setFactionRank(Vars.Slaver, 0)		
	endif
	
	float lastEval = StorageUtil.GetFloatValue(actorRef, "crdeLastEval")
	float lastSexEval = StorageUtil.GetFloatValue(actorRef, "crdeLastSexEval")
	if(lastEval > 0)
		;set up sympathetic/acknowledge slaves
	endif

	if(lastSexEval + MCM.fEventTimeout >= Utility.GetCurrentRealTime())
		;wantsSex calc
	endif

	StorageUtil.SetFloatValue(actorRef, "crdeLastEval", Utility.GetCurrentRealTime()) 
endFunction

function setCRDEBusyVariable(bool status = true)
  StorageUtil.SetFloatValue(player, "crdeBusyStatus", status as int)
endFunction
 
 ; --- debug and testing functions

; made by chase, ignored by verstort
function clearActorFactions(actor actorRef)
	actorRef.removeFromFaction(Vars.Slaver)
	actorRef.removeFromFaction(Vars.Slave)
	;actorRef.removeFromFaction(Vars.WantsSex)
	;actorRef.removeFromFaction(Vars.Sympathetic)
	;actorRef.removeFromFaction(Vars.AcknowledgesSlaves)
	;actorRef.removeFromFaction(Vars.RemembersPlayerWasSlave)
endFunction

; Plays a random DD bound animation, 
; BUG one of these won't reset on the player on certain enslavement events, IE CDx -> player keeps struggling during opening
function playRandomPlayerDDStruggle(int r = 0)
  if r <= -1 || r >= 7
    r = Utility.Randomint(1,6)
  endif
  if r == 1
    libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS01) 
  elseif r == 2
    libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS02)   
  elseif r == 3
    libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS03)  
  elseif r == 4
    libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS04)  
  elseif r == 5
    libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS05)  
  elseif r == 6
    libs.ApplyBoundAnim(player, libs.DDZaZAPCArmBZaDS06) 
  Endif
EndFunction

; debug, prints what animations we would get from sexlab given tags 
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
  CheckDevices()
  updateVulnerability()
  bool isNight = isNight()
  debugmsg("slave lvl: " + enslavedLevel + " vuln lvl: " + vulnerability, 3)  
  Debug.MessageBox("Nude: " + isNude + " Vulnerability: " + vulnerability)
  ;Debug.MessageBox("Wornboots: (" + wearingSlaveBoots + ") WornHarness: (" + wearingHarness + ") WornBukkake: (" + wearingBukkake + ")" )
  Debug.MessageBox("Worngag: (" + wearingGag + ") Worn armbidings: (" + wearingArmbinder + ") WornCollar: (" + wearingCollar +")" )
  Debug.MessageBox("Furniture: (" + NPCMonitorScript.checkActorBoundInFurniture(player) + ") Nudity: (" + isNude + ") MCM furniture: (" + MCM.bVulnerableFurniture +")" )
  ; print worn stuff
  ; print vulnerability
  bool iswearingblockinggag = (!MCM.bChastityGag || (player.wornhaskeyword( libs.zad_DeviousGag ) && !(player.wornhaskeyword( libs.zad_PermitOral ) || player.wornhaskeyword( libs.zad_DeviousGagPanel ))))
  Debug.MessageBox("gag: (" + player.wornhaskeyword( libs.zad_DeviousGag ) \
       + ") permitoral: (" + player.wornhaskeyword( libs.zad_PermitOral ) \
       + ") permitoral: (" + player.wornhaskeyword( libs.zad_DeviousGagPanel )  \
       + ") MCM chastgag: (" + MCM.bChastityGag +") expr result: (" + iswearingblockinggag  \
       +") actual gag var: (" + wearingBlockingGag + ")")
  Debug.MessageBox("is NOT wizrobes: " + playerIsNotWearingWizRobes() )
  Debug.MessageBox("is nighttime: " + isNight() )
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
    permanentFollowers.addForm(a[result])
    Mods.PreviousFollowers.addForm(a[result])
    Debug.Trace(a[result] + " -> " + a[result].GetDisplayName() +" has been added to the DEC manually marked list of followers.")
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
;	; get nearby actor (maybe)
;	debugmsg("looking for actor")
;	Actor valid = NPCMonitorScript.getClosestActor(player)
;	; start quest with new actor
;	if valid != None
;		debugmsg("Actor found, trying")
;		(Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat2(valid)
;		MCM.bAbductionTest = false
;	endif
;		
;endFunction

; previously maria's eden init
; currently SD Sanguine's teleport test
function testInit()
  ;debugmsg("looking for actor")
	;Actor valid = getClosestActor(player)
	; start quest with new actor
	;if valid != None
	;	debugmsg("Actor found, trying")
	;	(Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat2(valid)
	;	MCM.bAbductionTest = false
	;endif
  ;Actor valid = NPCMonitorScript.getClosestActor(player)
  ;if valid != None
	;	debugmsg("Actor found, trying")
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
;		MCM.bTestButton4 = false
;    ;(Quest.getQuest("crdeSlaverun") as crdeSlaverunScript).enslave()
;    ; put the next test here
;	endif
;endFunction

; test how far chase got with his pony function
function testPonyOutfit()
  ;equipPonygirlOutfit(player)
  player.SetOutfit(BlackPonyMixedOutfit)
  ;SlavetatsScript.testSlaveTats()
  MCM.bAbductionTest = false
endFunction

; captured dreams test
; now Slaverun test
function testCD()
  ;sendModEvent("SlaverunReloaded_ForceEnslavement")
  ;if Mods.modLoadedSlaverunR
  ;  bool isin = Mods.SlaverunScript.PlayerIsInEnforcedLocation()
  ;  debugmsg("is in slaverun enforceable location?:" + isin)
  ;else
  ;  debugmsg("slaverun not installed")
  ;  MCM.bCDTest = false
  ;endif
  armor[] items = ItemScript.getRandomCDItems(player)
  int i = 0
  while i < items.length
    armor item = items[i]
    if item != None
      player.additem(items[i])
      debugmsg("adding " + item )
    else
      debugmsg("item @ " + i + " is none" )
    endif
    i += 1
  endWhile
	
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
 
  ;debugmsg("testing DDZaZAPCArmBZaDS01",4) ; sure, makes sense
  ;Debug.SendAnimationEvent(player, "DDZaZAPCArmBZaDS01") ;arms back struggling
  ;Debug.SendAnimationEvent(player, libs.DDZaZAPCArmBZaDS01) ;arms back struggling  
  
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
	;	(Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).defeat(valid)
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
  
  
  ;int i = 0
  ;while i < a.length
  ;  
  ;  int num = 0
  ;  num =  ItemScript.checkItemAddingAvailability(a[i], libs.zad_DeviousCollar)
  ;  debugmsg("itemaddingavailability for actor: " + a[i] + " for keyword  collar is " + num)
  ;  
  ;  num =  ItemScript.checkItemAddingAvailability(a[i], libs.zad_DeviousBelt)
  ;  debugmsg("itemaddingavailability for actor: " + a[i] + " for keyword  belt is " + num)
  ;  
  ;  num =  ItemScript.checkItemAddingAvailability(a[i], libs.zad_DeviousGag)
  ;  debugmsg("itemaddingavailability for actor: " + a[i] + " for keyword  gag is " + num)
  ;  
  ;  num =  ItemScript.checkItemAddingAvailability(a[i], libs.zad_DeviousPiercingsNipple)
  ;  debugmsg("itemaddingavailability for actor: " + a[i] + " for keyword  nipple is " + num)
  ;  
  ;  i += 1
  ;endWhile
  
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
  
  int i = 0
  while i < permanentFollowers.GetSize()
    debugmsg((permanentFollowers.Getat(i) as actor).GetDisplayName() + " at " + i)
    i += 1
  endWhile
  debugmsg(permanentFollowers.GetSize() + " is the size")

  ;SendModEvent( "DvCidhna_StartBandits" )
  ;SendModEvent( "DvCidhna_StartVampires" )
  
  ;DistanceEnslave.enslaveLeon()
  ;MCM.bTestButton7 = false
  Debug.Notification("Test has completed.")
endFunction

  
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
  if Mods.bRefreshModDetect
    debugmsg("Resetting mod detection ...", 4)
    Mods.finishedCheckingMods = false
    Mods.updateForms()
    Mods.checkStatuses()
    debugmsg("Finished resetting mod detection.", 4)
    Mods.bRefreshModDetect = False
  endif
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
  actor nearest = NPCMonitorScript.getClosestActor(player)
  timeGetClosestActor = Utility.GetCurrentRealTime() - timeGetClosestActor
  
  float timeGetClosestRefActor = Utility.GetCurrentRealTime()
  actor[] nearest2 = NPCMonitorScript.getClosestRefActor(player)
  timeGetClosestRefActor = Utility.GetCurrentRealTime() - timeGetClosestRefActor
  
  float timeCheckDevices = Utility.GetCurrentRealTime()
  CheckDevices()
  timeCheckDevices = Utility.GetCurrentRealTime() - timeCheckDevices
  
  float timeUpdateVulnerabiltiy = Utility.GetCurrentRealTime()
  updateVulnerability()
  timeUpdateVulnerabiltiy = Utility.GetCurrentRealTime() - timeUpdateVulnerabiltiy
  
  float timeCheckBukkake = Utility.GetCurrentRealTime()
  CheckBukkake() 
  timeCheckBukkake = Utility.GetCurrentRealTime() - timeCheckBukkake
  
  float timePlayerEnslaved = Utility.GetCurrentRealTime()
  Mods.isPlayerEnslaved()
  timePlayerEnslaved = Utility.GetCurrentRealTime() - timePlayerEnslaved
  
  ;;;; rolling copy paste (because abstracting three floats to global hurts the compiler spilling
  float timeRollingWithModifiers = Utility.GetCurrentRealTime()
  if nearest == none ;|| isActorIneligable(nearest) == false ; already called in the search
    nearest = player
    ;return
  endif
  
  float rollEnslave	= Utility.RandomInt(1,100)
  ;float rollTalk		= Utility.RandomInt(1,100)
  float rollSex		  = Utility.RandomInt(1,100) 
    
  bool isSlaveTrader = Mods.isSlaveTrader(nearest) 
  if(isSlaveTrader)
    ;rollEnslave  = 1
    ;rollTalk 	  = 1
    ;rollSex 	    = 1
    rollEnslave   = (rollEnslave	    / MCM.fModifierSlaverChances)
    ;rollTalk 	    = (rollTalk		      / MCM.fModifierSlaverChances)
    rollSex 	    = (rollSex		      / MCM.fModifierSlaverChances)
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
      if (nearest.GetItemCount(libs.restraintsKey) > 0) || (nearest.GetItemCount(libs.chastityKey) > 0)
        rollSex     = rollSex     /  MCM.fChastityCompleteModifier
      else 
        rollSex 	  = 101         ; impossible
      endif
      ;rollTalk 	    = rollTalk    /  MCM.fChastityCompleteModifier
      rollEnslave   = rollEnslave /  MCM.fChastityCompleteModifier
    elseif wearingBlockingAnal || wearingBlockingVaginal || wearingBlockingBra || wearingBlockingGag
    ; partial chastity, but not complete
      rollSex       = rollSex     /  MCM.fChastityPartialModifier
      ;rollTalk 	    = rollTalk    /  MCM.fChastityPartialModifier
      rollEnslave   = rollEnslave /  MCM.fChastityPartialModifier
    
    endif
    ; do nothing, not wearing chastity
  endif
  timeRollingWithModifiers = Utility.GetCurrentRealTime() - timeRollingWithModifiers
  ;;; rolling copy paste end
  
  float timeSlavetats = Utility.GetCurrentRealTime()
  if MCM.bVulnerableSlaveTattoo || MCM.bVulnerableSlutTattoo 
    SlavetatsScript.detectTattoos(); for now
  endif
  bool isTattooVulnerable = (MCM.bVulnerableSlaveTattoo && (SlavetatsScript.wearingSlaveTattoo && (isNude || !MCM.bNakedReqSlaveTattoo || isSlaveTrader))) || \
                            (MCM.bVulnerableSlutTattoo && (SlavetatsScript.wearingSlutTattoo && (isNude || !MCM.bNakedReqSlutTattoo || isSlaveTrader))) ; and for slave
  timeSlavetats = Utility.GetCurrentRealTime() - timeSlavetats
  
  
  ;moved out because easier to read spread out like this
  String str = "Time results (seconds) isPlayerBusy: " + timePlayerBusy +\
               " GetClosestActor: " + timeGetClosestActor +\
               " GetClosestRefActor: " + timeGetClosestRefActor +\
               " CheckDevices: " + timeCheckDevices  +\
               " UpdateVulnerability: " + timeUpdateVulnerabiltiy  +\
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
  if gender_pref != 0 ; we need to rebuild the potential master list to match genders
    int old_length = DistanceEnslave.SDMasters.length ; less property fetching
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
      
  menu.AddEntryItem(" ** cancel **")
  menu.OpenMenu()
  int result = UIExtensions.GetmenuResultInt("UIListMenu")
  if  a[result].isDead() 
    Debug.MessageBox("The actor you selected: " + a[result] + " is dead, and cannot be used")
  elseif result >= 0 && result < a_index
    ; valid choice
    DistanceEnslave.SDNextMaster = a[result]  
    Debug.MessageBox("Next distance SD master set is " + a[result].GetDisplayName() +", wasPreviously:" + previous.GetDisplayName() + ", Last master:" + DistanceEnslave.SDPreviousMaster.GetDisplayName())
  elseif result <= a_index + 1
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

function StartCombat(actor Attacker)
  ; testing
  Attacker.StartCombat(player)
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
  
  Utility.wait(1.0)
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
    if followerRefAlias02 == None || mostRecent == tmp
      followerRefAlias02.forceRefTo(tmp)
      followerRefAlias01.forceRefTo(mostRecent)
    else
      ; we need to shift whether the last one is free or not, additional logic only hurts us
      followerRefAlias03.forceRefTo(followerRefAlias02.GetActorRef())
      followerRefAlias02.forceRefTo(tmp)
      followerRefAlias01.forceRefTo(mostRecent)
    endif
  endif

endFunction


Armor[] Property ponyGearDD  Auto 
Armor[] Property ponyGearZaz  Auto 

Armor[] Property petGear  Auto  ; ebonite collar should be in the back

Outfit Property BallandChainRedOutfit Auto
Outfit Property BlackPonyMixedOutfit Auto

Key[] Property deviousKeys  Auto  

Keyword[] Property clothingKeywords  Auto  

crdeVars Property Vars Auto ; still not sure what this thing was for

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

Keyword Property locationTypePlayerhome Auto

; moral cities
Worldspace Property solitudeSpace Auto 
Worldspace Property windhelmSpace Auto
; dawnstar is too cold

;immoral cities
Worldspace Property whiterunSpace Auto ; used with slaverun
Worldspace Property markarthSpace Auto ; used with slaverun
;Worldspace Property riftenSpace Auto ; used with slaverun

Race Property WerewolfBeastRace Auto
