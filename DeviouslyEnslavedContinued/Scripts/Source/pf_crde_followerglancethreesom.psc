;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerglancethreesom Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; Glance at follower -> yeah threesom!
crdePlayerMonitorScript PlayerMon = (GetOwningQuest() as crdePlayerMonitorScript)
PlayerMon.doPlayerSexFull(akSpeaker, PlayerMon.followerRefAlias01.GetActorRef())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
