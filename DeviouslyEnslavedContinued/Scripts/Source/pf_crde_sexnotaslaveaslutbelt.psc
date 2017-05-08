;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_sexnotaslaveaslutbelt Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
  actor player = Game.GetPlayer()
  Debug.SendAnimationEvent(player, "bleedOutStart")
  Utility.Wait(1.5)
  Debug.Messagebox("From their bag flies a magic chastity belt, before you know it you're locked up tight!")
  (GetOwningQuest() as crdeItemManipulateScript).equipPunishmentBeltAndStuff(player)
  Utility.Wait(1.5)
  Debug.SendAnimationEvent(player, "ZaZAPCSHFOFF")  ; shame pose
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
