{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Nostr.RelayPool where

import Control.Concurrent.MVar
import Control.Concurrent.STM.TChan
import Control.Monad.STM (atomically)
import Crypto.Random.DRBG (CtrDRBG, genBytes, newGen, newGenIO)
import Data.Default
import Data.Map (Map)
import Data.Text (Text)
import Data.Typeable (Typeable)
import Monomer
import Wuss

import qualified Data.ByteString.Base16 as B16
import qualified Data.Map as Map
import qualified Text.URI.QQ as QQ

import Nostr.Event
import Nostr.Filter
import Nostr.Relay
import Nostr.Request
import Nostr.Response

data RelayPool = RelayPool [Relay] (Map SubscriptionId (TChan Response))

instance Default RelayPool where
  def =
    RelayPool
      [
      --   Relay
      --   { host = "nostr-pub.wellorder.net"
      --   , port = 443
      --   , secure = True
      --   , readable = True
      --   , writable = True
      --   , connected = False
      --   }
      -- ,
        Relay
        { uri = [QQ.uri|ws://localhost:2700|]
        , info = RelayInfo True True
        , connected = False
        }
      ]
      Map.empty

registerResponseChannel :: MVar RelayPool -> SubscriptionId -> TChan Response -> IO ()
registerResponseChannel poolMVar subId responseChannel = do
  (RelayPool relays responseChannels) <- takeMVar poolMVar
  let responseChannels' = Map.insert subId responseChannel responseChannels
  putMVar poolMVar (RelayPool relays responseChannels')

removeResponseChannel :: MVar RelayPool -> SubscriptionId -> IO ()
removeResponseChannel poolMVar subId = do
  (RelayPool relays responseChannels) <- takeMVar poolMVar
  let responseChannels' = Map.delete subId responseChannels
  putMVar poolMVar (RelayPool relays responseChannels')

addRelay :: MVar RelayPool -> Relay -> IO ()
addRelay poolMVar relay = do
  (RelayPool relays responseChannels) <- takeMVar poolMVar
  let relays' = relay : (filter (\r -> r `sameRelay` relay) relays)
  putMVar poolMVar (RelayPool relays' responseChannels)

removeRelay :: MVar RelayPool -> Relay -> IO ()
removeRelay poolMVar relay = do
  (RelayPool relays responseChannels) <- takeMVar poolMVar
  let relays' = (filter (\r -> r `sameRelay` relay) relays)
  putMVar poolMVar (RelayPool relays' responseChannels)

subscribe :: MVar RelayPool -> TChan Request -> [Filter] -> TChan Response -> IO SubscriptionId
subscribe poolMVar input filters responseChannel = do
  gen <- newGenIO :: IO CtrDRBG
  let Right (randomBytes, newGen) = genBytes 16 gen
  let subId = B16.encodeBase16 randomBytes
  registerResponseChannel poolMVar subId responseChannel
  send input $ Subscribe $ Subscription filters subId
  return subId

unsubscribe :: MVar RelayPool -> TChan Request -> SubscriptionId -> IO ()
unsubscribe poolMVar channel subId = do
  send channel $ Close subId
  removeResponseChannel poolMVar subId

send :: TChan Request -> Request -> IO ()
send channel request =
  atomically $ writeTChan channel $ request
