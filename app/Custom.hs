{-# LANGUAGE OverloadedStrings #-}
module Custom where

import Control.MPD
import Control.Screen (screenshotOverwrite)
import Data.Default (def)
import qualified Control.Keyboard as Kbd
import qualified Network.MPD as MPD
import XMonad (X, XConfig(..), spawn, windows, composeAll, withFocused,
               className, doShift, (-->), (=?))
import qualified XMonad.Hooks.ManageDocks as Docks
import XMonad.ManageHook ((<+>))
import qualified XMonad.StackSet as StackSet


terminalCmd = "alacritty -e /usr/bin/tmux"

screenShotFile = "data/img/screen.png"

keyBindings = [
            ("M-C-l", spawn "xscreensaver-command -lock"),
            ("M-C-p", spawn "passmenu"),
            ("M-s", withFocused $ windows . StackSet.sink),
            ("M-l", Kbd.selectLayout),
            -- ("<F12>", screenshotOverwrite screenShotFile ["-s"]),
            -- ("C-<F12>", screenshotOverwrite screenShotFile []),
            ("<XF86AudioPrev>", withMPD MPD.previous),
            ("<XF86AudioNext>", withMPD MPD.next),
            ("<XF86AudioPlay>", withMPD mpdPlay),
            ("<XF86AudioStop>", withMPD MPD.stop)
        ]

startup :: X ()
startup = do
    spawn terminalCmd
    spawn "nyxt"
    spawn "/home/sven/code/bash/emacsclient-startup.sh" -- make sure to wait until service is ready.
    spawn "discord --start-minimized"
    spawn "slack"
    spawn "caprine"

workspaceNames = ["terminal", "browser", "editor", "communicator", "steam", "messanger"] ++
            zipWith (++) (repeat "stuff") (map show [1..4])

myManageHook = manageHook def <+> composeAll [
        Docks.manageDocks,
        className =? "Termite"      --> doShift "termite",
        className =? "nyxt"  --> doShift "browser",
        className =? "discord"      --> doShift "communicator",
        className =? "Slack"        --> doShift "communicator",
        className =? "Caprine"      --> doShift "messanger",
        className =? "Atom"         --> doShift "editor",
        className =? "Steam"        --> doShift "steam",
        className =? "Emacs"        --> doShift "editor"
    ]
