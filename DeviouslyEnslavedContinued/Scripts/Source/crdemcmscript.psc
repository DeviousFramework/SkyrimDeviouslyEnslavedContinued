scriptname crdeMCMScript extends SKI_ConfigBase
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: MCM
;
; Configuration script for the Deviously Enslaved Continued mod.
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

crdeModsMonitorScript Property Mods Auto
crdeStartQuestScript  Property StartScript Auto
import GlobalVariable ; apparently, need this to use global variable object functions, even if skyrim doesn't require it for actor ect

int lastChosenFollower
actor currentFollower 
string[] property actorNames Auto

;string Property ModName auto

int function GetVersion()
  return (StartScript.GetVersion() *10000) as int 
endFunction

; are we even using these, or did you forget about them
string[]  _difficultyList ; are any of these actually being used? I don't trust papyrus compiler to optimise these out

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int      _toggle1OID_B
int      _toggle2OID_B
int      _toggle3OID_B
int      _textOID_T
int      _counterOID_T
int      _sliderFormatOID_S
int      _difficultyMenuOID_M
; State
bool    _toggleState1      = false
bool    _toggleState2      = false
bool    _toggleState3      = false
int      _counter        = 0
float    _sliderPercent      = 50.0
int      _curDifficulty      = 0
; --- Version 2 ---
; OIDs
int      _colorOID_C
; State
int      _color          = 0xFFFFFF
; --- Version 3 ---
; OIDs
int      _keymapOID_K
; State
int      _myKey          = -1

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
  {Called when the user selects a menu option}
  if a_option == iGenderPrefOID
    SetMenuDialogStartIndex(iGenderPref)
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(genderList)
  elseif a_option == iGenderPrefMasterOID
    SetMenuDialogStartIndex(iGenderPrefMaster)
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(genderList)
  elseif a_option == aFollowerSelectOID
    SetMenuDialogStartIndex(0)
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(actorNames) ; xxx
  endIf
endEvent
; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
  {Called when the user accepts a new menu entry}
  if a_option == iGenderPrefOID
    iGenderPref = a_index
    SetMenuOptionValue(a_option, genderList[iGenderPref])
  elseif a_option == iGenderPrefMasterOID
    iGenderPrefMaster = a_index
    SetMenuOptionValue(a_option, genderList[iGenderPrefMaster])
  elseif a_option == aFollowerSelectOID
    lastChosenFollower = a_index
    ;UpdateFollowerPage()
    ;OnPageReset("Follower dialogue") ; might fix it
    ForcePageReset()
    ;SetMenuOptionValue(a_option, actorNames[lastChosenFollower])
  endIf
endEvent
; @implements SKI_ConfigBase
event OnOptionColorOpen(int a_option)
  {Called when a color option has been selected}
  if (a_option == _colorOID_C)
    SetColorDialogStartColor(_color)
    SetColorDialogDefaultColor(0xFFFFFF)
  endIf
endEvent
; @implements SKI_ConfigBase
event OnOptionColorAccept(int a_option, int a_color)
  {Called when a new color has been accepted}
  if (a_option == _colorOID_C)
    _color = a_color
    SetColorOptionValue(a_option, a_color)
  endIf
endEvent

; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnConfigInit()
  Utility.Wait(5) 
  while Mods.finishedCheckingMods == false
    Debug.Trace("[CRDE] mcm:mods not finished yet")
    Utility.Wait(2) 
  endwhile
  Pages = new string[8]
  Pages[0] = "" ; too lazy to move a page worth of contents here, just leaving it empty
  Pages[1] = "Settings"
  Pages[2] = "Item Options"
  Pages[3] = "Vulnerability"
  Pages[4] = "Enslavement"
  Pages[5] = "Follower dialogue"
  Pages[6] = "Intimidation Defense"
  Pages[7] = "Debug Settings"
  ModName = "Deviously Enslaved"  ; Why is this here? Because one user found his menu wasn't loading, 
                                  ; and the log said there was no name
                                  ; setting the name here fixed it
  
