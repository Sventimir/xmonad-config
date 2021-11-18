module Control.Keyboard (
  selectLayout
) where

import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import XMonad (X)
import XMonad.Util.Dmenu (dmenuMap, menuArgs)
import XMonad.Util.Run (safeSpawn)
import Util.Maybe (whenJust)


layouts :: Map String [String]
layouts = Map.fromList [
    ("polish",        ["-layout", "pl"]),
    ("international", ["-layout", "us", "-variant", "altgr-intl"])
  ]

selectLayout :: X ()
selectLayout = do
  layout <- dmenuMap layouts
  whenJust layout (safeSpawn "/usr/bin/setxkbmap" . (["-model", "pc104"] ++))
