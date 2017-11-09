{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE GADTs             #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds         #-}
{-# LANGUAGE RankNTypes        #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeInType        #-}
{-# LANGUAGE TypeOperators     #-}

module Silvi.Record
  ( rmap
  , rtraverse
  , NcsaLog
  , TestLog
  , Field(..)
  , Value(..)
  , SingField(..)
  ) where

import           Chronos.Types (OffsetDatetime (..))
import           Data.Exists   (Exists (..), Reify (..), ShowForall (..), Sing)
import           Data.Kind     (Type)
import           Data.Text     (Text)
import           GHC.Generics  (Generic)
import           Net.Types     (IPv4)
import           Silvi.Types
import           Topaz.Rec     (Rec (..), traverse)
import qualified Topaz.Rec     as Topaz

-- | Different types present in logs.
data Field
  = FieldHttpMethod          -- ^ More explicit name for Network.HTTP.Types.Method
  | FieldHttpStatus          -- ^ More explicit name for Network.HTTP.Types.Status
  | FieldHttpProtocol        -- ^ The HTTP Protocol used
  | FieldHttpProtocolVersion -- ^ More explicit name for Network.HTTP.Types.Version
  | FieldUrl                 -- ^ a url, e.g. "https://hackage.haskell.org"
  | FieldUserId              -- ^ userId as Text
  | FieldObjSize             -- ^ usually requested resource size
  | FieldIp                  -- ^ FieldIp present in log
  | FieldTimestamp           -- ^ Timestamp
  deriving (Bounded,Enum,Eq,Generic,Ord,Read,Show)

data Value :: Field -> Type where
  ValueHttpMethod :: HttpMethod -> Value 'FieldHttpMethod
  ValueHttpStatus :: HttpStatus -> Value 'FieldHttpStatus
  ValueHttpProtocol :: HttpProtocol -> Value 'FieldHttpProtocol
  ValueHttpProtocolVersion :: HttpProtocolVersion -> Value 'FieldHttpProtocolVersion
  ValueUrl :: Text -> Value 'FieldUrl
  ValueUserId :: Text -> Value 'FieldUserId
  ValueObjSize :: Int -> Value 'FieldObjSize
  ValueIp :: IPv4 -> Value 'FieldIp
  ValueTimestamp :: OffsetDatetime -> Value 'FieldTimestamp

instance ShowForall Value where
  showsPrecForall p (ValueHttpMethod x) = showParen (p > 10) $ showString "ValueHttpMethod" . showsPrec 11 x
  showsPrecForall p (ValueHttpStatus x) = showParen (p > 10) $ showString "ValueHttpStatus" . showsPrec 11 x
  showsPrecForall p (ValueHttpProtocol x) = showParen (p > 10) $ showString "ValueHttpProtocol" . showsPrec 11 x
  showsPrecForall p (ValueHttpProtocolVersion x) = showParen (p > 10) $ showString "ValueHttpProtocolVersion" . showsPrec 11 x
  showsPrecForall p (ValueUrl x) = showParen (p > 10) $ showString "ValueUrl" . showsPrec 11 x
  showsPrecForall p (ValueUserId x) = showParen (p > 10) $ showString "ValueUserId" . showsPrec 11 x
  showsPrecForall p (ValueObjSize x) = showParen (p > 10) $ showString "ValueObjSize" . showsPrec 11 x
  showsPrecForall p (ValueIp x) = showParen (p > 10) $ showString "ValueIp" . showsPrec 11 x
  showsPrecForall p (ValueTimestamp x) = showParen (p > 10) $ showString "ValueTimestamp" . showsPrec 11 x

data SingField :: Field -> Type where
  SingHttpMethod          :: SingField 'FieldHttpMethod
  SingHttpStatus          :: SingField 'FieldHttpStatus
  SingHttpProtocol        :: SingField 'FieldHttpProtocol
  SingHttpProtocolVersion :: SingField 'FieldHttpProtocolVersion
  SingUrl                 :: SingField 'FieldUrl
  SingUserId              :: SingField 'FieldUserId
  SingObjSize             :: SingField 'FieldObjSize
  SingIp                  :: SingField 'FieldIp
  SingTimestamp           :: SingField 'FieldTimestamp


type TestLog = '[ FieldIp
                , FieldTimestamp
                ]
-- | A single log entry from NCSA Common or Extended-formatted log. See:
--   http://publib.boulder.ibm.com/tividd/td/ITWSA/ITWSA_info45/en_US/HTML/guide/c-logs.html#combined
type NcsaLog = '[ FieldIp
                , FieldUserId
                , FieldTimestamp
                , FieldHttpMethod
                , FieldUrl
                , FieldHttpProtocol
                , FieldHttpProtocolVersion
                , FieldHttpStatus
                , FieldObjSize
                ]

type instance Sing = SingField
instance Reify 'FieldHttpMethod where
  reify = SingHttpMethod
instance Reify 'FieldHttpStatus where
  reify = SingHttpStatus
instance Reify 'FieldHttpProtocol where
  reify = SingHttpProtocol
instance Reify 'FieldHttpProtocolVersion where
  reify = SingHttpProtocolVersion
instance Reify 'FieldUrl where
  reify = SingUrl
instance Reify 'FieldUserId where
  reify = SingUserId
instance Reify 'FieldObjSize where
  reify = SingObjSize
instance Reify 'FieldIp where
  reify = SingIp
instance Reify 'FieldTimestamp where
  reify = SingTimestamp

-- | Alias for `Topaz.map`.
rmap :: (forall x. f x -> g x) -> Rec f as -> Rec g as
rmap = Topaz.map

-- | Alias for `Topaz.traverse`
rtraverse
  :: Applicative h
  => (forall x. f x -> h (g x))
  -> Rec f rs
  -> h (Rec g rs)
rtraverse = Topaz.traverse