; the enslavement on toggles, init should be set to if the mod is loaded
; we have to chance the weights too, since our formuulas don't check if mods are loaded, just assume 0 weights

  ; TODO: delete this, deprecated waste
  bCDEnslaveToggle            = Mods.modLoadedCD
  if !Mods.modLoadedCD
    
    iEnslaveWeightCD            = 0 ; TODO: there shouldn't be two of these
    iDistanceWeightCD           = 0
  endif
  bMariaDistanceToggle        = Mods.modLoadedMariaEden
  ;bMariaKhajitEnslaveToggle   = Mods.modLoadedMariaEden
  if !Mods.modLoadedMariaEden
    iEnslaveWeightMaria         = 0
    iDistanceWeightMaria        = 0
  endif
  bSSAuctionEnslaveToggle       = Mods.modLoadedSimpleSlavery
  if !Mods.modLoadedSimpleSlavery
    iEnslaveWeightSS            = 0
  endif
  bSDDistanceToggle             = Mods.modLoadedSD
  if !Mods.modLoadedSD
    ;bSDtoggle doesn't exist yet
    iEnslaveWeightSD            = 0
    iDistanceWeightSD           = 0
  endif
  bSlaverunEnslaveToggle      = Mods.modLoadedSlaverun
  if !Mods.modLoadedSlaverun
    iEnslaveWeightSS            = 0
  endif
  bWCDistanceToggle           = Mods.modLoadedWolfclub
  if !Mods.modLoadedWolfclub
    iDistanceWeightWC           = 0
  endif
    
  actorNames = new string[15]
    
  Debug.Trace("[CRDE] mcm: finished init")
    
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
  {Called when a version update of this script has been detected}
  ; what. nothing? why even override?
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_ConfigBase
event OnPageReset(string a_page)
  {Called when a new page is selected, including the initial empty page}

  ; Load custom logo in DDS format
  if (a_page == "")
    ; Image size 256x256
    ; X offset = 376 - (height / 2) = 258
    ; Y offset = 223 - (width / 2) = 95
    LoadCustomContent("skyui/res/mcm_logo.dds", 258, 95)
    return
  else
    UnloadCustomContent()
  endIf
  SetCursorFillMode(TOP_TO_BOTTOM)

  ; first page SHOULD be image, actually
  if a_page == Pages[1] ;Settings

    gCRDEEnableOID        = AddToggleOption("Mod Enabled", gCRDEEnable.GetValueInt() == 1)
    ;bCRDEEnableOID        = AddToggleOption("Mod Enabled", bCRDEEnable)
    AddEmptyOption() ; spacer
    
    AddHeaderOption("Dialogue Chances")
    iChanceSexConvoOID              = AddSliderOption("Chance of Sex Conversation", iChanceSexConvo, "{0}%")
    iChanceEnslavementConvoOID      = AddSliderOption("Chance of Enslavement Conversation", iChanceEnslavementConvo, "{0}%")
    iChanceVulEnslavementConvoOID   = AddSliderOption("Chance of Armbinder Conversation", iChanceVulEnslavementConvo, "{0}%", 1)
    fModifierSlaverChancesOID       = AddSliderOption("Modifier of chances if NPC is Slaver", fModifierSlaverChances, "{1}"); slaver event modifier
    AddEmptyOption() ; spacer
    
    AddHeaderOption("General Settings")
    fEventIntervalOID     = AddSliderOption("Event Interval", fEventInterval, "{0} seconds")
    fEventTimeoutOID      = AddSliderOption("Event Timeout", fEventTimeoutHours, "{1} Game Hours")
    iSearchRangeOID       = AddSliderOption("Search range", gSearchRange.GetValueInt(), "{0} Inches")  ; event range
    iApproachDurationOID  = AddSliderOption("Search duration", iApproachDuration, "{0} Game Mins")
    iNPCSearchCountOID    = AddSliderOption("NPC Search Count", iNPCSearchCount , "{0} NPCs", 1) ; search depth
    iGenderPrefOID        = AddMenuOption("Approacher Gender Preference", genderList[iGenderPref])
    iGenderPrefMasterOID  = AddMenuOption("Master Gender Preference", genderList[iGenderPrefMaster])
    bUseSexlabGenderOID   = AddToggleOption("Use Sexlab Genders", bUseSexlabGender)
    AddEmptyOption() ; spacer
    
    SetCursorPosition(1) ; switched sides
    
    AddHeaderOption("Sex Events")
    bHookAnySexlabEventOID      = AddToggleOption("Trigger after all sex", bHookAnySexlabEvent)
    bHookReqVictimStatusOID     = AddToggleOption("Require Victim Requirement", bHookReqVictimStatus)
    bFxFAlwaysAggressiveOID     = AddToggleOption("FxF always aggressive", bFxFAlwaysAggressive)
    iSexEventKeyOID             = AddSliderOption("Chance of Key Removal", iSexEventKey, "{0}%")
    iSexEventDeviceOID          = AddSliderOption("Chance of Devious Device(s)", iSexEventDevice, "{0}%")
    AddEmptyOption() ; spacer
    
    AddHeaderOption("Rape Events")
    iRapeEventEnslaveOID      = AddSliderOption("Chance of Enslavement", iRapeEventEnslave, "{0}%")
    iRapeEventDeviceOID       = AddSliderOption("Chance of Devious Device(s)", iRapeEventDevice, "{0}%")
    AddEmptyOption() ; spacer
    
    AddHeaderOption("General lockout")
    bSDGeneralLockoutOID     = AddToggleOption("SD+ Enslave Lockout", bSDGeneralLockout, (!Mods.modLoadedSD) as int)

    
  elseif a_page == Pages[2] ; items
    AddHeaderOption("Event weights")
    iWeightSingleDDOID         = AddSliderOption("Standard Devious Device", iWeightSingleDD, "{0}")
    iWeightMultiDDOID          = AddSliderOption("Multiple Devious Devices", iWeightMultiDD, "{0}")
    iWeightUniqueCollarsOID    = AddSliderOption("Unique Collars", iWeightUniqueCollars, "{0}")
    iWeightRandomCDOID         = AddSliderOption("Random CD collection", iWeightRandomCD, "{0}")

    
    AddEmptyOption() ; spacer
    AddHeaderOption("Single Event weights")
    iWeightSingleCollarOID        = AddSliderOption("Collar", iWeightSingleCollar, "{0}")
    iWeightSingleGagOID           = AddSliderOption("Gag", iWeightSingleGag, "{0}")
    iWeightSingleArmbinderOID     = AddSliderOption("Armbinder", iWeightSingleArmbinder, "{0}")
    iWeightSingleCuffsOID         = AddSliderOption("Cuffs", iWeightSingleCuffs, "{0}")
    iWeightSingleHarnessOID       = AddSliderOption("Harness", iWeightSingleHarness, "{0}")
    iWeightSingleBeltOID          = AddSliderOption("Belt", iWeightSingleBelt, "{0}")
    iWeightSingleGlovesBootsOID   = AddSliderOption("Gloves and Boots", iWeightSingleGlovesBoots, "{0}")
    iWeightSingleAnkleChainsOID   = AddSliderOption("Ankle Chains", iWeightSingleAnkleChains, "{0}");(!Mods.iWeightSingleAnkleChains) as int)
    iWeightSingleBlindfoldOID     = AddSliderOption("Blindfold", iWeightSingleBlindfold, "{0}",1)
    iWeightSingleYokeOID          = AddSliderOption("Yoke", iWeightSingleYoke, "{0}", 1)
    iWeightSingleBootsOID         = AddSliderOption("Boots", iWeightSingleBoots, "{0}", 1);(!Mods.iWeightSingleBoots) as int)
    iWeightSingleHoodOID          = AddSliderOption("Hoods", iWeightSingleHood, "{0}", 1);(!Mods.iWeightSingleHood) as int)

    
    AddEmptyOption() ; spacer
    AddHeaderOption("Multiple Event weights")
    iWeightMultiPonyOID           = AddSliderOption("Pony suit", iWeightMultiPony, "{0}")
    iWeightMultiRedBNCOID         = AddSliderOption("Red Ebonite suit", iWeightMultiRedBNC, "{0}")
    iWeightMultiSeveralOID        = AddSliderOption("Several single items", iWeightMultiSeveral, "{0}")
    iWeightMultiTransparentOID    = AddSliderOption("DCUR Transparent Suit", iWeightMultiTransparent, "{0}")
    iWeightMultiRubberOID         = AddSliderOption("DCUR Rubber Suit", iWeightMultiRubber, "{0}")

    AddEmptyOption() ; spacer
    AddHeaderOption("Unique Collar Event weights")
    iWeightPetcollarOID               = AddSliderOption("Pet Collar", iWeightPetcollar, "{0}", (!Mods.modLoadedPetCollar) as int)
    iWeightCursedCollarOID            = AddSliderOption("Cursed Collar", iWeightCursedCollar, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iWeightSlaveCollarOID             = AddSliderOption("Slave Collar", iWeightSlaveCollar, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iWeightSlutCollarOID              = AddSliderOption("Slut Collar", iWeightSlutCollar, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iWeightRubberDollCollarOID        = AddSliderOption("Rubber Doll Collar", iWeightRubberDollCollar, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iWeightDeviousPunishEquipmentBannnedCollarOID     = AddSliderOption("Banned Collar", iWeightDeviousPunishEquipmentBannnedCollar, "{0}", (!Mods.modLoadedDeviousPunishEquipment) as int)
    iWeightDeviousPunishEquipmentProstitutedCollarOID = AddSliderOption("Prostituted Collar", iWeightDeviousPunishEquipmentProstitutedCollar, "{0}", (!Mods.modLoadedDeviousPunishEquipment) as int)
    iWeightDeviousPunishEquipmentNakedCollarOID       = AddSliderOption("Naked Collar", iWeightDeviousPunishEquipmentNakedCollar, "{0}",(!Mods.modLoadedDeviousPunishEquipment) as int)
    iWeightStripCollarOID             = AddSliderOption("Strip Collar", iWeightStripCollar, "{0}", (!Mods.modLoadedCursedLoot) as int)
    
    AddEmptyOption() ; spacer
    ;AddHeaderOption("Event weights")
        ;AddEmptyOption() ; spacer

    SetCursorPosition(1) ; switched sides
    
    AddHeaderOption("Theme weights")
    ;iWeightDDRegularOID           = AddSliderOption("Single DD Items", iWeightDDRegular, "{0}", 1);(!Mods.iWeightDDRegular) as int)
    iWeightDDZazVelOID            = AddSliderOption("Single DD-Zaz Items", iWeightDDZazVel, "{0}", 1);(!Mods.iWeightDDZazVel) as int)
    iWeightZazRegOID              = AddSliderOption("Single Zaz Items", iWeightZazReg, "{0}", 1);(!Mods.iWeightZazReg) as int)
    AddEmptyOption() ; spacer

    iWeightEboniteRegularOID      = AddSliderOption("Black Ebonite", iWeightEboniteRegular, "{0}", 1)
    iWeightEboniteRedOID          = AddSliderOption("Red Ebonite", iWeightEboniteRed, "{0}" , 1)
    iWeightEboniteWhiteOID        = AddSliderOption("White Ebonite", iWeightEboniteWhite, "{0}", 1)
    iWeightZazMetalBrownOID       = AddSliderOption("Brown Metal Zaz", iWeightZazMetalBrown, "{0}", 1);(!Mods.iWeightZazMetalBrown) as int)
    iWeightZazMetalBlackOID       = AddSliderOption("Black Metal Zaz", iWeightZazMetalBlack, "{0}", 1);(!Mods.iWeightZazMetalBlack) as int)
    iWeightZazLeatherOID          = AddSliderOption("Leather Zaz", iWeightZazLeather, "{0}", 1);(!Mods.iWeightZazLeather) as int)
    iWeightZazRopeOID             = AddSliderOption("Rope Zaz", iWeightZazRope, "{0}", 1);(!Mods.iWeightZazRope) as int)
    iWeightCDGoldOID              = AddSliderOption("CD Gold", iWeightCDGold, "{0}", 1);(!Mods.iWeightCDGold) as int)
    iWeightCDSilverOID            = AddSliderOption("CD Silver", iWeightCDSilver, "{0}", 1);(!Mods.iWeightCDSilver) as int)
    
    AddEmptyOption() ; spacer
    AddHeaderOption("Plugs and stuff")
    iWeightPlugsOID               = AddSliderOption("Plugs", iWeightPlugs, "{0}")
    iWeightPiercingsOID           = AddSliderOption("Piercings", iWeightPiercings, "{0}")
    AddEmptyOption() ; spacer
    iWeightPiercingsSoulGemOID    = AddSliderOption("iWeightPiercingsSoulGem", iWeightPiercingsSoulGem, "{0}", 1);(!Mods.iWeightPiercingsSoulGem) as int)
    iWeightPiercingsShockOID      = AddSliderOption("iWeightPiercingsShock", iWeightPiercingsShock, "{0}", 1);(!Mods.iWeightPiercingsShock) as int)
    iWeightPlugSoulGemOID         = AddSliderOption("Soul Gem Plug", iWeightPlugSoulGem, "{0}")
    iWeightPlugInflatableOID      = AddSliderOption("Inflatable Plug", iWeightPlugInflatable, "{0}")
    iWeightPlugChargingOID        = AddSliderOption("Charging Plug", iWeightPlugCharging, "{0}")
    iWeightPlugShockOID           = AddSliderOption("Shock Plug", iWeightPlugShock, "{0}")
    iWeightPlugTrainingOID        = AddSliderOption("Training Plug", iWeightPlugTraining, "{0}")
    iWeightPlugCDEffectOID        = AddSliderOption("CD Special Plugs", iWeightPlugCDEffect, "{0}", (!Mods.modLoadedCD) as int)
    iWeightPlugCDClassOID         = AddSliderOption("CD Class Plugs", iWeightPlugCDSpecial, "{0}", (!Mods.modLoadedCD) as int);(!Mods.modLoadedCD) as int)
    iWeightPlugWoodOID            = AddSliderOption("Wood plugs", iWeightPlugWood, "{0}", 1);(!Mods.iWeightPlugWood) as int)
    iWeightPlugDashaOID           = AddSliderOption("Devious Toys Plugs", iWeightPlugDasha, "{0}", 1);(!Mods.iWeightPlugDasha) as int)

    AddEmptyOption() ; spacer
    AddHeaderOption("Belts")
    iWeightBeltPunishmentOID      = AddSliderOption("Punishment Belt", iWeightBeltPunishment, "{0}")
    iWeightBeltRegularOID         = AddSliderOption("Regular Belt", iWeightBeltRegular, "{0}")
    AddEmptyOption() ; spacer
    iWeightBeltPaddedOID                  = AddSliderOption("Padded Belt", iWeightBeltPadded, "{0}")
    iWeightBeltIronOID                    = AddSliderOption("Iron Belt",  iWeightBeltIron, "{0}")
    iWeightBeltRegulationsImperialOID     = AddSliderOption("Imperial Belt", iWeightBeltRegulationsImperial, "{0}", (!Mods.modLoadedDeviousRegulations) as int)
    iWeightBeltRegulationsStormCloakOID   = AddSliderOption("StormCloak Belt", iWeightBeltRegulationsStormCloak, "{0}", (!Mods.modLoadedDeviousRegulations) as int)
    iWeightBeltShameOID                   = AddSliderOption("Shame belt", iWeightBeltShame, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iWeightBeltCDOID                      = AddSliderOption("CD belt", iWeightBeltCD, "{0}", (!Mods.modLoadedCD) as int)

    AddEmptyOption() ; spacer
    AddHeaderOption("Boots")
    iWeightBootsSlaveOID        = AddSliderOption("iWeightBootsSlave", iWeightBootsSlave, "{0}", 1);(!Mods.iWeightBootsSlave) as int)
    iWeightBootsRestrictiveOID  = AddSliderOption("iWeightBootsRestrictive", iWeightBootsRestrictive, "{0}", 1);(!Mods.iWeightBootsRestrictive) as int)
    iWeightBootsPonyOID         = AddSliderOption("iWeightBootsPony", iWeightBootsPony, "{0}", 1);(!Mods.iWeightBootsPony) as int)
    ; punishment boots from that one guys mod
    
    AddEmptyOption() ; spacer
    AddHeaderOption("Tattoos")
    iWeightSlutTattooOID    = AddSliderOption("iWeightSlutTattoo", iWeightSlutTattoo, "{0}", 1);(!Mods.iWeightSlutTattoo) as int)
    iWeightSlaveTattooOID   = AddSliderOption("iWeightSlaveTattoo", iWeightSlaveTattoo, "{0}", 1);(!Mods.iWeightSlaveTattoo) as int)
    iWeightWhoreTattooOID   = AddSliderOption("iWeightWhoreTattoo", iWeightWhoreTattoo, "{0}", 1);(!Mods.iWeightWhoreTattoo) as int)

    
  elseif a_page == Pages[3] ; vulnerability

    AddHeaderOption("General Options")
    iMinEnslaveVulnerableOID        = AddSliderOption("Minimum Enslavement Vulnerability", iMinEnslaveVulnerable, "Level {0}")
    iMinApproachArousalOID          = AddSliderOption("Minimum NPC Arousal", gMinApproachArousal.GetValueInt(), "{0}%")
    iMaxEnslaveMoralityOID          = AddSliderOption("Maximum Morality (enslave)", iMaxEnslaveMorality, "Level {0}")
    iMaxSolicitMoralityOID          = AddSliderOption("Maximum Morality (sex)", iMaxSolicitMorality, "Level {0}")
    bIsVulNakedOID                  = AddToggleOption("Nudity Vulnerability", bIsVulNaked)
    bIsNonChestArmorIgnoredNakedOID = AddToggleOption("Alt Armor Slot Protection", bIsNonChestArmorIgnoredNaked)
    ;bChastityToggleOID              = AddToggleOption("Chastity Protection", bChastityToggle); deprecated: duplicate
    bVulnerableLOSOID               = AddToggleOption("Line of sight", bVulnerableLOS)
    iWeaponProtectionLevelOID       = AddSliderOption("Weapon Protection Level", iWeaponProtectionLevel, "Level {0}")
    iRelationshipProtectionLevelOID = AddSliderOption("Relationship Protection Level", iRelationshipProtectionLevel, "Level {0}")
    bVulnerableFurnitureOID         = AddToggleOption("Xaz Furniture", bVulnerableFurniture)
    bAttackersGuardsOID             = AddToggleOption("Guards Toggle",  bAttackersGuards)
    bAltBodySlotSearchWorkaroundOID = AddToggleOption("Alternate body slot search", bAltBodySlotSearchWorkaround)
    
    AddEmptyOption() ; spacer
    AddHeaderOption("Nighttime Options")
    fNightReqArousalModifierOID      = AddSliderOption("Night Arousal Modifier", fNightReqArousalModifier, "{1}", 0);(!Mods.fNightReqArousalModifier) as int)
    fNightDistanceModifierOID        = AddSliderOption("Night Distance Modifier", fNightDistanceModifier, "{1}", 1);(!Mods.fNightDistanceModifier) as int)
    fNightChanceModifierOID          = AddSliderOption("Night Approach Chance Modifier", fNightChanceModifier, "{1}", 0);(!Mods.fNightChanceModifier) as int
    iNightReqConfidenceReductionOID  = AddSliderOption("iNightReqConfidenceReduction", iNightReqConfidenceReduction, "{0}", 0);(!Mods.iNightReqConfidenceReduction) as int)
    bNightAddsToVulnerableOID        = AddToggleOption("Night Makes More Vulnerable", bNightAddsToVulnerable, 0);(!Mods.bNightAddsToVulnerable) as int)
    
    ;AddEmptyOption() ; spacer

    
    AddEmptyOption() ; spacer
    AddHeaderOption("Vulnerable items")
    bVulnerableGagOID         = AddToggleOption("Gag", bVulnerableGag)
    bVulnerableCollarOID      = AddToggleOption("Collar", bVulnerableCollar)
    bVulnerableArmbinderOID   = AddToggleOption("Armbinder+Yoke", bVulnerableArmbinder)
    bVulnerableBlindfoldOID   = AddToggleOption("BlindFold", bVulnerableBlindfold)
    bVulnerableBukkakeOID     = AddToggleOption("Semen", bVulnerableBukkake)
    bVulnerableSlaveBootsOID  = AddToggleOption("SlaveBoots",  bVulnerableSlaveBoots)
    bVulnerableHarnessOID     = AddToggleOption("Harness", bVulnerableHarness)
    bVulnerablePiercedOID     = AddToggleOption("Piercings", bVulnerablePierced)
    bVulnerableSlaveTattooOID = AddToggleOption("Slave Tattoos", bVulnerableSlaveTattoo)
    bVulnerableSlutTattooOID  = AddToggleOption("Slut Tattoos", bVulnerableSlutTattoo)
    
    SetCursorPosition(1) ; switch sides
    
    ;AddHeaderOption("Vulnerability Protection") 
    AddHeaderOption("Chastity General") 
    bChastityToggleOID            = AddToggleOption("Chastity Enable", bChastityToggle)
    fChastityPartialModifierOID   = AddSliderOption("Approach chance (partial) Modifier", fChastityPartialModifier, "{1}")
    fChastityCompleteModifierOID  = AddSliderOption("Approach chance (full) Modifier", fChastityCompleteModifier, "{1}")
    ; sliders for weight adjustment: partial and total chastity chances
    
    AddEmptyOption() ; spacer
    AddHeaderOption("Chastity items")   
    bChastityGagOID        = AddToggleOption("DD Gag (Blocking)", bChastityGag)
    bChastityBraOID        = AddToggleOption("DD Bra", bChastityBra)
    bChastityLockingZazOID = AddToggleOption("Restrict Zaz to locking items only", bChastityLockingZaz, 1)
    bChastityZazGagOID     = AddToggleOption("Zaz Gag (Blocking)", bChastityZazGag)
    bChastityZazBeltOID    = AddToggleOption("Zaz Belts", bChastityZazBelt)

    AddEmptyOption() ; spacer
    AddEmptyOption() ; spacer 
    AddHeaderOption("Fame Makes vulnerable")
    iReqLevelSLSFSlaveIncreaseVulnerableOID  = AddSliderOption("SLSF Slave Increases vulnerable", iReqLevelSLSFSlaveIncreaseVulnerable, "{0}", (!Mods.modLoadedFameFramework) as int)
    iReqLevelSLSFExhibIncreaseVulnerableOID  = AddSliderOption("SLSF Exhibition Increases vulnerable", iReqLevelSLSFExhibIncreaseVulnerable, "{0}", (!Mods.modLoadedFameFramework) as int)
    iReqLevelSLSFSlutIncreaseVulnerableOID   = AddSliderOption("SLSF Slut Increases vulnerable", iReqLevelSLSFSlutIncreaseVulnerable, "{0}", (!Mods.modLoadedFameFramework) as int)
    
    ;AddEmptyOption() ; spacer
    ;AddHeaderOption("Fame Makes vulnerable")
    iReqLevelSLSFSlaveMakeVulnerableOID  = AddSliderOption("SLSF Slave Makes vulnerable", iReqLevelSLSFSlaveMakeVulnerable, "{0}", (!Mods.modLoadedFameFramework) as int)
    iReqLevelSLSFExhibMakeVulnerableOID  = AddSliderOption("SLSF Exhibition Makes vulnerable", iReqLevelSLSFExhibMakeVulnerable, "{0}", (!Mods.modLoadedFameFramework) as int)
    iReqLevelSLSFSlutMakeVulnerableOID   = AddSliderOption("SLSF Slut Makes vulnerable", iReqLevelSLSFSlutMakeVulnerable, "{0}", (!Mods.modLoadedFameFramework) as int)

    ;AddEmptyOption() ; spacer
    AddEmptyOption() ; spacer
    AddHeaderOption("Vulnerable only while naked")
    bNakedReqGagOID         = AddToggleOption("Gag", bNakedReqGag, (!bIsVulNaked) as int)
    bNakedReqCollarOID      = AddToggleOption("Collar", bNakedReqCollar, (!bIsVulNaked) as int)
    bNakedReqArmbinderOID   = AddToggleOption("Armbinder+Yoke", bNakedReqArmbinder, 1)
    bNakedReqBlindfoldOID   = AddToggleOption("BlindFold", bNakedReqBlindfold, 1)
    bNakedReqBukkakeOID     = AddToggleOption("Semen", bNakedReqBukkake, (!bIsVulNaked) as int)
    bNakedReqSlaveBootsOID  = AddToggleOption("SlaveBoots",  bNakedReqSlaveBoots, 1)
    bNakedReqHarnessOID     = AddToggleOption("Harness", bNakedReqHarness, (!bIsVulNaked) as int)
    bNakedReqPiercedOID     = AddToggleOption("Piercings", bNakedReqPierced, (!bIsVulNaked) as int)
    bNakedReqSlaveTattooOID = AddToggleOption("Slave Tattoos", bNakedReqSlaveTattoo)
    bNakedReqSlutTattooOID  = AddToggleOption("Slut Tattoos", bNakedReqSlutTattoo)
    
  elseif a_page == Pages[4] ;Enslavement
    
    AddHeaderOption("General enslavement options")
    bGuardDialogueToggleOID       = AddToggleOption("Guard dialogue", bGuardDialogueToggle)
    bEnslaveLockoutDCUROID        = AddToggleOption("Cursed loot Blocking item lock", bEnslaveLockoutDCUR, (!Mods.modLoadedCursedLoot) as int)
    bEnslaveFollowerLockToggleOID = AddToggleOption("Nearby Follower Lock", bEnslaveFollowerLockToggle)
    
    AddHeaderOption("Enslavement Toggle Local")
    bMariaEnslaveToggleOID      = AddToggleOption("Maria local", bMariaEnslaveToggle, (!Mods.modLoadedMariaEden) as int)
    bSlaverunEnslaveToggleOID   = AddToggleOption("Slaverun Enslavement", bSlaverunEnslaveToggle, (!(Mods.modLoadedSlaverun || Mods.modLoadedSlaverunR)) as int)
    bSDEnslaveToggleOID         = AddToggleOption("SD+ local", bSDEnslaveToggle, (!Mods.modLoadedSD) as int)
    
    AddHeaderOption("Enslavement Toggle Distance (Given)")
    bWCDistanceToggleOID        = AddToggleOption("Wolfclub", bWCDistanceToggle, (!Mods.modLoadedWolfclub) as int)
    bSDDistanceToggleOID        = AddToggleOption("SD+", bSDDistanceToggle, (!Mods.modLoadedSD) as int)
    bDCPirateEnslaveToggleOID   = AddToggleOption("Devious Cidhna (Pirate)", bDCPirateEnslaveToggle, (!Mods.modLoadedDeviousCidhna) as int)
    bMariaDistanceToggleOID     = AddToggleOption("Maria's Eden (regular)", bMariaDistanceToggle, (!Mods.modLoadedMariaEden) as int)
    
    AddHeaderOption("Enslavement Toggle Distance (Sold)")
    bCDEnslaveToggleOID         = AddToggleOption("Captured Dreams", bCDEnslaveToggle, (!Mods.modLoadedCD) as int)
    bSSAuctionEnslaveToggleOID  = AddToggleOption("Simple Slavery auction", bSSAuctionEnslaveToggle, (!Mods.modLoadedSimpleSlavery) as int)
    bMariaKhajitEnslaveToggleOID= AddToggleOption("Maria's Eden (sold to khajit)", bMariaKhajitEnslaveToggle, (!Mods.modLoadedMariaEden) as int)
    
    AddheaderOption("Enslavement Quest Lock-out") 
    bEnslaveLockoutCLDollOID    = AddToggleOption("Cursed loot doll collar", bEnslaveLockoutCLDoll, (!Mods.modLoadedCursedLoot) as int)
    bEnslaveLockoutTIROID       = AddToggleOption("Trapped in rubber suit", bEnslaveLockoutTIR, (!Mods.modLoadedTrappedInRubber) as int)
    bEnslaveLockoutSDDreamOID   = AddToggleOption("SD+ Dreamworld", bEnslaveLockoutSDDream, (!Mods.modLoadedSD) as int)
    bEnslaveLockoutSRROID       = AddToggleOption("Slaverun Reloaded", bEnslaveLockoutSRR, (!Mods.modLoadedSlaverunR) as int)
    bEnslaveLockoutCDOID        = AddToggleOption("CD", bEnslaveLockoutCD, 1); (!Mods.modLoadedCD) as int)
    bEnslaveLockoutMiasLairOID  = AddToggleOption("MiasLair", bEnslaveLockoutMiasLair, 1); (!Mods.modLoadedMiasLair) as int)
    bEnslaveLockoutAngrimOID    = AddToggleOption("Angrim", bEnslaveLockoutAngrim, 1); (!Mods.modLoadedAngrim) as int)
    bEnslaveLockoutFTDOID       = AddToggleOption("FTD", bEnslaveLockoutFTD, 1); (!Mods.modLoadedFromTheDeep) as int)

    ; weight side
    SetCursorPosition(1) ; switch sides    

    AddHeaderOption("Enslavement Conversation Weights(type)")
    iEnslaveWeightLocalOID    = AddSliderOption("Local", iEnslaveWeightLocal);, !Mods.canRunLocal())
    iEnslaveWeightGivenOID    = AddSliderOption("Given", iEnslaveWeightGiven)
    iEnslaveWeightSoldOID     = AddSliderOption("Sold", iEnslaveWeightSold)
    
    ; this is silly, we don't really need to drop them to zero if we check if the mod is loaded
    AddHeaderOption("Enslavement Weights (local)")
    iEnslaveWeightSDOID           = AddSliderOption("SD+ Weight", iEnslaveWeightSD, "{0}", (!Mods.modLoadedSD) as int)
    iEnslaveWeightMariaOID        = AddSliderOption("Maria's Eden Weight", iEnslaveWeightMaria, "{0}", (!Mods.modLoadedMariaEden) as int)
    iEnslaveWeightSlaverunOID     = AddSliderOption("Slaverun Weight", iEnslaveWeightSlaverun, "{0}",  (!(Mods.modLoadedSlaverun || Mods.modLoadedSlaverunR)) as int)
    
    AddHeaderOption("Enslavement Weights(distance)")
    
    iDistanceWeightCDOID            = AddSliderOption("CD Weight", iDistanceWeightCD, "{0}", (!Mods.modLoadedCD) as int)
    iDistanceWeightMariaOID         = AddSliderOption("Maria Weight", iDistanceWeightMaria, "{0}", 1) 
    iDistanceWeightMariaKOID        = AddSliderOption("Maria (Kahjit) Weight", iDistanceWeightMariaK, "{0}", (!Mods.modLoadedMariaEden) as int) 
    iDistanceWeightSSOID            = AddSliderOption("Simple Slavery Weight", iDistanceWeightSS, "{0}", (!Mods.modLoadedSimpleSlavery) as int)
    iDistanceWeightSDOID            = AddSliderOption("SD+ Weight", iDistanceWeightSD, "{0}", (!Mods.modLoadedSD) as int)
    iDistanceWeightWCOID            = AddSliderOption("Wolfclub Weight", iDistanceWeightWC, "{0}", (!Mods.modLoadedWolfclub) as int)
    iDistanceWeightDCPirateOID      = AddSliderOption("Devious Cidhna (pirate) Weight", iDistanceWeightDCPirate, "{0}", (!Mods.modLoadedDeviousCidhna) as int)
    iDistanceWeightDCLDamselOID     = AddSliderOption("Cursed Loot damsel", iDistanceWeightDCLDamsel, "{0}", (!Mods.modLoadedCursedloot) as int)
    iDistanceWeightDCLBondageAdvOID = AddSliderOption("Cursed loot Bondage Adv", iDistanceWeightDCLBondageAdv, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iDistanceWeightSlaverunRSoldOID = AddSliderOption("Slaverun reloaded (Sold)", iDistanceWeightSlaverunRSold, "{0}", (!Mods.modLoadedSlaverunR) as int)
    iDistanceWeightSLUTSEnslaveOID  = AddSliderOption("SLUTS enslavement", iDistanceWeightSLUTSEnslave, "{0}", (!Mods.modLoadedSLUTS) as int)
    iDistanceWeightIOMEnslaveOID    = AddSliderOption("Isle of mara enslavement", iDistanceWeightIOMEnslave, "{0}", (!Mods.modLoadedIsleofMara) as int)
    iDistanceWeightDCLLeonOID       = AddSliderOption("Cursed loot Leon", iDistanceWeightDCLLeon, "{0}", (!Mods.modLoadedCursedLoot) as int)
    iDistanceWeightDCVampireOID     = AddSliderOption("Devious Cidhna (Vampires) Weight", iDistanceWeightDCVampire, "{0}", (!Mods.modLoadedDeviousCidhna) as int)
    iDistanceWeightDCBanditsOID     = AddSliderOption("Devious Cidhna (Bandits) Weight", iDistanceWeightDCBandits, "{0}", (!Mods.modLoadedDeviousCidhna) as int)

    
  elseif a_page == Pages[5] ; follower 
    ;UpdateFollowerPage()
    SetCursorFillMode(TOP_TO_BOTTOM) ; probably not needed, since I never change it, assumption: mod scope
    ;SetCursorPosition(0) ; left side first
    ;  AddHeaderOption("loading follower list ... " )

    ; get array of nearby followers

    SetCursorPosition(0) ; left side first
    AddHeaderOption("General")
    bFollowerDialogueToggleOID            = AddToggleOption("Follower dialogue", bFollowerDialogueToggle.GetValueInt(), 0)
    bSecondBusyCheckWorkaroundOID         = AddToggleOption("Remembers if you shot them", bSecondBusyCheckWorkaround, 1)
    AddEmptyOption() ; spacer

    gForceGreetItemFindOID                = AddToggleOption("Follower Approaches Directly (Item found)", gForceGreetItemFind.GetValueInt())
    bFollowerDungeonEnterRequiredOID      = AddToggleOption("Finding Item Requires Dungeon", bFollowerDungeonEnterRequired, 1);(!Mods.bFollowerDungeonEnterRequired) as int)
    fFollowerFindMinContainersOID         = AddSliderOption("Minimum containers", fFollowerFindMinContainers, "{1}", 1);(!Mods.fFollowerFindMinContainers) as int)
    fFollowerFindChanceMaxPercentageOID   = AddSliderOption("Max chance follower found an item", fFollowerFindChanceMaxPercentage, "{1}");(!Mods.fFollowerFindChanceMaxPercentage) as int)
    iFollowerFindChanceMaxContainersOID   = AddSliderOption("Containers needed for Max", iFollowerFindChanceMaxContainers, "{0}");(!Mods.iFollowerFindChanceMaxContainers) as int)
    fFollowerItemApproachExpOID           = AddSliderOption("Finding Item Curve Exponent", fFollowerItemApproachExp, "{1}");
    AddEmptyOption() ; spacer
    
    iFollowerMinVulnerableApproachableOID   = AddSliderOption("Vulnerable required for sex approach", iFollowerMinVulnerableApproachable, "{0}", 1);(!Mods.iFollowerMinVulnerableApproachable) as int)
    iFollowerRelationshipLimitOID           = AddSliderOption("Non-Follower Relationship lower limit", iFollowerRelationshipLimit.GetValueInt(), "Level {0}")

    gFollowerArousalMinOID                  = AddSliderOption("Follower Sex Arousal Min", gFollowerArousalMin.GetValueInt(), "{0}");(!Mods.gFollowerArousalMin) as int)
    fFollowerSexApproachChanceMaxPercentageOID = AddSliderOption("Max Approach Chance", fFollowerSexApproachChanceMaxPercentage, "{0}");
    fFollowerSexApproachExpOID              = AddSliderOption("Approach Curve Exponent", fFollowerSexApproachExp, "{1}");(
    AddEmptyOption() ; spacer

    
    SetCursorPosition(1) ; now for right-hand side

    FormList followers = Mods.PreviousFollowers  ; old unreliable method
    ;actor[] followers = new followers
    
    actorNames = new string[15] ; don't remove it locks to 1 name
    if followers != None
      int size = followers.GetSize()
      if size == 0
        actorNames[0] == "<no follower>"
      else
        int i = 0
        actor test_actor
        while i < followers.GetSize()
           test_actor = followers.GetAt(i) as Actor
          if test_actor != None
            actorNames[i] = test_actor.GetDisplayName()
          ;else
          ;  i += 100
          endif
          i += 1
        endWhile
      endif
    else
      ;Debug.Trace("[crde] mcm:followers is none")
      return
    endif
    currentFollower = None 
    int f_size = followers.GetSize()
    ;if followers == None ; assume can never be none, formlist
    if f_size <=  lastChosenFollower
      lastChosenFollower = 0 ; reset if the size changed
    endif 
    if f_size >= 1
      currentFollower = followers.GetAt(lastChosenFollower) as actor
    endif
    ;Debug.trace("[crde] mcm: followers count:" + f_size)

    
    ;AddHeaderOption("Follower Select:")
    ; list of followers
    
    ;if (lastChosenFollower == 0 && actorNames.length == 0)
    if (f_size <= 0)
      aFollowerSelectOID  = AddMenuOption("Follower: <None>", 0)
    else
      aFollowerSelectOID  = AddMenuOption("Follower:", actorNames[lastChosenFollower], 0)
    endif
      
    AddEmptyOption() ; spacer

    bAddFollowerManuallyOID = AddTextOption("Add Follower Manually", "Push Here")
    ; get follower, if NONE
    if currentFollower == None
      AddEmptyOption() ; spacer
      AddHeaderOption("No follower selected") ; used to be ,1

      AddEmptyOption() ; spacer
      AddTextOption("Followers need time to be added","")
      AddTextOption("If you have a follower and they","")
      AddTextOption("haven't shown up, exit the menu","")
      AddTextOption("and wait ~30 seconds for DEC to find them","")

      
    else
      ; follower dom
      ; follower sub
      ; follower thinks player is...
      AddHeaderOption("Name: " + currentFollower.GetDisplayName(), 0)
      tFollowerteleportToPlayerOID  = AddTextOption("Teleport follower to player", "Push Here")
      AddHeaderOption("Follower details: ",0)

      fFollowerSpecEnjoysDomOID         = AddSliderOption("Follower Enjoys Being Dom", StorageUtil.GetFloatValue(currentFollower, "crdeFollEnjoysDom"), "{1}")
      fFollowerSpecEnjoysSubOID         = AddSliderOption("Follower Enjoys Being Sub", StorageUtil.GetFloatValue(currentFollower, "crdeFollEnjoysSub") , "{1}")
      fFollowerSpecThinksPlayerDomOID   = AddSliderOption("Follower Thinks Player Dom", StorageUtil.GetFloatValue(currentFollower, "crdeThinksPCEnjoysDom"), "{1}")
      fFollowerSpecThinksPlayerSubOID   = AddSliderOption("Follower Thinks Player Sub", StorageUtil.GetFloatValue(currentFollower, "crdeThinksPCEnjoysSub"), "{1}")
      fFollowerSpecContainersCountOID   = AddSliderOption("Followers containers discovered", StorageUtil.GetIntValue(currentFollower, "crdeFollContainersSearched"), "{1}")
      fFollowerSpecFrustrationOID       = AddSliderOption("Followers level of Frustration", StorageUtil.GetFloatValue(currentFollower, "crdeFollowerFrustration"), "{1}")
      
    endif
    debug.trace("[crde] mcm: last follower:" + lastChosenFollower)
  
  elseif a_page == Pages[6]  ; dialogue guard/intimidation, and now confidence
    AddHeaderOption("Confidence options")
    bConfidenceToggleOID                  = AddToggleOption("Confidence Check", bConfidenceToggle)
    iWeightConfidenceArousalOverrideOID   = AddSliderOption("Confidence Override Arousal", iWeightConfidenceArousalOverride, "{0}")
  
    AddHeaderOption("Intimidate options")
    bIntimidateToggleOID              = AddToggleOption("Intimidate", gIntimidateToggle.GetValueInt()) ; intimidation main toggle
    bIntimidateWeaponFullToggleOID    = AddToggleOption("Intimidate Gag Block", bIntimidateGagFullToggle, 1) 
    bIntimidateWeaponFullToggleOID    = AddToggleOption("Intimidate Weapon Block", bIntimidateWeaponFullToggle, 1);
    ; gag prevention
    ; weapon protects 100% toggle
    
    AddHeaderOption("Modifiers ")
    ; more to come here later
    
  elseif a_page == Pages[7] ; debug
  
    AddHeaderOption("Workarounds")
    bArousalFunctionWorkaroundOID         = AddToggleOption("Aroused function alternative", bArousalFunctionWorkaround)
    bSecondBusyCheckWorkaroundOID         = AddToggleOption("Second busy check", bSecondBusyCheckWorkaround)
    bIgnoreZazOnNPCOID                    = AddToggleOption("Ignore Zaz on NPC Slaves", bIgnoreZazOnNPC)
    AddEmptyOption() ; spacer
  
    AddHeaderOption("Debug Toggle")
    bDebugModeOID                         = AddToggleOption("Debug Info Enable", bDebugMode)
    bDebugConsoleModeOID                  = AddToggleOption("Debug In Console", bDebugConsoleMode )
    gUnfinishedDialogueToggleOID          = AddToggleOption("Unfinished Dialogue", gUnfinishedDialogueToggle.GetValueInt() as bool )
    bDebugLoudApproachFailOID             = AddToggleOption("Louder Approach Fail", bDebugLoudApproachFail )
    
    AddHeaderOption("Debug visibility control")
    bDebugRollVisOID                      = AddToggleOption("Rolling information/results", bDebugRollVis )
    bDebugStateVisOID                     = AddToggleOption("State information", bDebugStateVis )
    bDebugStatusVisOID                    = AddToggleOption("Status information", bDebugStatusVis )
 
    SetCursorPosition(1) ; switch sides  
  
    AddHeaderOption("Useful Fixes/Debug Commands")
    bResetDHLPOID                 = AddToggleOption("Reset/resume DHLP suspend and approach", bResetDHLP)
    bRefreshSDMasterOID           = AddToggleOption("Refresh SD Masters", bRefreshSDMaster) 
    bRefreshModDetectOID          = AddToggleOption("Refresh detected mods", Mods.bRefreshModDetect) 
    bSetValidRaceOID              = AddToggleOption("Set Valid Race", bSetValidRace) 
    bPrintSexlabStatusOID         = AddToggleOption("Print Block/permit sexlab status", bPrintSexlabStatus)
    bPrintVulnerabilityStatusOID  = AddToggleOption("Print vulnerability status", bPrintVulnerabilityStatus)
    bTestTattoosOID               = AddToggleOption("Tattoo test", bTestTattoos)
    bTestTimeTestOID              = AddToggleOption("Component time test", bTestTimeTest)
    
    ;AddEmptyOption()
    AddHeaderOption("building/testing, not meant for regular use")
    bAbductionTestOID         = AddToggleOption("Pony Button", bAbductionTest);, (!Mods.modLoadedMariaEden) as int)
    bInitTestOID              = AddToggleOption("SD Dream test", bInitTest, (!Mods.modLoadedSD) as int)
    bTestButton1OID           = AddToggleOption("Remove Broken Item Test", bTestButton1)
    bTestButton2OID           = AddToggleOption("Broken DDi NPC reset test", bTestButton2)
    bTestButton3OID           = AddToggleOption("DD Key check", bTestButton3);, (!Mods.modLoadedSlaveTats) as int)
    bTestButton4OID           = AddToggleOption("Bed teleport test", bTestButton4, (!Mods.modLoadedCursedLoot) as int)
    bTestButton5OID           = AddToggleOption("Add Item test", bTestButton5);, (!Mods.modLoadedIsleofMara) as int)
    bCDTestOID                = AddToggleOption("CD item test", bCDTest, (!Mods.modLoadedSlaverunR) as int)
    bTestButton6OID           = AddToggleOption("SD distant start", bTestButton6, (!Mods.modLoadedSD) as int)
    bTestButton7OID           = AddToggleOption("Temporary test", bTestButton7);, (!Mods.modLoadedPrisonOverhaulPatch) as int)
  endIf
  
