;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_follitemgaglikescollarbonus Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; gagged player, gets new item through item appraoch, likes it
; gets new collar as bonus
  (GetOwningQuest() as crdeItemManipulateScript).equipFollowerAndPlayerItems(akSpeaker, forceCollar = true)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
