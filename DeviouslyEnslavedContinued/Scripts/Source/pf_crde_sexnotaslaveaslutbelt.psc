;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_sexnotaslaveaslutbelt Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
  ; sex approach -> i am not a slave -> then belted
  actor player = Game.GetPlayer()
  
  Debug.SendAnimationEvent(player, "bleedOutStart")
  Utility.Wait(1.5)
  Debug.Messagebox("From their bag flies a magic chastity belt, before you know it you're locked up tight!")
  (GetOwningQuest() as crdeItemManipulateScript).equipPunishmentBeltAndStuff(player)
  Utility.Wait(1.5)
  ; cut from 13.11.5 because it messes with a user, they wanted optional but I'm lazy
  if ! player.WornHasKeyword((GetOwningQuest() as crdePlayerMonitorScript).libs.zad_DeviousHeavyBondage)
    Debug.SendAnimationEvent(player, "ZaZAPCSHFOFF")  ; shame pose 
  endif
  
StorageUtil.SetFloatValue(akSpeaker, "crdeNPCApproachTimeout", Utility.GetCurrentGameTime() + 1.0) 

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
