Scriptname crdeDebugScript
;***********************************************************************************************
; Mod: Deviously Enslaved Continued
;
; Script: Debug
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

; getting real sick of your shit, papyrus

;crdeMCMScript Property MCM Auto
;crdeMCMScript MCM

; separated so I can call from multiple places

;debug: todo move to shared lib
;function debugmsg(string msg, int level = 0) global
;  MCM = GetLinkedRef()
;  msg = "[CRDE] " + msg
;    if level == 0                              ; debug. print in console so we can see it as needed
;      if MCMlinked.bDebugMode == true 
;        if MCMlinked.bDebugConsoleMode
;          MiscUtil.PrintConsole(msg)
;        else
;          Debug.Notification(msg)
;        endif
;        Debug.Trace(msg)
;      endif
;    elseif level == 1 && MCMlinked.bDebugStateVis    ; states/stages, shows up in trace IF debug is set
;      if MCMlinked.bDebugMode == true 
;        if MCMlinked.bDebugConsoleMode
;          MiscUtil.PrintConsole(msg)
;        else  
;          Debug.Notification(msg)
;        endif
;        Debug.Trace(msg)
;      endif
;    elseif level == 2 && MCMlinked.bDebugRollVis    ; rolling information
;      if MCMlinked.bDebugMode == true 
;        if MCMlinked.bDebugConsoleMode
;          MiscUtil.PrintConsole(msg)
;        else  
;          Debug.Notification(msg)
;        endif
;      endif
;      Debug.Trace(msg) 
;    elseif level == 3 && MCM.bDebugStatusVis    ; enslave reason
 ;     if MCM.bDebugMode == true 
 ;       if MCM.bDebugConsoleMode
;          MiscUtil.PrintConsole(msg)
;        else  
;          Debug.Notification(msg)
;        endif
;      endif
;      Debug.Trace(msg)
;    elseif(level == 4)     ; important: record if debug is off, notify user if on as well
;      Debug.Trace(msg)
;      MiscUtil.PrintConsole(msg)
;      if(MCM.bDebugMode == true)
;        Debug.Notification(msg)
;      endif
;    elseif(level == 5)     ; very important, errors
;      Debug.Trace(msg)
;      if(MCM.bDebugMode == true)
;        MiscUtil.PrintConsole(msg)
;        Debug.MessageBox(msg)
;      endif
;    endif
;endFunction
;;;
