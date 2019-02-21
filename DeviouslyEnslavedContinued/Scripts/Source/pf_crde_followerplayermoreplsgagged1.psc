;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayermoreplsgagged1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player -> "I want you to tie me up some more" -> add more items
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
;PlayerMon.setMaster(akSpeaker)

if PlayerMon.follower_enjoys_dom > 10 || PlayerMon.follower_thinks_player_sub > 10
  int i = Utility.RandomInt(0,9) ; 4/10
  if i <= 3 && PlayerMon.MCM.iWeightSingleBelt > 0
    PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true, forceGag = true, forceBelt = true)
  else
    PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true , forceArmbinder = true, forceGag = true, forceHarness = true)
  endif
else
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker)
endif

PlayerMon.setFollowerGameState(True)


;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
