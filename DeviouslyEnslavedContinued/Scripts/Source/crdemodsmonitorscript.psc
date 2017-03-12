Scriptname crdeModsMonitorScript extends Quest Conditional
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Mods Monitor
;
; A number of interfaces to bridge gaps between Deviously Enslaved Continued and other mods.
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

import GlobalVariable
;crds_SubmissionScript    Property submissionQuest Auto
crdePlayerMonitorScript   Property PlayMonScript Auto
crdeVars                  Property Vars Auto
;crdeDebugScript           Property DebugOut Auto
crdeMCMScript             Property MCM Auto
crdeDistantEnslaveScript  Property DistantEnslaveScript  Auto
crdeSlaverunScript        Property SlaverunScript       Auto
crdeLolaScript            Property LolaScript Auto

;state
bool Property finishedCheckingMods Auto Conditional
bool Property hasAnySlaveMods Auto Conditional
bool Property dhlpSuspendStatus Auto Conditional

; here because all other quests keep resetting
;actor[]                  Property PreviousFollowers Auto 
FormList                  Property PreviousFollowers Auto 
int PreviousFollowersIndex ; not needed

;mod loaded boolean
bool Property modLoadedSD auto Conditional
bool Property modLoadedMariaEden auto Conditional
bool Property modLoadedCursedLoot auto Conditional
bool Property modLoadedWolfclub auto Conditional
bool Property modLoadedTrappedInRubber auto Conditional
bool Property modLoadedCD auto Conditional
bool Property modLoadedHydra auto Conditional
bool Property modLoadedSlaverun auto Conditional 
bool Property modLoadedSlaverunR auto Conditional 
bool Property modLoadedPetCollar auto Conditional
bool Property modLoadedParadiseHalls auto Conditional
bool Property modLoadedCalyps auto Conditional
bool Property modLoadedHelpless auto Conditional
bool Property modLoadedMiasLair auto Conditional
bool Property modLoadedDefeat auto Conditional
bool Property modLoadedMoreDevious auto Conditional
bool Property modLoadedSimpleSlavery auto Conditional
bool Property modLoadedMistakenIdentity auto Conditional
bool Property modLoadedFromtheDeep auto Conditional
bool Property modLoadedAngrim auto Conditional
bool Property modLoadedDeviousCidhna auto Conditional 
bool Property modLoadedSGOMSE auto Conditional
bool Property modLoadedDarkwind auto Conditional
bool Property modLoadedPrisonOverhaul auto Conditional
bool Property modLoadedForswornStory auto Conditional
bool Property modLoadedQuickAsYouLike auto Conditional
bool Property modLoadedRavenous auto Conditional
bool Property modLoadedDeviousSurrender auto Conditional
bool Property modLoadedSlavesOfTamriel auto Conditional
bool Property modLoadedDeathAlternative auto Conditional
bool Property modLoadedSlaveTats auto Conditional
bool Property modLoadedPrisonOverhaulPatch auto Conditional
bool Property modLoadedSLUTS auto Conditional
bool Property modLoadedWorkingGirl auto Conditional
bool Property modLoadedFameFramework auto Conditional
bool Property modLoadeddeviousPunishEquipment auto Conditional 
bool Property modLoadedDeviousRegulations auto Conditional
bool Property modLoadedTITD auto Conditional

bool Property modLoadedSlaveTrainer auto Conditional

;modLoadedSLUTS modLoadedDeviousCidhna modLoadedCursedLoot modLoadedSlaverunR modLoadedIsleofMara
;bool Property modLoadedSexlabSolutions auto Conditional

; note actually used yet
bool Property modLoadedIsleofMara auto Conditional

bool Property enslavedSD auto Conditional
bool Property enslavedME auto Conditional
bool Property enslavedSlaverun auto Conditional
bool Property enslavedLola auto Conditional
bool Property enslavedCD auto Conditional

;dominia

bool Property bEnslaved auto conditional ; TODO: get rid of this, replace with iEnslavedLevel > 0
int Property iEnslavedLevel auto ; 0 = free, 1 = enslaved/free use, 2 = enslaved/ use if vulnerable, 3 = enslaved/no attack

Actor Property player Auto

race[] Property pointedValidRaces Auto

; our training plug
Armor Property crdeTrainingPlug Auto

;Maria Eden
Quest Property meSlaveQuest Auto ; MariaEdensTools
Keyword Property meSlaveKeyword Auto
Quest Property meSlaveOnAStroll Auto
Quest Property meTransportOfGoods Auto ; slave owned by kajit
Quest Property meSlaveIsJailed Auto
Quest Property meDefeatQuest Auto  ; Defeated by NPC, can't be attacked or will break animation?
Quest Property meWhoresJob  Auto ; just to reduce change of double sex and other things
keyword Property meCollarKeyword Auto
keyword Property meWhoreKeyword Auto
faction Property MariaEdensSlaverFaction Auto
faction Property MariaEdensSlaveFaction Auto
faction Property MariaPotentialMaster Auto
; new quests and stuff in 1.2x, we're missing both slave start quests in the brothel
Quest Property meSlaveTraderQuest Auto ; when player is owned and being trained by slave seller

; new me stuff
Quest Property meAuctionQuest Auto

; more for the whore side needs to be done too

;Deviously Cursed Loot
Armor Property dcurSlaveCollar Auto
Armor Property dcurSlaveCollarS Auto
Armor Property dcurCursedCollar Auto
Armor Property dcurCursedCollarS Auto
book  Property dcurCursedLetter Auto
Armor Property dcurSlutCollar Auto
Armor Property dcurSlutCollarS Auto
Armor Property dcurRubberCollar auto
Armor Property dcurTransparentSuit Auto
Armor Property dcurTransparentBoots Auto
Armor Property dcurBeltOfShame Auto
Armor Property dcurStripTeaseCollar Auto
Armor Property dcurAnkleChains Auto


Quest Property dcurDamselQuest Auto
Quest Property dcurBondageQuest Auto
Keyword Property dcurDollCollarKeyword Auto
;5.0 DCL stuff 
GlobalVariable Property dcurMisogynyDetect Auto
GlobalVariable Property dcurMisogynyCooldown Auto
Quest Property dcurRoyalChastityQuest Auto
Quest Property dcurLeonQuest Auto
Quest Property dcurLeonGGQuest Auto
Armor Property dcurLeonSlaveCollar Auto
Actor Property dcurLeonActor Auto ; we need leon so we can enable him
Cell Property dcurLeonHouse Auto ; we need his house to teleport to
;Key  Property dcur
FormList Property dcur_removableBlockedItems Auto

; sd+
Keyword Property sdEnslaveKeyword Auto
Faction Property sdSlaveFaction Auto
Quest Property sdDreamQuest Auto
Cell Property sdDreamWorld  Auto

;Wolfclub
location property wcCCLocation auto
Cell Property CragslaneCavern01  Auto  
Quest Property wolfclubQuest Auto ; pchsWolfclubDAYMOYL. why would we use the DAYMOYL quest?
Actor Property wolfclubGuy   Auto

;Trapped In Rubber
Quest tir_start01
Quest tir_fw ; tir_fw_scr
Faction tirWearingSuitFaction
;Book Property tir_journal

;Captured Dreams
quest cdExpQuest02
quest Property cdPlayerSlave Auto 
quest Property cdPlayerProperty Auto 
cell cdSlaveShipCell
cell cdMainShop
faction Property  cdGeneralFaction   Auto 
faction Property  cdCustomerFaction   Auto 
Armor   Property  cdProtectionAmulet   Auto 
Keyword Property  cdProtectionBeltKW   Auto 

Armor   Property  cdGoldBelt   Auto 
Armor   Property  cdGoldCollar   Auto 
Armor   Property  cdGoldArmCuffs  Auto 
Armor   Property  cdGoldLegCuffs   Auto 
Armor   Property  cdSilverBelt   Auto 
Armor   Property  cdSilverCollar   Auto 
Armor   Property  cdSilverArmCuffs   Auto 
Armor   Property  cdSilverLegCuffs   Auto 
Armor   Property  cdWhiteBelt   Auto 
Armor   Property  cdWhiteCollar   Auto 
Armor   Property  cdWhiteArmCuffs   Auto 
Armor   Property  cdWhiteLegCuffs   Auto 
Armor   Property  cdBlackBelt   Auto 
Armor   Property  cdBlackCollar   Auto 
Armor   Property  cdBlackArmCuffs   Auto 
Armor   Property  cdBlackLegCuffs   Auto 
Armor   Property  cdRedBelt   Auto 
Armor   Property  cdRedCollar   Auto 
Armor   Property  cdRedArmCuffs   Auto 
Armor   Property  cdRedLegCuffs   Auto 


Armor   Property  cdTormentingPlug   Auto 
Armor   Property  cdMagePlug Auto 
Armor   Property  cdTheifPlug Auto 
Armor   Property  cdAssassinPlug Auto 
Armor   Property  cdFighterPlug Auto 
Armor   Property  cdOrgasmPlug Auto 
Armor   Property  cdTeaserPlug Auto   
Armor   Property  cdFinisherPlug Auto 
Armor   Property  cdSpoilerPlug Auto   
Armor   Property  cdExciterPlug Auto   
Armor   Property  cdPunisherPlug Auto  
quest   property  cdxCellControl auto
GlobalVariable Property cdFollowerTiedUp Auto 
int               cdPreviousDisposition

;PetCollar
armor Property petCollar Auto ; Don't use this for detection, there are many collars, use magic effect for checking
armor Property petCollar_script Auto
MagicEffect Property petCollarEffect Auto ; we can use this to catch any petcollar collar

;Hydra Slavegirls
faction Property hydraSlaverFaction Auto
faction Property hydraSlaverFactionCaravan Auto
faction Property hydraSlaveFaction Auto

;Slaverun
faction Property slaverunSlaveFaction  Auto
faction Property slaverunSlaverFaction Auto
Quest   Property slaverunSlaveQuest    Auto
Quest   Property slaverunEnforcerQuest Auto
Actor   Property slaverunZaidActor     Auto

;Slaverun Reloaded
; no faction required, because using zazSlaveFaction?
Quest   Property slaverunRMainQuest   Auto
Quest   Property slaverunRTrainingQuest Auto 
Quest   Property slaverunRPeriodicQuest Auto 
Quest   Property slaverunRMCMQuest Auto ;slaverunRMCMQuest
;Faction Property slaverunRSlaveFaction Auto

;Paradise Halls
faction Property paradiseSlaveFaction Auto
faction Property paradiseRespectfulFaction Auto   ; shouldberespectful, makes it easier
faction Property paradiseHatefulFaction Auto      ; might not even use this until I make a dialogue for enslave reversal
faction Property paradiseSubmissiveFaction Auto   ; not sure about this one
faction Property paradisePlayerSlaveFaction Auto
Keyword Property paradiseSlaveRestraintKW Auto
Faction Property paradiseFollowingFaction Auto
Faction Property paradiseLeashedFaction Auto 
Faction Property PAHETied Auto

;Calyps
armor Property tailPlug Auto

;Deviously Helpless
faction Property helplessFaction Auto ; 0x00005379

;Mias Lair
faction Property miasSlaveFaction Auto
faction Property miasTrainingFaction Auto
faction Property miasBeginnerFaction Auto
Quest   Property miasTrapQuest    Auto
Quest   Property miasTrailQuest   Auto 
faction Property miasChainedSlave Auto
faction Property miasAQSSMisSlave Auto

;Defeat
MagicEffect Property defeatCalmEffect Auto
MagicEffect Property defeatCalmAltEffect Auto
faction     Property defeatFaction  Auto

;MoreDevious
faction    property  mdeviousBusyFaction Auto

;simple slavery
Quest Property simpleslaveryQuest Auto
Cell Property   simpleslaveryCell Auto


;MistakenIdentity
Quest Property mistakenIDQuest Auto

; Angrim's apprentice
Keyword     Property angrimBeltKeyword Auto
MagicEffect Property angrimGhostEffect Auto

;from the deeps
Faction Property ftdSlaveFaction Auto
Faction Property ftdServantFaction Auto
Faction Property ftdDagonSlaveFaction Auto

; devious cidhna
Faction Property cidhnaEscortFaction Auto
Faction Property cidhnaCapturedFaction Auto
Quest   Property cidhnaMainJailQuest        Auto
Quest   Property cidhnaErikurQuest       Auto
Quest   Property cidhnaPirateQuest          Auto
Quest   Property cidhnaLostKnifeQuest          Auto
Quest   Property cidhnaNeighborQuest        Auto

