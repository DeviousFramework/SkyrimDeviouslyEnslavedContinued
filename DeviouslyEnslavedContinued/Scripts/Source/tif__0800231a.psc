;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__0800231A Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
crdePlayerMonitorScript monitorScript = GetOwningQuest() as crdePlayerMonitorScript
monitorScript.doPlayerSex(akSpeaker, true)
Debug.Notification(akSpeaker.getDisplayName() + " grabs you as you try to leave.")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
