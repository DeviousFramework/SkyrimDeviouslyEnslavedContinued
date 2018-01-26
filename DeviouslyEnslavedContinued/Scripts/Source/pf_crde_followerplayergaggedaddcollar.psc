;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followerplayergaggedaddcollar Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; player gagged asking for release
; can you untie me now
; you need a collar to look more like a slave
; equip collar
; add dom points to follower
  crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
  PlayerMon.ItemScript.equipRandomGag(Game.GetPlayer())
  actor[] a = PlayerMon.NPCSearchScript.getNearbyActors(500)
  PlayerMon.adjustPerceptionPlayerSub(a, 3.0, 25)
  PlayerMon.modFollowerLikesDom(akSpeaker, 2.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