endEvent

Function UpdateFollowerPage()
  
  ;moved to above, since errors
  
  ; testing
  ;int i = 0
  ;while i < followers.GetSize()
  ;  AddHeaderOption("follower " + (followers.GetAt(i) as actor).GetDisplayName(), 1)
  ;  i += 1
  ;endWhile
  
  ; show stats and options for that follower, including assignments
  ; values for stress and opinion
  ; fields to change preferences
  
endFunction

function reevaluateItemParabolicModifier()

  ; y = ax^2 + bx + c
  ;  except b doesn't matter here, c is starting value,
  ;  a is what we want right now, then we can re-evaluate y from x any time using above
  ; a = (y - c)/ x^2

  itemParabolicModifier = ( fFollowerFindChanceMaxPercentage ) / (Math.Pow(iFollowerFindChanceMaxContainers, fFollowerItemApproachExp))
  ;itemParabolicModifier = ( fFollowerFindChanceMaxPercentage - fFollowerFindMinContainers ) / (Math.Pow(iFollowerFindChanceMaxContainers, fFollowerItemApproachExp))

endFunction

function reevaluateSexApproachParabolicModifier()

  ; y = ax^2 + bx + c
  ;  except b doesn't matter here, c is starting value,
  ;  a is what we want right now, then we can re-evaluate y from x any time using above
  ; a = (y - c)/ x^2  ->  a = y / (x ^ p) ; since c doesn't translate anymore, and we can use any power n > 1
  
  sexApproachParabolicModifier = ( fFollowerSexApproachChanceMaxPercentage ) / (Math.Pow(100, fFollowerSexApproachExp))

endFunction


; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)
  {Called when the user selects a non-dialog option}
  
  if (a_option == gCRDEEnableOID)
    bool new_value = gCRDEEnable.GetValueInt() == 0
    gCRDEEnable.SetValueInt( new_value as int)
    ;if new_value == 1
    ;  testTattoos()
    ;endif
    SetToggleOptionValue(a_option, new_value)
  elseIf (a_option == bIsVulNakedOID)
    bIsVulNaked = !bIsVulNaked
    SetToggleOptionValue(a_option, bIsVulNaked)
  elseIf (a_option == bIsNonChestArmorIgnoredNakedOID) ;bIsNonChestArmorIgnoredNaked
    bIsNonChestArmorIgnoredNaked = !bIsNonChestArmorIgnoredNaked
    SetToggleOptionValue(a_option, bIsNonChestArmorIgnoredNaked)
  elseif a_option == bHookAnySexlabEventOID 
    bHookAnySexlabEvent = !bHookAnySexlabEvent
    SetToggleOptionValue(a_option, bHookAnySexlabEvent)
  elseif a_option == bHookReqVictimStatusOID ;bFxFAlwaysAggressive
    bHookReqVictimStatus = !bHookReqVictimStatus
    SetToggleOptionValue(a_option, bHookReqVictimStatus)
  elseif a_option == bFxFAlwaysAggressiveOID ;bFxFAlwaysAggressive
    bFxFAlwaysAggressive = !bFxFAlwaysAggressive
    SetToggleOptionValue(a_option, bFxFAlwaysAggressive)
   
  elseIf (a_option == bDebugModeOID)
    bDebugMode = !bDebugMode
    SetToggleOptionValue(a_option, bDebugMode)
  elseIf (a_option == bDebugConsoleModeOID)
    bDebugConsoleMode = !bDebugConsoleMode
    SetToggleOptionValue(a_option, bDebugConsoleMode)
  elseif (a_option == bChastityToggleOID)
    bChastityToggle = !bChastityToggle
    SetToggleOptionValue(a_option, bChastityToggle)
  
  elseif (a_option == bChastityGagOID)
    bChastityGag = ! bChastityGag
    SetToggleOptionValue(a_option, bChastityGag)
  elseif (a_option == bChastityBraOID)
    bChastityBra = ! bChastityBra
    SetToggleOptionValue(a_option, bChastityBra)
  elseif (a_option == bChastityZazBeltOID)
    bChastityZazBelt = ! bChastityZazBelt
    SetToggleOptionValue(a_option, bChastityZazBelt)
  elseif (a_option == bChastityZazGagOID)
    bChastityZazGag = ! bChastityZazGag
    SetToggleOptionValue(a_option, bChastityZazGag)
    
  elseif (a_option == bVulnerableGagOID)
    bVulnerableGag = ! bVulnerableGag
    SetToggleOptionValue(a_option, bVulnerableGag)
  elseif (a_option == bVulnerableCollarOID)
    bVulnerableCollar = ! bVulnerableCollar
    SetToggleOptionValue(a_option, bVulnerableCollar)
  elseif (a_option == bVulnerableArmbinderOID)
    bVulnerableArmbinder = ! bVulnerableArmbinder
    SetToggleOptionValue(a_option, bVulnerableArmbinder)
  elseif (a_option == bVulnerableBlindfoldOID)
    bVulnerableBlindfold  = ! bVulnerableBlindfold
    SetToggleOptionValue(a_option, bVulnerableBlindfold)
  elseif (a_option == bVulnerableLOSOID)
    bVulnerableLOS = ! bVulnerableLOS
    SetToggleOptionValue(a_option, bConfidenceToggleOID) 
  elseif (a_option == bConfidenceToggleOID)
    bConfidenceToggle = ! bConfidenceToggle
    SetToggleOptionValue(a_option, bConfidenceToggle) 
  elseif (a_option == bFollowerDialogueToggleOID)
    ;bFollowerDialogueToggle = ! bFollowerDialogueToggle
    bFollowerDialogueToggle.SetValueInt( ( bFollowerDialogueToggle.GetValueInt() == 0) as int )
    SetToggleOptionValue(a_option, bFollowerDialogueToggle.GetValueInt())
  elseif (a_option == bVulnerableFurnitureOID)
    bVulnerableFurniture = ! bVulnerableFurniture
    SetToggleOptionValue(a_option, bVulnerableFurniture) ; 
  elseif (a_option == bVulnerableBukkakeOID)
    bVulnerableBukkake = ! bVulnerableBukkake
    SetToggleOptionValue(a_option, bVulnerableBukkake)
  elseif (a_option == bVulnerableSlaveBootsOID); long distance stuff too
    bVulnerableSlaveBoots = ! bVulnerableSlaveBoots
    SetToggleOptionValue(a_option, bVulnerableSlaveBoots)
  elseif (a_option == bVulnerableHarnessOID); long distance stuff too
    bVulnerableHarness = ! bVulnerableHarness
    SetToggleOptionValue(a_option, bVulnerableHarness)
  elseif (a_option == bVulnerablePiercedOID); long distance stuff too
    bVulnerablePierced = ! bVulnerablePierced
    SetToggleOptionValue(a_option, bVulnerablePierced)
  elseif (a_option == bVulnerableSlaveTattooOID)
    bVulnerableSlaveTattoo = ! bVulnerableSlaveTattoo
    SetToggleOptionValue(a_option, bVulnerableSlaveTattoo)  
  elseif (a_option == bVulnerableSlutTattooOID)
    bVulnerableSlutTattoo = ! bVulnerableSlutTattoo
    SetToggleOptionValue(a_option, bVulnerableSlutTattoo)

  elseif (a_option == bNakedReqGagOID)
    bNakedReqGag = ! bNakedReqGag
    SetToggleOptionValue(a_option, bNakedReqGag)
  elseif (a_option == bNakedReqCollarOID)
    bNakedReqCollar = ! bNakedReqCollar
    SetToggleOptionValue(a_option, bNakedReqCollar)
  elseif (a_option == bNakedReqArmbinderOID)
    bNakedReqArmbinder = ! bNakedReqArmbinder
    SetToggleOptionValue(a_option, bNakedReqArmbinder)
  elseif (a_option == bNakedReqBlindfoldOID)
    bNakedReqBlindfold  = ! bNakedReqBlindfold
    SetToggleOptionValue(a_option, bNakedReqBlindfold)

  elseif (a_option == bNakedReqBukkakeOID); long distance stuff too
    bNakedReqBukkake = ! bNakedReqBukkake
    SetToggleOptionValue(a_option, bNakedReqBukkake)
  elseif (a_option == bNakedReqSlaveBootsOID); long distance stuff too
    bNakedReqSlaveBoots = ! bNakedReqSlaveBoots
    SetToggleOptionValue(a_option, bNakedReqSlaveBoots)
  elseif (a_option == bNakedReqHarnessOID); long distance stuff too
    bNakedReqHarness = ! bNakedReqHarness
    SetToggleOptionValue(a_option, bNakedReqHarness)
  elseif (a_option == bNakedReqPiercedOID); long distance stuff too
    bNakedReqPierced = ! bNakedReqPierced
    SetToggleOptionValue(a_option, bNakedReqPierced)
  elseif (a_option == bNakedReqSlaveTattooOID)
    bNakedReqSlaveTattoo = ! bNakedReqSlaveTattoo
    SetToggleOptionValue(a_option, bNakedReqSlaveTattoo)  
  elseif (a_option == bNakedReqSlutTattooOID)
    bNakedReqSlutTattoo = ! bNakedReqSlutTattoo
    SetToggleOptionValue(a_option, bNakedReqSlutTattoo)
  elseif (a_option == bAttackersGuardsOID)
    bAttackersGuards = ! bAttackersGuards
    SetToggleOptionValue(a_option, bAttackersGuards) ; 
  elseif (a_option == bEnslaveFollowerLockToggleOID)
    bEnslaveFollowerLockToggle = ! bEnslaveFollowerLockToggle
    SetToggleOptionValue(a_option, bEnslaveFollowerLockToggle)

    
  elseif (a_option == bSDEnslaveToggleOID)
    bSDEnslaveToggle = ! bSDEnslaveToggle
    SetToggleOptionValue(a_option, bSDEnslaveToggle)
  elseif (a_option == bMariaEnslaveToggleOID)
    bMariaEnslaveToggle = ! bMariaEnslaveToggle
    SetToggleOptionValue(a_option, bMariaEnslaveToggle)
  elseif (a_option == bSlaverunEnslaveToggleOID)
    bSlaverunEnslaveToggle = ! bSlaverunEnslaveToggle
    SetToggleOptionValue(a_option, bSlaverunEnslaveToggle)
  elseif (a_option == bCDEnslaveToggleOID)
    bCDEnslaveToggle = ! bCDEnslaveToggle
    SetToggleOptionValue(a_option, bCDEnslaveToggle)
  elseif (a_option == bSSAuctionEnslaveToggleOID); long distance stuff too
    bSSAuctionEnslaveToggle = ! bSSAuctionEnslaveToggle
    SetToggleOptionValue(a_option, bSSAuctionEnslaveToggle)
  ;elseif (a_option == bCDEnslaveToggleOID) 
  ;  bCDEnslaveToggle = ! bCDEnslaveToggle
  ;  SetToggleOptionValue(a_option, bCDEnslaveToggle)
  elseif (a_option == bMariaKhajitEnslaveToggleOID )
    bMariaKhajitEnslaveToggle = ! bMariaKhajitEnslaveToggle 
    SetToggleOptionValue(a_option, bMariaKhajitEnslaveToggle )

