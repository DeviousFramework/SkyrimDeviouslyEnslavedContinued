#!/usr/bin/env python

# verstort 9/2026
# because yes, I am this lazy

fin = file("extra_var.txt", "r")
fout = file("output.txt", 'w')

split = fin.read()
print split
split = split.split()
print split

for s in split:
  """iDistanceWeightDCLLeonOID  = AddSliderOption("Cursed loot Leon", iDistanceWeightDCLLeon, "{0}", (!Mods.modLoadedCursedLoot) as int)"""
  fout.write( "    " + s + "OID  = AddSliderOption(\"" + s +"\", " + s + ", \"{0}\", 1);(!Mods."+s+") as int)\n")

fout.write("\n\n")
  
for s in split:
  """  elseif (a_option == iDistanceWeightDCLLeonOID)
    SetSliderDialogStartValue(iDistanceWeightDCLLeon)
    SetSliderDialogRange(0, 150)
    SetSliderDialogInterval( 1 )  """
  fout.write( "  elseif a_option == " + s + "OID\n\t\tSetSliderDialogStartValue(" + s + ")\n\
    SetSliderDialogRange(0, 150)\n\
    SetSliderDialogInterval( 1 )\n" )

fout.write("\n\n")

for s in split:
  """elseif (a_option == iDistanceWeightDCLLeonOID) ;iDistanceWeightIOMEnslave
    iDistanceWeightDCLLeon = a_value as int
    SetSliderOptionValue(a_option, a_value, "{0}")"""
  fout.write("  elseif a_option == " + s + "OID\n    " + s + " = a_value as int\n\
    SetSliderOptionValue(a_option, a_value, \"{0}\")\n")

fout.write("\n\n")

for s in split:
  """elseif a_option == iEnslaveWeightSoldOID
    SetInfoText("Weight of the chance to be sold by the person who approaches you, to be a slave to someone else")"""
  fout.write("  elseif a_option == " + s + "OID\n\
    SetInfoText(\"Weight for getting TODO FINISH TOOLTIPS\")\n") 
    
fout.write("\n\n")

for s in split:
  fout.write("Int Property  " + s + " Auto\nInt " + s + "OID\n") 

