;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followeraddbitchcollar2 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; follower approaches with item, player gagged, collar
; Perfect fit. Who would have thought you would fit right into a bitch collar so easily?
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
PlayerMon.ItemScript.equipFollowerFoundItems(PlayerMon.player)
PlayerMon.resetFollowerContainerCount(akSpeaker)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
