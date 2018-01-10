;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerletsseewhatIgot Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; I want you to tie me up -> lets see what I got
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript

if PlayerMon.follower_enjoys_dom > 10 || PlayerMon.follower_thinks_player_sub > 10
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker, forceCollar = true)
else
  PlayerMon.ItemScript.equipFollowerAndPlayerItems(akSpeaker )
endif

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
