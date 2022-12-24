import System.IO (hPutStrLn)
import XMonad (X, XConfig(..), ManageHook, xmonad, mod4Mask,
                spawn, kill, windows, composeAll, withFocused, className,
                ask, doShift, (-->), (=?))
import qualified XMonad.Config as Cfg
import qualified XMonad.Hooks.DynamicLog as DynLog
import qualified XMonad.Hooks.ManageDocks as Docks
import qualified XMonad.Util.EZConfig as EZConf
import qualified XMonad.Util.Run as XMRun
import qualified XMonad.StackSet as StackSet
import XMonad.Hooks.EwmhDesktops as EWMH

import qualified Control.Keyboard as Kbd
import qualified Network.MPD as MPD
import Custom


main = do
    readEnd <- XMRun.spawnPipe "xmobar"
    xmonad $ EWMH.ewmh $ configWith readEnd

configWith xmproc = Cfg.def {
            modMask     = mod4Mask,      -- Win as mod-key
            terminal    = terminalCmd,
            workspaces  = workspaceNames,
            layoutHook  = Docks.avoidStruts $ layoutHook Cfg.def,
            handleEventHook = eventHook,
            manageHook  = myManageHook,
            logHook     = logHookWith xmproc,
            startupHook = startup
        } `EZConf.additionalKeysP` keyBindings

eventHook = mconcat [ EWMH.fullscreenEventHook, Docks.docksEventHook, handleEventHook Cfg.def ]

logHookWith xmproc = DynLog.dynamicLogWithPP DynLog.xmobarPP {
        DynLog.ppOrder  = \(_ : _ : title) -> title,
        DynLog.ppOutput = hPutStrLn xmproc,
        DynLog.ppTitle  = DynLog.xmobarColor "green" "" . DynLog.shorten 50
    }