; SGO:MSE
Armor   Property sgomseCowBelt Auto
Armor   Property sgomseCowCollar Auto

; zaz animations
Keyword Property zazKeywordFurniture Auto
Keyword Property zazKeywordEffectRefresh Auto

; everything here is deprecated, we can jsut get it from zaz directly
; or at least load from creation kit instead of esp
Keyword Property zazKeywordHasBondageEffect Auto ; bondage
Faction Property zazFactionAnimating Auto
Keyword Property zazKeywordEffectOffsetAnim Auto ; keep offset animation
MagicEffect Property zazMagicEffectBondage Auto
Keyword Property zazKeywordAnimWrists Auto
Keyword Property zazKeywordWornGag Auto
Keyword Property zazKeywordWornBlindfold Auto 
Keyword Property zazKeywordWornYoke Auto
Keyword Property zazKeywordWornBelt Auto
Keyword Property zazKeywordWornCollar Auto 
Keyword Property zazKeywordPermitOral Auto
Keyword Property zazKeywordWornAnkles Auto
Armor   Property zazBindings  Auto
Armor   Property zazHood  Auto
Armor   Property zazClothGag   Auto
Armor   Property zazBitGag Auto
Armor   Property zazCollar  Auto
Armor   Property zazLegCuffs Auto
Faction Property zazFactionSlave Auto
Faction Property zazFactionSlaver Auto
Keyword Property zazFurnitureMilkOMatic auto
Keyword Property zazFurnitureMilkOMatic2 auto
Keyword Property zazFurnitureFuroTub1 auto

; darkwind
; quest
Faction Property darkwindSlaveFaction Auto

; forsworn story
Faction Property forswornStorySlaveFaction Auto
Faction Property forswornStoryEnslavedFaction Auto ; huh?
Faction Property forswornStoryWhoreFaction Auto

;xax PO with patches
bool    Property xaxPlayerInPrison Auto
Faction Property xazPrisonerFaction Auto
Quest   Property xazMain Auto  
Quest   Property xazPOPatchQuest Auto

; qayl
Quest   Property qaylQuickAsYouLikeQuest Auto

;ravenous
Faction Property ravMeatSlaveFaction Auto ; probably not required anymore, if he uses zaz slave faction
;Quest Property rav auto 

;devious surrender
; MagicEffect Property devsurCalmMagicEffect Auto ; deprecated

;slaves of tamriel
Quest Property tamslavesMainQuest Auto
MagicEffect Property tamslavesTattooEffect Auto

Faction Property sexlabArousedFaction Auto

;slavetats
;Quest Property slavetatsQuest auto

;Quest Property SLUTSFirstQuest auto
Faction Property SLUTSLiveryFaction auto
Faction Property SLUTSHaulierFaction auto
Faction Property SLUTSDriverFaction auto
Faction Property SLUTSDirtyFaction auto
Keyword Property SLUTSMissionKeyword auto
Keyword Property SLUTSSlaveryKeyword auto
Keyword Property SLUTSRestrainingDevice auto

Quest Property lolaDSMainQuest Auto

; lake of mara
Quest Property isleOfMaraEnslaveQuest auto
Worldspace Property isleOfMaraIsleWorldspace auto
Faction Property isleOfMaraSlaveFaction auto 
Faction Property isleOfMaraPlayerSlaveFaction auto 

; temptress race: vixen
Race Property temptressVixenRace Auto 

Faction Property workingGirlClientFaction Auto
MiscObject Property workingGirlJobToken Auto

Faction Property immersiveWenchGeneralFaction Auto

Armor Property deviousPunishEquipmentBannnedCollar Auto
Armor Property deviousPunishEquipmentProstitutedCollar Auto
Armor Property deviousPunishEquipmentNakedCollar Auto 
Armor Property deviousPunishEquipmentPunishPlug Auto 


Quest Property SLSF_Quest Auto
;GlobalVariable Property SLFameSlutGlobal  Auto
;GlobalVariable Property SLFameSlaveGlobal  Auto 
;GlobalVariable Property SLFameExhibitionistGlobal  Auto 


Key   Property deviousRegImperialKey  Auto 
Key   Property deviousRegStormCloakKey  Auto 
Armor Property deviousRegImperialBelt  Auto 
Armor Property deviousRegStormCloakBelt  Auto 
Keyword Property deviousRegImperialBeltKW  Auto 
Keyword Property deviousRegStormCloakBeltKW  Auto 

Quest   Property TITDQuest Auto
Faction Property TITDSlaveFaction Auto

Quest Property huntedHouseQuest Auto

; slave trainer
Faction Property sltSlaveFaction auto

MagicEffect Property dawnguardLordForm Auto

bool property bRefreshModDetect Auto

Perk property crdeContainerPerk Auto

Function Maintenance()
  ;RegisterForSingleUpdate(9)
  Debug.Trace("[CRDE]Mods:Maintenance ...")
  ; think we have to wait for the other mods to load
  Utility.Wait(7) ; used to be 3, doesn't work with 2-1, returning to longer
  finishedCheckingMods = false
  updateForms()
  checkStatuses()
EndFunction
; I THINK this is called with onUpdate, so they are redundant
Event OnInit()
  Debug.Trace("[CRDE]Mods:init ...")
  dhlpSuspendStatus = false
  pointedValidRaces = new race[10]
  RegisterForModEvent("dhlp-Suspend", "OnSuspend")
	RegisterForModEvent("dhlp-Resume", "OnResume")
  
  ;updateForms() ; move to maintenance, let it be called there
  ;checkStatuses()
  Maintenance() ; don't call here, playerstartquest is calling it
  ;RegisterForSingleUpdate(1)
EndEvent
Event onUpdate()
  Debug.Trace("[CRDE]Mods:OnUpdate running ...")
  if !player.HasPerk(crdeContainerPerk)
    Debug.Trace("[CRDE]Player Container Perk was missing, applying ...")
    player.addPerk(crdeContainerPerk)
  endif
  if bRefreshModDetect
    Utility.Wait(5.0)
    Maintenance() 
  endif
  PreviousFollowers.revert()
endEvent
;Event onGameLoad()

; Deviously Helpless suspend system
Event OnSuspend(string eventName, string strArg, float numArg, Form sender)
	dhlpSuspendStatus = true
EndEvent
Event OnResume(string eventName, string strArg, float numArg, Form sender)
	dhlpSuspendStatus = false
EndEvent

function dhlpSuspend()
  dhlpSuspendStatus = true
  SendModEvent("dhlp-Suspend")
endFunction
function dhlpResume()
  dhlpSuspendStatus = false
  SendModEvent("dhlp-Resume")
endFunction

bool function isModActive(string modName)
  if(Game.GetModByName(modName) != 255) 
    return true
  endif
  return false
endFunction

; this gets called so that the states can be checked and set as conditionals
function checkStatuses()
  Debug.Trace("[CRDE]Mods:checkStatuses() start ...")
  ;if(modLoadedWolfclub == true)
  ;  (Quest.getQuest("crdeWolfclub") as crdeWolfclubScript).canRun()
    ;debugmsg("wolfclub status: " +(Quest.getQuest("crdeWolfclub") as crdeWolfclubScript).canRun())
  ;  (Quest.getQuest("crdeWolfclub") as crdeWolfclubScript).canRun()
  ;endif
  if(modLoadedSlaverun == true)
    ;debugmsg("slaverun status: " +(Quest.getQuest("crdeSlaverun") as crdeSlaverunScript).canRun())
    (Quest.getQuest("crdeSlaverun") as crdeSlaverunScript).canRun()
  endif
  DistantEnslaveScript.canRunSold()
  DistantEnslaveScript.canRunGiven()
  hasAnySlaveMods = modLoadedSD || modLoadedMariaEden || modLoadedCD || modLoadedSlaverun  \
                                || modLoadedWolfclub || modLoadedSimpleSlavery \
                                || modLoadedSLUTS || modLoadedDeviousCidhna || modLoadedCursedLoot\
                                || modLoadedSlaverunR || modLoadedIsleofMara
  ;endif
  Debug.Trace("[CRDE]Mods:checkStatuses() finished ...")
endFunction

