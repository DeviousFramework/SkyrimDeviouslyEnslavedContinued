Scriptname crdeDeviousFrameworkScript extends Quest  


; why does this script exist? because every time you try to pull a unique filetype 
;  for a soft dependency mod you want to use, the compiler will look for that type
;  and if it doesn't find that type it crashes the whole script
;  if we make a script for that one mod, and that script crashes then who cares, 
;  it was only used for that one mod anyway


crdeModsMonitorScript Property Mods auto
dfwDeviousFramework Property FrameworkQuest Auto


Event OnInit()
  Utility.wait(10)
  while Mods.finishedCheckingMods == false
    Debug.Trace("[crde]in devious framework: mods not finished yet", 1)
    Utility.wait(2) ; in seconds
  endWhile
  RefreshQuest()
endEvent


bool function RefreshQuest()
  FrameworkQuest = Quest.getQuest("_dfwDeviousFramework") as dfwDeviousFramework
  if ! FrameworkQuest
    debug.trace("[CRDE] Error: Cannot resolve dfwDeviousFramework quest")
    return false
  endif
  return true
endFunction

bool function GetDFWPlayerBusy()
  if FrameworkQuest 

    ;return actualQuest.IsPlayerBusy() ; error: function does not exist...?
    return FrameworkQuest.IsPlayerCriticallyBusy()
  endif
  return false 
endFunction

actor function GetDFWMaster()
  if FrameworkQuest 
    return FrameworkQuest.GetMaster()
  endif
  return None 
endFunction


