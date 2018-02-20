;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayergagsexsubfolm Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player -> follower gagged, want sex
; follower is sub, lets player out so they can fuck
; this one assumes player is male

crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript ; oh alright, three references is enough for a temp variable
;PlayerMon.ItemScript.removeDDbyKWD(akSpeakerRef, ItemScript.libs.zad_DeviousBelt)
;however, for now, not completely care free, add one of some item to player
PlayerMon.ItemScript.removeDDs()
PlayerMon.doPlayerSex(akSpeaker, rape = false, soft = true)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby, 1, 25)
PlayerMon.modFollowerLikesSub(akSpeaker,1,10)
PlayerMon.modFollowerLikesDom(akSpeaker,1,20)


;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