function updateForms()
  player = Game.GetPlayer()
  
  ; I know this is bad practice, but I don't know enough about the life cycle of the papyrus script to remove either call
  if finishedCheckingMods ; we've been here already, leave
    return
  endIf
    
  Debug.Trace("[CRDE]Mods script updateForms() start ...")
  Debug.Trace("[CRDE] ******** ignore any errors between these two messages START ********", 1)

  ; in the slow process of making these all disappear, it's faster to call the variable reference manually than to search through each mod order to find
  ;modLoadedCursedLoot       = isModActive("Deviously Cursed Loot.esp")
  ;modLoadedSD               = isModActive("sanguinesDebauchery.esp")
  ;modLoadedMariaEden        = isModActive("Maria.esp")
  ;modLoadedWolfclub         = isModActive("wolfclub.esp")
  ;modLoadedTrappedInRubber  = isModActive("Trapped in Rubber.esp")
  ;modLoadedCD               = isModActive("Captured Dreams.esp")
  ;modLoadedHydra            = isModActive("hydra_slavegirls.esp")
  ;modLoadedSlaverun         = isModActive("slaverun.esp")
  ;modLoadedPetCollar        = isModActive("PetCollar.esp")
  ;modLoadedParadiseHalls    = isModActive("paradise_halls.esm")
  ;modLoadedCalyps           = isModActive("sextoys-calyps-2.esp")
  ;modLoadedHelpless         = isModActive("DeviouslyHelpless.esp")
  ;modLoadedMiasLair         = isModActive("MiasLair.esp")
  ;modLoadedDefeat           = isModActive("Defeat.esp")
  ;modLoadedMoreDevious      = isModActive("DeviousDevice - More Devious Quest.esp")
  ;modLoadedSimpleSlavery    = isModActive("SimpleSlavery.esp")
  ;modLoadedMistakenIdentity = isModActive("MistakenIdentity.esp")
  ;modLoadedFromtheDeep      = isModActive("zFromTheDeeps.esp")
  ;modLoadedAngrim           = isModActive("AngrimApprentice.esp")
  ;modLoadedDeviousCidhna    = isModActive("Devious Cidhna.esp")
  ;modLoadedSGOMSE           = isModActive("soulgem-oven-100-milk-slave-experience.esp")
  ;modLoadedZazAnimations    = isModActive("ZaZAnimationPack.esm") ; requirement, should always be true
  ;modLoadedDarkwind         = isModActive("Darkwind.esp")
  
  ;modLoadedForswornStory    = isModActive("ZaForswornStory.esp")
  ;modLoadedPrisonOverhaul   = isModActive("xazPrisonOverhaul - Patch.esp")
  ;modLoadedQuickAsYouLike   = isModActive("qayl.esp")
  modLoadedDeathAlternative   = Quest.GetQuest("daymoyl_Monitor") != None
  
  ;zadlibs, need for keyword detection
  
  dcurDamselQuest           = Quest.GetQuest("dcur_lbquest")
  modLoadedCursedLoot       = (dcurDamselQuest != None)
  if(modLoadedCursedLoot )
    ; we need the scripts for adding the items through libs.equipitems
    dcurSlaveCollar         = Game.GetFormFromFile(0x00017C97, "Deviously Cursed Loot.esp") as Armor
    dcurSlaveCollarS        = Game.GetFormFromFile(0x00017C98, "Deviously Cursed Loot.esp") as Armor 
    dcurCursedCollar        = Game.GetFormFromFile(0x00004340, "Deviously Cursed Loot.esp") as Armor
    dcurCursedCollarS       = Game.GetFormFromFile(0x00003DDC, "Deviously Cursed Loot.esp") as Armor 
    dcurCursedLetter        = Game.GetFormFromFile(0x00010028, "Deviously Cursed Loot.esp") as Book
    dcurSlutCollar          = Game.GetFormFromFile(0x00034C37, "Deviously Cursed Loot.esp") as Armor
    dcurSlutCollarS         = Game.GetFormFromFile(0x00034C38, "Deviously Cursed Loot.esp") as Armor 
    dcurRubberCollar        = Game.GetFormFromFile(0x00034C37, "Deviously Cursed Loot.esp") as Armor 
    ;dcurRubberCollarS       = Game.GetFormFromFile(0x0006CD51 , "Deviously Cursed Loot.esp") as Armor 
    dcurTransparentSuit     = Game.GetFormFromFile(0x0006CD51, "Deviously Cursed Loot.esp") as Armor 
    dcurTransparentBoots    = Game.GetFormFromFile(0x0006CD53, "Deviously Cursed Loot.esp") as Armor 
    dcurBeltOfShame         = Game.GetFormFromFile(0x790708A8, "Deviously Cursed Loot.esp") as Armor 
    dcurStripTeaseCollar    = Game.GetFormFromFile(0x7A0996CD, "Deviously Cursed Loot.esp") as Armor
    dcurAnkleChains         = Game.GetFormFromFile(0x7A06F30C, "Deviously Cursed Loot.esp") as Armor  
    
    dcurBondageQuest        = Quest.GetQuest("dcur_bondageadventurequest") ;= Game.GetFormFromFile(0x0000B495, "Deviously Cursed Loot.esp") as Quest
    dcurDollCollarKeyword   = Game.GetFormFromFile(0x00065665, "Deviously Cursed Loot.esp") as Keyword
    ;dcurLibs               = Game.GetFormFromFile(0x00024495, "Deviously Cursed Loot.esp") as dcur_library
    
    dcur_removableBlockedItems = (Quest.GetQuest("dcur_menuconfig") as dcur_mcmconfig).dcur_DDGenericBlockItems
    
    ; 5.0 stuff
    dcurRoyalChastityQuest  = Game.GetFormFromFile(0x0808428D, "Deviously Cursed Loot.esp") as Quest ; TODO: convert over to quest.getquest
    dcurLeonQuest           = Game.GetFormFromFile(0x0802F7BF, "Deviously Cursed Loot.esp") as Quest
    dcurLeonGGQuest         = Game.GetFormFromFile(0x0807A009, "Deviously Cursed Loot.esp") as Quest 
    if dcurLeonGGQuest == None
      Debug.trace("[CRDE] Leon's GG quest is None, is 5.0 installed?")
    endif
    dcurLeonActor           = Game.GetFormFromFile(0x7602D74E, "Deviously Cursed Loot.esp") as Actor 
    dcurLeonHouse           = Game.GetFormFromFile(0x7607823B, "Deviously Cursed Loot.esp") as Cell
    dcurLeonSlaveCollar     = Game.GetFormFromFile(0x7A077CC8, "Deviously Cursed Loot.esp") as Armor
    dcurMisogynyDetect      = Game.GetFormFromFile(0x08086911, "Deviously Cursed Loot.esp") as GlobalVariable
    dcurMisogynyCooldown    = Game.GetFormFromFile(0x080873E6, "Deviously Cursed Loot.esp") as GlobalVariable
  else
    Debug.Trace("[CRDE] Cursed loot is not installed")
  endIf
  
  sdDreamWorld        = Game.GetFormFromFile(0x0003D788, "sanguinesDebauchery.esp") as Cell
  modLoadedSD         = (sdDreamWorld != None)
  if modLoadedSD
    sdSlaveFaction      = Game.GetFormFromFile(0x080A2B09, "sanguinesDebauchery.esp") as Faction
    sdEnslaveKeyword    = Game.GetFormFromFile(0x00015bce, "sanguinesDebauchery.esp") as Keyword
    sdDreamQuest        = Quest.GetQuest("_SDDA_BlackoutDreamworld") ;"_SD_DA_DreamworldRadiant") <- old ?
  endif  
  
  meSlaveQuest              = Quest.GetQuest("mariaedensslave")
  modLoadedMariaEden        = (meSlaveQuest != None)
  if modLoadedMariaEden
    meSlaveKeyword          = Game.GetFormFromFile(0x0022FB73, "Maria.esp") as Keyword ; lets try this
    meSlaveOnAStroll        = Game.GetFormFromFile(0x001A9EE6, "Maria.esp") as Quest ; TODO Quest
    meTransportOfGoods      = Game.GetFormFromFile(0x005373A9, "Maria.esp") as Quest
    meDefeatQuest           = Game.GetFormFromFile(0x0054617d, "Maria.esp") as Quest
    meSlaveIsJailed         = Game.GetFormFromFile(0x485D344D, "Maria.esp") as Quest
    meWhoresJob             = Game.GetFormFromFile(0x19604CAE, "Maria.esp") as Quest
    ;meWhoresJob            = Game.GetFormFromFile(0x24604CAE, "Maria.esp") as Quest
    ;meWhoreofPerson        = Game.GetFormFromFile(0x19604CAE, "Maria.esp") as Quest
    meCollarKeyword         = Game.GetFormFromFile(0x0022FB73, "Maria.esp") as Keyword
    meWhoreKeyword          = Game.GetFormFromFile(0x0625759B, "Maria.esp") as Keyword ; busy being whore, not quest/situation
    ; there are at least 3 collars in ME
    MariaEdensSlaverFaction   = Game.GetFormFromFile(0x000DC502, "Maria.esp") as Faction
    MariaEdensSlaveFaction    = Game.GetFormFromFile(0x00052CE8, "Maria.esp") as Faction
    MariaPotentialMaster      = Game.GetFormFromFile(0x2470B59b, "Maria.esp") as Faction
    meSlaveTraderQuest        = Game.GetFormFromFile(0x8F16BF7B, "Maria.esp") as Quest
  else ; vers 2+
    meDefeatQuest           = Quest.GetQuest("MariaDefeat")
    modLoadedMariaEden      = (meDefeatQuest != None)
    if modLoadedMariaEden   
      Debug.trace("[CRDE] Maria Eden 2.0+ detected")
      meSlaveQuest            = Quest.GetQuest("Maria000")
      meSlaveKeyword          = Game.GetFormFromFile(0x0022FB73, "Maria.esp") as Keyword ; lets try this
      meSlaveOnAStroll        = Quest.GetQuest("MariaEdensSlaveHunt") 
      meTransportOfGoods      = Quest.GetQuest("MariaWhoreSell")
      meSlaveIsJailed         = Game.GetFormFromFile(0x485D344D, "Maria.esp") as Quest
      meWhoresJob             = Game.GetFormFromFile(0x19604CAE, "Maria.esp") as Quest
      ;meWhoresJob            = Game.GetFormFromFile(0x24604CAE, "Maria.esp") as Quest
      ;meWhoreofPerson        = Game.GetFormFromFile(0x19604CAE, "Maria.esp") as Quest
      meCollarKeyword         = Game.GetFormFromFile(0x05C5B9EB, "Maria.esp") as Keyword
      meWhoreKeyword          = Game.GetFormFromFile(0x0625759B, "Maria.esp") as Keyword ; busy being whore, not quest/situation
      ; there are at least 3 collars in ME
      MariaEdensSlaverFaction   = Game.GetFormFromFile(0x000DC502, "Maria.esp") as Faction
      MariaEdensSlaveFaction    = Game.GetFormFromFile(0x00052CE8, "Maria.esp") as Faction
      MariaPotentialMaster      = Game.GetFormFromFile(0x2470B59b, "Maria.esp") as Faction
      meSlaveTraderQuest        = Game.GetFormFromFile(0x8F16BF7B, "Maria.esp") as Quest
      meAuctionQuest            = Game.GetFormFromFile(0x057CEF9F, "Maria.esp") as Quest

    endif
  endif 

  tir_start01               = Quest.GetQuest("tir_start01") ; TODO fix
  modLoadedTrappedInRubber  = tir_start01 != None
  if modLoadedTrappedInRubber
    tir_fw                  = Game.GetFormFromFile(0x0002A092, "Trapped in Rubber.esp") as Quest 
    tirWearingSuitFaction   = Game.GetFormFromFile(0x090395BB, "Trapped in Rubber.esp") as Faction
  endIf

  cdExpQuest02        = Quest.GetQuest("CDxExpQuest02")
  modLoadedCD         = cdExpQuest02 != None
  if modLoadedCD 
    cdPlayerSlave       = Quest.GetQuest("CDxSlavery_Player")
    cdPlayerProperty    = Quest.GetQuest("CDxSlavery_Property")
    cdSlaveShipCell     = Game.GetFormFromFile(0x0807A556, "Captured Dreams.esp") as Cell  
    cdMainShop          = Game.GetFormFromFile(0x080012D5, "Captured Dreams.esp") as Cell  
    cdGeneralFaction    = Game.GetFormFromFile(0x000AEABD, "Captured Dreams.esp") as Faction
    cdCustomerFaction   = Game.GetFormFromFile(0x00091F9D, "Captured Dreams.esp") as Faction
    cdProtectionAmulet  = Game.GetFormFromFile(0x290B31AF, "Captured Dreams.esp") as Armor
    cdProtectionBeltKW  = Game.GetFormFromFile(0x29118666, "Captured Dreams.esp") as Keyword
    ;Armor   Property cdGoldBelt auto
    ;Armor   Property cdGoldCollar auto
    ;Armor   Property cdGoldArmCuffs auto
    ;Armor   Property cdGoldLegCuffs auto
    ;Armor   Property cdSilverBelt auto
    ;Armor   Property cdSilverCollar auto
    ;Armor   Property cdSilverArmCuffs auto
    ;Armor   Property cdSilverLegCuffs auto
    cdTormentingPlug   = Game.GetFormFromFile(0x2A023866, "Captured Dreams.esp") as Armor
    cdOrgasmPlug       = Game.GetFormFromFile(0x2A042AF8, "Captured Dreams.esp") as Armor
    cdTeaserPlug       = Game.GetFormFromFile(0x2A109B9F, "Captured Dreams.esp") as Armor
    cdFinisherPlug     = Game.GetFormFromFile(0x2A109B9D, "Captured Dreams.esp") as Armor
    cdSpoilerPlug      = Game.GetFormFromFile(0x2A042AFC, "Captured Dreams.esp") as Armor
    cdExciterPlug      = Game.GetFormFromFile(0x2A042AFB, "Captured Dreams.esp") as Armor
    cdPunisherPlug     = Game.GetFormFromFile(0x2A042AF7, "Captured Dreams.esp") as Armor
    
    cdAssassinPlug     = Game.GetFormFromFile(0x08031AF1, "Captured Dreams.esp") as Armor
    cdFighterPlug      = Game.GetFormFromFile(0x08031AEC, "Captured Dreams.esp") as Armor
    cdTheifPlug        = Game.GetFormFromFile(0x08031AEF, "Captured Dreams.esp") as Armor
    cdMagePlug         = Game.GetFormFromFile(0x08030ABB, "Captured Dreams.esp") as Armor

    cdGoldBelt         = Game.GetFormFromFile(0x0806EA95, "Captured Dreams.esp") as Armor
    cdGoldCollar       = Game.GetFormFromFile(0x0806EA9F, "Captured Dreams.esp") as Armor
    cdGoldArmCuffs     = Game.GetFormFromFile(0x0806EA9D, "Captured Dreams.esp") as Armor
    cdGoldLegCuffs     = Game.GetFormFromFile(0x0806EAA1, "Captured Dreams.esp") as Armor
    cdSilverBelt       = Game.GetFormFromFile(0x08068996, "Captured Dreams.esp") as Armor
    cdSilverCollar     = Game.GetFormFromFile(0x080689A0, "Captured Dreams.esp") as Armor
    cdSilverArmCuffs   = Game.GetFormFromFile(0x0806899E, "Captured Dreams.esp") as Armor
    cdSilverLegCuffs   = Game.GetFormFromFile(0x080689A2, "Captured Dreams.esp") as Armor
    cdWhiteBelt        = Game.GetFormFromFile(0x08041D3A, "Captured Dreams.esp") as Armor
    cdWhiteCollar      = Game.GetFormFromFile(0x08041D44, "Captured Dreams.esp") as Armor
    cdWhiteArmCuffs    = Game.GetFormFromFile(0x08041D42, "Captured Dreams.esp") as Armor
    cdWhiteLegCuffs    = Game.GetFormFromFile(0x08041D46, "Captured Dreams.esp") as Armor
    cdBlackBelt        = Game.GetFormFromFile(0x08041D1E, "Captured Dreams.esp") as Armor
    cdBlackCollar      = Game.GetFormFromFile(0x08041D28, "Captured Dreams.esp") as Armor
    cdBlackArmCuffs    = Game.GetFormFromFile(0x08041D26, "Captured Dreams.esp") as Armor
    cdBlackLegCuffs    = Game.GetFormFromFile(0x08041D2A, "Captured Dreams.esp") as Armor
    cdRedBelt          = Game.GetFormFromFile(0x080784BC, "Captured Dreams.esp") as Armor
    cdRedCollar        = Game.GetFormFromFile(0x080784C6, "Captured Dreams.esp") as Armor
    cdRedArmCuffs      = Game.GetFormFromFile(0x080784C4, "Captured Dreams.esp") as Armor
    cdRedLegCuffs      = Game.GetFormFromFile(0x080784C8, "Captured Dreams.esp") as Armor
    
    cdxCellControl     = Quest.GetQuest("CDxCellController")
    
    cdFollowerTiedUp      = Game.GetFormFromFile(0x00105F0D , "Captured Dreams.esp") as GlobalVariable
    cdPreviousDisposition = (Game.GetFormFromFile(0x000892FC, "Captured Dreams.esp") as GlobalVariable).GetValueInt()
    
    RegisterForModEvent("CDxDisposition ","CDxDispositionUpdate")
    ;Armor   Property cdMagePlug auto
    ;Armor   Property cdTheifPlug auto
    ;Armor   Property cdAssassinPlug auto
    ;Armor   Property cdFighterPlug auto
  endIf
  
  wolfclubQuest           = Quest.GetQuest("pchsWolfClub"); TODO fix
  modLoadedWolfclub       = wolfclubQuest != None 
  if modLoadedWolfclub
    wolfclubGuy           = Game.GetFormFromFile(0x0500184F, "wolfclub.esp") as Actor ;alfred, the guy outside the cave
  endif

  hydraSlaverFaction      = Game.GetFormFromFile(0x0000B670, "hydra_slavegirls.esp") as Faction
  modLoadedHydra          = hydraSlaverFaction != None
  if modLoadedHydra
    hydraSlaverFactionCaravan = Game.GetFormFromFile(0x9A072F71, "hydra_slavegirls.esp") as Faction
    hydraSlaveFaction         = Game.GetFormFromFile(0x0000B671, "hydra_slavegirls.esp") as Faction
  endif

  ; slave factions are deprecated in newer versions
  modLoadedSlaverun               = (Quest.GetQuest("slaverunmcmmenu") != None) ;slaverunmcmmenu
  if(modLoadedSlaverun)
    slaverunSlaverFaction         = Game.GetFormFromFile(0x00012268 , "slaverun.esp") as Faction
    slaverunSlaveFaction          = Game.GetFormFromFile(0x00012267 , "slaverun.esp") as Faction
    slaverunSlaveQuest            = Game.GetFormFromFile(0x00011cbe , "slaverun.esp") as Quest ; TODO fix
    slaverunZaidActor             = Game.GetFormFromFile(0x00011cbe , "slaverun.esp") as Actor  
    ;slaverunEnforcerQuest        = Game.GetFormFromFile(0x000012c4 , "SlaverunEnforcer.esp") as Quest
  endif

  ; TODO finish
  slaverunRMainQuest               = Quest.GetQuest("SLV_Mainquest"); TODO fix
  modLoadedSlaverunR               = (slaverunRMainQuest != None)
  if  modLoadedSlaverunR
    if modLoadedSlaverun 
      Debug.trace("[CRDE] Both slaverun classic and reloaded are loaded, this is a bad idea!")
    endif
    slaverunRTrainingQuest      = Quest.GetQuest("SLV_Slavetraining")
    slaverunRPeriodicQuest      = Quest.GetQuest("SLV_PeriodicChecking") ;TODO Why won't this load?
    slaverunRMCMQuest           = Quest.GetQuest("slv_mcmmenu")
    slaverunZaidActor           = Game.GetFormFromFile(0x070012CB , "Slaverun_Reloaded.esp") as Actor  
    ;slaverunRSlaveFaction       = Game.GetFormFromFile(0x07049C94 , "slaverun.esp") as Faction
    ; more stuff to look at/for
  endif

  modLoadedPetCollar              = Quest.GetQuest("PetCollarConfig") != None
  if modLoadedPetCollar 
    petCollar                     = Game.GetFormFromFile(0x00000D65 , "PetCollar.esp") as Armor
    petCollar_script              = Game.GetFormFromFile(0x00000D64 , "PetCollar.esp") as Armor
    petCollarEffect               = Game.GetFormFromFile(0x0001157a , "PetCollar.esp") as MagicEffect
  endif

  
  modLoadedParadiseHalls          = (Quest.GetQuest("PAH") != None) ;PAH
  if(modLoadedParadiseHalls)
    paradiseSlaveFaction          = Game.GetFormFromFile(0x0000581B , "paradise_halls.esm") as Faction
    paradiseRespectfulFaction     = Game.GetFormFromFile(0x01058B8E , "paradise_halls.esm") as Faction ; should be respectful, for now
    paradisePlayerSlaveFaction    = Game.GetFormFromFile(0x000047db , "paradise_halls.esm") as Faction
    paradiseSlaveRestraintKW      = Game.GetFormFromFile(0x1204BE3B , "paradise_halls.esm") as Keyword
    paradiseFollowingFaction      = Game.GetFormFromFile(0x00007309 , "paradise_halls.esm") as Faction
    paradiseLeashedFaction        = Game.GetFormFromFile(0x040062DB , "paradise_halls.esm") as Faction 
    PAHETied                      = Game.GetFormFromFile(0x0501EBF6 , "paradise_halls_SLExtension.esp") as Faction 
  endif
  
  tailPlug        = Game.GetFormFromFile(0x00004371 , "sextoys-calyps-2.esp") as armor
  modLoadedCalyps = tailPlug != None
  ;if(modLoadedCalyps == true)
  ;  tailPlug        = Game.GetFormFromFile(0x00004371 , "sextoys-calyps-2.esp") as armor
  ;endif

  ; for now don't deprecate, we still need to turn off the quest if enslaved
  ;if modLoadedHelpless == true
    ;helplessFaction     = Game.GetFormFromFile(0x00005379, "DeviouslyHelpless.esp") as Faction
  ;endif
  
  miasTrapQuest          = Quest.GetQuest("MiaDungeonCapture") ; TODO fix
  modLoadedMiasLair       = (miasTrapQuest != None )
  if modLoadedMiasLair
    miasTrainingFaction    = Game.GetFormFromFile(0x000085B3, "MiasLair.esp") as Faction 
    miasBeginnerFaction    = Game.GetFormFromFile(0x000085B4, "MiasLair.esp") as Faction 
    miasSlaveFaction       = Game.GetFormFromFile(0x000085B5, "MiasLair.esp") as Faction 
    miasTrailQuest         = Game.GetFormFromFile(0x00002DED, "MiasLair.esp") as Quest
    miasChainedSlave       = Game.GetFormFromFile(0x100595E9, "MiasLair.esp") as Faction 
    miasAQSSMisSlave       = Game.GetFormFromFile(0x100E4958, "MiasLair.esp") as Faction

    ; might get the quest too, since I can use it to say the player is non-usable slave 
  endIf
  
  defeatCalmEffect       = Game.GetFormFromFile(0x0004274f, "SexLabDefeat.esp") as MagicEffect
  modLoadedDefeat         = (defeatCalmEffect != None)
  if(modLoadedDefeat)
    defeatCalmEffect       = Game.GetFormFromFile(0x0004274f, "SexLabDefeat.esp") as MagicEffect
    defeatCalmAltEffect    = Game.GetFormFromFile(0x000ca2f6, "SexLabDefeat.esp") as MagicEffect
    defeatFaction          = Game.GetFormFromFile(0x00001d92, "SexLabDefeat.esp") as Faction
    If (defeatCalmEffect != none && defeatCalmAltEffect != none && defeatFaction != none)
      ; might as well leave this here too, for acceptable debug
      Debug.trace("CRDE: Defeat registered")
    Else
      Debug.trace("CRDE: Defeat version not compatible")
    EndIf
  endif
  
  ;if modLoadedMoreDevious 
  ;mdeviousBusyFaction   = Game.GetFormFromFile(0x0004623d , "DeviousDevice - More Devious Quest.esp") as Faction
  ;modLoadedMoreDevious  = mdeviousBusyFaction != None

  ;if modLoadedSimpleSlavery    
  simpleslaveryQuest          = Quest.GetQuest("SimpleSlavery");= Game.GetFormFromFile(0x0000492e , "SimpleSlavery.esp") as Quest
  modLoadedSimpleSlavery      = simpleslaveryQuest != None
  if modLoadedSimpleSlavery
    ; cell where you get teleported to; we can look this up when we need it, not all the time
    simpleslaveryCell           = Game.GetFormFromFile(0x000250ED , "SimpleSlavery.esp") as Cell ; needed now that the quest stage hasn't advanced 
  endif

  ;if modLoadedMistakenIdentity != None
  mistakenIDQuest           = Quest.GetQuest("MIxASimpleDelivery") ;= Game.GetFormFromFile(0x00000d62 , "MistakenIdentity.esp") as Quest
  modLoadedMistakenIdentity = mistakenIDQuest != None
  ;if   endIf

  ;ftdSlaveFaction       = Game.GetFormFromFile(0x000036CB , "zFromTheDeeps.esp") as Faction ; old:0x000036CB
  ;ftdServantFaction     = Game.GetFormFromFile(0x7E0036CA , "zFromTheDeeps.esp") as Faction
  ;ftdDagonSlaveFaction  = Game.GetFormFromFile(0x0500B853 , "zFromTheDeeps.esp") as Faction
  modLoadedFromtheDeep  =  Quest.GetQuest("aFTD") != None
  if modLoadedFromtheDeep
    ftdDagonSlaveFaction  = Game.GetFormFromFile(0x0500B853 , "zFromTheDeepsV2.esp") as Faction
  endif
  
  
  ;if modLoadedAngrim
  modLoadedAngrim       = (Quest.GetQuest("AngrimBeltQuest") != None)
  if modLoadedAngrim
    angrimBeltKeyword     = Game.GetFormFromFile(0x00000d63, "AngrimApprentice.esp") as Keyword
    angrimGhostEffect     = Game.GetFormFromFile(0x460084A9, "AngrimApprentice.esp") as MagicEffect
  endif
  
  cidhnaMainJailQuest   = Quest.GetQuest("DvCidhna_Quest")
  modLoadedDeviousCidhna = (cidhnaMainJailQuest != None)
  if modLoadedDeviousCidhna
    cidhnaCapturedFaction = Game.GetFormFromFile(0x0001C89C , "Devious Cidhna.esp") as Faction
    cidhnaEscortFaction   = Game.GetFormFromFile(0x0001D8C9 , "Devious Cidhna.esp") as Faction  
    cidhnaCapturedFaction = Game.GetFormFromFile(0x0001C89C , "Devious Cidhna.esp") as Faction
    cidhnaErikurQuest     = Game.GetFormFromFile(0x6D01D8D1 , "Devious Cidhna.esp") as Quest
    cidhnaPirateQuest     = Game.GetFormFromFile(0x7500C568 , "Devious Cidhna.esp") as Quest
    cidhnaLostKnifeQuest  = Game.GetFormFromFile(0x6D0244B2 , "Devious Cidhna.esp") as Quest
    cidhnaNeighborQuest   = Game.GetFormFromFile(0x75008494 , "Devious Cidhna.esp") as Quest
  endif
  
  ; deprecated, mod is dead and no longer available
  ;sgomseCowBelt         = Game.GetFormFromFile(0x6E002DD6 , "soulgem-oven-100-milk-slave-experience.esp") as Armor
  ;modLoadedSGOMSE       = sgomseCowBelt != None
  ;if modLoadedSGOMSE   
  ;  sgomseCowCollar       = Game.GetFormFromFile(0x6E002DDB , "soulgem-oven-100-milk-slave-experience.esp") as Armor
  ;endif
  
  ;if modLoadedZazAnimations ; hard requirement, should always be loaded
  ; assign some of these in CK, so we don't have to keep doing this left right and center
  ; deprecate these definitions, we can assign this stuff from the esp, less papyrus time needed at start
  zazKeywordFurniture         = Game.GetFormFromFile(0x1100762B , "ZaZAnimationPack.esm") as Keyword 
  zazKeywordEffectRefresh     = Game.GetFormFromFile(0x11007352 , "ZaZAnimationPack.esm") as Keyword 
  ;zazKeywordWornGag           = Game.GetFormFromFile(0x02008A4D , "ZaZAnimationPack.esm") as Keyword 
  zazKeywordWornBlindfold     = Game.GetFormFromFile(0x11019FDC , "ZaZAnimationPack.esm") as Keyword 
  ;zazKeywordWornYoke          = Game.GetFormFromFile(0x1100F300 , "ZaZAnimationPack.esm") as Keyword 
  ;zazKeywordWornBelt          = Game.GetFormFromFile(0x11019FDB , "ZaZAnimationPack.esm") as Keyword 
  zazKeywordWornCollar        = Game.GetFormFromFile(0x11008A4E , "ZaZAnimationPack.esm") as Keyword 
  ;zazKeywordPermitOral        = Game.GetFormFromFile(0x11019FDA , "ZaZAnimationPack.esm") as Keyword 
  zazKeywordAnimWrists        = Game.GetFormFromFile(0x1101440C, "ZaZAnimationPack.esm") as Keyword 
  zazKeywordWornAnkles        = Game.GetFormFromFile(0x0A008A4C, "ZaZAnimationPack.esm") as Keyword
  zazBindings                 = Game.GetFormFromFile(0x11001002, "ZaZAnimationPack.esm") as Armor 
  zazHood                     = Game.GetFormFromFile(0x11005006, "ZaZAnimationPack.esm") as Armor
  zazLegCuffs                 = Game.GetFormFromFile(0x0A004002, "ZaZAnimationPack.esm") as Armor
  ;zazClothGag                 = Game.GetFormFromFile(0x02002002 , "ZaZAnimationPack.esm") as Armor
  ;zazBitGag                   = Game.GetFormFromFile(0x11002004 , "ZaZAnimationPack.esm") as Armor
  zazFactionSlave             = Game.GetFormFromFile(0x110096AE, "ZaZAnimationPack.esm") as Faction 
  zazFactionSlaver            = Game.GetFormFromFile(0x110096B0, "ZaZAnimationPack.esm") as Faction 
  zazKeywordEffectOffsetAnim  = Game.GetFormFromFile(0x0F0184EA, "ZaZAnimationPack.esm") as Keyword 
  zazKeywordHasBondageEffect  = Game.GetFormFromFile(0x0F008A2E, "ZaZAnimationPack.esm") as Keyword ;useles
  zazFactionAnimating         = Game.GetFormFromFile(0x0F00E2B7, "ZaZAnimationPack.esm") as Faction 

  modLoadedDarkwind             = (Quest.GetQuest("DWSexController") != none)
  if modLoadedDarkwind
    darkwindSlaveFaction        = Game.GetFormFromFile(0x860043BC , "Darkwind.esp") as Faction
  endif
  
  forswornStorySlaveFaction       = Game.GetFormFromFile(0x00035751 , "ZaForswornStory.esp") as Faction
  modLoadedForswornStory          = (forswornStorySlaveFaction  != None)
  if forswornStorySlaveFaction
    forswornStoryEnslavedFaction  = Game.GetFormFromFile(0x00034BE5 , "ZaForswornStory.esp") as Faction
    forswornStoryWhoreFaction     = Game.GetFormFromFile(0x0002C318 , "ZaForswornStory.esp") as Faction
  endif
  
  qaylQuickAsYouLikeQuest         = Quest.GetQuest("QAYL") ;= Game.GetFormFromFile(0x77000D64, "qayl.esp") as Quest
  modLoadedQuickAsYouLike         = (qaylQuickAsYouLikeQuest != none)
  
  modLoadedRavenous               = Quest.GetQuest("a1RBegin") != None
  if modLoadedRavenous
    ravMeatSlaveFaction             = Game.GetFormFromFile(0x8900707A, "a1Ravenous.esp") as Faction
  endif  
  
  ;devsurCalmMagicEffect           = Game.GetFormFromFile(0x00000D62, "DeviousSurrender.esp") as MagicEffect
  ;modLoadedDeviousSurrender       = (devsurCalmMagicEffect != None)
  
  tamslavesMainQuest              = Quest.GetQuest("SLTMineQuest") ;= Game.GetFormFromFile(0x71005453, "Slaves of Tamriel.esp") as Quest
  tamslavesTattooEffect           = Game.GetFormFromFile(0x00000D62, "DeviousSurrender.esp") as MagicEffect
  modLoadedDeviousSurrender       = (tamslavesMainQuest != None)
  
  bool previouslyLoaded              = modLoadedPrisonOverhaul || modLoadedPrisonOverhaulPatch
  xazMain                            = Game.GetFormFromFile(0x3E0012C7 , "xazPrisonOverhaul.esp") as Quest
  xazPrisonerFaction                  = Game.GetFormFromFile(0x0400FA9F , "xazPrisonOverhaul.esp") as Faction
  ;modLoadedPrisonOverhaul            = xazMain != None
  modLoadedPrisonOverhaul             = xazPrisonerFaction != None
  xazPOPatchQuest                     = Game.GetFormFromFile(0x0500EFF7  , "xazPrisonOverhaul - Patch.esp") as Quest
  modLoadedPrisonOverhaulPatch        = xazPOPatchQuest    != None
  PlayMonScript.isArrestable = modLoadedPrisonOverhaulPatch 
  if previouslyLoaded && !(modLoadedPrisonOverhaul || modLoadedPrisonOverhaulPatch)
    Debug.Trace("[crde] Prison overhual was previously loaded but now isn't")
    Debug.Trace("[crde] attempting reload with esp lookup, slower ...")
    modLoadedPrisonOverhaul         = isModActive("xazPrisonOverhaul.esp")
    modLoadedPrisonOverhaulPatch    = isModActive("xazPrisonOverhaul - Patch.esp")
    if !(modLoadedPrisonOverhaul || modLoadedPrisonOverhaulPatch)
      Debug.Trace("[crde] PrisonOverhual loaded successfully! (wtf) " + modLoadedPrisonOverhaul + " " + modLoadedPrisonOverhaulPatch)
    else
      Debug.Trace("[crde] Prison overhual did not load with esp lookup")
    endif
  endif

  modLoadedSLUTS              = Quest.GetQuest("sluts_kicker") != None
  if modLoadedSLUTS
    SLUTSRestrainingDevice    = Game.GetFormFromFile(0x0900BAF8 , "S_L_U_T_S.esp") as Keyword
    SLUTSHaulierFaction       = Game.GetFormFromFile(0x09001845 , "S_L_U_T_S.esp") as Faction
    SLUTSDriverFaction        = Game.GetFormFromFile(0x0900A542 , "S_L_U_T_S.esp") as Faction
    SLUTSLiveryFaction        = Game.GetFormFromFile(0x0900CB61 , "S_L_U_T_S.esp") as Faction
    SLUTSDirtyFaction         = Game.GetFormFromFile(0x0900F137 , "S_L_U_T_S.esp") as Faction
    
    SLUTSMissionKeyword       = Game.GetFormFromFile(0x52001852 , "S_L_U_T_S.esp") as Keyword
    SLUTSSlaveryKeyword       = Game.GetFormFromFile(0x52001853 , "S_L_U_T_S.esp") as Keyword
  endif
  
  lolaDSMainQuest             = Quest.GetQuest("vkjMQ") ;= Game.GetFormFromFile(0x05026EC9, "submissivelola.esp") as Quest
  ;lolaDSGag
  
  ;if modLoadedPrisonOverhaul         
    ;xaxPlayerInPrison             = StorageUtil.GetIntValue(Game.GetPlayer(), "xpoPCinJail") as bool
    ; we can get this any time, why waste it now
  ;if !modLoadedPrisonOverhaul && xazMain == None
  ;  Debug.Trace("[crde]Prison patch did not load correctly")
  ;endif
  
  ; might pass on this until I know more
  isleOfMaraEnslaveQuest            = Quest.getQuest("melislehookquest") ; = Game.GetFormFromFile(0x0E3C7857, "Debauchery.esp") as Quest ; new:983EB489
  modLoadedIsleofMara = isleOfMaraEnslaveQuest != None ; I don't think this quest existed in the original, so we should be good here
  if modLoadedIsleofMara
    isleOfMaraIsleWorldspace        = Game.GetFormFromFile(0x0E00DCA6, "Debauchery.esp") as Worldspace
    isleOfMaraSlaveFaction          = Game.GetFormFromFile(0x0E01D4F7, "Debauchery.esp") as Faction  ;new:9801D4F7 
    isleOfMaraPlayerSlaveFaction    = Game.GetFormFromFile(0x0E315FF3, "Debauchery.esp") as Faction ;captured faction
  endif
    
  modLoadedSlaveTats                = Quest.GetQuest("SlaveTatsMenu") != None ; just detection is enough for now
    
  temptressVixenRace                = Game.GetFormFromFile(0x02000D62, "TemptressVixen.esp") as Race
  
  workingGirlClientFaction          = Game.GetFormFromFile(0xA602A990, "SexLabWorkingGirl.esp") as Faction
  modLoadedWorkingGirl              = workingGirlClientFaction != None
  if modLoadedWorkingGirl
    workingGirlJobToken               = Game.GetFormFromFile(0x00012575, "SexLabWorkingGirl.esp") as MiscObject
  endif
  
  immersiveWenchGeneralFaction      = Game.GetFormFromFile(0x0701716E, "Immersive Wenches.esp") as Faction
    
  deviousPunishEquipmentBannnedCollar               = Game.GetFormFromFile(0x08000802, "Devious Punishment Equipment.esp") as Armor
  modLoadeddeviousPunishEquipment                   = deviousPunishEquipmentBannnedCollar != None
  if modLoadeddeviousPunishEquipment
    deviousPunishEquipmentProstitutedCollar           = Game.GetFormFromFile(0x08000809, "Devious Punishment Equipment.esp") as Armor
    deviousPunishEquipmentNakedCollar                 = Game.GetFormFromFile(0x08200000, "Devious Punishment Equipment.esp") as Armor
    deviousPunishEquipmentPunishPlug                  = Game.GetFormFromFile(0xB250000D, "Devious Punishment Equipment.esp") as Armor
  endif
    
  ;SLFameSlutGlobal                  = Game.GetFormFromFile(0x19024266, "SexLab - Sexual Fame [SLSF].esm") as GlobalVariable
  SLSF_Quest                        = Quest.GetQuest("SLSF_CompatibilityScript")
  modLoadedFameFramework            = SLSF_Quest != None
  ;if modLoadedFameFramework
    ;SLFameSlaveGlobal                 = Game.GetFormFromFile(0x05024267, "SexLab - Sexual Fame [SLSF].esm") as GlobalVariable ;05024259
    ;SLFameExhibitionistGlobal         = Game.GetFormFromFile(0x19024259, "SexLab - Sexual Fame [SLSF].esm") as GlobalVariable ;05024259
  ;endif
  
  modLoadedDeviousRegulations = Quest.GetQuest("DR_BeltGuard") != None
  if modLoadedDeviousRegulations 
    ; we can do plugs and stuff later, low priority
    deviousRegImperialKey       = Game.GetFormFromFile(0x39000D65, "DeviousRegulations.esp") as Key
    deviousRegStormCloakKey     = Game.GetFormFromFile(0x39000D66, "DeviousRegulations.esp") as Key
    deviousRegImperialBelt      = Game.GetFormFromFile(0x3900184C, "DeviousRegulations.esp") as Armor
    deviousRegStormCloakBelt    = Game.GetFormFromFile(0x390285CA, "DeviousRegulations.esp") as Armor
    deviousRegImperialBeltKW    = Game.GetFormFromFile(0x39021F76, "DeviousRegulations.esp") as Keyword
    deviousRegStormCloakBeltKW  = Game.GetFormFromFile(0x39021F77, "DeviousRegulations.esp") as Keyword
  endIf

  TITDQuest     = Quest.GetQuest("aTID1Slave")
  modLoadedTITD = TITDQuest != None
  if modLoadedTITD
    TITDSlaveFaction = Game.GetFormFromFile(0xBC00C06c, "zThingsInDark.esp") as Faction
  endIf
  
  huntedHouseQuest = Quest.GetQuest("aHH0")
  
  modLoadedSlaveTrainer = Quest.GetQuest("SLT_Main") != None
  if modLoadedSlaveTrainer
    sltSlaveFaction =  Game.GetFormFromFile(0x05001D91, "SlaveTrainer.esp") as Faction
  endif
  
  dawnguardLordForm =  Game.GetFormFromFile(0x0200283C, "Dawnguard.esm") as MagicEffect 

  Debug.Trace("[CRDE] ******** ignore any errors between these two messages FINISH ********", 1)
  finishedCheckingMods = true