; distance enslave toggle
  elseif (a_option == bWCDistanceToggleOID)
    bWCDistanceToggle = ! bWCDistanceToggle
    SetToggleOptionValue(a_option, bWCDistanceToggle)
  elseif (a_option == bMariaDistanceToggleOID)
    bMariaDistanceToggle = ! bMariaDistanceToggle
    SetToggleOptionValue(a_option, bMariaDistanceToggle)
  elseif (a_option == bSDDistanceToggleOID)
    bSDDistanceToggle = ! bSDDistanceToggle
    SetToggleOptionValue(a_option, bSDDistanceToggle)
  elseif (a_option == bDCPirateEnslaveToggleOID)
    bDCPirateEnslaveToggle = ! bDCPirateEnslaveToggle
    SetToggleOptionValue(a_option, bDCPirateEnslaveToggle)

  ; lock-out bEnslaveLockoutCLDollOID bEnslaveLockoutTIROID bEnslaveLockoutTIROID
  elseif (a_option == bEnslaveLockoutCLDollOID)
    bEnslaveLockoutCLDoll = ! bEnslaveLockoutCLDoll
    SetToggleOptionValue(a_option, bEnslaveLockoutCLDoll)
  elseif (a_option == bEnslaveLockoutSRROID)
    bEnslaveLockoutSRR = ! bEnslaveLockoutSRR
    SetToggleOptionValue(a_option, bEnslaveLockoutSRR)
    
  elseif (a_option == bEnslaveLockoutTIROID)
    bEnslaveLockoutTIR = ! bEnslaveLockoutTIR
    SetToggleOptionValue(a_option, bEnslaveLockoutTIR)
  elseif (a_option == bEnslaveLockoutCDOID) 
    bEnslaveLockoutCD = ! bEnslaveLockoutCD
    SetToggleOptionValue(a_option, bEnslaveLockoutCD)
  elseif (a_option == bEnslaveLockoutSDDreamOID) ;bEnslaveLockoutSDDream
    bEnslaveLockoutSDDream = ! bEnslaveLockoutSDDream
    SetToggleOptionValue(a_option, bEnslaveLockoutSDDream)
  elseif (a_option == bEnslaveLockoutMiasLairOID)
    bEnslaveLockoutMiasLair = ! bEnslaveLockoutMiasLair
    SetToggleOptionValue(a_option, bEnslaveLockoutMiasLair)
  elseif (a_option == bEnslaveLockoutAngrimOID)
    bEnslaveLockoutAngrim = ! bEnslaveLockoutAngrim
    SetToggleOptionValue(a_option, bEnslaveLockoutAngrim)
  elseif (a_option == bEnslaveLockoutFTDOID)
    bEnslaveLockoutFTD = ! bEnslaveLockoutFTD
    SetToggleOptionValue(a_option, bEnslaveLockoutFTD)

  elseif (a_option == bGuardDialogueToggleOID)
    bGuardDialogueToggle = (gGuardDialogueToggle.GetValueInt() == 0) 
    gGuardDialogueToggle.SetValueInt( bGuardDialogueToggle as int ) ; expr: 0->1(true) 1->0(false)
    SetToggleOptionValue(a_option, bGuardDialogueToggle)
  ;bEnslaveLockoutDCUROID  
  elseif (a_option == bEnslaveLockoutDCUROID)
    bEnslaveLockoutDCUR = ! bEnslaveLockoutDCUR
    SetToggleOptionValue(a_option, bEnslaveLockoutDCUR)
  
  elseif (a_option == bIntimidateToggleOID); long distance stuff too
    bIntimidateToggle = (gIntimidateToggle.GetValueInt() == 0)
    gIntimidateToggle.SetValueInt( bIntimidateToggle as int) ; expr: 0->1(true) 1->0(false)
    SetToggleOptionValue(a_option, bIntimidateToggle)
  elseif (a_option == bIntimidateGagFullToggleOID); long distance stuff too
    bIntimidateGagFullToggle = ! bIntimidateGagFullToggle
    SetToggleOptionValue(a_option, bIntimidateGagFullToggle)
  elseif (a_option == bIntimidateWeaponFullToggleOID); long distance stuff too
    bIntimidateWeaponFullToggle = ! bIntimidateWeaponFullToggle
    SetToggleOptionValue(a_option, bIntimidateWeaponFullToggle)
  
  ; tests
  elseif (a_option == bPrintSexlabStatusOID)
    bPrintSexlabStatus = ! bPrintSexlabStatus
    SetToggleOptionValue(a_option, bPrintSexlabStatus)
  elseif (a_option == bPrintVulnerabilityStatusOID)
    bPrintVulnerabilityStatus = ! bPrintVulnerabilityStatus
    if bPrintVulnerabilityStatus 
      Debug.MessageBox("This feature is unmaintained, but still may be useful. You have to leave the menu and sit still for it to work.")
    endif
    SetToggleOptionValue(a_option, bPrintVulnerabilityStatus)
  elseif (a_option == bResetDHLPOID)
    bResetDHLP = ! bResetDHLP
    if bResetDHLP 
      ;Debug.MessageBox("DEC Approach is reset, leave this button on for it to reset one cycle after being approached (use: testing)")
      Mods.PlayMonScript.resetDHLPSuspend()
    endif
    SetToggleOptionValue(a_option, bResetDHLP)
  elseif a_option == bRefreshSDMasterOID
    bRefreshSDMaster = ! bRefreshSDMaster
    ;SetToggleOptionValue(a_option, bRefreshSDMaster)
    Mods.PlayMonScript.refreshSDMaster()
    
  elseif a_option == bRefreshModDetectOID
    Mods.bRefreshModDetect = ! Mods.bRefreshModDetect
    SetToggleOptionValue(a_option, Mods.bRefreshModDetect)
    ; reset options were moved to the playermonitor test, off thread

  elseif a_option == bSetValidRaceOID
    ;bSetValidRace = ! bSetValidRace
    ;if Mods.bRefreshModDetect 
    ;  Debug.MessageBox("Exit the menu and wait next to the NPC you want to set valid race for.")
    ;endif
    Mods.PlayMonScript.appointValidRace()
    SetToggleOptionValue(a_option, bSetValidRace)
  elseif a_option == bTestTattoosOID 
    bTestTattoos = ! bTestTattoos
    SetToggleOptionValue(a_option, bTestTattoos)  
  elseif a_option == bTestTimeTestOID
    bTestTimeTest = ! bTestTimeTest
    SetToggleOptionValue(a_option, bTestTimeTest)
  elseif (a_option == bAbductionTestOID)
    bAbductionTest = ! bAbductionTest
    SetToggleOptionValue(a_option, bAbductionTest)  
  
  ;debug
  elseif a_option == bArousalFunctionWorkaroundOID
    bArousalFunctionWorkaround = ! bArousalFunctionWorkaround
    SetToggleOptionValue(a_option, bArousalFunctionWorkaround)
  elseif a_option == bSecondBusyCheckWorkaroundOID ;bAltBodySlotSearchWorkaroundOID
    bSecondBusyCheckWorkaround = ! bSecondBusyCheckWorkaround
    SetToggleOptionValue(a_option, bSecondBusyCheckWorkaround)
  elseif a_option == bAltBodySlotSearchWorkaroundOID ;bIgnoreZazOnNPC
    bAltBodySlotSearchWorkaround = ! bAltBodySlotSearchWorkaround
    SetToggleOptionValue(a_option, bAltBodySlotSearchWorkaround)
  elseif a_option == bIgnoreZazOnNPCOID ;bIgnoreZazOnNPCOID
    bIgnoreZazOnNPC = ! bIgnoreZazOnNPC
    SetToggleOptionValue(a_option, bIgnoreZazOnNPC)
  
  elseif a_option == gUnfinishedDialogueToggleOID
    ;gUnfinishedDialogueToggle = ! gUnfinishedDialogueToggle
    gUnfinishedDialogueToggle.SetValueInt((gUnfinishedDialogueToggle.GetValueInt() == 0) as int) ; toggle based on == equivilence
    SetToggleOptionValue(a_option, gUnfinishedDialogueToggle.GetValueInt() as bool)
    
  elseif (a_option == bDebugLoudApproachFailOID); long distance stuff too
    bDebugLoudApproachFail = ! bDebugLoudApproachFail
    SetToggleOptionValue(a_option, bDebugLoudApproachFail)
  elseif (a_option == bDebugRollVisOID); long distance stuff too
    bDebugRollVis = ! bDebugRollVis
    SetToggleOptionValue(a_option, bDebugRollVis)
  elseif (a_option == bDebugStateVisOID); long distance stuff too
    bDebugStateVis = ! bDebugStateVis
    SetToggleOptionValue(a_option, bDebugStateVis)
  elseif (a_option == bDebugStatusVisOID); long distance stuff too
    bDebugStatusVis = ! bDebugStatusVis
    SetToggleOptionValue(a_option, bDebugStatusVis)
  elseif (a_option == bInitTestOID)
    bInitTest = ! bInitTest
    SetToggleOptionValue(a_option, bInitTest)
  elseif (a_option == bTestButton1OID)
    bTestButton1 = ! bTestButton1
    SetToggleOptionValue(a_option, bTestButton1)
  elseif (a_option == bTestButton2OID)
    bTestButton2 = ! bTestButton2
    SetToggleOptionValue(a_option, bTestButton2)
  elseif (a_option == bTestButton3OID)
    bTestButton3 = ! bTestButton3
    SetToggleOptionValue(a_option, bTestButton3)
  elseif (a_option == bTestButton4OID)
    bTestButton4 = ! bTestButton4
    SetToggleOptionValue(a_option, bTestButton4)
  elseif (a_option == bTestButton5OID)
    bTestButton5 = ! bTestButton5
    SetToggleOptionValue(a_option, bTestButton5)
  elseif (a_option == bCDTestOID)
    bCDTest = ! bCDTest
    SetToggleOptionValue(a_option, bCDTest)
  elseif (a_option == bTestButton6OID); long distance stuff too
    bTestButton6 = ! bTestButton6
    SetToggleOptionValue(a_option, bTestButton6)
  elseif (a_option == bTestButton7OID); long distance stuff too
    bTestButton7 = ! bTestButton7
    
    SetToggleOptionValue(a_option, bTestButton7)

  elseif (a_option == bNightAddsToVulnerableOID)
    bNightAddsToVulnerable = ! bNightAddsToVulnerable
    SetToggleOptionValue(a_option, bNightAddsToVulnerable)


  elseif a_option == gForceGreetItemFindOID 
    gForceGreetItemFind.SetValueInt( (gForceGreetItemFind.GetValueInt() == 0) as int )
    SetToggleOptionValue(a_option, gForceGreetItemFind.GetValueInt() as bool)
  elseif a_option == bFollowerDungeonEnterRequiredOID
    bFollowerDungeonEnterRequired = ! bFollowerDungeonEnterRequired
    SetToggleOptionValue(a_option, bFollowerDungeonEnterRequired)
  elseif a_option == bUseSexlabGenderOID
    bUseSexlabGender = ! bUseSexlabGender
    SetToggleOptionValue(a_option, bUseSexlabGender)

  elseif a_option == bSDGeneralLockoutOID
    bSDGeneralLockout = ! bSDGeneralLockout
    SetToggleOptionValue(a_option, bSDGeneralLockout)
    
  elseif a_option == tFollowerteleportToPlayerOID
    currentFollower.MoveTo(Mods.player)
  elseif a_option == bAddFollowerManuallyOID  
    ;bAddFollowerManually = ! bAddFollowerManually
    ;if bAddFollowerManually 
    ;  Debug.MessageBox("Exit the menu and wait next to the NPC you swant to add to your followers list.")
    ;endif
    Mods.PlayMonScript.addPermanentFollower()
    ;SetToggleOptionValue(a_option, bAddFollowerManually)
  endIf

  ; template
  ;elseif (a_option == dddOID); long distance stuff too
    ;ddd = ! ddd
    ;SetToggleOptionValue(a_option, ddd)
  
endEvent


; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
  {Called when the user selects a slider option}

  if (a_option == fEventIntervalOID)
    SetSliderDialogStartValue(fEventInterval)
    ;SetSliderDialogDefaultValue(15)
    SetSliderDialogRange(1, 60)
    SetSliderDialogInterval(1)
  elseif (a_option == fEventTimeoutOID)
    SetSliderDialogStartValue(fEventTimeoutHours);fEventTimeout * 24)
    ;SetSliderDialogDefaultValue(10)
    SetSliderDialogRange(0, 96)
    SetSliderDialogInterval(0.5)
  elseif (a_option == iChanceEnslavementConvoOID)
    SetSliderDialogStartValue(iChanceEnslavementConvo)
    ;SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iChanceVulEnslavementConvoOID)
    SetSliderDialogStartValue(iChanceVulEnslavementConvo)
    ;SetSliderDialogDefaultValue(45)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iChanceSexConvoOID)
    SetSliderDialogStartValue(iChanceSexConvo)
    ;SetSliderDialogDefaultValue(65)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iSexEventKeyOID)
    SetSliderDialogStartValue(iSexEventKey)
    ;SetSliderDialogDefaultValue(20)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iSexEventDeviceOID)
    SetSliderDialogStartValue(iSexEventDevice)
    ;SetSliderDialogDefaultValue(10)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iRapeEventDeviceOID)
    SetSliderDialogStartValue(iRapeEventDevice)
    ;SetSliderDialogDefaultValue(15)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iRapeEventEnslaveOID)
    SetSliderDialogStartValue(iRapeEventEnslave)
    ;SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeightSingleDDOID)
    SetSliderDialogStartValue(iWeightSingleDD)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeightMultiDDOID)
    SetSliderDialogStartValue(iWeightMultiDD)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeightPetcollarOID)
    SetSliderDialogStartValue(iWeightPetcollar)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeightCursedCollarOID)
    SetSliderDialogStartValue(iWeightCursedCollar)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeightSlaveCollarOID)
    SetSliderDialogStartValue(iWeightSlaveCollar)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeightSlutCollarOID)
    SetSliderDialogStartValue(iWeightSlutCollar)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1) ;iWeightRubberDollCollar
  elseif (a_option == iWeightRubberDollCollarOID)
    SetSliderDialogStartValue(iWeightRubberDollCollar)
    SetSliderDialogDefaultValue(8)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
    
  elseif (a_option == iSearchRangeOID)
    SetSliderDialogStartValue(gSearchRange.GetValueInt())
    SetSliderDialogDefaultValue(4096)
    SetSliderDialogRange(64, 32768)
    SetSliderDialogInterval(64)
    
  elseif (a_option == iApproachDurationOID)
    SetSliderDialogStartValue(iApproachDuration)
    SetSliderDialogDefaultValue(30)
    SetSliderDialogRange(5, 600)
    SetSliderDialogInterval(5)  
  elseif (a_option == iNPCSearchCountOID)
    SetSliderDialogStartValue(iNPCSearchCount)
    SetSliderDialogDefaultValue(6)
    SetSliderDialogRange(1, 15)
    SetSliderDialogInterval(1)
  elseif (a_option == iMinEnslaveVulnerableOID)
    SetSliderDialogStartValue(iMinEnslaveVulnerable)
    SetSliderDialogDefaultValue(2)
    SetSliderDialogRange(0, 3)
    SetSliderDialogInterval(1)
  elseif (a_option == iMinApproachArousalOID)
    SetSliderDialogStartValue( iMinApproachArousal)
    SetSliderDialogRange(-2, 100)
    SetSliderDialogInterval(1)
  elseif (a_option == iMaxEnslaveMoralityOID)
    SetSliderDialogStartValue(iMaxEnslaveMorality)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0, 4)
    SetSliderDialogInterval(1)
  elseif (a_option == iMaxSolicitMoralityOID)
    SetSliderDialogStartValue(iMaxSolicitMorality)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0, 4)
    SetSliderDialogInterval(1)
  elseif (a_option == iWeaponProtectionLevelOID )
    SetSliderDialogStartValue(iWeaponProtectionLevel)
    SetSliderDialogDefaultValue(2)
    SetSliderDialogRange(0, 4)
    SetSliderDialogInterval(1)
  elseif (a_option == iRelationshipProtectionLevelOID )
    SetSliderDialogStartValue(iRelationshipProtectionLevel)
    SetSliderDialogDefaultValue(2)
    SetSliderDialogRange(-3, 4)
    SetSliderDialogInterval(1)
  
  elseif a_option == iWeightConfidenceArousalOverrideOID
		SetSliderDialogStartValue(iWeightConfidenceArousalOverride)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iReqLevelSLSFExhibIncreaseVulnerableOID
		SetSliderDialogStartValue(iReqLevelSLSFExhibIncreaseVulnerable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iReqLevelSLSFExhibMakeVulnerableOID
		SetSliderDialogStartValue(iReqLevelSLSFExhibMakeVulnerable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iReqLevelSLSFSlutIncreaseVulnerableOID
		SetSliderDialogStartValue(iReqLevelSLSFSlutIncreaseVulnerable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iReqLevelSLSFSlutMakeVulnerableOID
		SetSliderDialogStartValue(iReqLevelSLSFSlutMakeVulnerable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iReqLevelSLSFSlaveIncreaseVulnerableOID
		SetSliderDialogStartValue(iReqLevelSLSFSlaveIncreaseVulnerable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iReqLevelSLSFSlaveMakeVulnerableOID
		SetSliderDialogStartValue(iReqLevelSLSFSlaveMakeVulnerable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  
  elseif (a_option == fModifierSlaverChancesOID)
    SetSliderDialogStartValue(fModifierSlaverChances)
    SetSliderDialogDefaultValue(3.0)
    SetSliderDialogRange(0.1, 15.0)
    SetSliderDialogInterval( 0.1 )
  elseif (a_option == fChastityPartialModifierOID)
    SetSliderDialogStartValue(fChastityPartialModifier)
    SetSliderDialogDefaultValue(1.3)
    SetSliderDialogRange(0.1, 15.0)
    SetSliderDialogInterval( 0.1 )
  elseif (a_option == fChastityCompleteModifierOID)
    SetSliderDialogStartValue(fChastityCompleteModifier)
    SetSliderDialogDefaultValue(2.0)
    SetSliderDialogRange(0.1, 15.0)
    SetSliderDialogInterval( 0.1 )
    
  elseif (a_option == iEnslaveWeightSDOID)
    SetSliderDialogStartValue(iEnslaveWeightSD)
    SetSliderDialogDefaultValue(55)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iEnslaveWeightMariaOID)
    SetSliderDialogStartValue(iEnslaveWeightMaria)
    SetSliderDialogDefaultValue(45)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iEnslaveWeightSlaverunOID)
    SetSliderDialogStartValue(iEnslaveWeightSlaverun)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iEnslaveWeightCDOID)
    SetSliderDialogStartValue(iEnslaveWeightCD)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightSDOID)
    SetSliderDialogStartValue(iDistanceWeightSD)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightMariaOID)
    SetSliderDialogStartValue(iDistanceWeightMaria)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iDistanceWeightMariaKOID
    float vers = (Quest.getQuest("crdeMariaEden") as crdeMariaEdenScript).getVersion()
    if vers > 1.22
      Debug.Messagebox("WARNING: Your version of maria is detected as:" + vers  \
      + " which this slavery entrance (Defeat Khajit) should not work for! " \
      + "It should stop working as soon as the player reaches whiterun, and I do not know of a way to fix it. " \
      + "You are advised to leave it off or downgrade to version 1.19 if you wish to play with this enslavement")
    endif
    SetSliderDialogStartValue(iDistanceWeightMariaK)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightCDOID)
    SetSliderDialogStartValue(iDistanceWeightCD)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 ) 
  elseif (a_option == iDistanceWeightSSOID)
    SetSliderDialogStartValue(iDistanceWeightSS)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightWCOID)
    SetSliderDialogStartValue(iDistanceWeightWC)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightDCPirateOID)
    SetSliderDialogStartValue(iDistanceWeightDCPirate)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
    
  elseif (a_option == iDistanceWeightDCLDamselOID)
    SetSliderDialogStartValue(iDistanceWeightDCLDamsel)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightDCLBondageAdvOID)
    SetSliderDialogStartValue(iDistanceWeightDCLBondageAdv)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightSlaverunRSoldOID)
    SetSliderDialogStartValue(iDistanceWeightSlaverunRSold)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightSLUTSEnslaveOID)
    SetSliderDialogStartValue(iDistanceWeightSLUTSEnslave)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightIOMEnslaveOID)
    SetSliderDialogStartValue(iDistanceWeightIOMEnslave)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iDistanceWeightDCLLeonOID)
    SetSliderDialogStartValue(iDistanceWeightDCLLeon)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
    
  elseif a_option == iDistanceWeightDCVampireOID
		SetSliderDialogStartValue(iDistanceWeightDCVampire)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iDistanceWeightDCBanditsOID
		SetSliderDialogStartValue(iDistanceWeightDCBandits)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 ) 
    
  elseif (a_option == iEnslaveWeightLocalOID)
    SetSliderDialogStartValue(iEnslaveWeightLocal)
    SetSliderDialogDefaultValue(25)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iEnslaveWeightGivenOID)
    SetSliderDialogStartValue(iEnslaveWeightGiven)
    SetSliderDialogDefaultValue(50)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif (a_option == iEnslaveWeightSoldOID)
    SetSliderDialogStartValue(iEnslaveWeightSold)
    SetSliderDialogDefaultValue(50)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )

  elseif a_option == iWeightSingleCollarOID
		SetSliderDialogStartValue(iWeightSingleCollar)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleGagOID
		SetSliderDialogStartValue(iWeightSingleGag)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleArmbinderOID
		SetSliderDialogStartValue(iWeightSingleArmbinder)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleCuffsOID
		SetSliderDialogStartValue(iWeightSingleCuffs)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleBlindfoldOID
		SetSliderDialogStartValue(iWeightSingleBlindfold)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleHarnessOID
		SetSliderDialogStartValue(iWeightSingleHarness)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleBeltOID
		SetSliderDialogStartValue(iWeightSingleBelt)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleGlovesBootsOID
		SetSliderDialogStartValue(iWeightSingleGlovesBoots)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleYokeOID
		SetSliderDialogStartValue(iWeightSingleYoke)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPiercingsOID
		SetSliderDialogStartValue(iWeightPiercings)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugsOID
		SetSliderDialogStartValue(iWeightPlugs)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightEboniteRegularOID
		SetSliderDialogStartValue(iWeightEboniteRegular)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightEboniteRedOID
		SetSliderDialogStartValue(iWeightEboniteRed)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightEboniteWhiteOID
		SetSliderDialogStartValue(iWeightEboniteWhite)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightZazMetalBrownOID
		SetSliderDialogStartValue(iWeightZazMetalBrown)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightZazMetalBlackOID
		SetSliderDialogStartValue(iWeightZazMetalBlack)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightZazLeatherOID
		SetSliderDialogStartValue(iWeightZazLeather)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightZazRopeOID
		SetSliderDialogStartValue(iWeightZazRope)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightCDGoldOID
		SetSliderDialogStartValue(iWeightCDGold)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightCDSilverOID
		SetSliderDialogStartValue(iWeightCDSilver)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightDDRegularOID
		SetSliderDialogStartValue(iWeightDDRegular)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightDDZazVelOID
		SetSliderDialogStartValue(iWeightDDZazVel)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightZazRegOID
		SetSliderDialogStartValue(iWeightZazReg)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightMultiPonyOID
		SetSliderDialogStartValue(iWeightMultiPony)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightMultiRedBNCOID
		SetSliderDialogStartValue(iWeightMultiRedBNC)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightMultiSeveralOID
		SetSliderDialogStartValue(iWeightMultiSeveral)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightMultiTransparentOID
		SetSliderDialogStartValue(iWeightMultiTransparent)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightMultiRubberOID
		SetSliderDialogStartValue(iWeightMultiRubber)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPiercingsSoulGemOID
		SetSliderDialogStartValue(iWeightPiercingsSoulGem)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPiercingsShockOID
		SetSliderDialogStartValue(iWeightPiercingsShock)
    
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugSoulGemOID
		SetSliderDialogStartValue(iWeightPlugSoulGem)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugWoodOID
		SetSliderDialogStartValue(iWeightPlugWood)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugInflatableOID
		SetSliderDialogStartValue(iWeightPlugInflatable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugTrainingOID
		SetSliderDialogStartValue(iWeightPlugTraining)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugCDClassOID
		SetSliderDialogStartValue(iWeightPlugCDSpecial)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugCDEffectOID
		SetSliderDialogStartValue(iWeightPlugCDEffect)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugChargingOID
		SetSliderDialogStartValue(iWeightPlugCharging)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightPlugDashaOID
		SetSliderDialogStartValue(iWeightPlugDasha)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltPunishmentOID
		SetSliderDialogStartValue(iWeightBeltPunishment)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltRegularOID
		SetSliderDialogStartValue(iWeightBeltRegular)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltShameOID
		SetSliderDialogStartValue(iWeightBeltShame)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltCDOID
		SetSliderDialogStartValue(iWeightBeltCD)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltRegulationsImperialOID
		SetSliderDialogStartValue(iWeightBeltRegulationsImperial)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltRegulationsStormCloakOID
		SetSliderDialogStartValue(iWeightBeltRegulationsStormCloak)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightUniqueCollarsOID
		SetSliderDialogStartValue(iWeightUniqueCollars)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )  
  elseif a_option == iWeightRandomCDOID
		SetSliderDialogStartValue(iWeightRandomCD)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
    
    
  elseif a_option == iWeightDeviousPunishEquipmentBannnedCollarOID
		SetSliderDialogStartValue(iWeightDeviousPunishEquipmentBannnedCollar)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightDeviousPunishEquipmentProstitutedCollarOID
		SetSliderDialogStartValue(iWeightDeviousPunishEquipmentProstitutedCollar)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightDeviousPunishEquipmentNakedCollarOID
		SetSliderDialogStartValue(iWeightDeviousPunishEquipmentNakedCollar)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
    
  elseif a_option == iWeightBeltPaddedOID
		SetSliderDialogStartValue(iWeightBeltPadded)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBeltIronOID
		SetSliderDialogStartValue(iWeightBeltIron)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )    
  elseif a_option == iWeightPlugShockOID
		SetSliderDialogStartValue(iWeightPlugShock)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  
  elseif a_option == iWeightSingleBootsOID
		SetSliderDialogStartValue(iWeightSingleBoots)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleAnkleChainsOID
		SetSliderDialogStartValue(iWeightSingleAnkleChains)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSingleHoodOID
		SetSliderDialogStartValue(iWeightSingleHood)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBootsSlaveOID
		SetSliderDialogStartValue(iWeightBootsSlave)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBootsRestrictiveOID
		SetSliderDialogStartValue(iWeightBootsRestrictive)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightBootsPonyOID
		SetSliderDialogStartValue(iWeightBootsPony)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightStripCollarOID
		SetSliderDialogStartValue(iWeightStripCollar)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSlutTattooOID
		SetSliderDialogStartValue(iWeightSlutTattoo)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightSlaveTattooOID
		SetSliderDialogStartValue(iWeightSlaveTattoo)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iWeightWhoreTattooOID
		SetSliderDialogStartValue(iWeightWhoreTattoo)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
    
  elseif a_option == fNightReqArousalModifierOID
		;SetSliderDialogStartValue(fNightReqArousalModifier)
 		SetSliderDialogStartValue(1.0)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0.1, 10)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fNightDistanceModifierOID
		SetSliderDialogStartValue(1.0)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0.1, 10)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fNightChanceModifierOID
		;SetSliderDialogStartValue(fNightChanceModifier)
		SetSliderDialogStartValue(1.0)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0.1, 10)
    SetSliderDialogInterval( 0.1 )
    
  elseif a_option == iNightReqConfidenceReductionOID
		SetSliderDialogStartValue(iNightReqConfidenceReduction)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-3, 4)
    SetSliderDialogInterval( 1 )
    

  
  elseif a_option == fFollowerSpecEnjoysDomOID
		SetSliderDialogStartValue(fFollowerSpecEnjoysDom)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fFollowerSpecEnjoysSubOID
		SetSliderDialogStartValue(fFollowerSpecEnjoysSub)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fFollowerSpecThinksPlayerDomOID
		SetSliderDialogStartValue(fFollowerSpecThinksPlayerDom)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fFollowerSpecThinksPlayerSubOID
		SetSliderDialogStartValue(fFollowerSpecThinksPlayerSub)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fFollowerSpecContainersCountOID
		SetSliderDialogStartValue(fFollowerSpecContainersCount)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 0.1 )
    
  elseif a_option == fFollowerSpecFrustrationOID
		SetSliderDialogStartValue(fFollowerSpecFrustration)
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 0.1 )


    
  elseif a_option == gFollowerArousalMinOID
		SetSliderDialogStartValue(gFollowerArousalMin.GetValueInt())
    SetSliderDialogRange(0, 101)
    SetSliderDialogInterval( 1 )  
  elseif a_option == fFollowerSexApproachExpOID
		SetSliderDialogStartValue(fFollowerSexApproachExp)
    SetSliderDialogRange(1, 10)
    SetSliderDialogInterval( 0.1 )
  elseif a_option == fFollowerSexApproachChanceMaxPercentageOID
		SetSliderDialogStartValue(fFollowerSexApproachChanceMaxPercentage)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval( 1 )

    
  elseif a_option == fFollowerFindMinContainersOID
		SetSliderDialogStartValue(fFollowerFindMinContainers)
    SetSliderDialogRange(-20, 50)
    SetSliderDialogInterval( 1 )
  elseif a_option == fFollowerFindChanceMaxPercentageOID
		SetSliderDialogStartValue(fFollowerFindChanceMaxPercentage)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval( 1 )
  elseif a_option == iFollowerFindChanceMaxContainersOID
		SetSliderDialogStartValue(iFollowerFindChanceMaxContainers)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iFollowerMinVulnerableApproachableOID 
		SetSliderDialogStartValue(iFollowerMinVulnerableApproachable)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )
  elseif a_option == iFollowerRelationshipLimitOID
		SetSliderDialogStartValue(iFollowerRelationshipLimit.GetValueInt())
    SetSliderDialogRange(1, 5)
    SetSliderDialogInterval( 1 )
  elseif a_option == fFollowerItemApproachExpOID
		SetSliderDialogStartValue(fFollowerItemApproachExp)
    SetSliderDialogRange(1, 10)
    SetSliderDialogInterval( 0.1 )
    
  endIf ; 
  
  
; template
;  elseif (a_option == zzzOID)
;    SetSliderDialogStartValue(zzz)
;    
;    SetSliderDialogRange(0, 150)
;    SetSliderDialogInterval( 1 )

endEvent

;iChanceEnslavementConvo  Auto  
;iChanceVulEnslavementConvo  Auto  
;iChanceSexConvo  Auto  
;iSexEventKey  Auto 
;iSexEventDevice  Auto  
;iRapeEventDevice  Auto  
;iRapeEventEnslave  Auto  


; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
  {Called when the user accepts a new slider value}
    
  if (a_option == fEventIntervalOID)
    fEventInterval = a_value
    SetSliderOptionValue(a_option, a_value, "{0} seconds")
  elseif (a_option == fEventTimeoutOID)
    fEventTimeout = (a_value as float) / (24)
    fEventTimeoutHours = a_value as float
    SetSliderOptionValue(a_option, fEventTimeoutHours, "{1} Game Hours")
  elseif (a_option == iChanceEnslavementConvoOID)
    iChanceEnslavementConvo = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iChanceVulEnslavementConvoOID)
    iChanceVulEnslavementConvo = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iChanceSexConvoOID)
    iChanceSexConvo = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iSexEventKeyOID)
    iSexEventKey = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iSexEventDeviceOID)
    iSexEventDevice = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iRapeEventDeviceOID)
    iRapeEventDevice  = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iRapeEventEnslaveOID)
    iRapeEventEnslave = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iWeightSingleDDOID)
    iWeightSingleDD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iWeightMultiDDOID)
    iWeightMultiDD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iWeightPetcollarOID)
    iWeightPetcollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iWeightCursedCollarOID)
    iWeightCursedCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iWeightSlaveCollarOID)
    iWeightSlaveCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iWeightSlutCollarOID)
    iWeightSlutCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}") 
  elseif (a_option == iWeightRubberDollCollarOID)
    iWeightRubberDollCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")  
   
  elseif (a_option == iApproachDurationOID)
    iApproachDuration = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0} Game Mins")
  elseif (a_option == iSearchRangeOID)
    iSearchRange = a_value as int
    gSearchRange.SetValueInt(a_value as int)
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iNPCSearchCountOID)
    iNPCSearchCount = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0} NPCs")
  elseif (a_option == iMinEnslaveVulnerableOID)
    iMinEnslaveVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "Level {0}")
  elseif (a_option == iMinApproachArousalOID)
    iMinApproachArousal = a_value as int
    gMinApproachArousal.SetValueInt(a_value as int)
    SetSliderOptionValue(a_option, a_value, "{0}%")
  elseif (a_option == iMaxEnslaveMoralityOID)
    iMaxEnslaveMorality = a_value as int
    SetSliderOptionValue(a_option, a_value, "Level {0}")
  elseif (a_option == iMaxSolicitMoralityOID)
    iMaxSolicitMorality = a_value as int
    SetSliderOptionValue(a_option, a_value, "Level {0}")
  elseif (a_option == iWeaponProtectionLevelOID)
    iWeaponProtectionLevel = a_value as int
    SetSliderOptionValue(a_option, a_value, "Level {0}")
  elseif (a_option == iRelationshipProtectionLevelOID)
    iRelationshipProtectionLevel = a_value as int
    SetSliderOptionValue(a_option, a_value, "Level {0}")
  
  elseif a_option == iWeightConfidenceArousalOverrideOID
    iWeightConfidenceArousalOverride = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
    
  elseif a_option == iReqLevelSLSFExhibIncreaseVulnerableOID
    iReqLevelSLSFExhibIncreaseVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iReqLevelSLSFExhibMakeVulnerableOID
    iReqLevelSLSFExhibMakeVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iReqLevelSLSFSlutIncreaseVulnerableOID
    iReqLevelSLSFSlutIncreaseVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iReqLevelSLSFSlutMakeVulnerableOID
    iReqLevelSLSFSlutMakeVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iReqLevelSLSFSlaveIncreaseVulnerableOID
    iReqLevelSLSFSlaveIncreaseVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iReqLevelSLSFSlaveMakeVulnerableOID
    iReqLevelSLSFSlaveMakeVulnerable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  
  elseif (a_option == fChastityPartialModifierOID)
    fChastityPartialModifier = a_value as int
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif (a_option == fChastityCompleteModifierOID)
    fChastityCompleteModifier = a_value as int
    SetSliderOptionValue(a_option, a_value, "{1}")
    
  elseif (a_option == fModifierSlaverChancesOID)
    fModifierSlaverChances = a_value as float
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif (a_option == iEnslaveWeightSDOID)
    iEnslaveWeightSD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iEnslaveWeightMariaOID)
    iEnslaveWeightMaria = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iEnslaveWeightSlaverunOID)
    iEnslaveWeightSlaverun = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  
  elseif (a_option == iDistanceWeightCDOID)
    iDistanceWeightCD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightSDOID)
    iDistanceWeightSD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightMariaOID)
    iDistanceWeightMaria = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
    elseif (a_option == iDistanceWeightMariaKOID)
    iDistanceWeightMariaK = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightSSOID)
    iDistanceWeightSS = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightWCOID)
    iDistanceWeightWC = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}"); 
  elseif (a_option == iDistanceWeightDCPirateOID)
    iDistanceWeightDCPirate = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
    
  elseif (a_option == iDistanceWeightDCLDamselOID)
    iDistanceWeightDCLDamsel = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightDCLBondageAdvOID)
    iDistanceWeightDCLBondageAdv = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")  
  elseif (a_option == iDistanceWeightSlaverunRSoldOID)
    iDistanceWeightSlaverunRSold = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightSLUTSEnslaveOID) ;iDistanceWeightIOMEnslave
    iDistanceWeightSLUTSEnslave = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightIOMEnslaveOID) ;iDistanceWeightIOMEnslave
    iDistanceWeightIOMEnslave = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iDistanceWeightDCLLeonOID) ;iDistanceWeightIOMEnslave
    iDistanceWeightDCLLeon = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iDistanceWeightDCVampireOID
    iDistanceWeightDCVampire = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iDistanceWeightDCBanditsOID
    iDistanceWeightDCBandits = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")  
    
  elseif (a_option == iEnslaveWeightLocalOID)
    iEnslaveWeightLocal = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iEnslaveWeightGivenOID)
    iEnslaveWeightGiven = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif (a_option == iEnslaveWeightSoldOID)
    iEnslaveWeightSold = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
    
  elseif a_option == iWeightSingleCollarOID
    iWeightSingleCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleGagOID
    iWeightSingleGag = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleArmbinderOID
    iWeightSingleArmbinder = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleCuffsOID
    iWeightSingleCuffs = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleBlindfoldOID
    iWeightSingleBlindfold = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleHarnessOID
    iWeightSingleHarness = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleBeltOID
    iWeightSingleBelt = a_value as int
    crdeBDialogueCanBeBeltedToggle.SetValueInt((iWeightSingleBelt >= 1) as int)
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleGlovesBootsOID
    iWeightSingleGlovesBoots = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleYokeOID
    iWeightSingleYoke = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPiercingsOID
    iWeightPiercings = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugsOID
    iWeightPlugs = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightEboniteRegularOID
    iWeightEboniteRegular = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightEboniteRedOID
    iWeightEboniteRed = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightEboniteWhiteOID
    iWeightEboniteWhite = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightZazMetalBrownOID
    iWeightZazMetalBrown = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightZazMetalBlackOID
    iWeightZazMetalBlack = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightZazLeatherOID
    iWeightZazLeather = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightZazRopeOID
    iWeightZazRope = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightCDGoldOID
    iWeightCDGold = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightCDSilverOID
    iWeightCDSilver = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightDDRegularOID
    iWeightDDRegular = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightDDZazVelOID
    iWeightDDZazVel = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightZazRegOID
    iWeightZazReg = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightMultiPonyOID
    iWeightMultiPony = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightMultiRedBNCOID
    iWeightMultiRedBNC = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightMultiSeveralOID
    iWeightMultiSeveral = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightMultiTransparentOID
    iWeightMultiTransparent = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightMultiRubberOID
    iWeightMultiRubber = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPiercingsSoulGemOID
    iWeightPiercingsSoulGem = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPiercingsShockOID
    iWeightPiercingsShock = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugSoulGemOID
    iWeightPlugSoulGem = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugWoodOID
    iWeightPlugWood = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugInflatableOID
    iWeightPlugInflatable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugTrainingOID
    iWeightPlugTraining = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugCDClassOID
    iWeightPlugCDSpecial = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugCDEffectOID
    iWeightPlugCDEffect = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugChargingOID
    iWeightPlugCharging = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugDashaOID
    iWeightPlugDasha = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltPunishmentOID
    iWeightBeltPunishment = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltRegularOID
    iWeightBeltRegular = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltShameOID
    iWeightBeltShame = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltCDOID
    iWeightBeltCD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltRegulationsImperialOID
    iWeightBeltRegulationsImperial = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltRegulationsStormCloakOID
    iWeightBeltRegulationsStormCloak = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightUniqueCollarsOID
    iWeightUniqueCollars = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")     
  elseif a_option == iWeightRandomCDOID
    iWeightRandomCD = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")     
  elseif a_option == iWeightDeviousPunishEquipmentBannnedCollarOID
    iWeightDeviousPunishEquipmentBannnedCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightDeviousPunishEquipmentProstitutedCollarOID
    iWeightDeviousPunishEquipmentProstitutedCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightDeviousPunishEquipmentNakedCollarOID
    iWeightDeviousPunishEquipmentNakedCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltPaddedOID
    iWeightBeltPadded = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBeltIronOID
    iWeightBeltIron = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightPlugShockOID
    iWeightPlugShock = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
   
  elseif a_option == iWeightSingleBootsOID
    iWeightSingleBoots = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleAnkleChainsOID
    iWeightSingleAnkleChains = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSingleHoodOID
    iWeightSingleHood = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBootsSlaveOID
    iWeightBootsSlave = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBootsRestrictiveOID
    iWeightBootsRestrictive = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightBootsPonyOID
    iWeightBootsPony = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightStripCollarOID
    iWeightStripCollar = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSlutTattooOID
    iWeightSlutTattoo = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightSlaveTattooOID
    iWeightSlaveTattoo = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iWeightWhoreTattooOID
    iWeightWhoreTattoo = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}") 
   
  elseif a_option == fNightReqArousalModifierOID
    fNightReqArousalModifier = a_value as float
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fNightDistanceModifierOID
    fNightDistanceModifier = a_value as float
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fNightChanceModifierOID
    fNightChanceModifier = a_value as float
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == iNightReqConfidenceReductionOID
    iNightReqConfidenceReduction = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
   
  elseif a_option == fFollowerSpecEnjoysDomOID
    fFollowerSpecEnjoysDom = a_value as Float
    StorageUtil.SetFloatValue(currentFollower, "crdeFollEnjoysDom", a_value)
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fFollowerSpecEnjoysSubOID
    fFollowerSpecEnjoysSub = a_value as Float
    StorageUtil.SetFloatValue(currentFollower, "crdeFollEnjoysSub", a_value)
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fFollowerSpecThinksPlayerDomOID
    fFollowerSpecThinksPlayerDom = a_value as Float
    StorageUtil.SetFloatValue(currentFollower, "crdeThinksPCEnjoysDom", a_value)
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fFollowerSpecThinksPlayerSubOID
    fFollowerSpecThinksPlayerSub = a_value as Float
    StorageUtil.SetFloatValue(currentFollower, "crdeThinksPCEnjoysSub", a_value)
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fFollowerSpecContainersCountOID
    fFollowerSpecContainersCount = a_value as Float
    StorageUtil.SetFloatValue(currentFollower, "crdeFollContainersSearched", a_value)
    SetSliderOptionValue(a_option, a_value, "{1}")
  elseif a_option == fFollowerSpecFrustrationOID
    fFollowerSpecFrustration = a_value as Float
    StorageUtil.SetFloatValue(currentFollower, "crdeFollowerFrustration", a_value)
    SetSliderOptionValue(a_option, a_value, "{1}")   
   
  elseif a_option == gFollowerArousalMinOID
    gFollowerArousalMin.SetValueInt( a_value as int )
    SetSliderOptionValue(a_option, a_value, "{0}") 
    reevaluateSexApproachParabolicModifier()
  elseif a_option == fFollowerSexApproachExpOID ;
    fFollowerSexApproachExp = a_value as float
    SetSliderOptionValue(a_option, a_value, "{1}") ;
    reevaluateSexApproachParabolicModifier()
  elseif a_option == fFollowerSexApproachChanceMaxPercentageOID ;
    fFollowerSexApproachChanceMaxPercentage = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}") ;
    reevaluateSexApproachParabolicModifier()
  elseif a_option == fFollowerFindMinContainersOID
    fFollowerFindMinContainers = a_value as Float
    SetSliderOptionValue(a_option, a_value, "{1}")
    reevaluateitemParabolicModifier()
  elseif a_option == fFollowerFindChanceMaxPercentageOID
    fFollowerFindChanceMaxPercentage = a_value as Float
    SetSliderOptionValue(a_option, a_value, "{1}")
    reevaluateitemParabolicModifier()
  elseif a_option == iFollowerFindChanceMaxContainersOID
    iFollowerFindChanceMaxContainers = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
    reevaluateitemParabolicModifier()
  elseif a_option == iFollowerMinVulnerableApproachableOID 
    iFollowerMinVulnerableApproachable = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == iFollowerRelationshipLimitOID
    iFollowerRelationshipLimit.SetValueInt(a_value as int)
    SetSliderOptionValue(a_option, a_value, "{0}")
  elseif a_option == fFollowerItemApproachExpOID
    fFollowerItemApproachExp = a_value as int
    SetSliderOptionValue(a_option, a_value, "{1}")
    reevaluateitemParabolicModifier()
   
  endIf ; 

endEvent
;tempalte
;  elseif (a_option == zzzOID)
;    zzz = a_value as int
;    SetSliderOptionValue(a_option, a_value, "{0}")

