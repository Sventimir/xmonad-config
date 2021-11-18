module Control.Zoom (
  launchZoom
) where

import qualified Data.Map as Map
import System.FilePath.Posix ((</>))
import System.Posix.User (UserEntry(..), getRealUserID, getUserEntryForID)
import XMonad (X, liftIO)
import XMonad.Util.Dmenu (dmenuMap)
import XMonad.Util.Run (safeSpawn)
import Util.Maybe (whenJust)


launchZoom :: X ()
launchZoom = do
  meetings <- fmap meetingsMap . liftIO $ do
    userId <- getRealUserID
    UserEntry { homeDirectory = home } <- getUserEntryForID userId
    readFile (home </> ".config" </> "zoom-meetings.conf")
  selection <- dmenuMap meetings
  whenJust selection (safeSpawn "usr/bin/xdg-open" . (: []))


meetingsMap :: String -> Map.Map String String
meetingsMap = Map.fromList . map (mkPair . words) . lines
  where
  mkPair [] = ("<empty>", "")
  mkPair [x] = (x, x)
  mkPair (x : y : _) = (x, y)
