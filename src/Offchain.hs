{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE DeriveAnyClass         #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE NoImplicitPrelude      #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE ScopedTypeVariables    #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeApplications       #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE TypeOperators          #-}

{-# OPTIONS_GHC -fno-warn-unused-imports #-}

module Offchain where

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

import Onchain

type MySchema =
            Endpoint "lock" Integer
        .\/ Endpoint "unlock" (Integer, Integer)

lock :: AsContractError e => Integer -> Contract w s e ()
lock n = do
    let dat = MyDatum { pubKey = n }
        tx  = Constraints.mustPayToTheScript dat $ Ada.lovelaceValueOf 10000000
    ledgerTx <- submitTxConstraints typedValidator tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
    logInfo @String $ printf "made a gift lock with El-Gamal encryption."

unlock :: forall w s e. AsContractError e => (Integer, Integer) -> Contract w s e ()
unlock (n, m) = do
      let myDatum = MyDatum { pubKey = n }
          datum = Datum { getDatum = (PlutusTx.dataToBuiltinData . PlutusTx.toData) myDatum }
          myRedeemer = MyRedeemer { privKey = m }
          redeemer = Redeemer { getRedeemer = (PlutusTx.dataToBuiltinData . PlutusTx.toData) myRedeemer }
      pkh   <- Plutus.Contract.ownPaymentPubKeyHash
      utxos <- Map.filter (isSuitable datum) <$> utxosAt scrAddress
      if Map.null utxos
        then logInfo @String $ "No locked funds available"
        else do
          let orefs = fst <$> Map.toList utxos
              lookups = Constraints.unspentOutputs utxos <> Constraints.otherScript validator
              tx :: TxConstraints Void Void
              tx = mconcat [Constraints.mustSpendScriptOutput oref redeemer | oref <- orefs] 
          ledgerTx <- submitTxConstraintsWith @Void lookups tx
          void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
          logInfo @String $ "collected funds"
    where
      isSuitable :: Datum -> ChainIndexTxOut -> Bool
      isSuitable datum o = case _ciTxOutDatum o of
            Left  i               -> i == datumHash datum 
            Right j               -> j == datum

endpoints :: Contract () MySchema Text ()
endpoints = awaitPromise (lock' `select` unlock') >> endpoints
  where
    lock'   = endpoint @"lock"   lock
    unlock' = endpoint @"unlock" unlock

mkSchemaDefinitions ''MySchema
