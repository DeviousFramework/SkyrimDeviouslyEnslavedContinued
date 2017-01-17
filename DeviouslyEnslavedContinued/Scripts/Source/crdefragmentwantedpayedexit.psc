;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname crdefragmentwantedpayedexit Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; agreed to pay for crimes
;(Quest.getQuest("crdeModsMonitor") as crdeModsMonitorScript).arrestPlayer(0)
; easier to get the bounty from our script since we don't know which crime faction they belong to
int bounty = ((Quest.getQuest("crdePlayerMonitor") as crdePlayerMonitorScript).localBounty)
Form GoldItem = Game.GetFormFromFile(0x0f, "Skyrim.esp") as form ; why I couldn't just pass the actual pointer, huh?
Game.GetPlayer().RemoveItem(GoldItem, bounty + 500)
;remove the debt the player actually has
;akSpeakerRef.GetCrimeFaction(). nvm
;akSpeakerRef.GetCrimeFaction().PlayerPayCrimeGold()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