; @implements SKI_ConfigBase ; is this even used?
event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
  {Called when a key has been remapped}
  if (a_option == _keymapOID_K)
    bool continue = true
    if (a_conflictControl != "")
      string msg
      if (a_conflictName != "")
        msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
      else
        msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
      endIf
      continue = ShowMessage(msg, true, "$Yes", "$No")
    endIf
    if (continue)
      _myKey = a_keyCode
      SetKeymapOptionValue(a_option, a_keyCode)
    endIf
  endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
  {Called when the user highlights an option}
  
  if (a_option == iWeightSingleDDOID)
    SetInfoText("Relative chance of equipping a single standard Devious Device")
  elseIf (a_option == iWeightMultiDDOID)
    SetInfoText("Relative chance of equipping several slave items")
  elseIf (a_option == iWeightPetcollarOID)
    SetInfoText("Relative chance of equipping a Pet Collar (requires the Pet Collar mod)")
  elseIf (a_option == iWeightCursedCollarOID)
    SetInfoText("Relative chance of equipping a Cursed Collar (requires Deviously Cursed Loot)")
  elseIf (a_option == iWeightSlaveCollarOID)
    SetInfoText("Relative chance of equipping a Slave Collar (requires Deviously Cursed Loot)")
  elseIf (a_option == iWeightSlutCollarOID)
    SetInfoText("Relative chance of equipping a Slut Collar (requires Deviously Cursed Loot)")
  elseIf (a_option == iWeightRubberDollCollarOID)
    SetInfoText("Relative chance of equipping a Rubber Doll Collar (requires Deviously Cursed Loot)")  ;iWeightRubberDollCollarOID
  elseIf (a_option == bDebugModeOID)
    SetInfoText("Turns on debug information to help identify if the mod is working properly")
  elseIf (a_option == bDebugConsoleModeOID)
    SetInfoText("Routes most of the debug output into the console instead of the notification area, so less spam")
  elseIf (a_option == fEventIntervalOID)
    SetInfoText("How often a nearby NPC will approach the player when they appear to be a slave")
  elseIf (a_option == fEventTimeoutOID)
    SetInfoText("In-game time between slave event attempts")
  elseIf (a_option == iChanceEnslavementConvoOID)
    SetInfoText("Chance of NPC approaching vulnerable player to enslave")
  elseIf (a_option == iChanceVulEnslavementConvoOID)
    SetInfoText("Chance of NPC approaching vulnerable player to enslave when the player is wearing an armbinder")
  elseIf (a_option == iChanceSexConvoOID)
    SetInfoText("Chance of NPC approaching vulnerable player for sex (applies if enslave dialogue doesn't run)")
  elseIf (a_option == iSearchRangeOID)
    SetInfoText("The range in yards that the mod looks for people to attack the player")
  elseif a_option == iApproachDurationOID
    SetInfoText("The duration in in-game minutes that a NPC can approach you before the approach self-cancels and gives up")
  elseIf (a_option == iNPCSearchCountOID)
    SetInfoText("The number of NPCs the mod will look through to find someone to attack the player")
  elseIf (a_option == fModifierSlaverChancesOID)
    SetInfoText("Modifier than increases chance Slaver will approach the player (1 is same, 0 is no slaver, 2 is half chance,ect)")
    
  elseif a_option == bHookAnySexlabEventOID
    SetInfoText("Toggles Deviously enslaved to catch sexlab sessions started by other mods and run events on them (rape, adding DD items, enslave, ect)")
  elseif a_option == bHookReqVictimStatusOID 
    SetInfoText("Toggles if player's victim status from sexlab should be a requirement for postsex. If ON, player must be sexlab \"Victim\" to get post-sex events from DEC")
  elseif a_option == bFxFAlwaysAggressiveOID ;bFxFAlwaysAggressive
    SetInfoText("Toggles if Female attackers, while attacking a Female player, always use aggressive animations in rape situations. If off, aggressive is not specified so there are more animations.")
    
  elseif a_option == iMinEnslaveVulnerableOID
    SetInfoText("Sets the minimum Vulnerability required for NPCs to approach the player for enslavement, check the support thread for Vulnerability explanation")
  elseif a_option == iMinApproachArousalOID
    SetInfoText("Sets the minimum NPC Arousal required for NPCs to approach the player, Slavers are exempt from this rule")
  elseif a_option == iMaxEnslaveMoralityOID
    SetInfoText("Sets the maximum Morality required for the NPCs to attempt to enslave you")
  elseif a_option == iRelationshipProtectionLevelOID
    SetInfoText("Sets the upper limit of what relationship is allowed for NPCs to have and still attack you.")
  elseif a_option == iMaxSolicitMoralityOID
    SetInfoText("Sets the maximum Morality required for the NPCs to solicit sex from you")
  elseif a_option == bConfidenceToggleOID 
    SetInfoText("Toggles the requirement that the attacker must be confident enough to attack you based on your vulnerability")
  elseif a_option == bFollowerDialogueToggleOID 
    SetInfoText("Toggles if follower dialogue can show up")
  elseif a_option == iReqLevelSLSFExhibIncreaseVulnerableOID
    SetInfoText("(Sexlab Fame Framework) The Required amount of Fame as an exhibitionist before it starts making you more vulnerable")
  elseif a_option == iReqLevelSLSFExhibMakeVulnerableOID
    SetInfoText("(Sexlab Fame Framework) The Required amount of Fame as an exhibitionist before you are considered vulnerable from it alone")
  elseif a_option == iReqLevelSLSFSlutIncreaseVulnerableOID
    SetInfoText("(Sexlab Fame Framework) The Required amount of Fame as an slut before it starts making you more vulnerable")
  elseif a_option == iReqLevelSLSFSlutMakeVulnerableOID
    SetInfoText("(Sexlab Fame Framework) The Required amount of Fame as an slut before you are considered vulnerable from it alone")
  elseif a_option == iReqLevelSLSFSlaveIncreaseVulnerableOID
    SetInfoText("(Sexlab Fame Framework) The Required amount of Fame as an submissive slave before it starts making you more vulnerable")
  elseif a_option == iReqLevelSLSFSlaveMakeVulnerableOID
    SetInfoText("(Sexlab Fame Framework) The Required amount of Fame as an submissive slave before you are considered vulnerable from it alone") 
   
  elseif a_option == bIsVulNakedOID
    SetInfoText("Toggles whether Nudity itself counts as a low level vulnerability (LVL 1)")
  elseif a_option == bIsNonChestArmorIgnoredNakedOID 
    SetInfoText("Toggles whether wearing Armor on any other part than the chest protects you from being considered Naked (IE: Armoured helmet: no longer nude) legacy nudity detection")
  elseIf (a_option == bVulnerableGagOID)
    SetInfoText("Toggles whether DD gags as a vulnerable item")
  elseIf (a_option == bVulnerableCollarOID)
    SetInfoText("Toggles whether DD collars as a vulnerable item")
  elseIf (a_option == bVulnerableArmbinderOID)
    SetInfoText("Toggles whether DD armbinders and yokes as vulnerable items")
  elseIf (a_option == bVulnerableBlindfoldOID)
    SetInfoText("Toggles whether DD blindfolds as a vulnerable item")
  elseif a_option == bChastityToggleOID
    SetInfoText("Toggles whether the chastity system is on")
  elseIf (a_option == bChastityGagOID)
    SetInfoText("Toggles whether DD gags as an item that counts to chastity")
  elseIf (a_option == bChastityBraOID)
    SetInfoText("Toggles whether DD chastity Bras as an item that counts to chastity")
  elseif (a_option == bChastityToggleOID )          
    SetInfoText("Toggles whether the Chastity system is engaged")
  elseif (a_option == fChastityPartialModifierOID )
    SetInfoText("Modifies (devisor) the chance of being approached for sex and enslavement while wearing a incomplete set of chastity items")
  elseif (a_option == fChastityCompleteModifierOID )
    SetInfoText("Modifies (devisor) the chance of being approached for sex and enslavement while wearing a complete set of chastity items")
    
  elseif a_option == bVulnerableSlaveTattooOID
    SetInfoText("Toggles whether being marked with slave tattoos is considered a vulnerability (turns on slavetats detection)")
  elseif a_option == bVulnerableSlutTattooOID
    SetInfoText("Toggles whether being marked with slut tattoos is considered a vulnerability (turns on slavetats detection)")
  elseif a_option == bNakedReqGagOID || a_option == bNakedReqCollarOID || a_option == bNakedReqArmbinderOID || a_option == bNakedReqBlindfoldOID ||\
        a_option == bNakedReqBukkakeOID || a_option == bNakedReqSlaveBootsOID || a_option == bNakedReqHarnessOID || a_option == bNakedReqPiercedOID ||  a_option == bNakedReqSlaveTattooOID || a_option ==bNakedReqSlutTattooOID
    SetInfoText("Toggles whether the item is counted for vulnerability ONLY while naked/nude")
  elseIf (a_option == bVulnerableLOSOID)
    SetInfoText("Restricts NPC detection to those that have Line of Sight (this is literal, they have to look RIGHT AT YOU at the moment we check")
  elseIf (a_option == iWeaponProtectionLevelOID)
    SetInfoText("Sets the Max vulnerable level that a weapon or college robe prevents being approached for sex/enslavement")
  elseIf (a_option == bVulnerableFurnitureOID)
    SetInfoText("Allows the player to be considered vulnerable when locked in Xaz furniture")
    
  elseIf a_option == bGuardDialogueToggleOID
    SetInfoText("Toggles whether the guard dialogue shows, and if they will approach the player")
  elseif a_option == bEnslaveLockoutDCUROID
    SetInfoText("Toggles whether certain Cursed loot items, that have block genetic keywords, but are also removable, prevent the player from being enslaved. If off, these items will be removed and enslavement will commence as normal instead.")
    
  elseIf a_option == bEnslaveFollowerLockToggleOID
    SetInfoText("Toggle if having a nearby follower stops the player from being enslaved")

  elseIf a_option == iEnslaveWeightSDOID || a_option == iEnslaveWeightMariaOID || a_option == iEnslaveWeightSlaverunOID
    SetInfoText("Sets the weights for the possible enslavements available to the person who approaches the player")
  elseif (a_option == bSlaverunEnslaveToggleOID)
    SetInfoText("Toggles whether the mod lets the player be enslaved from dialogue into slaverun slave quest")
  elseif (a_option == bAttackersGuardsOID)
    SetInfoText("Toggles whether guards are considered valid to attack player (off means no guard attacks)")
    
  elseif a_option == bWCDistanceToggleOID || a_option == bMariaDistanceToggleOID || a_option == bMariaKhajitEnslaveToggleOID  || a_option == bSDDistanceToggleOID || a_option == bSSAuctionEnslaveToggleOID  || a_option == bCDEnslaveToggleOID || a_option == bDCPirateEnslaveToggleOID 
    SetInfoText("Toggles if the enslave outcome will show up (if it doesn't work, try turning slider to zero)")
  elseif (a_option == iEnslaveWeightLocalOID)
    SetInfoText("Weight of the chance to be enslaved by the person who approaches you")
  elseif (a_option == iEnslaveWeightGivenOID)
    SetInfoText("Weight of the chance you will be given to someone else in the world")
  elseif (a_option == iEnslaveWeightSoldOID)
    SetInfoText("Weight of the chance to be sold by the person who approaches you, to be a slave to someone else")
    
  elseif a_option == bEnslaveLockoutCLDollOID
    SetInfoText("Locks the player out of being enslaved while wearing Deviously cursed loot's Rubber doll collar")
  elseif a_option == bEnslaveLockoutSRROID
    SetInfoText("Locks the player out of being enslaved while on slave errand for Zaid under Slaverun Reloaded, when otherwise the player could get attacked and enslaved by someone else")
  elseif a_option == bEnslaveLockoutTIROID
    SetInfoText("Locks the player out of being enslaved while wearing the rubber suit from the trapped in rubber quest")
  elseif (a_option == bEnslaveLockoutCDOID)
    SetInfoText("Locks the player out of being enslaved through DE while taking part in CD expansion")
  elseif (a_option == bEnslaveLockoutSDDreamOID)
    SetInfoText("Locks the player out of being attacked while in the SD Dream world")  
    ;bEnslaveLockoutSDDream
  elseif (a_option == bEnslaveLockoutFTDOID)
    SetInfoText("Locks the player out of being enslaved through while taking part in the FTD quest line")
  elseif a_option == iDistanceWeightCDOID || a_option == iDistanceWeightWCOID || a_option == iDistanceWeightMariaOID || a_option == iDistanceWeightMariaKOID || a_option == iDistanceWeightSDOID || a_option == iDistanceWeightSSOID || a_option == iDistanceWeightDCPirateOID
    SetInfotext("Sets the relative weight of the enslavement compared to one another")
  elseif (a_option == bIntimidateToggleOID)
    SetInfoText("Toggles if the player can use intimidation to get out of being attacked")
  elseif (a_option == bIntimidateGagFullToggleOID)
    SetInfoText("Toggles if the player can not intimidate while wearing a gag (on is impossible, off is still possible)")
  elseif (a_option == bIntimidateWeaponFullToggleOID)
    SetInfoText("Toggles if having a weapon at the ready guarentees intimidation success")
   
  elseif a_option == bArousalFunctionWorkaroundOID 
    SetInfoText("Switches arousal detection to using the old function rather than the faction, slower but properly inits the NPC's arousal for now.")
  elseif a_option == bSecondBusyCheckWorkaroundOID ;bAltBodySlotSearchWorkaround
    SetInfoText("Forces the mod to check if the player is busy twice, adding a second check at the last second to catch changes that might have happened later.")
  elseif a_option == bAltBodySlotSearchWorkaroundOID ;bAltBodySlotSearchWorkaround
    SetInfoText("Searches all armor slots for body keywords and Sexlab Aroused nude status")
  elseif a_option == bIgnoreZazOnNPCOID 
    SetInfoText("Ignores non-restrictive Zaz items on NPCs when considering them as slaves")
   
  elseif a_option == bDebugRollVisOID 
    SetInfoText("Prints out the rolling information on random selection")
  elseif a_option == bDebugStateVisOID 
    SetInfoText("Prints the state of the script, such as if script is waiting for something or busy with approach")
  elseif a_option == bDebugStatusVisOID 
    SetInfoText("Prints the vulnerable/enslave status and the reason for status")  
  elseif a_option == gUnfinishedDialogueToggleOID 
    SetInfoText("Allows unfinished dialogue trees to appear in-game")  
  elseif a_option == bDebugLoudApproachFailOID ;bDebugLoudApproachFail
    SetInfoText("A failed approach now brings up a messagebox instead of quietly displaying in the console")  
    
  elseif a_option == bPrintSexlabStatusOID 
    SetInfoText("Prints the sexlab configuration")
  elseif a_option == bPrintVulnerabilityStatusOID        
    SetInfoText("Prints out vulnerability debug information")
  elseif a_option == bResetDHLPOID  
    SetInfoText("Resets and resumes the DHLP suspension system allowing the mod to continue WARNING: deviously enslaved is not the only mod that uses this, don't use unless you're sure DE is what caused the suspend")
    
  elseif a_option == bRefreshSDMasterOID  
    SetInfoText("Refreshes the next master that will be chosen for distance SD outcome, prints the previous and next after refreshing.")
  elseif a_option == bRefreshModDetectOID  ;bRefreshModDetect
    SetInfoText("Refreshes the Mod detection manually, rechecking which available mods we can use")
   
  elseif a_option == bSetValidRaceOID
    SetInfoText("Searches for nearby NPCs and allows you to pick one to set their race as valid for approach. THIS FEATURE REQUIRES UIEXTENSIONS")
  elseif a_option == bTestTattoosOID  
    SetInfoText("Checks if the tattoos worn by the player count as tattoos for vulnerability. REMINDER: I hard coded tattoos, if they don't count TELL ME and I'll fix it")

  elseif a_option == bTestTimeTestOID  
    SetInfoText("Performs a time test on the heaviest parts of this mod, since the time required is heavily reliant on input (nearby NPCs, gear on player, number of optional mods) these times can vary wildly.")

  elseif (a_option == bAbductionTestOID || a_option == bInitTestOID ||\
          a_option == bTestButton1OID || a_option == bTestButton2OID || a_option == bTestButton3OID || a_option == bTestButton4OID || a_option == bTestButton5OID ||\
          a_option == bCDTestOID || a_option == bTestButton6OID || a_option == bTestButton7OID )
    SetInfoText("Meant for testing. Save first before using these, as they might break the game")
  elseif a_option == iWeightSingleCollarOID
    SetInfoText("Weight for getting a single (non-unique) Collar")
  elseif a_option == iWeightSingleGagOID
    SetInfoText("Weight for getting a single Gag")
  elseif a_option == iWeightSingleArmbinderOID
    SetInfoText("Weight for getting a single Armbinder")
  elseif a_option == iWeightSingleCuffsOID
    SetInfoText("Weight for getting a pair of Cuffs")
  elseif a_option == iWeightSingleBlindfoldOID
    SetInfoText("Weight for getting a single Blindfold")
  elseif a_option == iWeightSingleHarnessOID
    SetInfoText("Weight for getting a single Harness")
  elseif a_option == iWeightSingleBeltOID
    SetInfoText("Weight for getting a single Chastity Belt")
  elseif a_option == iWeightSingleGlovesBootsOID
    SetInfoText("Weight for getting pair of restrictive Gloves and Boots")
  elseif a_option == iWeightSingleYokeOID
    SetInfoText("Weight for getting a single Yoke")
  elseif a_option == iWeightPiercingsOID
    SetInfoText("Weight for getting Piercings with a Belt/Harness")
  elseif a_option == iWeightPlugsOID
    SetInfoText("Weight for getting Plugs with a Belt/Harness")
  elseif a_option == iWeightEboniteRegularOID
    SetInfoText("Weight for getting an item with the theme being Regular Ebonite")
  elseif a_option == iWeightEboniteRedOID
    SetInfoText("Weight for gettomg an item with the theme being Red Ebonite")
  elseif a_option == iWeightEboniteWhiteOID
    SetInfoText("Weight for getting an item with the theme being White Ebonite")
  elseif a_option == iWeightZazMetalBrownOID
    SetInfoText("Weight for getting an item with the theme being Brown Metal Zaz")
  elseif a_option == iWeightZazMetalBlackOID
    SetInfoText("Weight for getting an item with the theme being Black Metal Zaz")
  elseif a_option == iWeightZazLeatherOID
    SetInfoText("Weight for getting an item with the theme being Leather Zaz")
  elseif a_option == iWeightZazRopeOID
    SetInfoText("Weight for getting an item with the theme being Rope Zaz")
  elseif a_option == iWeightCDGoldOID
    SetInfoText("Weight for getting an item with the theme being Gold Captured Dreams")
  elseif a_option == iWeightCDSilverOID
    SetInfoText("Weight for getting an item with the theme being Silver Captured Dreams")
  elseif a_option == iWeightDDRegularOID
    SetInfoText("Weight for getting an item with the theme being Regular DD")
  elseif a_option == iWeightDDZazVelOID
    SetInfoText("Weight for getting an item with the theme being Vel's Devious Extra's DD enabled Zaz items")
  elseif a_option == iWeightZazRegOID
    SetInfoText("Weight for getting an item with the theme being Regular non-locking Zaz")
  elseif a_option == iWeightMultiPonyOID
    SetInfoText("Weight for getting a Pony suit DD item combination")
  elseif a_option == iWeightMultiRedBNCOID
    SetInfoText("Weight for getting a red ebonnite DD combination")
  elseif a_option == iWeightMultiSeveralOID
    SetInfoText("Weight for getting 2 to 3 regular single items")
  elseif a_option == iWeightMultiTransparentOID
    SetInfoText("Weight for getting a DCL Transparent suit")
  elseif a_option == iWeightMultiRubberOID
    SetInfoText("Weight for getting a DCL Rubber suit")
  elseif a_option == iWeightPiercingsSoulGemOID
    SetInfoText("Weight for getting a DD Soul gem Piercing")
  elseif a_option == iWeightPiercingsShockOID
    SetInfoText("Weight for getting a DDx Shock Piercing")
  elseif a_option == iWeightPlugSoulGemOID
    SetInfoText("Weight for getting a DD Soul gem Plug")
  elseif a_option == iWeightPlugWoodOID
    SetInfoText("Weight for getting a DD Wood Plug")
  elseif a_option == iWeightPlugInflatableOID
    SetInfoText("Weight for getting a DD Inflatable Plug")
  elseif a_option == iWeightPlugTrainingOID
    SetInfoText("Weight for getting a DD Training Plug")
  elseif a_option == iWeightPlugCDClassOID
    SetInfoText("Weight for getting a Captured dreams class Plug")
  elseif a_option == iWeightPlugCDEffectOID
    SetInfoText("Weight for getting a Captured dreams special Plug")
  elseif a_option == iWeightPlugChargingOID
    SetInfoText("Weight for getting a DD Chargable Plug")
  elseif a_option == iWeightPlugDashaOID
    SetInfoText("Weight for getting a DD Inflatable plug")
  elseif a_option == iWeightBeltPunishmentOID
    SetInfoText("Weight for getting a Punishment Belt and extras")
  elseif a_option == iWeightBeltRegularOID
    SetInfoText("Weight for getting a Regular Belt and extras")
  elseif a_option == iWeightBeltShameOID
    SetInfoText("Weight for getting a DCL Shame Belt")
  elseif a_option == iWeightBeltCDOID
    SetInfoText("Weight for getting a Captured Dreams Belt")
  elseif a_option == iWeightBeltRegulationsImperialOID
    SetInfoText("Weight for getting a Devious Regulations Imperial Belt")
  elseif a_option == iWeightBeltRegulationsStormCloakOID
    SetInfoText("Weight for getting a Devious Regulations StormCloak Belt")
  elseif a_option == iWeightUniqueCollarsOID
    SetInfoText("Weight for getting Unique Collars")
  elseif a_option == iWeightRandomCDOID
    SetInfoText("Weight for getting a collection of CD items")

  
  elseif a_option == iWeightConfidenceArousalOverrideOID
    SetInfoText("The NPC arousal required to bypass the confidence requirement")
    
  elseif a_option == iWeightDeviousPunishEquipmentBannnedCollarOID
    SetInfoText("Weight for getting the Force nude and punishment Banned Collar")
  elseif a_option == iWeightDeviousPunishEquipmentProstitutedCollarOID
    SetInfoText("Weight for getting the Force nude and punishment Prostituted Collar")
  elseif a_option == iWeightDeviousPunishEquipmentNakedCollarOID
    SetInfoText("Weight for getting the Force nude and punishment Naked Collar")
    
  elseif a_option == iWeightBeltPaddedOID
    SetInfoText("Weight for getting DD Padded Chastity Belt")
  elseif a_option == iWeightBeltIronOID
    SetInfoText("Weight for getting DD Iron Chastity Belt")  
  elseif a_option == iWeightPlugShockOID
    SetInfoText("Weight for getting a DDx Shock Vag Plug")

  elseif a_option == iWeightSingleBootsOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightSingleAnkleChainsOID
    SetInfoText("Weight for getting Ankle chains")
  elseif a_option == iWeightSingleHoodOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightBootsSlaveOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightBootsRestrictiveOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightBootsPonyOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightStripCollarOID
    SetInfoText("Weight for getting the Cursed loot Strip Tease Collar")
  elseif a_option == iWeightSlutTattooOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightSlaveTattooOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")
  elseif a_option == iWeightWhoreTattooOID
    SetInfoText("Weight for getting TODO FINISH TOOLTIPS")

  elseif a_option == fNightReqArousalModifierOID
    SetInfoText("Modifies the required arousal amount during night time hours =(RequiredArousal * this)")
  elseif a_option == fNightDistanceModifierOID
    SetInfoText("Modifies the required distance amount during night time hours =(RequiredDistance * this)")
  elseif a_option == fNightChanceModifierOID
    SetInfoText("Modifies the chance of approach amount during night time hours =(ApprChance / this)")
   elseif a_option == iNightReqConfidenceReductionOID
    SetInfoText("Shifts the required confidnece during night time hours =(RequiredConfidence - this)")
  elseif a_option == bNightAddsToVulnerableOID
    SetInfoText("If toggled on, adds +1 to player's vulnerability during nighttime.")
    
  elseif a_option == tFollowerteleportToPlayerOID
    SetInfoText("Teleports the follower to the player's side in the case they got lost.")
    
  elseif a_option == fFollowerSpecEnjoysDomOID
    SetInfoText("The value of how much your follower enjoys being dominant.")
  elseif a_option == fFollowerSpecEnjoysSubOID
    SetInfoText("The value of how much your follower enjoys being submissive")
  elseif a_option == fFollowerSpecThinksPlayerDomOID
    SetInfoText("The value of how much your follower thinks player enjoys being dominant")
  elseif a_option == fFollowerSpecThinksPlayerSubOID
    SetInfoText("The value of how much your follower thinks player enjoys being submissive")
  elseif a_option == fFollowerSpecContainersCountOID
    SetInfoText("How many containers your followre has found. This determines the likelyhood that they will find DD items anytime soon.")
  elseif a_option == fFollowerSpecFrustrationOID
    SetInfoText("The value of how frustrated your follower is")

  elseif a_option == gForceGreetItemFindOID
    SetInfoText("Toggle if your follower shall approach you directly if they find an item. If off, they will bring it up if you approach them instead")
  elseif a_option == gFollowerArousalMinOID
    SetInfoText("Minimum arousal level needed before follower will use your bound body for sex")
  elseif a_option == bFollowerDungeonEnterRequiredOID 
    SetInfoText("Toggles whether your Follower can find items without having visited a dungeon first, and if containers only count inside of a dungeon")
  elseif a_option == bUseSexlabGenderOID 
    SetInfoText("Toggles using sexlab actor genders instead of vanilla skyrim assigned genders for NPCs")
  elseif a_option == fFollowerFindMinContainersOID
    SetInfoText("Percent chance your follower finds an item")
  elseif a_option == fFollowerFindChanceMaxPercentageOID
    SetInfoText("Max percent chance your follower will find an item")
  elseif a_option == iFollowerFindChanceMaxContainersOID
    SetInfoText("Max containers that affect the chance your follower finds an item.")
  elseif a_option == iFollowerMinVulnerableApproachableOID
    SetInfoText("Min vulnerability needed before your follower will take advantage of you.")
  elseif a_option == iFollowerRelationshipLimitOID
    SetInfoText("Minimum relationship for NPCs, who are not currently yourfollower, to treat you like a follower and attack you for sex. 5 is never, only active follower can approach you.")

  elseif a_option == fFollowerItemApproachExpOID
    SetInfoText("Exponent used to calculate curve chance of follower finding items per containers. 1 is staight line, Higher is more curved (slower ramp up)")
  elseif a_option == fFollowerSexApproachExpOID
    SetInfoText("Exponent used to calculate curve chance of follower being horny enough to approach the player for sex. 1 is staight line, Higher is more curved (slower ramp up)")
  elseif a_option == fFollowerSexApproachChanceMaxPercentageOID
    SetInfoText("Chance your follower will approach you with 100 arousal.")

  elseif a_option == bSDGeneralLockoutOID
    SetInfoText("Toggles if DEC shouldn't be active during SD+ Enslavement, if ON DEC will do nothing")

  elseif a_option == iSexEventDeviceOID
    SetInfoText("Chance of getting items after DEC started sex when the player is already enslaved")
  elseif a_option == iRapeEventDeviceOID
    SetInfoText("Chance of getting items after DEC started sex when the player is not enslaved yet")

    
  else ; catch all; the stuff I forgot and then some
    SetInfoText("Catchall tooltip: typing hints is tedious, if you want to know what this does ask in the support thread, and/or report which option is missing the tooltip")
  endIf ; fFollowerItemApproachExpOID

endEvent


;Bool Property bCRDEEnable  Auto  
GlobalVariable Property gCRDEEnable Auto
int gCRDEEnableOID

Bool Property bDebugMode  Auto  
int bDebugModeOID
Bool Property bDebugConsoleMode  Auto  
int bDebugConsoleModeOID

Float Property fEventInterval  Auto  
int fEventIntervalOID

Float Property fEventTimeout  Auto  
Float fEventTimeoutHours
int fEventTimeoutOID

Int Property iGenderPref  Auto  
int iGenderPrefOID
Int Property iGenderPrefMaster Auto  
int iGenderPrefMasterOID
bool Property bUseSexlabGender Auto  
int bUseSexlabGenderOID
int aFollowerSelectOID 


Int Property iChanceEnslavementConvo  Auto  
int iChanceEnslavementConvoOID

Int Property iChanceVulEnslavementConvo  Auto  
int iChanceVulEnslavementConvoOID

Int Property iChanceSexConvo  Auto  
int iChanceSexConvoOID

Int Property iSexEventKey  Auto 
int iSexEventKeyOID 

Int Property iSexEventDevice  Auto  
int iSexEventDeviceOID

Int Property iRapeEventDevice  Auto  
int iRapeEventDeviceOID

Int Property iRapeEventEnslave  Auto  
int iRapeEventEnslaveOID

Bool Property bIsVulNaked  Auto  
int bIsVulNakedOID 
Bool Property bIsNonChestArmorIgnoredNaked  Auto  
int bIsNonChestArmorIgnoredNakedOID 

bool Property bHookAnySexlabEvent Auto 
int bHookAnySexlabEventOID
bool Property bHookReqVictimStatus Auto 
int bHookReqVictimStatusOID 
bool Property bFxFAlwaysAggressive Auto 
int bFxFAlwaysAggressiveOID ;bFxFAlwaysAggressive

string[] Property genderList Auto
;string[] Property genderListMaster Auto ;can reuse

Int Property iWeightSingleDD Auto
int iWeightSingleDDOID 
Int Property iWeightMultiDD Auto
int iWeightMultiDDOID 
Int Property iWeightPetcollar Auto
int iWeightPetcollarOID
Int Property iWeightCursedCollar Auto
int iWeightCursedCollarOID  
Int Property iWeightSlaveCollar Auto
int iWeightSlaveCollarOID  
Int Property iWeightSlutCollar Auto
int iWeightSlutCollarOID  
Int Property iWeightRubberDollCollar Auto
int iWeightRubberDollCollarOID  

float Property fModifierSlaverChances Auto
float fModifierSlaverChancesOID

Int Property iSearchRange Auto     ; deprecated, if I get the global to work, since we can use globals in condition (CK)
GlobalVariable Property gSearchRange Auto
int iSearchRangeOID  

Int Property iNPCSearchCount Auto
int iNPCSearchCountOID 
int property iApproachDuration auto
int iApproachDurationOID
bool Property bAttackersGuards Auto
int bAttackersGuardsOID

; player vulnerability items worn/off
int Property iMinEnslaveVulnerable Auto
int iMinEnslaveVulnerableOID
int Property iMinApproachArousal Auto
GlobalVariable Property gMinApproachArousal Auto
int iMinApproachArousalOID
int Property iMaxEnslaveMorality Auto
int iMaxEnslaveMoralityOID
int Property iMaxSolicitMorality Auto
int iMaxSolicitMoralityOID
bool Property bConfidenceToggle Auto
int bConfidenceToggleOID
GlobalVariable Property bFollowerDialogueToggle Auto
int bFollowerDialogueToggleOID

