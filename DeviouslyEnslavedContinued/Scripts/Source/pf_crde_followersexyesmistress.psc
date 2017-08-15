;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followersexyesmistress Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; yes, mistress -> good slut
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript ; oh alright, three references is enough for a temp variable
;PlayerMon.ItemScript.removeDDbyKWD(akSpeakerRef, ItemScript.libs.zad_DeviousBelt)
;however, for now, not completely care free, add one of some item to player
PlayerMon.doPlayerSex(akSpeaker, rape = false, soft = true)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby,3,25)
PlayerMon.modFollowerLikesDom(akSpeaker,3,25)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
