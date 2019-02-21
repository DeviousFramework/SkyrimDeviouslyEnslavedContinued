;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followeryesmasterlikes2 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
;yes, master -> "I love it when you call me that"
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
;PlayerMon.ItemScript.removeDDbyKWD(akSpeakerRef, ItemScript.libs.zad_DeviousBelt)
PlayerMon.doPlayerSexAndReplaceBelt(akSpeaker)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby,3,25)
PlayerMon.modFollowerLikesDom(akSpeaker,3,25)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
