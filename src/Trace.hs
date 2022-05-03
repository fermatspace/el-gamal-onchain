{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DataKinds        #-}

module Trace where

import Control.Monad.Freer.Extras as Extras
import Data.Default               (Default (..))
import Data.Functor               (void)
import Ledger.TimeSlot
import Plutus.Trace
import Wallet.Emulator.Wallet

import Offchain
import Onchain
import Elgamal

test :: IO ()
test = runEmulatorTraceIO myTrace

privKeyTest :: Integer
privKeyTest = 24461607233589665820838038485240328552889391811429595669227128265630055388250503581850040548336814509347349141982641861203912609549372675196672580283350701565308428214113433572516989845399167042038022950990211472630024552144540632133834188802718484059565230473546264239939795902289682842065679356327363375565996574108983073846684218253772442501160722536440713019542076876674488457993565341125866824595107253480920807672850731267366236591529775383536011472113406737005728149485511146498942865750093592049917731643613522277753598041482710029229779913760559299142349933527639180419097439546841781642284312374235993023053

pubKeyTest :: Integer
pubKeyTest = exponentiateMod (params_g unsafeParams) privKeyTest (params_p unsafeParams)

myTrace :: EmulatorTrace ()
myTrace = do
    h1 <- activateContractWallet (knownWallet 1) endpoints
    h2 <- activateContractWallet (knownWallet 2) endpoints
    callEndpoint @"lock" h1 pubKeyTest
    void $ waitUntilSlot 20
    callEndpoint @"unlock" h2 (pubKeyTest, privKeyTest + 0)
    s <- waitNSlots 2
    Extras.logInfo $ "reached " ++ show s

