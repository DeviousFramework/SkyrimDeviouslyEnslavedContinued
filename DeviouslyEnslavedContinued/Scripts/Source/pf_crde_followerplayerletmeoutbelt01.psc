;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayerletmeoutbelt01 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; I can't take it anymore please unlock me
crdePlayerMonitorScript PlayerMon = (GetOwningQuest() as crdePlayerMonitorScript)
if PlayerMon.follower_enjoys_dom >= 10
  PlayerMon.ItemScript.removeDDs(removerActor = akSpeaker, ignoreCollar = true)
else
  PlayerMon.ItemScript.removeDDs(removerActor = akSpeaker)
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
