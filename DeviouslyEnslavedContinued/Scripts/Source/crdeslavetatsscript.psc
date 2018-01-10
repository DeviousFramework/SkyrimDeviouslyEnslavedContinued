Scriptname crdeSlaveTatsScript extends Quest ;conditional ;extends ReferenceAlias  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Slave Tats
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

; detections set (because they'r set in creation kit, can't see here without slow ass load into creation kit):
;   branding device of doom (slave): section -> BDoD
;   aloe slut: section -> Aloe Slut
;   submissive, slutmarks, qayl, ownership, rejected, slavenumber, masochist

; definitions
crdeModsMonitorScript   Property  Mods auto
crdePlayerMonitorScript Property  PlayerMon auto
;import                           SlaveTats
Quest                   Property  SlaveTatsQuest auto
Keyword                 Property  ClothingCirclet Auto
actor                             player 
GlobalVariable          Property  modEnabled Auto

bool semaphore
Bool Property changesHappened auto

; strings of names of tattoos that count for detection and their type
string[] Property slaveTattooNames Auto
string[] Property slutTattooNames Auto
string[] Property whoreTattooNames Auto
string[] Property bitchTattooNames Auto

; mod specific
string[] Property slaveTattooGrooovusNames Auto
string[] Property slutTattooGrooovusNames Auto
string[] Property slaveTattooBDoDNames Auto

string[] Property slaveTattooSections Auto
string[] Property slutTattooSections Auto

string[] Property slaveTattooAuthors Auto
string[] Property slutTattooAuthors Auto

string[] Property bisSectionNames Auto


bool Property wearingSlaveTattoo Auto
bool Property wearingSlutTattoo Auto 
bool Property wearingOwnedTattoo Auto ; for when a tattoo is a brand of a specific owner

bool Property wearingWhoreTattoo Auto
bool Property wearingBitchTattoo Auto

; "face" tattoos are always visible
; forarm items could count here too
bool Property wearingSlaveTattooFace   Auto
bool Property wearingSlutTattooFace   Auto

;init, might not need this one here
Event OnInit()
  ;if SlaveTats && SlaveTats.VERSION() as bool ; WARNING, this is error if no slavetats, error is ok?
  if SlaveTats.VERSION() as bool ; WARNING, this is error if no slavetats, error is ok?
    Utility.Wait(10) 
  
    debug.trace("[CRDE] SlaveTats loaded as version " + SlaveTats.VERSION())

    RegisterForModEvent("SlaveTats-removed","TattooUpdate")
    RegisterForModEvent("SlaveTats-added","TattooUpdate")
    init_templates()
    player = Game.GetPlayer()
  EndIf
EndEvent

; too lazy to look up the details of the tattoo, especially when we don't care
Event TattooUpdate( String s1, String s2, Form f1)
  debug.trace("[CRDE] *** Tattoo update detected ***")
  if modEnabled.GetValueInt() == 0 || Mods.iEnslavedLevel == 3
    changesHappened = true
  elseif (PlayerMon.MCM.iVulnerableSlaveTattoo || PlayerMon.MCM.iVulnerableSlutTattoo )
    detectTattoos()
  endif

EndEvent

; meta thread, call this it knows what else to do
Function detectTattoos()
  ; reset flags
  
  if semaphore ; already running, leave and let it continue at it's own pace
    debug.trace("[CRDE] *** Tattoo recycle called too early, still working from before ***")
    return
  endif
  
  semaphore = true
  Utility.Wait(3) ; do this after the semaphore is called, so we lock early in the first instance and the wait kills the other instances

  ; reset values
  wearingSlaveTattoo      = false
  wearingSlutTattoo       = false
  ;wearingWhoreTattoo  = false ; currently don't use these
  ;wearingBitchTattoo  = false
  wearingOwnedTattoo      = false
  wearingSlaveTattooFace  = false
  wearingSlutTattooFace   = false
  
  
  ; start calling stuff
  ; TODO: check what we need to look for before we look for it
  detectTattooBySlot("BODY")    ; body
  detectTattooBySlot("FACE")   
  ;detectTattooBySlot("HAND")       ; the rest can come later
  ;detectTattooBySlot("FOOT")

  semaphore = false
endFunction


; separate out so that I can call this again whenever the game reloads as needed
; this is if I manage to use templates to detect tattoos
Function init_templates()
  ; do what?
    ; need to be further along before this gets fleshed out
EndFunction