endFunction

; Oh... right, we can do this here if we want
function equipCursedCollar()
  libs.EquipDevice(player, dcurCursedCollar, dcurCursedCollarS, libs.zad_DeviousCollar)

  ; replace this with a letter drop instead
  libs.playerRef.additem(dcurCursedLetter, 1, false)
endFunction

function equipSlaveCollar(actor actorRef)
  libs.EquipDevice(actorRef, dcurSlaveCollar, dcurSlaveCollarS, libs.zad_DeviousCollar)
endFunction

function equipSlutCollar(actor actorRef)
  libs.EquipDevice(actorRef, dcurSlutCollar, dcurSlutCollarS, libs.zad_DeviousCollar)
endFunction

function equipPetCollar(actor actorRef)
  libs.EquipDevice(actorRef, petCollar, petCollar_script, libs.zad_DeviousCollar)
endFunction

; uh oh, player only for now
function equipRubberDollCollar(actor actorRef)
  SendModEvent("dcur-triggerrubberdoll") ; TODO get the mod 
endFunction

function removeDCURCollars(actor actorRef)
  ; two colars
  ; unfinished: not sure if there's an easy way to fix issues here
endFunction

; should only be player
function enslaveSD(actor akActor)
  StorageUtil.SetFormValue( Game.getPlayer() , "_SD_TempAggressor", akActor)
  PlayMonScript.ItemScript.removeDDArmbinder(akActor)
  SendModEvent("PCSubEnslave")
  debugmsg("sent SD event for " + akActor, 1)
