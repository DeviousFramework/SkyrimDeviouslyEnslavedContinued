;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_follplgagsexyesminor01 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player -> follower gagged, want sex, lets
; follower isn't dom yet, but will be soon,

crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript ; oh alright, three references is enough for a temp variable
;PlayerMon.ItemScript.removeDDbyKWD(akSpeakerRef, ItemScript.libs.zad_DeviousBelt)
;however, for now, not completely care free, add one of some item to player
PlayerMon.doPlayerSex(akSpeaker, rape = false, soft = true)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby,5,35)
PlayerMon.modFollowerLikesDom(akSpeaker,5,30)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
