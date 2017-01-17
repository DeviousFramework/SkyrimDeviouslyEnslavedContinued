;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_enslaveintimidatefailgag Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; enslave intimidate failed, gagged
; equip gag on playe, for now, zaz gag because it works better for cross-mod interaction
(GetOwningQuest() as crdeItemManipulateScript).equipRandomGag(Game.GetPlayer())
(GetOwningQuest()  as crdePlayerMonitorScript).wearingGag = true
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
