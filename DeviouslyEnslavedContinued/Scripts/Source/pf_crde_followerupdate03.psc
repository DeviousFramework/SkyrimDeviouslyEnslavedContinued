;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerupdate03 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; MMMmmm! -> What is it?
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
PlayerMon.updateFollowerOpinions(akSpeaker)
PlayerMon.updatePlayerVulnerability()

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
