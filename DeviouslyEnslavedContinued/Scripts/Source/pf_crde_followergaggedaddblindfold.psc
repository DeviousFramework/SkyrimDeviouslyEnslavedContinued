;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followergaggedaddblindfold Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
crdeItemManipulateScript itemscript = (GetOwningQuest() as crdeItemManipulateScript)
crdePlayerMonitorScript PlayerMon = (GetOwningQuest() as crdePlayerMonitorScript)
itemscript.equipRandomGag(PlayerMon.player)
Utility.Wait(3)
itemscript.equipRandomDDBlindfolds(PlayerMon.player)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby,1,20)
PlayerMon.modFollowerLikesDom(akSpeaker,1,20)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
