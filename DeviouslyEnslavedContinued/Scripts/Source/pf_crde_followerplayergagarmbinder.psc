;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname pf_crde_followerplayergagarmbinder Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player ->follower gagged, can you untie me, misread as "can you put me in armbinder"

  crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
  actor player = Game.GetPlayer()
  armor arm = PlayerMon.ItemScript.getRandomHeavyBondage(player)
  if arm.HasKeyword(PlayerMon.libs.zad_DeviousYoke)
    Debug.Notification("Your follower locks your arms in a yoke, preventing you from using your hands.")
  else
    Debug.Notification("Your follower locks yoru arms behind your back in a leather restraint, preventing you from using your hands.")
  endif
  PlayerMon.ItemScript.equipRegularDDItem(player, arm, none)
  actor[] a = PlayerMon.NPCSearchScript.getNearbyActors(500)
  PlayerMon.adjustPerceptionPlayerSub(a, 3.0, 30) ; 30 because we're already gagged with follower acting as dom
  PlayerMon.modFollowerLikesDom(akSpeaker, 2.0)
  
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
