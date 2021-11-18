module Control.MPD (
  withMPD,
  mpdPlay
) where

import Control.Monad.IO.Class (liftIO)
import qualified Network.MPD as MPD
import Network.MPD (MPD, Status(..), PlaybackState(..), status, play,
                    toggle, stop)
import XMonad (X)


withMPD :: MPD () -> X ()
withMPD mpdAction = liftIO (MPD.withMPD mpdAction >> return ())

mpdPlay :: MPD ()
mpdPlay = do
  s <- status
  case stState s of
    Stopped -> play Nothing
    _ -> toggle

