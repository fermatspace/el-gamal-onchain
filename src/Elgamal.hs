{-# LANGUAGE NoImplicitPrelude #-}

module Elgamal where

import PlutusTx.Prelude as Plutus
import PlutusTx 
import Prelude          as Prelude

-- | A 2048 bit safe prime generated via generateSafePrime in the Crypto.Number.Prime module of the cryptonite package
safePrime2048 :: Integer
safePrime2048 = 26006645102793338807810923612989518151059133495728528399856510483777587007725527731951314116559668014818408287975263610058208931047892984153732691376729763098774953813179394604392969194221987615757898295861427793216864423559379795549846279654373675127301030359938889707141315250209058067316369812482516816670530958133285155932461418550596015726080901922506759608859148980083036852159637160987343168023134537117474143592314732823789956937931848225695975318787212025703794117780049327954942307756693745501145692227764358472601348237313084601085592846113941365237097934286083838276351628649508719697565238352288988335987

{-# INLINABLE exponentiate #-}
exponentiate :: Integer -> Integer -> Integer
exponentiate x n
    | n Plutus.== 0      = 1
    | x Plutus.== 0      = 0
    | Plutus.even n      = (exponentiate x (n `divide` 2)) Plutus.* (exponentiate x (n `divide` 2))
    | otherwise   = x Plutus.* (exponentiate x ((n Plutus.- 1) `divide` 2)) Plutus.* (exponentiate x ((n Plutus.- 1) `divide` 2))

{-# INLINABLE exponentiateMod #-}
exponentiateMod :: Integer -> Integer -> Integer -> Integer
exponentiateMod b e m
    | b Plutus.== 1    = b
    | e Plutus.== 0    = 1
    | e Plutus.== 1    = b `Plutus.modulo` m
    | Plutus.even e    = let p = exponentiateMod b (e `divide` 2) m `modulo` m
                   in (exponentiate p 2) `modulo` m
    | otherwise = (b Plutus.* exponentiateMod b (e Plutus.- 1) m) `modulo` m
