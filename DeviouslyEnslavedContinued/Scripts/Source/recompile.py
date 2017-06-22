#!/usr/bin/env python

# recompiles all psc after changes

# location information
src_locs = []
src_locs.append('G:/Games/Mod Organizer/overwrite/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/skse_1_07_03/scripts/Source')
src_locs.append( 'G:/bin/steam_win/steamapps/common/Skyrim/Data/scripts/source')

src_locs.append( 'G:/bin/steam_win/steamapps/common/Skyrim/Data/scripts/source/Dragonborn')
src_locs.append( 'G:/bin/steam_win/steamapps/common/Skyrim/Data/scripts/source/Hearthfire')
src_locs.append( 'G:/bin/steam_win/steamapps/common/Skyrim/Data/scripts/source/Dawnguard')

src_locs.append( 'G:/Games/Mod Organizer/mods/Deviously Cursed Loot 5.8/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/Maria Eden 1.19/scripts/Source')

src_locs.append( 'F:/work/ll/DD/DDa/00 Core/scripts/source')
src_locs.append( 'F:/work/ll/DD/DDi/00 Core/scripts/Source')
src_locs.append( 'F:/work/ll/DD/DDx/00 Core/Scripts/Source')
#src_locs.append( 'F:/work/DD/DDi/old
#src_locs.append( 'F:/work/DD/DDx/old

src_locs.append( 'G:/Games/Mod Organizer/mods/SexLabFramework v161b FULL/scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/SexLabAroused V27a Loose/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/SkyUI_5.1_SDK/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/Sex Lab - Sexual Fame 0.96c/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/Wolfclub 20150226 Alpha (loose)/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/PapyrusUtilv32/scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/JContainers-v3.3.0-alpha/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/ZazAnimationPack_v61/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/submissivelola-1.5(1)/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/SlaveTats-1.1.1/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/Deviously Helpless 1.15d/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/NetImmerse Override v-3-4-4-37481-3-4-4(2)/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/XP32 Maximum Skeleton Extended 3.76/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/SkoomaWhore1.0/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/Captured Dreams v3.84 full/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/SlaverunReloaded 06 Mar 2016/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/xazPrisonOverhaul/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/xazPrisonOverhaul_V033 Patch 8d/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/ConsolePlugin 3/Scripts/Source')
src_locs.append( 'G:/Games/Mod Organizer/mods/Aradia Devious Devices (UNP)Integrated V2/scripts/source')
src_locs.append( 'G:/Games/Mod Organizer/mods/UIExtensions v1-2/scripts/source')
# Kimy added it as a requirement for DDi in 3.1 beta
src_locs.append( 'G:/Games/Mod Organizer/mods/FNIS Sexy Move/Scripts/Source')

src_locs.append("%~2")
#= "%~2";%Overwrite%;%SKSE%;%Vanilla%;%Dragonborn%;%Hearthfire%;%Dawnguard%;%Maria%;%DDa%;%DDi%;%Sexlab%;%SexlabAroused%;%SkyUI%;%SLSF%;%wolfclub%;%papyrusUtil%;%Jcontainers%;%zaz%;%dcur%;%DDx%;%Lola%;%SlaveTats%;%Helpless%;%NiO%;%XPMSE%;%Skooma%;%CDx%;%SLV%;%PO%;%POx%;%ConsoleUtil%;%aradia%;%UIExtensions%;%SexyMove%;


def CompileScript(f):
  from subprocess import Popen
  Popen("G:\bin\steam_win\steamapps\common\Skyrim\Papyrus Compiler\PapyrusCompiler.exe" "%1" -i="%AllScripts%" -o=%2\.. -f="G:\bin\steam_win\steamapps\common\Skyrim\Data\scripts\source\TESV_Papyrus_Flags.flg")  


### main ###

import glob
#files = glob.glob('./*.psc')
import os
files = [os.path.basename(x) for x in glob.glob('./*.psc')]


from concurrent.futures import ThreadPoolExecutor
import time
threads = 4
tpe = ThreadPoolExecutor(threads)

jobs = []
while len(files) > 0:
  for j in jobs:
    if j.done():
      jobs.remove(j)
  if len(jobs) < 4:
    i = 0
    while i < 3 and len(files) > 0:
      print("tpe.submit(CompileScript, files.pop()) ")
      tpe.submit(CompileScript, files.pop()) 
  time.sleep(0.1)

tpe.shutdown(wait=True) # wait for it to finish, this just locks this thread waiting until we're done        

print("waiting for finish")

# for all files in location:
