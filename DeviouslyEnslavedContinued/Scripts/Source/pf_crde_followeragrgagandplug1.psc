;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname pf_crde_followeragrgagandplug1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
actor player = Game.GetPlayer()
Utility.Wait(3)

crdeItemManipulateScript itemscript = (GetOwningQuest() as crdeItemManipulateScript)
itemscript.equipRandomGag(player)
Debug.MessageBox(akSpeaker.GetDisplayName()  + " shoves a gag in your mouth.")
Utility.Wait(2)
itemscript.equipArousingPlugAndBelt(player, akSpeaker)
itemscript.stealKeys(akSpeaker)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
