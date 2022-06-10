{-# LANGUAGE OverloadedStrings #-}

module UIHelpers where

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
import Nostr.Profile

data ImageSize = Big | Small | Mini
  deriving (Eq)

selectableText :: WidgetEvent e => Text -> WidgetNode s e
selectableText t =
  textFieldD_ (WidgetValue t) [ readOnly ]
    `styleBasic` [ border 0 transparent, radius 0, bgColor $ rgbHex "#515151" ]

xOnlyPubKeyElem :: WidgetEvent e => XOnlyPubKey -> WidgetNode s e
xOnlyPubKeyElem xo =
  hstack
    [ label "XOnlyPubKey"
    , spacer
    , textFieldD_ (WidgetValue $ T.pack $ exportXOnlyPubKey xo) [ readOnly ]
    ]

bigLabel :: Text -> WidgetNode s e
bigLabel text =
  label text `styleBasic` [ textSize 20, textFont "Bold" ]

profileBox :: (WidgetModel s, WidgetEvent e) => XOnlyPubKey -> Text -> WidgetNode s e
profileBox xo name =
  vstack
    [ label name
    , spacer
    , (label $ shortXOnlyPubKey xo) `styleBasic` [textSize 10]
    ]

rowSepColor :: Color
rowSepColor = rgbaHex "#A9A9A9" 0.75

customDarkTheme :: Theme
customDarkTheme = darkTheme
  & L.userColorMap . at "rowBg" ?~ rgbHex "#656565"
  & L.userColorMap . at "replyBg" ?~ rgbHex "#555555"
  & L.userColorMap . at "replyFg" ?~ rgbHex "#909090"
