;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followeronslavenowthen Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript ; oh alright, three references is enough for a temp variable
;PlayerMon.player.removeItem(PlayerMon.libs.chastityKey)
PlayerMon.Itemscript.removeDDbyKWD(PlayerMon.slaveRefAlias.GetActorRef() ,PlayerMon.libs.zad_DeviousBelt)
;akSpeaker.additem(PlayerMon.libs.chastityKey)
PlayerMon.doFollowerRapeSlave(akSpeaker)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
