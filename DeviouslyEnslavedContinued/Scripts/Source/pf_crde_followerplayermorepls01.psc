;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayermorepls01 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player -> follower "I want you to tie me up some more" -> "I guess we can do that"
; master is already required for this one
;PlayerMon.setMaster(akSpeaker)
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript


if PlayerMon.follower_enjoys_dom > 10 || PlayerMon.follower_thinks_player_sub > 10
  int i = Utility.RandomInt(0,9) ; 4/10
  if i <= 3 && PlayerMon.MCM.iWeightSingleBelt > 0
    PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true, forceBelt = true)
  else
    PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true, forceHarness = true)
  endif
else
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker)
endif

PlayerMon.setFollowerGameState(True)


;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