; search the the name of the tatoo for the specific keywords
Function checkNameForKeywords(string section, string tattoo_name, bool face)
  ;if mcm slave option is set,
  if section == "Grooovus"
    ; special case, tattoo that is blocked by chastity belt, so we can't see if it player isn't naked anyway
    if tattoo_name == "DD Belt belly" && !player.wornHasKeyword(Mods.zazKeywordWornBelt) ;!PlayerMon.wearingBlockingVaginal
      wearingSlaveTattoo = true 
    elseif tattoo_name == "Captured Dreams Property (belly)"
      wearingOwnedTattoo = true
    endif
    
    int name = 0 ; (wearingSlaveTattoo * slaveTattooGrooovusNames.LENGTH)
    while name < slaveTattooGrooovusNames.LENGTH
      if tattoo_name == slaveTattooGrooovusNames[name]
        wearingSlaveTattoo = true 
        wearingSlaveTattooFace = face && wearingSlaveTattoo
        name = slaveTattooGrooovusNames.LENGTH ; break
      endif
      name += 1
    endWhile
    
  endif
  
  ;if mcm slave option is set,
  if section == "BDoD"
    ; special case, tattoo that is blocked by chastity belt, so we can't see if it player isn't naked anyway
    if !(face && !player.wornHasKeyword(ClothingCirclet) && (tattoo_name == "SlaveF (forehead)" || tattoo_name == "SlaveM (forehead)"))
      wearingSlaveTattoo = true 
      wearingSlaveTattooFace = face && wearingSlaveTattoo
    ;elseif tattoo_name == "Unknown"
    ;  wearingOwnedTattoo = true
    ;elseif tattoo_name == "Unknown"
    ;else
    ;  wearingSlaveTattoo = true 
    ;  wearingSlaveTattooFace = face && wearingSlaveTattoo
    endif
    
    ; this a touch extreme, every other thing we can ignore, just use the section
    ;int name = 0 ; (wearingSlaveTattoo * slaveTattooBDoDNames.LENGTH)
    ;while name < slaveTattooBDoDNames.LENGTH
    ;  if tattoo_name == slaveTattooBDoDNames[name]
    ;    wearingSlaveTattoo = true 
    ;    wearingSlaveTattooFace = face && wearingSlaveTattoo
    ;    name = slaveTattooBDoDNames.LENGTH ; break
    ;  endif
    ;  name += 1
    ;endWhile
    
  endif

  ; repeat per subtype
 
EndFunction 

; search the the name of the tatoo for the specific keywords
Function checkSectionForKeywords( string tattoo_section, bool face)
  int section = 0
  While section < slaveTattooSections.LENGTH              ; SLAVE
    if tattoo_section == slaveTattooSections[section]
      wearingSlaveTattoo = true
      wearingSlaveTattooFace = face && wearingSlaveTattoo ;= true
      Debug.trace("[CRDE] compared correctly: " + tattoo_section + " + " + slaveTattooSections[section])
      section = slaveTattooSections.LENGTH ; end the loop, since papyrus doesn't have a continue keyword
    endif
    section += 1
  EndWhile
  
  section = 0
  While section < slutTattooSections.LENGTH                ; SLUT
    if tattoo_section == slutTattooSections[section]
      wearingSlutTattoo = true
      wearingSlutTattooFace = face && wearingSlutTattoo
      Debug.trace("[CRDE] compared correctly: " + tattoo_section + " + " + slutTattooSections[section])
      section = slutTattooSections.LENGTH ; end the loop, since papyrus doesn't have a continue keyword
    endif
    section += 1
  EndWhile
  ; repeat per subtype, if more
 
  ; special case: Bistro slavetats has too many sections, but they all start with "BIS "
  section = 0
  While section < bisSectionNames.LENGTH                ; BIS
    if bisSectionNames[section] == tattoo_section
      wearingSlaveTattoo = true
    endif
    section += 1
  EndWhile

 
EndFunction 

; unfinished
; search the the author of the tatoo for the specific keywords
;string tattoo_name = "non-specified",
Function checkAuthorForKeywords(  string tattoo_author)
  ; unused, almost nobody puts themeslves as author in 3rd party tattoos
EndFunction 

