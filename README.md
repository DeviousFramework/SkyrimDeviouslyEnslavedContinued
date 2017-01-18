# SkyrimDeviouslyEnslavedContinued
An add on mod to the devious mods of Skyrim allowing you to be assaulted the more vulnerable you appear.<Br>
Much credit for original work to Chase Roxand of Lovers Lab.<Br>
Credit for continuation work to Verstort who carried on development before passing it along to me.

Required Mods:
-------------
Sexlab:                       http://git.loverslab.com/sexlab/framework/
Sexlab Aroused Redux          https://www.loverslab.com/files/file/307-wip-sexlab-aroused-v2014-01-24/
Zaz Animation Pack            https://www.loverslab.com/files/file/156-zaz-animation-pack-2016-03-31/
Devious Devices (DDa/DDi/DDx) https://github.com/DeviousDevices
***UIExtensions***            http://www.nexusmods.com/skyrim/mods/57046/

Incompatible mods:
-----------------

Currently, the only mod I recommend users not use in combination with DEC is Sky Slavery, which adds male slaves around skyrim. I cannot find a way to detect that they are slaves, so there is no way to stop them from attacking the player, and some of them were bugged out and could not interact with last time I tried the mod.

Mia's Lair: I think I got all incompatibilities with Mia's lair sorted out, but you might still get a stack dump during the interrogation part, because I haven't added location based detection for that part yet. Everything after that is smooth, and you shouldn't need to turn DEC off, if you have reason to believe otherwise tell me.

Some mods, for whatever reason, create template NPCs that have the wrong gender assigned to them. DEC uses ActorReference.GetActorBase().getSex() to get gender, and I don't know how else to get it. So far, I don't know of a more accurate way to fix it from my side, ask the dev from that side if there's anything that could fix it.
As a reminder: if DEC is getting in the way of a mod/quest/scene you can turn it off temporarily in the MCM settings
