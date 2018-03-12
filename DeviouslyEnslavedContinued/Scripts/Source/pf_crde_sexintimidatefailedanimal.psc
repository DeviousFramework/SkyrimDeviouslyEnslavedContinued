;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_sexintimidatefailedanimal Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; sex intimidate failed 
;crdePlayerMonitorScript monitorScript = GetOwningQuest() as crdePlayerMonitorScript
; add more items? collar
(GetOwningQuest() as crdeItemManipulateScript).equipRandomPetItem(Game.GetPlayer())
;(GetOwningQuest() as  crdePlayerMonitorScript).doPlayerSex(akSpeaker, rape = true)
(GetOwningQuest() as  crdePlayerMonitorScript).doPlayerSexAndReplaceBelt(akSpeaker)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
