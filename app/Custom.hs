module Custom where

import Control.MPD
import Data.Default (def)
import qualified Network.MPD as MPD
import qualified Control.Keyboard as Kbd
import XMonad (X, XConfig(..), ManageHook, xmonad, defaultConfig, mod4Mask,
                spawn, kill, windows, composeAll, withFocused, className,
                ask, doShift, (-->), (=?))
import qualified XMonad.Config as Cfg
import qualified XMonad.Hooks.ManageDocks as Docks
import XMonad.ManageHook ((<+>))
import qualified XMonad.StackSet as StackSet


terminalCmd = "alacritty -e /usr/bin/tmux"

keyBindings = [
            ("M-C-l", spawn "xscreensaver-command -lock"),
            ("M-C-p", spawn "passmenu"),
            ("M-s", withFocused $ windows . StackSet.sink),
            ("M-l", Kbd.selectLayout),
            ("<XF86AudioPrev>", withMPD MPD.previous),
            ("<XF86AudioNext>", withMPD MPD.next),
            ("<XF86AudioPlay>", withMPD mpdPlay),
            ("<XF86AudioStop>", withMPD MPD.stop)
        ]

startup :: X ()
startup = do
    spawn terminalCmd
    spawn "qutebrowser"
    spawn "/home/sven/code/bash/emacsclient-startup.sh" -- make sure to wait until service is ready.
    spawn "discord --start-minimized"
    spawn "slack"
    spawn "caprine"

workspaceNames = ["terminal", "browser", "editor", "communicator", "steam", "messanger"] ++
            zipWith (++) (repeat "stuff") (map show [1..4])

myManageHook = manageHook def <+> composeAll [
        Docks.manageDocks,
        className =? "Termite"      --> doShift "termite",
        className =? "qutebrowser"  --> doShift "browser",
        className =? "discord"      --> doShift "communicator",
        className =? "Slack"        --> doShift "communicator",
        className =? "caprine"      --> doShift "messanger",
        className =? "Atom"         --> doShift "editor",
        className =? "Steam"        --> doShift "steam",
        className =? "Emacs"        --> doShift "editor"
    ]
