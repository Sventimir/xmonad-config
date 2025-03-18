import Data.Semigroup (All)
import GHC.IO.Handle.Types (Handle)
import qualified Graphics.X11.Xlib as Xlib
import qualified Graphics.X11.Xlib.Extras as Xlib.Extras
import System.IO (hPutStrLn)
import XMonad (X, XConfig(..), ManageHook, xmonad, mod4Mask,
                spawn, kill, windows, composeAll, withFocused, className,
                ask, doShift, (-->), (=?))
import qualified XMonad.Config as Cfg
import qualified XMonad.Hooks.DynamicLog as DynLog
import qualified XMonad.Hooks.ManageDocks as Docks
import qualified XMonad.Layout as Layout
import qualified XMonad.Layout.LayoutModifier as LayoutModifier
import qualified XMonad.Util.EZConfig as EZConf
import qualified XMonad.Util.Run as XMRun
import qualified XMonad.StackSet as StackSet
import XMonad.Hooks.EwmhDesktops as EWMH

import qualified Control.Keyboard as Kbd
import qualified Network.MPD as MPD
import Custom


main :: IO ()
main = do
    readEnd <- XMRun.spawnPipe "xmobar"
    xmonad $ EWMH.ewmh $ configWith readEnd

configWith :: GHC.IO.Handle.Types.Handle
           -> XConfig
           (LayoutModifier.ModifiedLayout
             Docks.AvoidStruts
             (Layout.Choose
              Layout.Tall
               (Layout.Choose
                (Layout.Mirror Layout.Tall) Layout.Full)))
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


eventHook :: Xlib.Extras.Event -> X All
eventHook = mconcat [ EWMH.fullscreenEventHook, Docks.docksEventHook, handleEventHook Cfg.def ]

logHookWith :: Handle -> X ()
logHookWith xmproc = DynLog.dynamicLogWithPP DynLog.xmobarPP {
        DynLog.ppOrder  = \(_ : _ : title) -> title,
        DynLog.ppOutput = hPutStrLn xmproc,
        DynLog.ppTitle  = DynLog.xmobarColor "green" "" . DynLog.shorten 50
    }