endFunction

function enslaveME(actor akActor)
    ;Actor master = Game.GetFormFromFile(0x003E3E65, "Maria.esp") as Actor
    ;(meSlave as MariaEdensTools).Enslave(akActor, 0)
    (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).enslave(akActor)
endFunction

; huh?
function enslaveTIR()
   if (tir_start01.GetStage() >= 30) && (tir_start01.GetStage() <= 40)
    tir_start01.SetStage(50)
  endif
endFunction

;deprecated
function enslaveWC()
  DistantEnslaveScript.enslaveWC()
endFunction

bool function canRunLocal()
  ;debugmsg( "can run slaverun: (modloaded slaverun, r, weight): " + modLoadedSlaverun + "," + modLoadedSlaverunR + "," + MCM.iEnslaveWeightSlaverun ) 

  return (modLoadedMariaEden && (MCM.iEnslaveWeightMaria > 0) ) || \
         (modLoadedSD && (MCM.iEnslaveWeightSD > 0)) || \
         ((modLoadedSlaverun || modLoadedSlaverunR) && (MCM.iEnslaveWeightSlaverun > 0))
  
endFunction

function clearHelpless()
  debugmsg("[CRDE] Clearing Helpless...", 1)
  if(modLoadedHelpless == true)
    debugmsg("[CRDE] Helpless is loaded...",1)
    (Quest.getQuest("crdeHelpless") as crdeHelplessScript).StopSceneAndClear()
  endif
