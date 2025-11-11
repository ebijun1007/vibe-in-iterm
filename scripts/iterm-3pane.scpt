on run argv
  set workdir to item 1 of argv

  tell application "iTerm"
    -- keep current window, just add a new tab
    set theWindow to current window
    tell theWindow
      create tab with default profile
      set theTab to current tab
    end tell

    -- first session in the new tab
    tell current session of theTab
      -- set a flag so .envrc doesn't run again in this tab
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir
      -- split into left and right
      set leftPane to it
      set rightPane to (split vertically with default profile)
    end tell

    -- split the right pane into 3 sections (top, middle, bottom)
    tell rightPane
      set topRight to it
      set middleBottomPane to (split horizontally with default profile)
    end tell

    tell middleBottomPane
      set middleRight to it
      set bottomRight to (split horizontally with default profile)
    end tell

    -- left pane: watch todo.md (create if not exists)
    tell leftPane
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; [ ! -f todo.md ] && touch todo.md; while true; do clear; cat todo.md; sleep 1; done"
    end tell

    -- top-right: run codex
    tell topRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; codex"
    end tell

    -- middle-right: run claude with --dangerously-skip-permissions
    tell middleRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; claude --dangerously-skip-permissions"
    end tell

    -- bottom-right: just cd into the repo and stay there
    tell bottomRight
      write text "export ITERM_LAYOUT_DONE=1; cd " & workdir
    end tell
  end tell
end run