Int Property  iReqLevelSLSFExhibIncreaseVulnerable Auto
Int  iReqLevelSLSFExhibIncreaseVulnerableOID
Int Property  iReqLevelSLSFExhibMakeVulnerable Auto
Int  iReqLevelSLSFExhibMakeVulnerableOID
Int Property  iReqLevelSLSFSlutIncreaseVulnerable Auto
Int  iReqLevelSLSFSlutIncreaseVulnerableOID
Int Property  iReqLevelSLSFSlutMakeVulnerable Auto
Int  iReqLevelSLSFSlutMakeVulnerableOID
Int Property  iReqLevelSLSFSlaveIncreaseVulnerable Auto
Int  iReqLevelSLSFSlaveIncreaseVulnerableOID
Int Property  iReqLevelSLSFSlaveMakeVulnerable Auto
Int  iReqLevelSLSFSlaveMakeVulnerableOID

int Property iWeaponProtectionLevel Auto 
int iWeaponProtectionLevelOID
int Property iRelationshipProtectionLevel Auto 
int iRelationshipProtectionLevelOID

bool Property bVulnerableLOS Auto
int bVulnerableLOSOID

bool Property bVulnerableFurniture Auto
Int bVulnerableFurnitureOID
bool Property bVulnerableGag Auto
bool Property bVulnerableCollar Auto
bool Property bVulnerableArmbinder Auto
bool Property bVulnerableBlindfold Auto
Int  bVulnerableGagOID 
Int  bVulnerableCollarOID 
Int  bVulnerableArmbinderOID 
Int  bVulnerableBlindfoldOID 
bool Property bVulnerableBukkake Auto
Int bVulnerableBukkakeOID
bool Property bVulnerableSlaveBoots Auto
Int bVulnerableSlaveBootsOID
bool Property bVulnerableHarness Auto
Int bVulnerableHarnessOID
bool Property bVulnerablePierced Auto
Int bVulnerablePiercedOID
bool Property bVulnerableStained Auto
Int bVulnerableStainedOID

bool Property bVulnerableSlaveTattoo Auto
bool Property bVulnerableSlutTattoo Auto
int bVulnerableSlaveTattooOID
int bVulnerableSlutTattooOID

; naked requirement for vulnerability
bool Property bNakedReqFurniture Auto
Int bNakedReqFurnitureOID
bool Property bNakedReqGag Auto
bool Property bNakedReqCollar Auto
bool Property bNakedReqArmbinder Auto
bool Property bNakedReqBlindfold Auto
Int  bNakedReqGagOID 
Int  bNakedReqCollarOID 
Int  bNakedReqArmbinderOID 
Int  bNakedReqBlindfoldOID 
bool Property bNakedReqBukkake Auto
Int bNakedReqBukkakeOID
bool Property bNakedReqSlaveBoots Auto
Int bNakedReqSlaveBootsOID
bool Property bNakedReqHarness Auto
Int bNakedReqHarnessOID
bool Property bNakedReqPierced Auto
Int bNakedReqPiercedOID
bool Property bNakedReqStained Auto
Int bNakedReqStainedOID

bool Property bNakedReqSlaveTattoo Auto
bool Property bNakedReqSlutTattoo Auto
int bNakedReqSlaveTattooOID
int bNakedReqSlutTattooOID

; chasity items valid/off
; rename this to chastitytoggle one day
bool  Property bChastityToggle auto
int   bChastityToggleOID
bool  Property bChastityGag Auto
bool  Property bChastityBra Auto
Int   bChastityGagOID 
Int   bChastityBraOID 
int   bChastityLockingZazOID
bool  Property bChastityLockingZaz Auto Conditional
bool Property bChastityZazGag Auto Conditional
bool Property bChastityZazBelt Auto Conditional
int bChastityZazGagOID  
int bChastityZazBeltOID
float Property fChastityCompleteModifier Auto Conditional
int fChastityCompleteModifierOID
float Property fChastityPartialModifier Auto Conditional
int fChastityPartialModifierOID


; enslavement options on/off
bool Property bEnslaveLockoutDCUR Auto Conditional
int bEnslaveLockoutDCUROID 

bool Property bEnslaveFollowerLockToggle Auto Conditional
int bEnslaveFollowerLockToggleOID

; local toggles
bool Property bSlaverunEnslaveToggle Auto Conditional
Int  bSlaverunEnslaveToggleOID 
bool Property  bSDEnslaveToggle Auto Conditional 
Int   bSDEnslaveToggleOID 
bool Property  bMariaEnslaveToggle Auto Conditional
int bMariaEnslaveToggleOID

; enslavement options long distance
bool Property bWCDistanceToggle Auto Conditional
Int  bWCDistanceToggleOID 
bool Property bMariaDistanceToggle Auto Conditional
int bMariaDistanceToggleOID
bool Property bMariaKhajitEnslaveToggle Auto Conditional
Int  bMariaKhajitEnslaveToggleOID 
bool Property bSDDistanceToggle Auto Conditional 
int bSDDistanceToggleOID
bool Property bSSAuctionEnslaveToggle Auto Conditional
Int  bSSAuctionEnslaveToggleOID 
bool Property bCDEnslaveToggle Auto Conditional
Int  bCDEnslaveToggleOID
bool Property bDCPirateEnslaveToggle Auto Conditional
Int  bDCPirateEnslaveToggleOID

; enslavement sliders (local and standard)
Int Property  iEnslaveWeightSD Auto
Int Property  iEnslaveWeightMaria Auto
Int Property  iEnslaveWeightSlaverun Auto
Int Property  iEnslaveWeightCD Auto
Int Property  iEnslaveWeightSS Auto
Int  iEnslaveWeightSDOID
Int  iEnslaveWeightMariaOID
Int  iEnslaveWeightSlaverunOID
Int  iEnslaveWeightCDOID
Int  iEnslaveWeightSSOID 

; enslave type weights
Int Property  iEnslaveWeightLocal Auto
Int  iEnslaveWeightLocalOID
Int Property  iEnslaveWeightGiven Auto
Int  iEnslaveWeightGivenOID
Int Property  iEnslaveWeightSold Auto
Int  iEnslaveWeightSoldOID

; long distance sliders
Int Property  iDistanceWeightCD Auto
Int  iDistanceWeightCDOID
Int Property  iDistanceWeightWC Auto
Int  iDistanceWeightWCOID
Int Property  iDistanceWeightMaria Auto
Int  iDistanceWeightMariaOID
Int Property  iDistanceWeightMariaK Auto
Int  iDistanceWeightMariaKOID
Int Property  iDistanceWeightSD Auto
Int  iDistanceWeightSDOID
Int Property iDistanceWeightSS Auto 
Int iDistanceWeightSSOID
Int Property iDistanceWeightDCPirate Auto 
Int iDistanceWeightDCPirateOID

Int Property iDistanceWeightDCLDamsel Auto 
Int iDistanceWeightDCLDamselOID
Int Property iDistanceWeightDCLBondageAdv Auto 
Int iDistanceWeightDCLBondageAdvOID
Int Property iDistanceWeightSlaverunRSold Auto 
Int iDistanceWeightSlaverunRSoldOID
Int Property iDistanceWeightSLUTSEnslave Auto 
Int iDistanceWeightSLUTSEnslaveOID
Int Property iDistanceWeightIOMEnslave Auto 
Int iDistanceWeightIOMEnslaveOID
Int Property iDistanceWeightDCLLeon Auto 
int iDistanceWeightDCLLeonOID
Int Property  iDistanceWeightDCVampire Auto
Int iDistanceWeightDCVampireOID
Int Property  iDistanceWeightDCBandits Auto
Int iDistanceWeightDCBanditsOID

; enslave lock-out bEnslaveLockoutSRROID
bool Property  bEnslaveLockoutCLDoll Auto 
int bEnslaveLockoutCLDollOID
bool Property  bEnslaveLockoutSRR Auto 
int bEnslaveLockoutSRROID

bool Property  bEnslaveLockoutTIR Auto 
int bEnslaveLockoutTIROID
bool Property  bEnslaveLockoutCD Auto
Int  bEnslaveLockoutCDOID
bool Property  bEnslaveLockoutSDDream Auto
Int  bEnslaveLockoutSDDreamOID
bool Property  bEnslaveLockoutMiasLair Auto
Int  bEnslaveLockoutMiasLairOID
bool Property  bEnslaveLockoutAngrim Auto
Int  bEnslaveLockoutAngrimOID
bool Property  bEnslaveLockoutFTD Auto
Int  bEnslaveLockoutFTDOID

;guard dialogue 
bool Property bGuardDialogueToggle Auto Conditional           ; deprecated
GlobalVariable Property gGuardDialogueToggle Auto Conditional
int bGuardDialogueToggleOID

; intimidation
bool Property  bIntimidateToggle Auto                         ; deprecated
GlobalVariable Property gIntimidateToggle Auto Conditional
Int  bIntimidateToggleOID
bool Property  bIntimidateGagFullToggle Auto
Int  bIntimidateGagFullToggleOID
bool Property  bIntimidateWeaponFullToggle Auto
Int  bIntimidateWeaponFullToggleOID

; workarounds
bool property bArousalFunctionWorkaround auto
int bArousalFunctionWorkaroundOID
bool property bSecondBusyCheckWorkaround auto
int bSecondBusyCheckWorkaroundOID
bool property bAltBodySlotSearchWorkaround auto
int bAltBodySlotSearchWorkaroundOID
bool property bIgnoreZazOnNPC auto
int bIgnoreZazOnNPCOID;bIgnoreZazOnNPCOID

; debug
bool Property bDebugRollVis Auto
bool Property bDebugStateVis Auto
bool Property bDebugStatusVis Auto
int bDebugRollVisOID 
int bDebugStateVisOID     
int bDebugStatusVisOID

GlobalVariable Property gUnfinishedDialogueToggle Auto Conditional
int gUnfinishedDialogueToggleOID
bool Property bDebugLoudApproachFail Auto
int bDebugLoudApproachFailOID 

bool Property bPrintSexlabStatus Auto
int bPrintSexlabStatusOID
bool Property bPrintVulnerabilityStatus Auto
int bPrintVulnerabilityStatusOID
bool Property bResetDHLP Auto
int bResetDHLPOID
bool Property bRefreshSDMaster Auto
int bRefreshSDMasterOID ;bRefreshModDetect
bool Property bSetValidRace Auto
int bSetValidRaceOID
;bool Property bRefreshModDetect Auto
int bRefreshModDetectOID 

bool Property bTestTattoos Auto
int bTestTattoosOID
bool Property bTestTimeTest Auto
int bTestTimeTestOID

bool Property bTestButton1 Auto
int bTestButton1OID
bool Property bTestButton2 Auto
int bTestButton2OID
bool Property bTestButton3 Auto
int bTestButton3OID
bool Property bTestButton4 Auto
int bTestButton4OID
bool Property bTestButton5 Auto
int bTestButton5OID
bool Property bTestButton6 Auto
int bTestButton6OID
bool Property bTestButton7 Auto
int bTestButton7OID
bool Property bAbductionTest Auto
int bAbductionTestOID
bool Property bInitTest Auto
int bInitTestOID

bool Property bCDTest Auto
int bCDTestOID
bool Property bSimpleSlaveryTest Auto
int bSimpleSlaveryTestOID

Int Property  iWeightSingleCollar Auto
Int  iWeightSingleCollarOID
Int Property  iWeightSingleGag Auto
Int  iWeightSingleGagOID
Int Property  iWeightSingleArmbinder Auto
Int  iWeightSingleArmbinderOID
Int Property  iWeightSingleCuffs Auto
Int  iWeightSingleCuffsOID
Int Property  iWeightSingleBlindfold Auto
Int  iWeightSingleBlindfoldOID
Int Property  iWeightSingleHarness Auto
Int  iWeightSingleHarnessOID
Int Property  iWeightSingleBelt Auto
Int  iWeightSingleBeltOID
Int Property  iWeightSingleGlovesBoots Auto
Int  iWeightSingleGlovesBootsOID
Int Property  iWeightSingleYoke Auto
Int  iWeightSingleYokeOID
Int Property  iWeightPiercings Auto
Int  iWeightPiercingsOID
Int Property  iWeightPlugs Auto
Int  iWeightPlugsOID
Int Property  iWeightEboniteRegular Auto
Int  iWeightEboniteRegularOID
Int Property  iWeightEboniteRed Auto
Int  iWeightEboniteRedOID
Int Property  iWeightEboniteWhite Auto
Int  iWeightEboniteWhiteOID
Int Property  iWeightZazMetalBrown Auto
Int  iWeightZazMetalBrownOID
Int Property  iWeightZazMetalBlack Auto
Int  iWeightZazMetalBlackOID
Int Property  iWeightZazLeather Auto
Int  iWeightZazLeatherOID
Int Property  iWeightZazRope Auto
Int  iWeightZazRopeOID
Int Property  iWeightCDGold Auto
Int  iWeightCDGoldOID
Int Property  iWeightCDSilver Auto
Int  iWeightCDSilverOID
Int Property  iWeightDDRegular Auto
Int  iWeightDDRegularOID
Int Property  iWeightDDZazVel Auto
Int  iWeightDDZazVelOID
Int Property  iWeightZazReg Auto
Int  iWeightZazRegOID
Int Property  iWeightMultiPony Auto
Int  iWeightMultiPonyOID
Int Property  iWeightMultiRedBNC Auto
Int  iWeightMultiRedBNCOID
Int Property  iWeightMultiSeveral Auto
Int  iWeightMultiSeveralOID
Int Property  iWeightMultiTransparent Auto
Int  iWeightMultiTransparentOID
Int Property  iWeightMultiRubber Auto
Int  iWeightMultiRubberOID
Int Property  iWeightPiercingsSoulGem Auto
Int  iWeightPiercingsSoulGemOID
Int Property  iWeightPiercingsShock Auto
Int  iWeightPiercingsShockOID
Int Property  iWeightPlugSoulGem Auto
Int  iWeightPlugSoulGemOID
Int Property  iWeightPlugWood Auto
Int  iWeightPlugWoodOID
Int Property  iWeightPlugInflatable Auto
Int  iWeightPlugInflatableOID
Int Property  iWeightPlugTraining Auto
Int  iWeightPlugTrainingOID
Int Property  iWeightPlugCDSpecial Auto
Int  iWeightPlugCDClassOID
Int Property  iWeightPlugCDEffect Auto
Int  iWeightPlugCDEffectOID
Int Property  iWeightPlugCharging Auto
Int  iWeightPlugChargingOID
Int Property  iWeightPlugDasha Auto
Int  iWeightPlugDashaOID
Int Property  iWeightBeltPunishment Auto
Int  iWeightBeltPunishmentOID
Int Property  iWeightBeltRegular Auto
Int  iWeightBeltRegularOID
Int Property  iWeightBeltShame Auto
Int  iWeightBeltShameOID
Int Property  iWeightBeltCD Auto
Int  iWeightBeltCDOID
Int Property  iWeightBeltRegulationsImperial Auto
Int  iWeightBeltRegulationsImperialOID
Int Property  iWeightBeltRegulationsStormCloak Auto
Int  iWeightBeltRegulationsStormCloakOID
Int Property  iWeightUniqueCollars Auto
Int  iWeightUniqueCollarsOID
Int Property iWeightRandomCD Auto
Int  iWeightRandomCDOID
Int Property  iWeightConfidenceArousalOverride Auto
Int  iWeightConfidenceArousalOverrideOID

Int Property  iWeightDeviousPunishEquipmentBannnedCollar Auto
Int  iWeightDeviousPunishEquipmentBannnedCollarOID
Int Property  iWeightDeviousPunishEquipmentProstitutedCollar Auto
Int  iWeightDeviousPunishEquipmentProstitutedCollarOID
Int Property  iWeightDeviousPunishEquipmentNakedCollar Auto
Int  iWeightDeviousPunishEquipmentNakedCollarOID
Int Property  iWeightBeltPadded Auto
Int  iWeightBeltPaddedOID
Int Property  iWeightBeltIron Auto
Int  iWeightBeltIronOID
Int Property  iWeightPlugShock Auto
Int  iWeightPlugShockOID

Int Property  iWeightSingleBoots Auto
Int  iWeightSingleBootsOID
Int Property  iWeightSingleAnkleChains Auto
Int  iWeightSingleAnkleChainsOID
Int Property  iWeightSingleHood Auto
Int  iWeightSingleHoodOID
Int Property  iWeightBootsSlave Auto
Int  iWeightBootsSlaveOID
Int Property  iWeightBootsRestrictive Auto
Int  iWeightBootsRestrictiveOID
Int Property  iWeightBootsPony Auto
Int  iWeightBootsPonyOID
Int Property  iWeightStripCollar Auto
Int  iWeightStripCollarOID
Int Property  iWeightSlutTattoo Auto
Int  iWeightSlutTattooOID
Int Property  iWeightSlaveTattoo Auto
Int  iWeightSlaveTattooOID
Int Property  iWeightWhoreTattoo Auto
Int  iWeightWhoreTattooOID

float Property  fNightReqArousalModifier Auto
Int  fNightReqArousalModifierOID
float Property  fNightDistanceModifier Auto
Int  fNightDistanceModifierOID
float Property  fNightChanceModifier Auto
Int  fNightChanceModifierOID
Int Property  iNightReqConfidenceReduction Auto
Int  iNightReqConfidenceReductionOID
bool Property  bNightAddsToVulnerable Auto
Int  bNightAddsToVulnerableOID

int tFollowerteleportToPlayerOID
Float Property  fFollowerSpecEnjoysDom Auto
Int  fFollowerSpecEnjoysDomOID
Float Property  fFollowerSpecEnjoysSub Auto
Int  fFollowerSpecEnjoysSubOID
Float Property  fFollowerSpecThinksPlayerDom Auto
Int  fFollowerSpecThinksPlayerDomOID
Float Property  fFollowerSpecThinksPlayerSub Auto
Int  fFollowerSpecThinksPlayerSubOID
Float Property fFollowerSpecContainersCount Auto
int fFollowerSpecContainersCountOID
Float Property  fFollowerSpecFrustration Auto
Int  fFollowerSpecFrustrationOID

GlobalVariable Property  gForceGreetItemFind Auto
Int  gForceGreetItemFindOID
GlobalVariable Property   gFollowerArousalMin Auto
Int  gFollowerArousalMinOID
bool Property  bFollowerDungeonEnterRequired Auto
Int  bFollowerDungeonEnterRequiredOID
Float Property   fFollowerFindMinContainers Auto
Int  fFollowerFindMinContainersOID
Float Property   fFollowerFindChanceMaxPercentage Auto
Int  fFollowerFindChanceMaxPercentageOID
Int Property   iFollowerFindChanceMaxContainers Auto
Int  iFollowerFindChanceMaxContainersOID
Int Property   iFollowerMinVulnerableApproachable Auto
Int  iFollowerMinVulnerableApproachableOID 
GlobalVariable Property   iFollowerRelationshipLimit Auto
Int  iFollowerRelationshipLimitOID

Int  fFollowerItemApproachExpOID
Float  Property fFollowerItemApproachExp Auto
Int  fFollowerSexApproachExpOID
Float  Property fFollowerSexApproachExp Auto
Int  fFollowerSexApproachChanceMaxPercentageOID
int  Property fFollowerSexApproachChanceMaxPercentage Auto

Float  Property itemParabolicModifier Auto
Float  Property sexApproachParabolicModifier Auto

GlobalVariable property crdeBDialogueCanBeBeltedToggle auto

bool Property bSDGeneralLockout Auto
int bSDGeneralLockoutOID

bool property bAddFollowerManually Auto
int bAddFollowerManuallyOID
