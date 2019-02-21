;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayeruntiemegagged02 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player: can you untie me now -> sure, but why did you put these items on anyway? gagged
crdePlayerMonitorScript PlayerMon = (GetOwningQuest() as crdePlayerMonitorScript)

PlayerMon.ItemScript.removeDDs(removerActor = akSpeaker)

PlayerMon.setFollowerGameState(False)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
