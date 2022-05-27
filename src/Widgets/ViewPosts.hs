{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Widgets.ViewPosts where

import           Control.Lens
import           Crypto.Schnorr
import           Data.DateTime
import           Data.Default
import qualified Data.Map               as Map
import           Data.Text              (Text, strip)
import qualified Data.Text              as T
import           Monomer
import qualified Monomer.Lens           as L

import Helpers
import NostrTypes
import UIHelpers

data ViewPostsModel = ViewPostsModel
  { _time             :: DateTime
  , _profiles         :: Map.Map XOnlyPubKey Profile
  , _receivedEvents   :: [ReceivedEvent]
  } deriving (Eq, Show)

instance Default ViewPostsModel where
  def = ViewPostsModel (fromSeconds 0) Map.empty []

makeLenses 'ViewPostsModel

viewPostsWidget
  :: (WidgetModel sp, WidgetEvent ep)
  => WidgetEnv sp ep
  -> ALens' sp ViewPostsModel
  -> (ReceivedEvent -> Bool)
  -> (ReceivedEvent -> ep)
  -> (XOnlyPubKey -> ep)
  -> WidgetNode sp ep
viewPostsWidget wenv model eventFilter viewDetailsAction viewProfileAction =
  composite "ViewPostsWidget" model (viewPosts eventFilter viewDetailsAction viewProfileAction) (\_ _ _ e -> [Report e])

viewPosts
  :: (WidgetModel s, WidgetEvent e)
  => (ReceivedEvent -> Bool)
  -> (ReceivedEvent -> e)
  -> (XOnlyPubKey -> e)
  -> WidgetEnv s e
  -> ViewPostsModel
  -> WidgetNode s e
viewPosts eventFilter viewDetailsAction viewProfileAction wenv model =
    vscroll_ [ scrollOverlay ] posts
  where
    posts = vstack postRows
    filteredEvents = filter eventFilter (model ^. receivedEvents)
    postFade idx ev = animRow
      where
        item = postRow wenv (model ^. profiles) idx ev (model ^. time) viewDetailsAction viewProfileAction
        animRow =
          animFadeOut_ [] item `nodeKey` (content $ fst ev)
    postRows = zipWith postFade [ 0 .. ] filteredEvents

postRow
  :: (WidgetModel s, WidgetEvent e)
  => WidgetEnv s e
  -> Map.Map XOnlyPubKey Profile
  -> Int
  -> ReceivedEvent
  -> DateTime
  -> (ReceivedEvent -> e)
  -> (XOnlyPubKey -> e)
  -> WidgetNode s e
postRow wenv m idx re time viewDetailsAction viewProfileAction = row
  where
    event = fst re
    xo = NostrTypes.pubKey event
    rowBg = wenv ^. L.theme . L.userColorMap . at "rowBg" . non def
    profileBox =
      vstack
        [ label $ profileName m xo
        , spacer
        , (label $ shortXOnlyPubKey xo) `styleBasic` [textSize 10]
        ]
    row =
      vstack
        [ hstack
            [ filler
            , (label $ xTimeAgo (created_at event) time)
                `styleBasic` [ textSize 10 ]
            ]
        , hstack
            [ box_ [ onClick (viewProfileAction xo) ] profileBox
                `styleBasic` [ cursorHand ]
            , spacer
            , label_ (content event) [ multiline, ellipsis ]
            , filler
            , vstack
                [ filler
                , button "Details" $ viewDetailsAction re
                , filler
                ]
            ]
        ] `styleBasic` [ paddingT 10, paddingB 10, paddingR 20, borderB 1 rowSepColor ]
