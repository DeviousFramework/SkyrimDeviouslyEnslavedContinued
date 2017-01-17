;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname crdefragmentwantedrunawaygag Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; add gag to stop her from talking
Game.GetPlayer().EquipItem((Quest.getQuest("crdeModsMonitor") as crdeModsMonitorScript).zazClothGag)
(Quest.getQuest("crdePlayerMonitor") as crdePlayerMonitorScript).wearingGag = true
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
