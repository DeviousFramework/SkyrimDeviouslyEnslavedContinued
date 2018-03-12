;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followerupdate04 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player approaches follower while gagged, follower is dom
; Good slave.
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
PlayerMon.updateFollowerOpinions(akSpeaker)
PlayerMon.updatePlayerVulnerability()

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
