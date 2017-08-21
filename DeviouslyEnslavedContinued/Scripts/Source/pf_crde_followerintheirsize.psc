;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerintheirsize Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; I wonder if it fits -> "Oh you think it might be in your size?"
;(GetOwningQuest() as crdeItemManipulateScript).equipFollowerFoundItems(akSpeaker)
crdeNPCSearchingScript SearchScript = (GetOwningQuest() as crdePlayerMonitorScript).NPCSearchScript
actor[] nearby = SearchScript.getNearbyActors(500)
(GetOwningQuest() as crdePlayerMonitorScript).adjustPerceptionPlayerSub(nearby,1,20)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
