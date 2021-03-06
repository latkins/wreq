{-# LANGUAGE RecordWildCards #-}

module Network.Wreq.Session
    (
      Session
    , withSession
    -- * HTTP verbs
    , get
    , post
    , head_
    , options
    , put
    , delete
    -- ** Configurable verbs
    , getWith
    , postWith
    , headWith
    , optionsWith
    , putWith
    , deleteWith
    ) where

import Control.Concurrent.MVar (MVar, modifyMVar, newMVar)
import Control.Lens ((&), (.~), (^.))
import Network.Wreq (Options, Response, defaults)
import Network.Wreq.Internal (defaultManagerSettings)
import Network.Wreq.Types (Postable, Putable)
import Prelude hiding (head)
import qualified Data.ByteString.Lazy as L
import qualified Network.HTTP.Client as HTTP
import qualified Network.Wreq as Wreq

data Session = Session {
      seshCookies :: MVar HTTP.CookieJar
    , seshManager :: HTTP.Manager
    }

instance Show Session where
    show _ = "Session"

withSession :: (Session -> IO a) -> IO a
withSession act = do
  mv <- newMVar $ HTTP.createCookieJar []
  HTTP.withManager defaultManagerSettings $ \mgr ->
    act Session { seshCookies = mv, seshManager = mgr }

get :: Session -> String -> IO (Response L.ByteString)
get = getWith defaults

post :: Postable a => Session -> String -> a -> IO (Response L.ByteString)
post = postWith defaults

head_ :: Session -> String -> IO (Response ())
head_ = headWith defaults

options :: Session -> String -> IO (Response ())
options = optionsWith defaults

put :: Putable a => Session -> String -> a -> IO (Response L.ByteString)
put = putWith defaults

delete :: Session -> String -> IO (Response ())
delete = deleteWith defaults

getWith :: Options -> Session -> String -> IO (Response L.ByteString)
getWith opts sesh url =
  override opts sesh $ \opts' -> Wreq.getWith opts' url

postWith :: Postable a => Options -> Session -> String -> a
         -> IO (Response L.ByteString)
postWith opts sesh url payload =
  override opts sesh $ \opts' -> Wreq.postWith opts' url payload

headWith :: Options -> Session -> String -> IO (Response ())
headWith opts sesh url =
  override opts sesh $ \opts' -> Wreq.headWith opts' url

optionsWith :: Options -> Session -> String -> IO (Response ())
optionsWith opts sesh url =
  override opts sesh $ \opts' -> Wreq.optionsWith opts' url

putWith :: Putable a => Options -> Session -> String -> a
        -> IO (Response L.ByteString)
putWith opts sesh url payload =
  override opts sesh $ \opts' -> Wreq.putWith opts' url payload

deleteWith :: Options -> Session -> String -> IO (Response ())
deleteWith opts sesh url =
  override opts sesh $ \opts' -> Wreq.deleteWith opts' url

override :: Options -> Session -> (Options -> IO (Response body))
         -> IO (Response body)
override opts Session{..} act =
  modifyMVar seshCookies $ \cj -> do
    resp <- act $ opts & Wreq.cookies .~ cj &
                         Wreq.manager .~ Right seshManager
    return (resp ^. Wreq.responseCookieJar, resp)
