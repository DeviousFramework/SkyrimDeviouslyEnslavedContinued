;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_sexintimidatedfriends1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; needs intimidation timeout
  float gametime = Utility.GetCurrentGameTime()
  float daycount = Math.Floor(gametime)
  float timeofday = gametime - daycount ; IE 17.5 - 17 = 0.5
  ; we should make it either tonight, if tonight is too close, make it tomorrow night
  daycount += (timeofday >= 1.0/24 * 19.0) as int ; 7 pm is late enough
  gametime = daycount + 1.0/24 * 19.0
  StorageUtil.SetFloatValue(akSpeaker, "crdeNPCApproachTimeout", gametime) 

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
