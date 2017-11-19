;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayerapproach1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; wanna have fun -> gagged follower (normal)\
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript 
PlayerMon.doPlayerSex(akSpeaker, rape = false, soft = true)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
