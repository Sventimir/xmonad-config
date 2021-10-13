import Data.Default (def)
import System.IO (hPutStrLn)
import XMonad (X, XConfig(..), ManageHook, xmonad, defaultConfig, mod4Mask,
                spawn, kill, windows, composeAll, withFocused, className,
                ask, doShift, (-->), (=?))
import XMonad.ManageHook ((<+>))
import qualified XMonad.Hooks.DynamicLog as DynLog
import qualified XMonad.Hooks.ManageDocks as Docks
import qualified XMonad.Util.EZConfig as EZConf
import qualified XMonad.Util.Run as XMRun
import qualified XMonad.StackSet as StackSet
import XMonad.Hooks.EwmhDesktops as EWMH

import qualified Control.Keyboard as Kbd
import qualified Network.MPD as MPD
import Control.MPD
import Control.Zoom


terminalCmd = "alacritty -e /usr/bin/tmux"

main = do
    readEnd <- XMRun.spawnPipe "xmobar"
    xmonad $ EWMH.ewmh $ configWith readEnd

configWith xmproc = defaultConfig {
            modMask     = mod4Mask,      -- Win as mod-key
            terminal    = terminalCmd,
            workspaces  = workspaceNames,
            layoutHook  = Docks.avoidStruts $ layoutHook defaultConfig,
            handleEventHook = eventHook,
            manageHook  = myManageHook,
            logHook     = logHookWith xmproc,
            startupHook = startup
        } `EZConf.additionalKeysP` [
            ("M-C-l", spawn "xscreensaver-command -lock"),
            ("M-C-d", kill),
            ("M-s", withFocused $ windows . StackSet.sink),
            ("M-z", launchZoom),
            ("M-l", Kbd.selectLayout),
            ("<XF86AudioPrev>", withMPD MPD.previous),
            ("<XF86AudioNext>", withMPD MPD.next),
            ("<XF86AudioPlay>", withMPD mpdPlay),
            ("<XF86AudioStop>", withMPD MPD.stop)
        ]

workspaceNames = ["terminal", "browser", "editor", "communicator", "steam", "messanger"] ++
            zipWith (++) (repeat "stuff") (map show [1..4])

eventHook = mconcat [ EWMH.fullscreenEventHook, Docks.docksEventHook, handleEventHook defaultConfig ]

startup = do
    spawn terminalCmd
    spawn "qutebrowser"
    spawn "/home/sven/code/bash/emacsclient-startup.sh" -- make sure to wait until service is ready.
    spawn "discord --start-minimized"
    spawn "slack"
    spawn "caprine"

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

logHookWith xmproc = DynLog.dynamicLogWithPP DynLog.xmobarPP {
        DynLog.ppOrder  = \(_ : _ : title) -> title,
        DynLog.ppOutput = hPutStrLn xmproc,
        DynLog.ppTitle  = DynLog.xmobarColor "green" "" . DynLog.shorten 50
    }
