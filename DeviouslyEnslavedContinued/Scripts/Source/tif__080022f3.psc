;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__080022F3 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
crdePlayerMonitorScript monitorScript = GetOwningQuest() as crdePlayerMonitorScript
monitorScript.forceGreetSlave = 0
monitorScript.timeoutEnslaveGameTime = Utility.GetCurrentGameTime() + monitorScript.MCM.fEventTimeout
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
