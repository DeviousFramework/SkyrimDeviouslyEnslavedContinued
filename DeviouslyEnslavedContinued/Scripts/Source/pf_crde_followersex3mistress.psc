;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followersex3mistress Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
;yes, mistress -> don't call me that you'll ruin the mood
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript ; oh alright, three references is enough for a temp variable
;PlayerMon.ItemScript.equipRandomSingleDD(akSpeaker)
;however, for now, not completely care free, add one of some item to player
PlayerMon.doPlayerSex(akSpeaker, rape = false, soft = true , oral_only = false)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby,3,25)
PlayerMon.modFollowerLikesDom(akSpeaker,-5)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