; based on slavetatsmcmmenu code
Function detectTattooBySlot(String area = "BODY")
  ; this code seems useful in finding specific tattoos by checking each and every slot individually
  int external = JValue.retain(JArray.object(), "SlaveTats")
  SlaveTats.external_slots(Game.GetPlayer(), area, external) ;target = player substitute
  int slots = SlaveTats.SLOTS(area)
  if slots > 12
      slots = 12
  endif

  int slot = 0
  while slot < slots
    int entry = SlaveTats.get_applied_tattoo_in_slot(Game.GetPlayer(), area, slot)
    if entry == 0
      ;Debug.Trace("[CRDE] no tattoo found in slot:" + slot)
    else
      Debug.Trace("[CRDE]: tattoo name:" + JMap.getStr(entry, "name") + " tattoo section:" + JMap.getStr(entry, "section"))
      checkNameForKeywords(JMap.getStr(entry, "section"), JMap.getStr(entry, "name"), (area == "FACE"))
      checkSectionForKeywords(JMap.getStr(entry, "section"), (area == "FACE"))
    endif
    slot += 1
  endWhile
  
  ; finally, check for odd ball cases, like slaves of tamriel
  
  
endFunction

; meant to test against standard butt slut tattoo
; all of this fails to work, your query_applied_tattoos function requires too specific of a template, I think
; please consider making a better way to detect based on one field. The whole point of an API is to prevent people like me reinventing the wheel
Function testSlaveTats()
  ;init_templates()
  ; bool resultAll  = query_applied_tattoos(Actor target, int template, int matches, string except_area = "", int except_slot = -1)
  Actor p = Game.getPlayer()
  int matches = JValue.retain(JArray.object())
  
  int templateAll = JValue.retain(JMap.object())
  JMap.setStr(templateAll, "section", "SlaveTats")
  ;matches = JValue.retain(JArray.object(), "SlaveTats")
  bool resultAll  = SlaveTats.query_applied_tattoos(p, templateAll, matches)
  Debug.Trace("[CRDE] templateall:" + templateAll + " ,resultAll: " + resultAll, 2)
  
  int templateSlave = JValue.retain(JMap.object())
  JMap.setStr(templateSlave, "area", "BODY")
  ;matches = JValue.retain(JArray.object())
  bool resultSlave  = SlaveTats.query_applied_tattoos(p, templateSlave, matches)
  Debug.Trace("[CRDE] templateBODY:" + templateSlave + " ,resultBODY: " + resultSlave, 2)
  
  int templateButt = JValue.retain(JMap.object())
  JMap.setStr(templateButt, "section", "Anal")
  matches = JValue.retain(JArray.object())
  bool resultButt  = SlaveTats.query_applied_tattoos(p, templateButt, matches)
  Debug.Trace("[CRDE] templateButt:" + templateButt + " ,resultButt: " + resultButt, 2)
  
  int templateButt2 = JValue.retain(JMap.object())
  JMap.setStr(templateButt2, "name", "Butt Slut")
  matches = JValue.retain(JArray.object())
  bool resultButt2  = SlaveTats.query_applied_tattoos(p, templateButt2, matches)
  Debug.Trace("[CRDE] templateButt2:" + templateButt2 + " ,resultButt2: " + resultButt2, 2)
  
  int templateButt3 = JValue.retain(JMap.object())
  JMap.setStr(templateButt3, "area", "BODY")
  JMap.setStr(templateButt3, "credit", "zqzqz")
  JMap.setStr(templateButt3, "name", "Butt Slut")
  JMap.setStr(templateButt3, "section", "Anal")
  ;JMap.setStr(templateButt3, "texture", "anal\\butt_butt_slut_zqzqz.dds")
  ;matches = JValue.retain(JArray.object(), "Butt Slut")
  bool resultButt3  = SlaveTats.query_applied_tattoos(p, templateButt3, matches)
  Debug.Trace("[CRDE] templateButt3:" + templateButt3 + " ,resultButt3: " + resultButt3, 2)
  
  ;int templateButt4 = JValue.retain(JMap.object())
  ;int applied = JFormDB.getObj("Butt", ".SlaveTats.applied")
  ;;matches = JValue.retain(JArray.object(), "Butt Slut")
  ;Debug.Trace("[CRDE] templateButt3:" + templateButt4 + " ,applied: " + applied)
  
  ; alright, round 5, most everything here borrowed from slavetatsmcmmenu::OnPageReset()
  detectTattooBySlot("BODY")
  
EndFunction

; doesn't work
;bool Function IsWearingTattoos()
;  if SlaveTats.VERSION() as bool
    
    ; reinit templates; do this every game load, not needed any more frequently than that
  
    ; slavetats: query_applied_tattoos(Actor target, int template, int matches, string except_area = "", int except_slot = -1) global
;    return false
;  else
;    return false
;  EndIf 
;EndFunction
