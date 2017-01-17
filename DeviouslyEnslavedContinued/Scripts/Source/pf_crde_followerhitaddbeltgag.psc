;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname pf_crde_followerhitaddbeltgag Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; add gag belt with specific plugs and gag
crdePlayerMonitorScript PlayerMon = GetOwningQuest() as crdePlayerMonitorScript
PlayerMon.modFollowerFrustration(akSpeaker, -10)

; put on yoke or armbinder onto player
; TODO replace this with using any yoke/armbinder they have before using one that is random
PlayerMon.ItemScript.equipSpellPunishmentBelt(PlayerMon.player)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
