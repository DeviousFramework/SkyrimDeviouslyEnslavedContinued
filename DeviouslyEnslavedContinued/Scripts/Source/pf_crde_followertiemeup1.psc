;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname pf_crde_followertiemeup1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; tie me up -> sure in town
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript

if PlayerMon.follower_enjoys_dom > 10 || PlayerMon.follower_thinks_player_sub > 10
  int i = Utility.RandomInt(0,9) ; 4/10
  if i <= 3 && PlayerMon.MCM.iWeightSingleBelt > 0
    PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true, forceGag = true, forceBelt = true)
  else
    PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true, forceGag = true, forceHarness = true)
  endif
else
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true)
endif


;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; WRONG do not use, this is an accidental pre-dialogue fragment I do not want
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