endFunction

; this is for NPCs, for player use isplayerenslaved
; for factions and keywords, items are checked at isWearingSlave**
bool function isSlave(actor actorRef)
 
  ; fuck you paparus, giving me generic parameters unless they are objects
  if actorRef == None
    actorRef = player
  endif
  
  if actorRef.isInFaction(zazFactionSlave) 
    debugmsg("debug: " + actorRef.GetDisplayName() + " is in faction zazSlaveFaction", 3)
    return true
  endIf
  
	if( modLoadedHydra == true )
    ;if (actorRef.isInFaction(hydraSlaveGirlFaction))
    ;  debugmsg("debug: " + actorRef.GetDisplayName() + " is in hydra slave girl faction", 0)
    ;endif
    if ( actorRef.isInFaction(hydraSlaveFaction ) && !actorRef.isInFaction(hydraSlaverFaction))
      debugmsg("debug: " + actorRef.GetDisplayName() + " is in faction hydraSlaveFaction, not slaver fact", 3)
      return true
    endif
  endif
	if modLoadedSlaverun == true && actorRef.isInFaction(slaverunSlaveFaction) 
    debugmsg("debug: " + actorRef.GetDisplayName() + " is a Slaverun slave", 3)
		return true
  endif
  ; should this get reduced out to separate function? we might want it for follower interaction
	if modLoadedParadiseHalls == true 
    if actorRef.isInFaction(paradiseRespectfulFaction)
      debugmsg("debug: " + actorRef.GetDisplayName() + " is in the paradise hall faction and respectful", 3)
      return true
    elseif actorRef.WornHasKeyword(paradiseSlaveRestraintKW) ;&& actorRef.isInFaction(paradiseSlaveFaction) 
      debugmsg("debug: " + actorRef.GetDisplayName() + " is wearing a PAH slave collar (keyword)", 3)
      return true
    endif
  endif
	if  modLoadedMiasLair == true  ; too long
		if actorRef.isInFaction(miasBeginnerFaction) == true || actorRef.isInFaction(miasChainedSlave) ; come on guys, just make one faction and a quest or something
   		debugmsg("debug: " + actorRef.GetDisplayName() + " is mias lair slave", 3)
			return true
		endif
  endif
  if modLoadedFromTheDeep && actorRef.isInFaction(ftdSlaveFaction) || actorRef.isInFaction(ftdDagonSlaveFaction) 
    debugmsg("debug: " + actorRef.GetDisplayName() + " is from the deeps slave", 3)
    return true
  endif
  if modLoadedDarkwind && actorRef.isInFaction(darkwindSlaveFaction)  
    debugmsg("debug: " + actorRef.GetDisplayName() + " is a darkwind slave", 3)
    return true
  endif
  if modLoadedTITD && actorRef.IsInFaction(TITDSlaveFaction)
    debugmsg("debug: " + actorRef.GetDisplayName() + " is a thingsinthedark slave", 3)
    return true
  endif
  if modLoadedSGOMSE && ( actorRef.isEquipped(sgomseCowBelt) || actorRef.isEquipped(sgomseCowCollar))
      debugmsg("debug: " + actorRef.GetDisplayName() + " is a SGOMSE slave", 3)
      return true
  endif
  if modLoadedPetCollar && actorRef.HasMagicEffect(petCollarEffect)
    debugmsg("debug: " + actorRef.GetDisplayName() + " is a petcollar bitch", 3)
    return true
  endIf
  if modLoadedForswornStory && actorRef.isInFaction(forswornStoryEnslavedFaction) || player.isInFaction(forswornStorySlaveFaction) || actorRef.isInFaction(forswornStoryWhoreFaction)
    debugmsg("debug: " + actorRef.GetDisplayName() + " is a Forsworn Story slave", 3)
    return true
  endif
  if modLoadedIsleofMara && (actorRef.isInFaction(isleOfMaraSlaveFaction) || actorRef.isInFaction(isleOfMaraPlayerSlaveFaction))
    debugmsg("debug: " + actorRef.GetDisplayName() + " is a IOM slave", 3)
    return true
  endif

	return false
endFunction

;isSlaver <- search tag
bool function isSlaveTrader(actor actorRef)	
  ;if  actorRef.isInFaction(zazFactionSlaver) ||\
  ;    (modLoadedHydra     && actorRef.isInFaction(hydraSlaverFaction) ) ||\
  ;    (modLoadedSlaverun  && actorRef.isInFaction(slaverunSlaverFaction) ) ||\
  ;    (modLoadedMariaEden && actorRef.isInFaction(MariaEdensSlaverFaction))
  ;  return true
  
  ;debugmsg(actorRef.GetDisplayName() + " " + actorRef.isInFaction(hydraSlaverFaction) +" " + actorRef.isInFaction(hydraSlaverFactionCaravan) +" " + actorRef.isInFaction(hydraSlaveFaction) ) 

  if     actorRef.isInFaction(zazFactionSlaver)
    debugmsg("attacker is slaver: zbfFactionSlaver", 3)
    return true
  elseif modLoadedHydra && (actorRef.isInFaction(hydraSlaverFaction) || actorRef.isInFaction(hydraSlaverFactionCaravan)) && !actorRef.isInFaction(hydraSlaveFaction)
    debugmsg("attacker is slaver: hydra slaver faction", 3)
    return true
  elseif modLoadedSlaverun  && actorRef.isInFaction(slaverunSlaverFaction)
    debugmsg("attacker is slaver: slaverun slaver faction", 3)
    return true
  elseif modLoadedMariaEden && actorRef.isInFaction(MariaEdensSlaverFaction)
    debugmsg("attacker is slaver: maria eden slaver faction", 3)
    return true
  ;elseif actorRef == wolfclubGuy ; doesn't work anyway, wolfclub is disabled in the region where the guy stands
  ;  return true
	; get ready for Captured Dreams slave traders
  ; PAH slave traders?
	elseif(actorRef.GetDisplayName() == "Slaver" || actorRef.GetDisplayName() == "Slave Trader") ; moved to last, string compare takes longest
    debugmsg("attacker is slaver: Named:" + actorRef.GetDisplayName(), 3)
		return true
	endif
	return false
endFunction


