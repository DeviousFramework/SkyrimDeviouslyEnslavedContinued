;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followeritemgagged02 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; follower approaches with item, player gagged
;"lets see if it finds on you, you seem to like it anyway"
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
PlayerMon.ItemScript.equipFollowerFoundItems(PlayerMon.player)
PlayerMon.resetFollowerContainerCount(PlayerMon.player)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
