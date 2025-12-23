{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Gists
  ( Gist(..)
  , GistFile(..)
  , GistsAPI
  , gistsSwagger
  ) where

import Control.Lens
import Data.Aeson
import Data.Aeson.Types (camelTo2)
import Data.HashMap.Strict (HashMap)
import Data.Proxy
import Data.Swagger
import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)
import Servant
import Servant.Swagger

-- JSON options: snake_case + omit Nothing
jsonOpts :: Options
jsonOpts = defaultOptions
  { fieldLabelModifier = camelTo2 '_'
  , omitNothingFields  = True
  }

-- Gist File model
data GistFile = GistFile
  { filename :: Text
  , language :: Maybe Text
  , content  :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON GistFile where
  toJSON = genericToJSON jsonOpts
instance FromJSON GistFile where
  parseJSON = genericParseJSON jsonOpts
instance ToSchema GistFile

-- Gist model
data Gist = Gist
  { gistId      :: Text
  , description :: Maybe Text
  , public      :: Bool
  , files       :: HashMap Text GistFile
  , createdAt   :: UTCTime
  , updatedAt   :: UTCTime
  } deriving (Show, Eq, Generic)

instance ToJSON Gist where
  toJSON = genericToJSON jsonOpts
instance FromJSON Gist where
  parseJSON = genericParseJSON jsonOpts
instance ToSchema Gist

-- Servant API
type GistsAPI =
       "gists" :> Get '[JSON] [Gist]
  :<|> "gists" :> Capture "id" Text :> Get '[JSON] Gist

-- Swagger generation
gistsSwagger :: Swagger
gistsSwagger =
  toSwagger (Proxy :: Proxy GistsAPI)
    & info.title       .~ "Gists API"
    & info.version     .~ "1.0.0"
    & info.description ?~ "Type-safe Gists API powered by Servant and Swagger"