; If there was a place to put "abused in sight of master" it would go here
; even if that's more of something that should be handled by the slave mods
; is player busy with mod, also determined here often
int function isPlayerEnslaved()

  bool      isEnslaved    = false
  location  curLocation   = player.GetCurrentLocation()
  cell      curCell       = player.GetParentCell()
  enslavedSD              = false
  enslavedME              = false
  iEnslavedLevel          = 0 ; reset
  
  ; the following are sorted in order of importance
  ; quests set to "do not attack" should have the higher priority, followed by un-removable items, regular enslavement
  
  if modLoadedDarkwind
    if player.isInFaction(darkwindSlaveFaction)       
      debugmsg("enslaved: darkwind slave 2", 3)
      setEnslavedLevel(2)      
    endif
  endif
  
  if modLoadedAngrim 
    if player.WornHasKeyword(angrimBeltKeyword)
      ; if the player is belted, then we should lock out the possibility of being re-enslaved by someone else
      setEnslavedLevel(2) ;
      debugmsg("enslaved: angrim belt 2", 3)
      return iEnslavedLevel
    elseif player.HasMagicEffect(angrimGhostEffect)
      setEnslavedLevel(3) ; they can't interact with the player anyway, this is pointless
      debugmsg("enslaved busy: is ghost, unapproachable", 3)
      return iEnslavedLevel
    endif
  endIf
  
  if modLoadedCD 
    if(cdExpQuest02.GetStage() > 50 && cdExpQuest02.GetStage() < 900) ; does this last until game reload?
      ;debugmsg("CD enslave 3")
      setEnslavedLevel(3)          ; expansion quest
      debugmsg("enslaved: cd expansion quest 3", 3)
      return iEnslavedLevel ; should be a singleton case, we can leave
    elseif curCell == cdSlaveShipCell || curCell == cdMainShop
      setEnslavedLevel(3)          ; slave start
      debugmsg("enslaved: CD location protected 3", 3)
      return iEnslavedLevel ; should be a singleton case, we can leave
    elseif (cdPlayerSlave != None && cdPlayerSlave.GetStage() != 0 && cdPlayerSlave.isRunning()) ||\
           (cdPlayerProperty != None && cdPlayerProperty.GetStage() != 0 && cdPlayerProperty.isRunning())
      setEnslavedLevel(2)          ; slave start
      debugmsg("enslaved: CD player is slave 2", 3)
      return iEnslavedLevel ; should be a singleton case, we can leave
    endif
    ; loaded but not a slave, keep going
  endif
   
  if modLoadedFromtheDeep
    if player.isinfaction(ftdSlaveFaction)
      setEnslavedLevel(2)
      debugmsg("enslaved: from depths slave fact 2", 3)
      return iEnslavedLevel
    elseif player.isinfaction(ftdServantFaction)     
      setEnslavedLevel(3)
      debugmsg("enslaved: from depths servant fact 3", 3)
      return iEnslavedLevel
    elseif player.isinfaction(ftdDagonSlaveFaction)
      setEnslavedLevel(2)
      debugmsg("enslaved: from depths dagon_slave fact 2", 3)
      return iEnslavedLevel
    endif
  endif

  if modLoadedSimpleSlavery  
    if simpleslaveryQuest.isRunning()
      if curCell == simpleslaveryCell || (simpleslaveryQuest.GetStage() < 10 && simpleslaveryQuest.GetStage() > 0)
        setEnslavedLevel(3) ; in cell, can get sex attacked
        debugmsg("enslaved: simple slave in cell 3", 3)
        return iEnslavedLevel
      elseif simpleslaveryQuest.GetStage() >= 10 && simpleslaveryQuest.GetStage() <= 40
        setEnslavedLevel(3) ; during actual auction, turn off (should be caught by scene anyway
        debugmsg("enslaved: simple slave on stage 3", 3)
        return iEnslavedLevel
      endif
    endif
  endif
  
  if modLoadedTITD 
    if player.isinfaction(TITDSlaveFaction)
      setEnslavedLevel(2)
      debugmsg("enslaved: things in the dank", 3)
      return iEnslavedLevel
    endif
  endif

  
  if modLoadedTrappedInRubber && player.isinfaction(tirWearingSuitFaction)
    ; should be faster than using an if, since it should get converted to faster add
    setEnslavedLevel(2 + (MCM.bEnslaveLockoutTIR as int))
    debugmsg("enslaved: trapped in rubber", 3)
    return iEnslavedLevel
  endif
  
  if modLoadedDeviousCidhna
    if cidhnaMainJailQuest.isRunning()  
      if cidhnaMainJailQuest.GetStage() >= 20
        setEnslavedLevel(3)      
        debugmsg("enslaved: devious cidhna concubine 3", 3)
        return iEnslavedLevel
      else
        setEnslavedLevel(1)      
        debugmsg("enslaved: devious cidhna mine playtoy 1", 3)
        return iEnslavedLevel
      endif
    elseif (cidhnaPirateQuest.isRunning()  && cidhnaPirateQuest.GetStage() < 50) \
        || ( cidhnaLostKnifeQuest.isRunning() && cidhnaLostKnifeQuest.GetStage() < 50)
      debugmsg("enslaved: devious cidhna jail/lostknife quests 1", 3)
      setEnslavedLevel(1) ; always vulnerable to sex attack as per plot of those quests
      return iEnslavedLevel
    elseif  cidhnaErikurQuest.isRunning() || cidhnaNeighborQuest.isRunning()
      setEnslavedLevel(3) ; don't interrupt
      debugmsg("enslaved: devious cidhna erikur/neighbor quests 3", 3)
      return iEnslavedLevel
    elseif player.isinfaction(cidhnaCapturedFaction)          
      setEnslavedLevel(2)          
      debugmsg("enslaved: devious cidhna captured 2", 3)
      return iEnslavedLevel
    elseif player.isinfaction(cidhnaEscortFaction) 
      setEnslavedLevel(2)      
      debugmsg("enslaved: devious cidhna escort 2", 3)
      return iEnslavedLevel
    endIf
    
  endIf
  
  if modLoadedQuickAsYouLike
    if qaylQuickAsYouLikeQuest.isRunning() && qaylQuickAsYouLikeQuest.GetStage() < 50
      debugmsg("enslaved: quickasyoulike quest 2", 3)
      setEnslavedLevel(2) 
      return iEnslavedLevel
    endif 
  endif
  
  if modLoadedMiasLair
    if  (miasTrapQuest.GetStage() < 80 && miasTrapQuest.GetStage() > 1 ) 
      ; we have to check for none since the quest doesn't exist in the last stable release, only the new beta
      setEnslavedLevel(3) ; short term, the quest needs to complete without interuption
      debugmsg("enslaved: mia's lair It'saTrap quest 3", 3)
      return iEnslavedLevel
    elseif (miasTrailQuest != None && miasTrailQuest.GetStage() > 52 && miastrailQuest.GetStage() < 340)
      setEnslavedLevel(3) ; we have slaves, not sure what would happen if you were enslaved with them following you
      debugmsg("enslaved: mia's lair OnTheTrail Quest with slaves 3", 3)
      return iEnslavedLevel
    endif
    ; add onthetrail capture so that, later, if we have slaves, we can stop the player from getting enslaved to avoid  trouble
    ; not added yet because right now 44-45 is beta and not released as official
  endif
  
  if modLoadedWolfclub 
    if(curLocation ==  wcCCLocation || curCell == CragslaneCavern01) ; just don't get in the way, for now
      setEnslavedLevel(3) ; I want "use if vulnerable" but it breaks the yoke animation for this mod
      debugmsg("enslaved: wolfclub 3", 3)
      return iEnslavedLevel ; should be a singleton case, we can leave
    endif
  endIf
  
  if modLoadedSLUTS && player.WornHasKeyword(SLUTSRestrainingDevice)
    setEnslavedLevel(2)
    debugmsg("enslaved: sluts 2", 3) ; for now, assume sex is fine, user can turn off if needed
    return iEnslavedLevel
  endif
  
  if modLoadedForswornStory
    if player.isInFaction(forswornStoryEnslavedFaction) || player.isInFaction(forswornStorySlaveFaction) 
      setEnslavedLevel(2) ; regular slave, depends on what you wear
      debugmsg("enslaved: forsworn story slave/enslaved faction 2", 3)
      return iEnslavedLevel
    elseif  player.isInFaction(forswornStoryWhoreFaction)
      setEnslavedLevel(1) ; whore, always aproachable
      debugmsg("enslaved: devious cidhna concubine quests 1", 3)
      return iEnslavedLevel
    endif
  endif
  
  if modLoadedSlavesOfTamriel 
    if tamslavesMainQuest.IsRunning()
      setEnslavedLevel(3) ; for now, I'll assume nobody can approach, certainly nobody can enslave
      debugmsg("enslaved: slaves of tamriel 3", 3)
      return iEnslavedLevel
    endif  
  endif
  
  if lolaDSMainQuest != None && lolaDSMainQuest.IsRunning()
    setEnslavedLevel(2) ; Don't know enough, leave as 2 and player can turn DE off if they like
    debugmsg("enslaved: lola DS slave 2", 3)
    enslavedLola = true
    return iEnslavedLevel
  endif
  
  if modLoadedIsleofMara
    if player.IsInFaction(isleOfMaraPlayerSlaveFaction) || (player.GetWorldSpace() == isleOfMaraIsleWorldspace)
      setEnslavedLevel(3); hope we can catch everything
      debugmsg("enslaved: isle of mara 3", 3)
      return iEnslavedLevel
    endif
  endif
  
  if modLoadedMariaEden == true
    if(player.IsInFaction(MariaEdensSlaveFaction))
      if(meSlaveOnAStroll.isRunning() && meSlaveOnAStroll.GetStage() != 0)
        debugmsg("enslaved: maria eden stroll quest 1", 3)
        setEnslavedLevel(1)      
      else
        debugmsg("enslaved: maria eden slave 2", 3)
        setEnslavedLevel(2)
      endif
      enslavedME = true
      return iEnslavedLevel ; should be a singleton case, we can leave
    elseif meTransportOfGoods.isRunning() || meSlaveIsJailed.isRunning()
      setEnslavedLevel(2) ; use but not re-enslavement, unless clothed
      debugmsg("enslaved: maria eden transport 2", 3)
      enslavedME = true
      return iEnslavedLevel ; should be a singleton case, we can leave
    elseif (meDefeatQuest != None && meDefeatQuest.isRunning()) || (meSlaveTraderQuest != None && meSlaveTraderQuest.isRunning())
      setEnslavedLevel(3) ; since attack can mean getting up and being free, should be possible but not if owner puts clothes on you
      debugmsg("enslaved: maria eden defeat or training 3", 3)
      enslavedME = true
      return iEnslavedLevel
    elseif (meWhoresJob.isRunning() || player.HasKeyword(meWhoreKeyword)) 
      setEnslavedLevel(3) ; extra sex just gets in the way, especially since it almost ALWAYS only triggers with the one NPC who you're already soliciting
      debugmsg("enslaved: maria eden player is whore, busy 3", 3)
      return iEnslavedLevel
    elseif meAuctionQuest != None && meAuctionQuest.isRunning()
      setEnslavedLevel(3) ; extra sex just gets in the way, especially since it almost ALWAYS only triggers with the one NPC who you're already soliciting
      debugmsg("enslaved: maria eden player is being sold at auction, busy 3", 3)
      return iEnslavedLevel
    endIf
    enslavedME = false
    ;debugmsg("Maria enslave not slave")
    ; loaded but not a slave, keep going
  endIf
  
  if modLoadedMistakenIdentity && mistakenIDQuest.isRunning() 
    ; stage 15 is the stage where the maid fetches the master, might as well turn it on here so that we
    ; don't get attacked by master when she sits down
    ; for now the quest ends, fix this when the mod gets more interesting
    int stage = mistakenIDQuest.GetStage()
    if stage > 15
      if stage >= 110 && stage < 150
        setEnslavedLevel(2)
        debugmsg("enslaved: mistaken identity errands quest 2", 3)
      else
        setEnslavedLevel(3)
        debugmsg("enslaved: mistaken identity is running, busy 3", 3)
      endif
      return iEnslavedLevel
    endif
    ; too early in quest, ignore
  endIf 
  
  ; devide into general items, at least until leons quest

  if(modLoadedCursedLoot == true)
    if dcurBondageQuest.IsRunning() && dcurBondageQuest.GetStage() < 1000
      debugmsg("enslaved: cursed loot bondage adventure quest 2", 3) ;&& dcurLeonQuest.GetStage() > 0
      setEnslavedLevel(2) ;  not sure why or where this quest is even used
    elseif (dcurLeonSlaveCollar != None && player.isEquipped(dcurLeonSlaveCollar)) || (dcurLeonGGQuest != None && dcurLeonGGQuest.IsRunning()) ;&& (dcurLeonGGQuest.GetStage() || dcurLeonGGQuest.GetStage() >= )
      debugmsg("enslaved: cursed loot leonGG quest 3", 3)
      setEnslavedLevel(3) ; block anything for now, for all I know we want to stop system
    elseif dcurDamselQuest.IsRunning()
      debugmsg("enslaved: cursed loot Damsel quest 2", 3) ;&& dcurLeonQuest.GetStage() > 0
      setEnslavedLevel(2) ; for now, 2, maybe 1 later
    elseif dcurLeonQuest != None && dcurLeonQuest.IsRunning() && dcurLeonQuest.GetStage() >= 40 && dcurLeonQuest.GetStage() < 1000
      debugmsg("enslaved: cursed loot leon quest 3", 3)
      setEnslavedLevel(3) ; block anything for now, for all I know we want to stop system
    endif
    bool DCLItemLock  = MCM.bEnslaveLockoutDCUR
    if player.isEquipped(dcurCursedCollar) == true  ;|| player.isEquipped(dcurCursedCollarS) == true
      debugmsg("enslaved: cursed loot cursed collar 2", 3)
      setEnslavedLevel(2) ; you don't be wearing clothes for long, but at the start you can stay decent if you wish
    elseif player.isEquipped(dcurSlaveCollar) && DCLItemLock  ;|| player.isEquipped(dcurSlaveCollarS) == true
      debugmsg("enslaved: cursed loot slave collar 2", 3)
      setEnslavedLevel(2) 
    elseif player.WornHasKeyword(dcurDollCollarKeyword) && DCLItemLock
      if MCM.bEnslaveLockoutCLDoll ; does the player want to lock out enslavement while collared?
        setEnslavedLevel(2)
      else
        ;setEnslavedLevel(2)
      endif
      debugmsg("enslaved: cursed loot doll collar " + iEnslavedLevel, 3)
    elseif(player.isEquipped(dcurSlutCollar) == true ) && DCLItemLock;|| player.isEquipped(dcurSlutCollarS) == true)
      debugmsg("enslaved: cursed loot slut collar 1", 3)
      setEnslavedLevel(1) 
    endIf
    if iEnslavedLevel > 0
      return iEnslavedLevel
    endif
  endIf
  
  if player.WornHasKeyword(libs.zad_BlockGeneric) ; most common stopgap
    if !MCM.bEnslaveLockoutDCUR && isBlockFromDCURItemsOnly()
      debugmsg("not enslaved: zad block generic detected, but only on DCUR items", 3)
    else
      setEnslavedLevel(2)   ; some blocking item, don't try to enslave over it
      debugmsg("enslaved: zad block generic keyword item, level 2", 3)
      ;return iEnslavedLevel ; should be a singleton case, we can leave
      ; we can keep going because we might get a enslave lvl 1, but since no lvl 0 can be assigned after this point we're fine
    endif  
  endif

  ; todo: make this a MCM option 
    ; no point, the follower will stop attacks and if no follower then player should be attackable
  if(modLoadedPetCollar == true)
    ;if(player.isEquipped(petCollar) == true) ; only catches one armor or official armor, magic effect can catch more (in thoery)
    if player.HasMagicEffect(petCollarEffect)
      debugmsg("enslaved: pet collar 2", 3)
      setEnslavedLevel(2) ; 2 takes fewer cpu cycles, let pet collar worry about keeping the player naked
    endIf
  endIf

  if(modLoadedSD == true)
    if (sdSlaveFaction != None && player.IsInFaction(sdSlaveFaction)) ; StorageUtil.GetIntValue(Game.GetPlayer(), "_SD_iEnslaved") > 0
      if MCM.bSDGeneralLockout
        debugmsg("enslaved: SD slave and lockout 3", 3)
        setEnslavedLevel(3) 
        enslavedSD = true
      else
        debugmsg("enslaved: sd enslaved 2", 3)
        setEnslavedLevel(2) ; up to master if the player is vulnerable
        enslavedSD = true
      endif
    elseif MCM.bEnslaveLockoutSDDream && curCell == sdDreamWorld
      setEnslavedLevel(3) ;lock out
    endIf
    
  endif

  if modLoadedSlaverunR
    ;if ; part of the training event, don't bother anything
    int stage = slaverunRTrainingQuest.GetStage() ; called too much, save it
    if slaverunRTrainingQuest.isRunning(); && slaverunRMainQuest.isRunning()
      if stage <= 10 ; start is kinda dialogue heavy, surrounded by attackers, let the scene playout
        PlayMonScript.master = slaverunZaidActor
        setEnslavedLevel(3)
        debugmsg("enslaved: slaverun reloaded slave training start 3", 3)
        return iEnslavedLevel    
      elseif SlaverunScript.PlayerIsInEnforcedLocation() && stage >= 1450 
        ;  you've gone through training and gained a reputation, people recognize you
        ; quest doesn't even need to be running
        ; might be be a better idea to set always vulnerable instead, but for now...
        PlayMonScript.master = slaverunZaidActor
        setEnslavedLevel(1)
        debugmsg("enslaved: slaverun reloaded trained slave 1", 3)
        return iEnslavedLevel
      elseif stage >= 200; you've been striped and have reported to zaid
        PlayMonScript.master = slaverunZaidActor
        setEnslavedLevel(2)
        debugmsg("enslaved: slaverun reloaded quest 2", 3)
        return iEnslavedLevel
      ;else ; player was stripped/raped, but did not report to anyone yet, in wild, not strictly restrained, and not locked to anything yet
      endif
    elseif slaverunRMainQuest.isRunning() && stage == 1500 ; trained, marked, in slaverun
      stage = slaverunRMainQuest.GetStage()
      ;if stage == 1000
      ;  PlayMonScript.master = slaverunZaidActor
      ;  setEnslavedLevel(3)
      ;  debugmsg("enslaved: slaverun entrance, ", 3)
      ;  return iEnslavedLevel
      if stage >= 1200 
        if SlaverunScript.PlayerIsInEnforcedLocation()
          PlayMonScript.master = slaverunZaidActor
          setEnslavedLevel(1)
          debugmsg("enslaved: slaverun reloaded slave location 1", 3)
          return iEnslavedLevel
        elseif MCM.bEnslaveLockoutSRR
          PlayMonScript.master = slaverunZaidActor
          setEnslavedLevel(2)
          debugmsg("enslaved: slaverun reloaded slave lock-out 2", 3)
          return iEnslavedLevel
        endif
        ; for now, if not in an enslaved location we consider the player free-able, and more importantly re-enslaveable
        debugmsg("enslaved but free: slaverun reloaded 2", 3)
        ;return iEnslavedLevel
      endif
    endif
  endif

  if modLoadedSlaverun
    ; there's probably a better way, but since there is one big main quest ...
    if slaverunSlaveQuest.isRunning() && slaverunSlaveQuest.GetStage() > 20
      setEnslavedLevel(2)
      debugmsg("enslaved: slaverun quest 2", 3)
      ; set zaid as master
      PlayMonScript.master = slaverunZaidActor
      return iEnslavedLevel
    endif
  endif
  
  if huntedHouseQuest!= None && huntedHouseQuest.GetStage() >= 50  && huntedHouseQuest.GetStage() < 520 
    debugmsg("enslaved: Hunted house 3", 3)
    setEnslavedLevel(3)
  endif
  
  if modLoadedSGOMSE && ( player.isEquipped(sgomseCowBelt) || player.isEquipped(sgomseCowCollar) )
      debugmsg("enslaved: SGOMES collar or belt 2", 3)
      setEnslavedLevel(2) ; up to master if the player is vulnerable
  endif
  
  if player.isInFaction(zazFactionSlave) 
    setEnslavedLevel(2) 
    debugmsg("enslaved: in zaz slave faction 2", 3)
    return iEnslavedLevel 
  endIf

  ;if zazFurnitureMilkOMatic ; moved to playerbusy instead
  
  ;if(modLoadedTrappedInRubber == true)
    ; TODO incomplete? hmm...
  ;endif

  ; might add a Mia's lair section here too ; player is rarely the slave
  
  ;Debug.trace("[CRDE] EnslaveLevel " + iEnslavedLevel)

  if iEnslavedLevel >= 1
    PlayMonScript.updateMaster()
  endif
  if iEnslavedLevel > 0
    debugmsg("enslaved: default return " + iEnslavedLevel, 2)
  endif
  return iEnslavedLevel
