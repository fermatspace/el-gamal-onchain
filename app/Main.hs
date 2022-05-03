module Main where

{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeApplications           #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}

import           Prelude
import           System.Environment

import           Cardano.Api
import qualified Plutus.V1.Ledger.Api as Plutus
import           Data.Aeson (encode)
import qualified Data.ByteString.Short as SBS
import qualified Data.ByteString.Lazy  as LBS
import qualified Data.ByteString as B
import qualified Data.Text as T
import qualified Data.Map as Map
import qualified Data.Set as Set
import Numeric (showHex)
import GHC.Generics
import           Cardano.Api.Shelley   (PlutusScript (..), fromPlutusData)
import           Codec.Serialise       (serialise)
import           PlutusTx              (Data (..))
import qualified PlutusTx
import qualified Ledger

import Utils
import Onchain
import Elgamal
import Trace

--main :: IO (Either (FileError ()) ())
--main = writeValidator "temp/script.plutus" $ validator

main :: IO ()
main = do
--    print $ testDatum
--    writeJSON "temp/datum.json" testDatum
--    writeJSON "temp/redeemer.json" testRedeemer
    test
