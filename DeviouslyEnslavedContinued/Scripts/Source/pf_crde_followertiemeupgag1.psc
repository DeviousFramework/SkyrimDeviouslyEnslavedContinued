;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followertiemeupgag1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; tie me up -> force gag 1
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
PlayerMon.setMaster(akSpeaker)
PlayerMon.ItemScript.StealKeys(akSpeaker)

; assuming we reset the values for the follower we are talking to specifically at the start of this conversation
if PlayerMon.follower_enjoys_dom > 10 || PlayerMon.follower_thinks_player_sub > 10
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceGag = true , forceCollar = true)
else
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceGag = true )
endif

PlayerMon.setFollowerGameState(True)


;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
