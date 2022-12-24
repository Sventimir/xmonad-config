{-# LANGUAGE OverloadedStrings #-}
module Control.Screen (
  screenshot,
  screenshotOverwrite
) where

import Control.Monad (when)
import Control.Monad.IO.Class (liftIO)
import System.Environment (getEnv)
import System.Posix.Files (fileExist, removeLink)
import System.Process (callProcess)
import XMonad (X)


-- scrot adds a suffix to filename if file exists.
screenshotOverwrite :: FilePath -> [String] -> IO ()
screenshotOverwrite output scrotArgs = liftIO $ do
  home <- getEnv "HOME"
  let filename = home <> "/" <> output
  exists <- fileExist filename
  when exists $ removeLink filename
  callProcess "/usr/bin/scrot" (filename : scrotArgs)
  
screenshot :: FilePath -> [String] -> X ()
screenshot output scrotArgs = liftIO $ do
  home <- getEnv "HOME"
  let filename = home <> "/" <> output
  callProcess "/usr/bin/scrot" (filename : scrotArgs)