endFunction


; deprecate: this function no longer has a use, just adding to the stack load, slowdown
function setEnslavedLevel(int level)
; in theory this saves us time, but the condition branches are actually more expensive than the assignment
; for something as simple as one assignment, this actually slows us down
; It's actually faster to just assign even if we don't change anything
; the (only save highest) functionality can be implicit if you leave after the high value cases, never reach lower values
; even if this isn't used anymore, keeps the code in one place so we can change it back if we need to for some reason
  ;if(level >= 1) 
  ;  bEnslaved = true
  ;else
  ;  bEnslaved = false
  ;endIf
  bEnslaved = (level >= 1)
  iEnslavedLevel = level
endFunction

; --- PO patch functions

bool function isPlayerInJail()
  ; pretty sure we can check this without the other things
  ;debugmsg("POX StorageUtil: " + StorageUtil.GetIntValue(Game.GetPlayer(), "xpoPCinJail"), 1 )
  if StorageUtil.GetIntValue(Game.GetPlayer(), "xpoPCinJail") == true
    return true
  endif
  if modLoadedPrisonOverhaul || modLoadedPrisonOverhaulPatch
    ;debugmsg("StorageUtil: " + StorageUtil.GetIntValue(Game.GetPlayer(), "xpoPCinJail") + " Faction:" + player.IsInFaction(xazPrisonerFaction), 1)
    return (StorageUtil.GetIntValue(Game.GetPlayer(), "xpoPCinJail") || player.IsInFaction(xazPrisonerFaction)) as bool
  endif
  ;debugmsg("Player does not have PrisonOverhaul or patch", 1)
  ;elseif player is in jail cells
  return false
endFunction

; zad_BlockGeneric were detected on the player, is it from a DCUR item?
; WARNING: we assume not finding a blocking item at all to be a true case
bool function isBlockFromDCURItemsOnly()
  if dcur_removableBlockedItems == None
    debugmsg("isBlockFromDCURItems called but dcur_DDGenericBlockItems is None, cannot continue(is DCL not installed?)",4)
    return false
  endif

  int exp = 1
  Form armor_form = None
  Armor tmp_armor = None
  ; for all item slots
  while exp < 2147483648 
    armor_form = player.getWornForm(exp)
    ; if slot is not vacant
    if armor_form != None 
      tmp_armor = armor_form as Armor
      ; if has blocking keyword, and not in the dcur_list ; dcur_removableBlockedItems
      if tmp_armor.HasKeyword(libs.zad_BlockGeneric) && dcur_removableBlockedItems.Find(tmp_armor) == -1
        ; item has blocking keyword but not a dcur removable item, we have our answer
        debugmsg("Armor " + tmp_armor.GetName() + "has a block keyword, but does not belong to DCUR",3)
        return false
      endif
    endif
    exp = exp * 2
  endwhile
    ; is that item in the list?
    ; if not, return false
  ; return true
  return true
endFunction

; not ALL DCUR items, just the ones that have the blocking keyword but are also in the list of items we can safely remove...?
function removeDCURBlockingItems()
  ; for now empty, because I think I'll need more than one (per enslavment even)
endFunction

; these are for sexlab fame framework
Int function metReqFrameworkIncreaseVuln()
  if SLSF_Quest == None
    ;debugmsg("Fame quest is none")
    return 0
  endif
  int[] fame_values = (SLSF_Quest as SLSF_CompatibilityScript).GetCurrentFameValues()
  if fame_values.Length > 1
    debugmsg("current fame nums:(slut, slave, exhi) " + fame_values[17] + "/" + fame_values[18] + "/" + fame_values[4],1)
    return ((fame_values[17] >= MCM.iReqLevelSLSFSlutMakeVulnerable) as int) \
         + ((fame_values[18] >= MCM.iReqLevelSLSFSlaveMakeVulnerable) as int) \
         + ((fame_values[4] >= MCM.iReqLevelSLSFExhibMakeVulnerable) as int) 
  else
    debugmsg("fame system didn't return enough stats. size " + fame_values.Length)
  endif
  return 0
endFunction

; these are for sexlab fame framework
Int function metReqFrameworkMakeVuln()
  if SLSF_Quest == None
    ;debugmsg("Fame quest is none")
    return 0
  endif
  int[] fame_values = (SLSF_Quest as SLSF_CompatibilityScript).GetCurrentFameValues()
  if fame_values.Length > 16
    ;debugmsg("current fame nums:(slut, slave, exhi) " + fame_values[17] + "/" + fame_values[18] + "/" + fame_values[4],1)
    return ((fame_values[17] >= MCM.iReqLevelSLSFSlutIncreaseVulnerable) as int) \
         + ((fame_values[18] >= MCM.iReqLevelSLSFSlaveIncreaseVulnerable) as int) \
         + ((fame_values[4] >= MCM.iReqLevelSLSFExhibIncreaseVulnerable) as int) 
  else
    debugmsg("fame system didn't return enough stats. size " + fame_values.Length)
  endif
  return 0
endFunction

; if bounty is 0, then we use the bounty they already have in that hold
function arrestPlayer(int bounty = 0)
  if modLoadedPrisonOverhaulPatch
    if bounty == 0
      ; TODO: check to see if the new version counts as add or exact
      ;bounty = 500 
      bounty = PlayMonScript.localBounty
    endif
    SendModEvent("xpoArrestPC", "", bounty)
  else
    debugmsg("reached arrestPlayer without PO patches installed, so adding items instead", 5)
    crdeItemManipulateScript ItemScript = Quest.GetQuest("crdeItemManipulation") as crdeItemManipulateScript
    ItemScript.equipRandomGag(player)
    ItemScript.equipRandomAnkleChains(player)
    ItemScript.equipRandomDDBlindfolds(player)
  endIf
  ; if they don't have that mod, do nothing for now
endFunction

function addPointedValidRace(race r)
  if pointedValidRaces.length < 1
    pointedValidRaces = new race[10]
  endif

  int index = 0 ; this function should be used so infrequently that I think the CPU loss by not saving index is unimportant
  while pointedValidRaces[index] != None && index != pointedValidRaces.length
    index += 1
  endWhile
  
  if pointedValidRaces[index] == None
    pointedValidRaces[index] = r
  else
    debugmsg("Err: Race list index is not empty",4) ; shouldn't happen
  endif
  
endFunction

Event CDxDispositionUpdate(float newValue)
  ; xxxx
  if cdPreviousDisposition == 0 
    debugmsg("Err: cddisposition was zero when it shouldn't have been")
    cdPreviousDisposition = newValue as int
    return
  endif
  int diff = ((newValue as int) - cdPreviousDisposition) * 2
  actor[] a = PlayMonScript.NPCSearchScript.getNearbyFollowers() ;getNearbyActors() 
  PlayMonScript.adjustPerceptionPlayerSub( a, 0  - diff )
  PlayMonScript.adjustPerceptionPlayerDom( a, diff )

endEvent

bool function isTiedUpCDFollower( actor actorRef)

  if modLoadedCD
    actor[] suspected_actors = new actor[10]
    CDxCellController cell_controller = cdxCellControl as CDxCellController
    suspected_actors[0] = cell_controller.Alias_NewBarracksPrisoner.GetActorRef()
    suspected_actors[1] = cell_controller.Alias_NewCagePrisoner.GetActorRef()
    suspected_actors[2] = cell_controller.Alias_NewManorPrisoner.GetActorRef()
    suspected_actors[3] = cell_controller.Alias_NewShopPrisoner.GetActorRef()
    suspected_actors[4] = cell_controller.Alias_Prisoner01_Shop01.GetActorRef()
    suspected_actors[5] = cell_controller.Alias_Prisoner02_Shop02.GetActorRef()
    suspected_actors[6] = cell_controller.Alias_Prisoner03_Shop03.GetActorRef()
    suspected_actors[7] = cell_controller.Alias_Prisoner04_Shop04_Player.GetActorRef()
    suspected_actors[8] = cell_controller.Alias_Prisoner05_Manor01.GetActorRef()

  
    int i = 0
    actor tmp_actor
    while i < 10
      tmp_actor = suspected_actors[i]
      if tmp_actor != None && actorRef != tmp_actor
        return true
      endif
      i += 1
    endWhile
  endif
  return false

endFunction


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
