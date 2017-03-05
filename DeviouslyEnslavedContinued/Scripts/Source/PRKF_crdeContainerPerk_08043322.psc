;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname PRKF_crdeContainerPerk_08043322 Extends Perk Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
  if  !akTargetRef.IsLocked() && akTargetRef.GetNumItems() >= 1  ; hope this limits us to chests and stuff
    ; type is suppposed to be 28 for containers ; akTargetRef.GetType() == 28 &&
    ;if akTargetRef.GetType() == 28
    ;  Debug.trace(akTargetRef + " is a container")
    ;endif
    ;if akTargetRef.GetType() == 28
    ;  Debug.trace(akTargetRef + " is an actor")
    ;endif
    ;if akTargetRef as actor
    ;  Debug.trace(akTargetRef + " is an actor2")
    ;endif
    actor body = akTargetRef as actor
    if body && !body.isDead()
      ; do nothing, not dead yet
      ;  follower can't find items pickpocketing other people
    else
      ; lets not count containers in the player's home
      Location current_loc = akTargetRef.GetCurrentLocation()
      if !current_loc.haskeyword(LocTypePlayerHouse)
        PlayerMon.playerContainerOpenCount += 1
      endif
    endif
  endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Keyword Property LocTypePlayerHouse Auto

crdePlayerMonitorScript Property PlayerMon auto

