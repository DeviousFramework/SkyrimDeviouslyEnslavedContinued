;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_sexfreefuckservice Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; Look a free fuck slave service me
crdePlayerMonitorScript monitorScript = GetOwningQuest() as crdePlayerMonitorScript
monitorScript.forceGreetSex = 0
; why was this being reset?
;monitorScript.timeoutEnslaveGameTime = Utility.GetCurrentGameTime() + monitorScript.MCM.fEventTimeout
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
