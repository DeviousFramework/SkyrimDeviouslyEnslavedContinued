;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followersexapproach Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
(getOwningQuest() as crdePlayerMonitorScript).forceGreetSex = 0
(getOwningQuest() as crdePlayerMonitorScript).timeoutFollowerNag = Utility.GetCurrentGameTime() + ( 30/1400.00 ) ; 30 in-game minutes
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
