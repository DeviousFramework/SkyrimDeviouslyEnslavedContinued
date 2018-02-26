;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followergaggedinteresting2 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; follower item add to gagged player, player likes it 2
; "Glad you like it, because you look good in it."

; increase sub/dom
crdePlayerMonitorScript PlayerMon = (GetOwningQuest() as crdePlayerMonitorScript)
actor[] nearby = PlayerMon.NPCSearchScript.getNearbyActors(500)
PlayerMon.adjustPerceptionPlayerSub(nearby,2)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
