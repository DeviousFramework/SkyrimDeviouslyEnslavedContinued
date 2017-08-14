;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname PRKF_crdeContainerPerk_08043322 Extends Perk Hidden

GlobalVariable property followerSearchesContainers Auto
Keyword property DDKeyword Auto
Keyword property DDRestraintsKey Auto
Keyword property DDChastityKey Auto
Keyword Property LocTypePlayerHouse Auto
crdePlayerMonitorScript Property PlayerMon auto

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
  if akTargetRef.GetNumItems() >= 1  ; hope this limits us to chests and stuff
    actor body = akTargetRef as actor
    if body && !body.isDead()
      ; do nothing, not dead yet
      ;  follower can't find items pickpocketing other people
    elseif !body && akTargetRef.IsLocked()
      ; do nothing, todo: figure out if we can detect the object was locked previously
    else
      ; lets not count containers in the player's home
      Location current_loc = akTargetRef.GetCurrentLocation()
      if current_loc == None
        debug.Trace("[CRDE] ERR: Container check lookup: cell was NULL, leaving early ") ; how the fuck does this even happen? does it happen if we leave the cell?
        return
      elseif ! current_loc.haskeyword(LocTypePlayerHouse)
        PlayerMon.playerContainerOpenCount += 1
        if followerSearchesContainers == None
          ;debug.Trace("[CRDE] ERROR: followersearchcontainers is NONE" )
          ; this is put in in 13.9 and will stay here for a few minor versions, maybe a major versions
          ; the reason: Papyrus doesn't allow for perks to be reset by removing and readding them,
          ; we can't reinit, so that global is stuck in NONE
          followerSearchesContainers = PlayerMon.MCM.bFollowerContainerSearch
        endif
        if followerSearchesContainers != None && followerSearchesContainers.GetValueInt() == 1 
          ; user wants us to search the container for items for the follower to find
          ; search through container looking for data
          Utility.Wait(4) ; long enough for cursed loot to roll and add items I hope
          
          Form[] found = new Form[8] ; for now, max 8 items can be found per container, hard limits may be extended later
          int index = 0
          int found_index = 0
          int containerSize = akTargetRef.GetNumItems()
          int random_offset = Utility.RandomInt(0, containerSize)
          Form tmp = None
          debug.Trace("[CRDE] looking at " + containerSize +  " items ...")
          while index < containerSize && found_index < 8
            tmp = akTargetRef.GetNthForm(index + random_offset % containerSize)
            if tmp != None 
              if tmp.HasKeyword(DDKeyword) || tmp.HasKeyword(DDRestraintsKey) || tmp.HasKeyword(DDChastityKey)
                found[found_index] = tmp
                found_index += 1
              ;elseif tmp.HasKeyword(DDKeyword) ; right now they do the same thing, moving up
              ;  found[found_index] = tmp
              ;  found_index += 1
              endif
            endif
            index += 1
          endwhile
          if found_index > 0
            Debug.Trace("[CRDE] Found items:" + found_index + " in container:" + akTargetRef.GetDisplayName())
            PlayerMon.addToFollowerFoundItems(found, akTargetRef)
          endif
        endif
      endif
    endif
  endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
