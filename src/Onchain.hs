{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

{-# OPTIONS_GHC -fno-warn-unused-imports #-}

module Onchain where

import           Control.Monad        hiding (fmap)
import           Data.Aeson           (FromJSON, ToJSON)
import           Data.Map             as Map
import           Data.Text            (Text)
import           Data.Void            (Void)
import           GHC.Generics         (Generic)
import           Plutus.Contract
import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..), unless)
import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Typed.Scripts as Scripts
import           Ledger.Ada           as Ada
import           Playground.Contract  (printJson, printSchemas, ensureKnownCurrencies, stage, ToSchema)
import           Playground.TH        (mkKnownCurrencies, mkSchemaDefinitions)
import           Playground.Types     (KnownCurrency (..))
import           Prelude              (IO, Semigroup (..), String, Show)
import           Text.Printf          (printf)
import           Elgamal

data MyDatum = MyDatum
    { pubKey :: Integer
    } deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

data MyRedeemer = MyRedeemer
    { privKey :: Integer
    } deriving (Generic, FromJSON, ToJSON, ToSchema)

data Params = Params
    { params_p :: Integer
    , params_g :: Integer
    , params_bits :: Integer
    } deriving (Generic, FromJSON, ToJSON, ToSchema)

unsafeParams :: Params
unsafeParams = Params p g 64
        where
                p = safePrime64
                g = (safePrime64 - 1) `PlutusTx.Prelude.divide` 2

PlutusTx.makeIsDataIndexed ''MyDatum [('MyDatum, 0)]
PlutusTx.makeLift ''MyDatum
PlutusTx.makeIsDataIndexed ''MyRedeemer [('MyRedeemer, 0)]
PlutusTx.makeLift ''MyRedeemer
PlutusTx.makeLift ''Params

{-# INLINABLE mkValidator #-}
mkValidator :: Params -> MyDatum -> MyRedeemer -> ScriptContext -> Bool
mkValidator (Params p g _) (MyDatum pub) (MyRedeemer priv) _ = pub == exponentiateMod g priv p

data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = MyDatum
    type instance RedeemerType Typed = MyRedeemer

typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed
    ($$(PlutusTx.compile [|| mkValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode unsafeParams)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @MyDatum @MyRedeemer

validator :: Validator
validator = Scripts.validatorScript typedValidator

valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator

scrAddress :: Ledger.Address
scrAddress = scriptAddress validator
