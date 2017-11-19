Scriptname crdeSettingsScript extends Quest  
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Settings
;
; Todo: Not sure what this does yet.
; Are any of these even used?  This all looks like copies of what MCM is used for today!
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

; WHEN
int Property chanceBase Auto
int Property chanceOfPassingConversation Auto
int Property chanceOfForcedConversation Auto
int Property chanceOfForcedEnslavement Auto
int Property chanceOfSexEnslavement Auto
int Property chanceOfRapeEnslavement Auto
int Property chanceOfWaitEnslavement Auto
int Property chanceOfSleepEnslavement Auto

bool Property nudeIsVulnerable Auto
bool Property noNotes Auto
bool Property preventConflicts Auto

; WHAT
int Property eventEnslaveWeight Auto
int Property eventRapeWeight Auto
int Property eventDeviceWeight Auto
int Property eventKeysWeight Auto


int Property weightSD Auto
int Property weightME Auto
int Property weightDCL Auto
int Property weightWolfclub Auto
int Property weightTIR Auto
int Property weightGC Auto
int Property weightQAYL Auto

float Property enslaveTimeout Auto
float Property sexTimeout Auto
float Property talkTimeout Auto

Int Property genderPreference = 0 Auto  

Int Property DebugMode = 0 Auto  

function resetValues()
  chanceOfForcedConversation = 8
  chanceOfForcedEnslavement = 40

  eventEnslaveWeight = 15
  eventRapeWeight = 45
  eventDeviceWeight = 10
  eventKeysWeight = 33
  nudeIsVulnerable = false

  genderPreference = 1
  ; 0 = none
  ; 1 = male
  ; 2 = female

  enslaveTimeout = 0.007
  sexTimeout = 0.007
  talkTimeout = 0.007
  DebugMode = 0
endFunction


event onInit()
   resetValues()
endEvent

