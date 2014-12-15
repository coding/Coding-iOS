//
//  NSString+FontAwesome.h
//
//  Copyright (c) 2012 Alex Usbergo. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//

#import <Foundation/Foundation.h>

static NSString *const kFontAwesomeFamilyName = @"FontAwesome";

/**
 @abstract FontAwesome Icons.
 */
typedef NS_ENUM(NSInteger, FAIcon) {
    
    /**
     @abstract Glass.
     @discussion id: glass, unicode: f000, created: 1.0
     */
    FAIconGlass,
    
    /**
     @abstract Music.
     @discussion id: music, unicode: f001, created: 1.0
     */
    FAIconMusic,
    
    /**
     @abstract Search.
     @discussion id: search, unicode: f002, created: 1.0
     */
    FAIconSearch,
    
    /**
     @abstract Envelope Alt.
     @discussion id: envelope-alt, unicode: f003, created: 1.0.
     */
    FAIconEnvelopeAlt,
    
    /**
     @abstract Heart.
     @discussion id: heart, unicode: f004, created: 1.0
     */
    FAIconHeart,
    
    /**
     @abstract  Star
     @discussion id: star, unicode: f005, created: 1.0.
     */
    FAIconStar,
    
    /**
     @abstract  Star Empty
     @discussion id: star-empty, unicode: f006, created: 1.0.
     */
    FAIconStarEmpty,
    
    /**
     @abstract  User
     @discussion id: user, unicode: f007, created: 1.0.
     */
    FAIconUser,
    
    /**
     @abstract  Film
     @discussion id: film, unicode: f008, created: 1.0.
     */
    FAIconFilm,
    
    /**
     @abstract  th-large
     @discussion id: th-large, unicode: f009, created: 1.0.
     */
    FAIconThLarge,
    
    /**
     @abstract  th
     @discussion id: th, unicode: f00a, created: 1.0.
     */
    FAIconTh,
    
    /**
     @abstract  th-list
     @discussion id: th-list, unicode: f00b, created: 1.0.
     */
    FAIconThList,
    
    /**
     @abstract  OK
     @discussion id: ok, unicode: f00c, created: 1.0.
     */
    FAIconOk,
    
    /**
     @abstract  Remove
     @discussion id: remove, unicode: f00d, created: 1.0.
     */
    FAIconRemove,
    
    /**
     @abstract  Zoom In
     @discussion id: zoom-in, unicode: f00e, created: 1.0.
     */
    FAIconZoomIn,
    
    /**
     @abstract  Zoom Out
     @discussion id: zoom-out, unicode: f010, created: 1.0.
     */
    FAIconZoomOut,
    
    /**
     @abstract  Off
     @discussion id: off, unicode: f011, created: 1.0.
     */
    FAIconOff,
    
    /**
     @abstract  Power Off
     @discussion id: power-off, unicode: f011, created: 1.0.
     */
    FAIconPowerOff,
    
    /**
     @abstract  signal
     @discussion id: signal, unicode: f012, created: 1.0.
     */
    FAIconSignal,
    
    /**
     @abstract  cog
     @discussion id: cog, unicode: f013, created: 1.0.
     */
    FAIconCog,
    
    /**
     @abstract  Gear
     @discussion id: Gear, unicode: f013, created: 1.0.
     */
    FAIconGear,
    
    /**
     @abstract  trash
     @discussion id: trash, unicode: f014, created: 1.0.
     */
    FAIconTrash,
    
    /**
     @abstract  home
     @discussion id: home, unicode: f015, created: 1.0.
     */
    FAIconHome,
    
    /**
     @abstract  file-alt
     @discussion id: file-alt, unicode: f016, created: 1.0.
     */
    FAIconFileAlt,
    
    /**
     @abstract  time
     @discussion id: time, unicode: f017, created: 1.0.
     */
    FAIconTime,
    
    /**
     @abstract  road
     @discussion id: road, unicode: f018, created: 1.0.
     */
    FAIconRoad,
    
    /**
     @abstract  download-alt
     @discussion id: download-alt, unicode: f019, created: 1.0.
     */
    FAIconDownloadAlt,
    
    /**
     @abstract  download
     @discussion id: download, unicode: f01a, created: 1.0.
     */
    FAIconDownload,
    
    /**
     @abstract  upload
     @discussion id: upload, unicode: f01b, created: 1.0.
     */
    FAIconUpload,
    
    /**
     @abstract  inbox
     @discussion id: inbox, unicode: f01c, created: 1.0.
     */
    FAIconInbox,
    
    /**
     @abstract  play-circle
     @discussion id: play-circle, unicode: f01d, created: 1.0.
     */
    FAIconPlayCircle,
    
    /**
     @abstract  repeat
     @discussion id: repeat, unicode: f01e, created: 1.0.
     */
    FAIconRepeat,
    
    /**
     @abstract  Rotate Right
     @discussion id: rotate-right, unicode: f01e, created: 1.0.
     */
    FAIconRotateRight,
    
    /**
     @abstract  Refresh
     @discussion id: refresh, unicode: f021, created: 1.0.
     */
    FAIconRefresh,
    
    /**
     @abstract  list-alt
     @discussion id: list-alt, unicode: f022, created: 1.0.
     */
    FAIconListAlt,
    
    /**
     @abstract  lock
     @discussion id: lock, unicode: f023, created: 1.0.
     */
    FAIconLock,
    
    /**
     @abstract  flag
     @discussion id: flag, unicode: f024, created: 1.0.
     */
    FAIconFlag,
    
    /**
     @abstract  headphones
     @discussion id: headphones, unicode: f025, created: 1.0.
     */
    FAIconHeadphones,
    
    /**
     @abstract  volume-off
     @discussion id: volume-off, unicode: f026, created: 1.0.
     */
    FAIconVolumeOff,
    
    /**
     @abstract  volume-down
     @discussion id: volume-down, unicode: f027, created: 1.0.
     */
    FAIconVolumeDown,
    
    /**
     @abstract  volume-up
     @discussion id: volume-up, unicode: f028, created: 1.0.
     */
    FAIconVolumeUp,
    
    /**
     @abstract  qrcode
     @discussion id: qrcode, unicode: f029, created: 1.0.
     */
    FAIconQrcode,
    
    /**
     @abstract  barcode
     @discussion id: barcode, unicode: f02a, created: 1.0.
     */
    FAIconBarcode,
    
    /**
     @abstract  tag
     @discussion id: tag, unicode: f02b, created: 1.0.
     */
    FAIconTag,
    
    /**
     @abstract  tags
     @discussion id: tags, unicode: f02c, created: 1.0.
     */
    FAIconTags,
    
    /**
     @abstract  book
     @discussion id: book, unicode: f02d, created: 1.0.
     */
    FAIconBook,
    
    /**
     @abstract  bookmark
     @discussion id: bookmark, unicode: f02e, created: 1.0.
     */
    FAIconBookmark,
    
    /**
     @abstract  print
     @discussion id: print, unicode: f02f, created: 1.0.
     */
    FAIconPrint,
    
    /**
     @abstract  camera
     @discussion id: camera, unicode: f030, created: 1.0.
     */
    FAIconCamera,
    
    /**
     @abstract  font
     @discussion id: font, unicode: f031, created: 1.0.
     */
    FAIconFont,
    
    /**
     @abstract  bold
     @discussion id: bold, unicode: f032, created: 1.0.
     */
    FAIconBold,
    
    /**
     @abstract  italic
     @discussion id: italic, unicode: f033, created: 1.0.
     */
    FAIconItalic,
    
    /**
     @abstract  text-height
     @discussion id: text-height, unicode: f034, created: 1.0.
     */
    FAIconTextHeight,
    
    /**
     @abstract  text-width
     @discussion id: text-width, unicode: f035, created: 1.0.
     */
    FAIconTextWidth,
    
    /**
     @abstract  align-left
     @discussion id: align-left, unicode: f036, created: 1.0.
     */
    FAIconAlignLeft,
    
    /**
     @abstract  align-center
     @discussion id: align-center, unicode: f037, created: 1.0.
     */
    FAIconAlignCenter,
    
    /**
     @abstract  align-right
     @discussion id: align-right, unicode: f038, created: 1.0.
     */
    FAIconAlignRight,
    
    /**
     @abstract  align-justify
     @discussion id: align-justify, unicode: f039, created: 1.0.
     */
    FAIconAlignJustify,
    
    /**
     @abstract  list
     @discussion id: list, unicode: f03a, created: 1.0.
     */
    FAIconList,
    
    /**
     @abstract  indent-left
     @discussion id: indent-left, unicode: f03b, created: 1.0.
     */
    FAIconIndentLeft,
    
    /**
     @abstract  indent-right
     @discussion id: indent-right, unicode: f03c, created: 1.0.
     */
    FAIconIndentRight,
    
    /**
     @abstract  facetime-video
     @discussion id: facetime-video, unicode: f03d, created: 1.0.
     */
    FAIconFacetimeVideo,
    
    /**
     @abstract  picture
     @discussion id: picture, unicode: f03e, created: 1.0.
     */
    FAIconPicture,
    
    /**
     @abstract  pencil
     @discussion id: pencil, unicode: f040, created: 1.0.
     */
    FAIconPencil,
    
    /**
     @abstract  map-marker
     @discussion id: map-marker, unicode: f041, created: 1.0.
     */
    FAIconMapMarker,
    
    /**
     @abstract  adjust
     @discussion id: adjust, unicode: f042, created: 1.0.
     */
    FAIconAdjust,
    
    /**
     @abstract  tint
     @discussion id: tint, unicode: f043, created: 1.0.
     */
    FAIconTint,
    
    /**
     @abstract  edit
     @discussion id: edit, unicode: f044, created: 1.0.
     */
    FAIconEdit,
    
    /**
     @abstract  share
     @discussion id: share, unicode: f045, created: 1.0.
     */
    FAIconShare,
    
    /**
     @abstract  check
     @discussion id: check, unicode: f046, created: 1.0.
     */
    FAIconCheck,
    
    /**
     @abstract  move
     @discussion id: move, unicode: f047, created: 1.0.
     */
    FAIconMove,
    
    /**
     @abstract  step-backward
     @discussion id: step-backward, unicode: f048, created: 1.0.
     */
    FAIconStepBackward,
    
    /**
     @abstract  fast-backward
     @discussion id: fast-backward, unicode: f049, created: 1.0.
     */
    FAIconFastBackward,
    
    /**
     @abstract  backward
     @discussion id: backward, unicode: f04a, created: 1.0.
     */
    FAIconBackward,
    
    /**
     @abstract  play
     @discussion id: play, unicode: f04b, created: 1.0.
     */
    FAIconPlay,
    
    /**
     @abstract  pause
     @discussion id: pause, unicode: f04c, created: 1.0.
     */
    FAIconPause,
    
    /**
     @abstract  stop
     @discussion id: stop, unicode: f04d, created: 1.0.
     */
    FAIconStop,
    
    /**
     @abstract  forward
     @discussion id: forward, unicode: f04e, created: 1.0.
     */
    FAIconForward,
    
    /**
     @abstract  fast-forward
     @discussion id: fast-forward, unicode: f050, created: 1.0.
     */
    FAIconFastForward,
    
    /**
     @abstract  step-forward
     @discussion id: step-forward, unicode: f051, created: 1.0.
     */
    FAIconStepForward,
    
    /**
     @abstract  eject
     @discussion id: eject, unicode: f052, created: 1.0.
     */
    FAIconEject,
    
    /**
     @abstract  chevron-left
     @discussion id: chevron-left, unicode: f053, created: 1.0.
     */
    FAIconChevronLeft,
    
    /**
     @abstract  chevron-right
     @discussion id: chevron-right, unicode: f054, created: 1.0.
     */
    FAIconChevronRight,
    
    /**
     @abstract  plus-sign
     @discussion id: plus-sign, unicode: f055, created: 1.0.
     */
    FAIconPlusSign,
    
    /**
     @abstract  minus-sign
     @discussion id: minus-sign, unicode: f056, created: 1.0.
     */
    FAIconMinusSign,
    
    /**
     @abstract  remove-sign
     @discussion id: remove-sign, unicode: f057, created: 1.0.
     */
    FAIconRemoveSign,
    
    /**
     @abstract  ok-sign
     @discussion id: ok-sign, unicode: f058, created: 1.0.
     */
    FAIconOkSign,
    
    /**
     @abstract  question-sign
     @discussion id: question-sign, unicode: f059, created: 1.0.
     */
    FAIconQuestionSign,
    
    /**
     @abstract  info-sign
     @discussion id: info-sign, unicode: f05a, created: 1.0.
     */
    FAIconInfoSign,
    
    /**
     @abstract  screenshot
     @discussion id: screenshot, unicode: f05b, created: 1.0.
     */
    FAIconScreenshot,
    
    /**
     @abstract  remove-circle
     @discussion id: remove-circle, unicode: f05c, created: 1.0.
     */
    FAIconRemoveCircle,
    
    /**
     @abstract  ok-circle
     @discussion id: ok-circle, unicode: f05d, created: 1.0.
     */
    FAIconOkCircle,
    
    /**
     @abstract  ban-circle
     @discussion id: ban-circle, unicode: f05e, created: 1.0.
     */
    FAIconBanCircle,
    
    /**
     @abstract  arrow-left
     @discussion id: arrow-left, unicode: f060, created: 1.0.
     */
    FAIconArrowLeft,
    
    /**
     @abstract  arrow-right
     @discussion id: arrow-right, unicode: f061, created: 1.0.
     */
    FAIconArrowRight,
    
    /**
     @abstract  arrow-up
     @discussion id: arrow-up, unicode: f062, created: 1.0.
     */
    FAIconArrowUp,
    
    /**
     @abstract  arrow-down
     @discussion id: arrow-down, unicode: f063, created: 1.0.
     */
    FAIconArrowDown,
    
    /**
     @abstract  share-alt
     @discussion id: share-alt, unicode: f064, created: 1.0.
     */
    FAIconShareAlt,
    
    /**
     @abstract  mail-forward
     @discussion id: mail-forward, unicode: f064, created: 1.0.
     */
    FAIconMailForward,
    
    /**
     @abstract  resize-full
     @discussion id: resize-full, unicode: f065, created: 1.0.
     */
    FAIconResizeFull,
    
    /**
     @abstract  resize-small
     @discussion id: resize-small, unicode: f066, created: 1.0.
     */
    FAIconResizeSmall,
    
    /**
     @abstract  plus
     @discussion id: plus, unicode: f067, created: 1.0.
     */
    FAIconPlus,
    
    /**
     @abstract  minus
     @discussion id: minus, unicode: f068, created: 1.0.
     */
    FAIconMinus,
    
    /**
     @abstract  asterisk
     @discussion id: asterisk, unicode: f069, created: 1.0.
     */
    FAIconAsterisk,
    
    /**
     @abstract  exclamation-sign
     @discussion id: exclamation-sign, unicode: f06a, created: 1.0.
     */
    FAIconExclamationSign,
    
    /**
     @abstract  gift
     @discussion id: gift, unicode: f06b, created: 1.0.
     */
    FAIconGift,
    
    /**
     @abstract  leaf
     @discussion id: leaf, unicode: f06c, created: 1.0.
     */
    FAIconLeaf,
    
    /**
     @abstract  fire
     @discussion id: fire, unicode: f06d, created: 1.0.
     */
    FAIconFire,
    
    /**
     @abstract  eye-open
     @discussion id: eye-open, unicode: f06e, created: 1.0.
     */
    FAIconEyeOpen,
    
    /**
     @abstract  eye-close
     @discussion id: eye-close, unicode: f070, created: 1.0.
     */
    FAIconEyeClose,
    
    /**
     @abstract  warning-sign
     @discussion id: warning-sign, unicode: f071, created: 1.0.
     */
    FAIconWarningSign,
    
    /**
     @abstract  plane
     @discussion id: plane, unicode: f072, created: 1.0.
     */
    FAIconPlane,
    
    /**
     @abstract  calendar
     @discussion id: calendar, unicode: f073, created: 1.0.
     */
    FAIconCalendar,
    
    /**
     @abstract  random
     @discussion id: random, unicode: f074, created: 1.0.
     */
    FAIconRandom,
    
    /**
     @abstract  comment
     @discussion id: comment, unicode: f075, created: 1.0.
     */
    FAIconComment,
    
    /**
     @abstract  magnet
     @discussion id: magnet, unicode: f076, created: 1.0.
     */
    FAIconMagnet,
    
    /**
     @abstract  chevron-up
     @discussion id: chevron-up, unicode: f077, created: 1.0.
     */
    FAIconChevronUp,
    
    /**
     @abstract  chevron-down
     @discussion id: chevron-down, unicode: f078, created: 1.0.
     */
    FAIconChevronDown,
    
    /**
     @abstract  retweet
     @discussion id: retweet, unicode: f079, created: 1.0.
     */
    FAIconRetweet,
    
    /**
     @abstract  shopping-cart
     @discussion id: shopping-cart, unicode: f07a, created: 1.0.
     */
    FAIconShoppingCart,
    
    /**
     @abstract  folder-close
     @discussion id: folder-close, unicode: f07b, created: 1.0.
     */
    FAIconFolderClose,
    
    /**
     @abstract  folder-open
     @discussion id: folder-open, unicode: f07c, created: 1.0.
     */
    FAIconFolderOpen,
    
    /**
     @abstract  resize-vertical
     @discussion id: resize-vertical, unicode: f07d, created: 1.0.
     */
    FAIconResizeVertical,
    
    /**
     @abstract  resize-horizontal
     @discussion id: resize-horizontal, unicode: f07e, created: 1.0.
     */
    FAIconResizeHorizontal,
    
    /**
     @abstract  bar-chart
     @discussion id: bar-chart, unicode: f080, created: 1.0.
     */
    FAIconBarChart,
    
    /**
     @abstract  twitter-sign
     @discussion id: twitter-sign, unicode: f081, created: 1.0.
     */
    FAIconTwitterSign,
    
    /**
     @abstract  facebook-sign
     @discussion id: facebook-sign, unicode: f082, created: 1.0.
     */
    FAIconFacebookSign,
    
    /**
     @abstract  camera-retro
     @discussion id: camera-retro, unicode: f083, created: 1.0.
     */
    FAIconCameraRetro,
    
    /**
     @abstract  key
     @discussion id: key, unicode: f084, created: 1.0.
     */
    FAIconKey,
    
    /**
     @abstract  cogs
     @discussion id: cogs, unicode: f085, created: 1.0.
     */
    FAIconCogs,
    
    /**
     @abstract  gears
     @discussion id: gears, unicode: f085, created: 1.0.
     */
    FAIconGears,
    
    /**
     @abstract  comments
     @discussion id: comments, unicode: f086, created: 1.0.
     */
    FAIconComments,
    
    /**
     @abstract  thumbs-up-alt
     @discussion id: thumbs-up-alt, unicode: f087, created: 1.0.
     */
    FAIconThumbsUpAlt,
    
    /**
     @abstract  thumbs-down-alt
     @discussion id: thumbs-down-alt, unicode: f088, created: 1.0.
     */
    FAIconThumbsDownAlt,
    
    /**
     @abstract  star-half
     @discussion id: star-half, unicode: f089, created: 1.0.
     */
    FAIconStarHalf,
    
    /**
     @abstract  heart-empty
     @discussion id: heart-empty, unicode: f08a, created: 1.0.
     */
    FAIconHeartEmpty,
    
    /**
     @abstract  signout
     @discussion id: signout, unicode: f08b, created: 1.0.
     */
    FAIconSignout,
    
    /**
     @abstract  linkedin-sign
     @discussion id: linkedin-sign, unicode: f08c, created: 1.0.
     */
    FAIconLinkedinSign,
    
    /**
     @abstract  pushpin
     @discussion id: pushpin, unicode: f08d, created: 1.0.
     */
    FAIconPushpin,
    
    /**
     @abstract  external-link
     @discussion id: external-link, unicode: f08e, created: 1.0.
     */
    FAIconExternalLink,
    
    /**
     @abstract  signin
     @discussion id: signin, unicode: f090, created: 1.0.
     */
    FAIconSignin,
    
    /**
     @abstract  trophy
     @discussion id: trophy, unicode: f091, created: 1.0.
     */
    FAIconTrophy,
    
    /**
     @abstract  github-sign
     @discussion id: github-sign, unicode: f092, created: 1.0.
     */
    FAIconGithubSign,
    
    /**
     @abstract  upload-alt
     @discussion id: upload-alt, unicode: f093, created: 1.0.
     */
    FAIconUploadAlt,
    
    /**
     @abstract  lemon
     @discussion id: lemon, unicode: f094, created: 1.0.
     */
    FAIconLemon,
    
    /**
     @abstract  phone
     @discussion id: phone, unicode: f095, created: 2.0.
     */
    FAIconPhone,
    
    /**
     @abstract  check-empty
     @discussion id: check-empty, unicode: f096, created: 2.0.
     */
    FAIconCheckEmpty,
    
    /**
     @abstract  unchecked
     @discussion id: unchecked, unicode: f096, created: 2.0.
     */
    FAIconUnchecked,
    
    /**
     @abstract  bookmark-empty
     @discussion id: bookmark-empty, unicode: f097, created: 2.0.
     */
    FAIconBookmarkEmpty,
    
    /**
     @abstract  phone-sign
     @discussion id: phone-sign, unicode: f098, created: 2.0.
     */
    FAIconPhoneSign,
    
    /**
     @abstract  twitter
     @discussion id: twitter, unicode: f099, created: 2.0.
     */
    FAIconTwitter,
    
    /**
     @abstract  facebook
     @discussion id: facebook, unicode: f09a, created: 2.0.
     */
    FAIconFacebook,
    
    /**
     @abstract  github
     @discussion id: github, unicode: f09b, created: 2.0.
     */
    FAIconGithub,
    
    /**
     @abstract  unlock
     @discussion id: unlock, unicode: f09c, created: 2.0.
     */
    FAIconUnlock,
    
    /**
     @abstract  credit-card
     @discussion id: credit-card, unicode: f09d, created: 2.0.
     */
    FAIconCreditCard,
    
    /**
     @abstract  rss
     @discussion id: rss, unicode: f09e, created: 2.0.
     */
    FAIconRss,
    
    /**
     @abstract  hdd
     @discussion id: hdd, unicode: f0a0, created: 2.0.
     */
    FAIconHdd,
    
    /**
     @abstract  bullhorn
     @discussion id: bullhorn, unicode: f0a1, created: 2.0.
     */
    FAIconBullhorn,
    
    /**
     @abstract  bell
     @discussion id: bell, unicode: f0a2, created: 2.0.
     */
    FAIconBell,
    
    /**
     @abstract  certificate
     @discussion id: certificate, unicode: f0a3, created: 2.0.
     */
    FAIconCertificate,
    
    /**
     @abstract  hand-right
     @discussion id: hand-right, unicode: f0a4, created: 2.0.
     */
    FAIconHandRight,
    
    /**
     @abstract  hand-left
     @discussion id: hand-left, unicode: f0a5, created: 2.0.
     */
    FAIconHandLeft,
    
    /**
     @abstract  hand-up
     @discussion id: hand-up, unicode: f0a6, created: 2.0.
     */
    FAIconHandUp,
    
    /**
     @abstract  hand-down
     @discussion id: hand-down, unicode: f0a7, created: 2.0.
     */
    FAIconHandDown,
    
    /**
     @abstract  circle-arrow-left
     @discussion id: circle-arrow-left, unicode: f0a8, created: 2.0.
     */
    FAIconCircleArrowLeft,
    
    /**
     @abstract  circle-arrow-right
     @discussion id: circle-arrow-right, unicode: f0a9, created: 2.0.
     */
    FAIconCircleArrowRight,
    
    /**
     @abstract  circle-arrow-up
     @discussion id: circle-arrow-up, unicode: f0aa, created: 2.0.
     */
    FAIconCircleArrowUp,
    
    /**
     @abstract  circle-arrow-down
     @discussion id: circle-arrow-down, unicode: f0ab, created: 2.0.
     */
    FAIconCircleArrowDown,
    
    /**
     @abstract  globe
     @discussion id: globe, unicode: f0ac, created: 2.0.
     */
    FAIconGlobe,
    
    /**
     @abstract  wrench
     @discussion id: wrench, unicode: f0ad, created: 2.0.
     */
    FAIconWrench,
    
    /**
     @abstract  tasks
     @discussion id: tasks, unicode: f0ae, created: 2.0.
     */
    FAIconTasks,
    
    /**
     @abstract  filter
     @discussion id: filter, unicode: f0b0, created: 2.0.
     */
    FAIconFilter,
    
    /**
     @abstract  briefcase
     @discussion id: briefcase, unicode: f0b1, created: 2.0.
     */
    FAIconBriefcase,
    
    /**
     @abstract  fullscreen
     @discussion id: fullscreen, unicode: f0b2, created: 2.0.
     */
    FAIconFullscreen,
    
    /**
     @abstract  group
     @discussion id: group, unicode: f0c0, created: 2.0.
     */
    FAIconGroup,
    
    /**
     @abstract  link
     @discussion id: link, unicode: f0c1, created: 2.0.
     */
    FAIconLink,
    
    /**
     @abstract  cloud
     @discussion id: cloud, unicode: f0c2, created: 2.0.
     */
    FAIconCloud,
    
    /**
     @abstract  beaker
     @discussion id: beaker, unicode: f0c3, created: 2.0.
     */
    FAIconBeaker,
    
    /**
     @abstract  cut
     @discussion id: cut, unicode: f0c4, created: 2.0.
     */
    FAIconCut,
    
    /**
     @abstract  copy
     @discussion id: copy, unicode: f0c5, created: 2.0.
     */
    FAIconCopy,
    
    /**
     @abstract  paper-clip
     @discussion id: paper-clip, unicode: f0c6, created: 2.0.
     */
    FAIconPaperClip,
    
    /**
     @abstract  save
     @discussion id: save, unicode: f0c7, created: 2.0.
     */
    FAIconSave,
    
    /**
     @abstract  sign-blank
     @discussion id: sign-blank, unicode: f0c8, created: 2.0.
     */
    FAIconSignBlank,
    
    /**
     @abstract  reorder
     @discussion id: reorder, unicode: f0c9, created: 2.0.
     */
    FAIconReorder,
    
    /**
     @abstract  list-ul
     @discussion id: list-ul, unicode: f0ca, created: 2.0.
     */
    FAIconListUl,
    
    /**
     @abstract  list-ol
     @discussion id: list-ol, unicode: f0cb, created: 2.0.
     */
    FAIconListOl,
    
    /**
     @abstract  strikethrough
     @discussion id: strikethrough, unicode: f0cc, created: 2.0.
     */
    FAIconStrikethrough,
    
    /**
     @abstract  underline
     @discussion id: underline, unicode: f0cd, created: 2.0.
     */
    FAIconUnderline,
    
    /**
     @abstract  table
     @discussion id: table, unicode: f0ce, created: 2.0.
     */
    FAIconTable,
    
    /**
     @abstract  magic
     @discussion id: magic, unicode: f0d0, created: 2.0.
     */
    FAIconMagic,
    
    /**
     @abstract  truck
     @discussion id: truck, unicode: f0d1, created: 2.0.
     */
    FAIconTruck,
    
    /**
     @abstract  pinterest
     @discussion id: pinterest, unicode: f0d2, created: 2.0.
     */
    FAIconPinterest,
    
    /**
     @abstract  pinterest-sign
     @discussion id: pinterest-sign, unicode: f0d3, created: 2.0.
     */
    FAIconPinterestSign,
    
    /**
     @abstract  google-plus-sign
     @discussion id: google-plus-sign, unicode: f0d4, created: 2.0.
     */
    FAIconGooglePlusSign,
    
    /**
     @abstract  google-plus
     @discussion id: google-plus, unicode: f0d5, created: 2.0.
     */
    FAIconGooglePlus,
    
    /**
     @abstract  money
     @discussion id: money, unicode: f0d6, created: 2.0.
     */
    FAIconMoney,
    
    /**
     @abstract  caret-down
     @discussion id: caret-down, unicode: f0d7, created: 2.0.
     */
    FAIconCaretDown,
    
    /**
     @abstract  caret-up
     @discussion id: caret-up, unicode: f0d8, created: 2.0.
     */
    FAIconCaretUp,
    
    /**
     @abstract  caret-left
     @discussion id: caret-left, unicode: f0d9, created: 2.0.
     */
    FAIconCaretLeft,
    
    /**
     @abstract  caret-right
     @discussion id: caret-right, unicode: f0da, created: 2.0.
     */
    FAIconCaretRight,
    
    /**
     @abstract  columns
     @discussion id: columns, unicode: f0db, created: 2.0.
     */
    FAIconColumns,
    
    /**
     @abstract  sort
     @discussion id: sort, unicode: f0dc, created: 2.0.
     */
    FAIconSort,
    
    /**
     @abstract  sort-down
     @discussion id: sort-down, unicode: f0dd, created: 2.0.
     */
    FAIconSortDown,
    
    /**
     @abstract  sort-up
     @discussion id: sort-up, unicode: f0de, created: 2.0.
     */
    FAIconSortUp,
    
    /**
     @abstract  Envelope
     @discussion id: envelope, unicode: f0e0, created: 2.0.
     */
    FAIconEnvelope,
    
    /**
     @abstract  linkedin
     @discussion id: linkedin, unicode: f0e1, created: 2.0.
     */
    FAIconLinkedin,
    
    /**
     @abstract  undo
     @discussion id: undo, unicode: f0e2, created: 2.0.
     */
    FAIconUndo,
    
    /**
     @abstract  rotate-left
     @discussion id: rotate-left, unicode: f0e2, created: 2.0.
     */
    FAIconRotateLeft,
    
    /**
     @abstract  legal
     @discussion id: legal, unicode: f0e3, created: 2.0.
     */
    FAIconLegal,
    
    /**
     @abstract  dashboard
     @discussion id: dashboard, unicode: f0e4, created: 2.0.
     */
    FAIconDashboard,
    
    /**
     @abstract  comment-alt
     @discussion id: comment-alt, unicode: f0e5, created: 2.0.
     */
    FAIconCommentAlt,
    
    /**
     @abstract  comments-alt
     @discussion id: comments-alt, unicode: f0e6, created: 2.0.
     */
    FAIconCommentsAlt,
    
    /**
     @abstract  bolt
     @discussion id: bolt, unicode: f0e7, created: 2.0.
     */
    FAIconBolt,
    
    /**
     @abstract  sitemap
     @discussion id: sitemap, unicode: f0e8, created: 2.0.
     */
    FAIconSitemap,
    
    /**
     @abstract  umbrella
     @discussion id: umbrella, unicode: f0e9, created: 2.0.
     */
    FAIconUmbrella,
    
    /**
     @abstract  paste
     @discussion id: paste, unicode: f0ea, created: 2.0.
     */
    FAIconPaste,
    /**
     @abstract  lightbulb
     @discussion id: lightbulb, unicode: f0eb, created: 3.0.
     */
    FAIconLightbulb,
    
    /**
     @abstract  exchange
     @discussion id: exchange, unicode: f0ec, created: 3.0.
     */
    FAIconExchange,
    
    /**
     @abstract  cloud-download
     @discussion id: cloud-download, unicode: f0ed, created: 3.0.
     */
    FAIconCloudDownload,
    
    /**
     @abstract  cloud-upload
     @discussion id: cloud-upload, unicode: f0ee, created: 3.0.
     */
    FAIconCloudUpload,
    
    /**
     @abstract  user-md
     @discussion id: user-md, unicode: f0f0, created: 2.0.
     */
    FAIconUserMd,
    
    /**
     @abstract  stethoscope
     @discussion id: stethoscope, unicode: f0f1, created: 3.0.
     */
    FAIconStethoscope,
    
    /**
     @abstract  suitcase
     @discussion id: suitcase, unicode: f0f2, created: 3.0.
     */
    FAIconSuitcase,
    
    /**
     @abstract  bell-alt
     @discussion id: bell-alt, unicode: f0f3, created: 3.0.
     */
    FAIconBellAlt,
    
    /**
     @abstract  coffee
     @discussion id: coffee, unicode: f0f4, created: 3.0.
     */
    FAIconCoffee,
    
    /**
     @abstract  food
     @discussion id: food, unicode: f0f5, created: 3.0.
     */
    FAIconFood,
    
    /**
     @abstract  file-text-alt
     @discussion id: file-text-alt, unicode: f0f6, created: 3.0.
     */
    FAIconFileTextAlt,
    
    /**
     @abstract  building
     @discussion id: building, unicode: f0f7, created: 3.0.
     */
    FAIconBuilding,
    
    /**
     @abstract  hospital
     @discussion id: hospital, unicode: f0f8, created: 3.0.
     */
    FAIconHospital,
    
    /**
     @abstract  ambulance
     @discussion id: ambulance, unicode: f0f9, created: 3.0.
     */
    FAIconAmbulance,
    
    /**
     @abstract  medkit
     @discussion id: medkit, unicode: f0fa, created: 3.0.
     */
    FAIconMedkit,
    
    /**
     @abstract  fighter-jet
     @discussion id: fighter-jet, unicode: f0fb, created: 3.0.
     */
    FAIconFighterJet,
    
    /**
     @abstract  beer
     @discussion id: beer, unicode: f0fc, created: 3.0.
     */
    FAIconBeer,
    
    /**
     @abstract e: h-sign
     @discussion id: h-sign, unicode: f0fd, created: 3.0.
     */
    FAIconHSign,
    
    /**
     @abstract  plus-sign-alt
     @discussion id: plus-sign-alt, unicode: f0fe, created: 3.0.
     */
    FAIconPlusSignAlt,
    
    /**
     @abstract  double-angle-left
     @discussion id: double-angle-left, unicode: f100, created: 3.0.
     */
    FAIconDoubleAngleLeft,
    
    /**
     @abstract  double-angle-right
     @discussion id: double-angle-right, unicode: f101, created: 3.0.
     */
    FAIconDoubleAngleRight,
    
    /**
     @abstract  double-angle-up
     @discussion id: double-angle-up, unicode: f102, created: 3.0.
     */
    FAIconDoubleAngleUp,
    
    /**
     @abstract  double-angle-down
     @discussion id: double-angle-down, unicode: f103, created: 3.0.
     */
    FAIconDoubleAngleDown,
    
    /**
     @abstract  angle-left
     @discussion id: angle-left, unicode: f104, created: 3.0.
     */
    FAIconAngleLeft,
    
    /**
     @abstract  angle-right
     @discussion id: angle-right, unicode: f105, created: 3.0.
     */
    FAIconAngleRight,
    
    /**
     @abstract  angle-up
     @discussion id: angle-up, unicode: f106, created: 3.0.
     */
    FAIconAngleUp,
    
    /**
     @abstract  angle-down
     @discussion id: angle-down, unicode: f107, created: 3.0.
     */
    FAIconAngleDown,
    
    /**
     @abstract  desktop
     @discussion id: desktop, unicode: f108, created: 3.0.
     */
    FAIconDesktop,
    
    /**
     @abstract  laptop
     @discussion id: laptop, unicode: f109, created: 3.0.
     */
    FAIconLaptop,
    
    /**
     @abstract  tablet
     @discussion id: tablet, unicode: f10a, created: 3.0.
     */
    FAIconTablet,
    
    /**
     @abstract  mobile-phone
     @discussion id: mobile-phone, unicode: f10b, created: 3.0.
     */
    FAIconMobilePhone,
    
    /**
     @abstract  circle-blank
     @discussion id: circle-blank, unicode: f10c, created: 3.0.
     */
    FAIconCircleBlank,
    
    /**
     @abstract  quote-left
     @discussion id: quote-left, unicode: f10d, created: 3.0.
     */
    FAIconQuoteLeft,
    
    /**
     @abstract  quote-right
     @discussion id: quote-right, unicode: f10e, created: 3.0.
     */
    FAIconQuoteRight,
    
    /**
     @abstract  spinner
     @discussion id: spinner, unicode: f110, created: 3.0.
     */
    FAIconSpinner,
    
    /**
     @abstract  circle
     @discussion id: circle, unicode: f111, created: 3.0.
     */
    FAIconCircle,
    
    /**
     @abstract  reply
     @discussion id: reply, unicode: f112, created: 3.0.
     */
    FAIconReply,
    
    /**
     @abstract  mail-reply
     @discussion id: mail-reply, unicode: f112, created: 3.0.
     */
    FAIconMailReply,
    
    /**
     @abstract  github-alt
     @discussion id: github-alt, unicode: f113, created: 3.0.
     */
    FAIconGithubAlt,
    
    /**
     @abstract  folder-close-alt
     @discussion id: folder-close-alt, unicode: f114, created: 3.0.
     */
    FAIconFolderCloseAlt,
    
    /**
     @abstract  folder-open-alt
     @discussion id: folder-open-alt, unicode: f115, created: 3.0.
     */
    FAIconFolderOpenAlt,
    
    /**
     @abstract  expand-alt
     @discussion id: expand-alt, unicode: f116, created: 3.1.
     */
    FAIconExpandAlt,
    
    /**
     @abstract  collapse-alt
     @discussion id: collapse-alt, unicode: f117, created: 3.1.
     */
    FAIconCollapseAlt,
    
    /**
     @abstract  smile
     @discussion id: smile, unicode: f118, created: 3.1.
     */
    FAIconSmile,
    
    /**
     @abstract  frown
     @discussion id: frown, unicode: f119, created: 3.1.
     */
    FAIconFrown,
    
    /**
     @abstract  meh
     @discussion id: meh, unicode: f11a, created: 3.1.
     */
    FAIconMeh,
    
    /**
     @abstract  gamepad
     @discussion id: gamepad, unicode: f11b, created: 3.1.
     */
    FAIconGamepad,
    
    /**
     @abstract  keyboard
     @discussion id: keyboard, unicode: f11c, created: 3.1.
     */
    FAIconKeyboard,
    
    /**
     @abstract  flag-alt
     @discussion id: flag-alt, unicode: f11d, created: 3.1.
     */
    FAIconFlagAlt,
    
    /**
     @abstract  flag-checkered
     @discussion id: flag-checkered, unicode: f11e, created: 3.1.
     */
    FAIconFlagCheckered,
    
    /**
     @abstract  terminal
     @discussion id: terminal, unicode: f120, created: 3.1.
     */
    FAIconTerminal,
    
    /**
     @abstract  code
     @discussion id: code, unicode: f121, created: 3.1.
     */
    FAIconCode,
    
    /**
     @abstract  reply-all
     @discussion id: reply-all, unicode: f122, created: 3.1.
     */
    FAIconReplyAll,
    
    /**
     @abstract  mail-reply-all
     @discussion id: mail-reply-all, unicode: f122, created: 3.1.
     */
    FAIconMailReplyAll,
    
    /**
     @abstract  star-half-empty
     @discussion id: star-half-empty, unicode: f123, created: 3.1.
     */
    FAIconStarHalfEmpty,
    
    /**
     @abstract  star-half-full
     @discussion id: star-half-full, unicode: f123, created: 3.1.
     */
    FAIconStarHalfFull,
    
    /**
     @abstract  location-arrow
     @discussion id: location-arrow, unicode: f124, created: 3.1.
     */
    FAIconLocationArrow,
    
    /**
     @abstract  crop
     @discussion id: crop, unicode: f125, created: 3.1.
     */
    FAIconCrop,
    
    /**
     @abstract  code-fork
     @discussion id: code-fork, unicode: f126, created: 3.1.
     */
    FAIconCodeFork,
    
    /**
     @abstract  unlink
     @discussion id: unlink, unicode: f127, created: 3.1.
     */
    FAIconUnlink,
    
    /**
     @abstract  question
     @discussion id: question, unicode: f128, created: 3.1.
     */
    FAIconQuestion,
    
    /**
     @abstract  info
     @discussion id: info, unicode: f129, created: 3.1.
     */
    FAIconInfo,
    
    /**
     @abstract  exclamation
     @discussion id: exclamation, unicode: f12a, created: 3.1.
     */
    FAIconExclamation,
    
    /**
     @abstract  superscript
     @discussion id: superscript, unicode: f12b, created: 3.1.
     */
    FAIconSuperscript,
    
    /**
     @abstract  subscript
     @discussion id: subscript, unicode: f12c, created: 3.1.
     */
    FAIconSubscript,
    
    /**
     @abstract  eraser
     @discussion id: eraser, unicode: f12d, created: 3.1.
     */
    FAIconEraser,
    
    /**
     @abstract  puzzle-piece
     @discussion id: puzzle-piece, unicode: f12e, created: 3.1.
     */
    FAIconPuzzlePiece,
    
    /**
     @abstract  microphone
     @discussion id: microphone, unicode: f130, created: 3.1.
     */
    FAIconMicrophone,
    
    /**
     @abstract  microphone-off
     @discussion id: microphone-off, unicode: f131, created: 3.1.
     */
    FAIconMicrophoneOff,
    
    /**
     @abstract  shield
     @discussion id: shield, unicode: f132, created: 3.1.
     */
    FAIconShield,
    
    /**
     @abstract  calendar-empty
     @discussion id: calendar-empty, unicode: f133, created: 3.1.
     */
    FAIconCalendarEmpty,
    
    /**
     @abstract  fire-extinguisher
     @discussion id: fire-extinguisher, unicode: f134, created: 3.1.
     */
    FAIconFireExtinguisher,
    
    /**
     @abstract  rocket
     @discussion id: rocket, unicode: f135, created: 3.1.
     */
    FAIconRocket,
    
    /**
     @abstract  MaxCDN
     @discussion id: maxcdn, unicode: f136, created: 3.1.
     */
    FAIconMaxcdn,
    
    /**
     @abstract  Chevron Sign Left
     @discussion id: chevron-sign-left, unicode: f137, created: 3.1.
     */
    FAIconChevronSignLeft,
    
    /**
     @abstract  Chevron Sign Right
     @discussion id: chevron-sign-right, unicode: f138, created: 3.1.
     */
    FAIconChevronSignRight,
    
    /**
     @abstract  Chevron Sign Up
     @discussion id: chevron-sign-up, unicode: f139, created: 3.1.
     */
    FAIconChevronSignUp,
    
    /**
     @abstract  Chevron Sign Down
     @discussion id: chevron-sign-down, unicode: f13a, created: 3.1.
     */
    FAIconChevronSignDown,
    
    /**
     @abstract  HTML 5 Logo
     @discussion id: html5, unicode: f13b, created: 3.1.
     */
    FAIconHtml5,
    
    /**
     @abstract  CSS 3 Logo
     @discussion id: css3, unicode: f13c, created: 3.1.
     */
    FAIconCss3,
    
    /**
     @abstract  Anchor
     @discussion id: anchor, unicode: f13d, created: 3.1.
     */
    FAIconAnchor,
    
    /**
     @abstract  Unlock Alt
     @discussion id: unlock-alt, unicode: f13e, created: 3.1.
     */
    FAIconUnlockAlt,
    
    /**
     @abstract  Bullseye
     @discussion id: bullseye, unicode: f140, created: 3.1.
     */
    FAIconBullseye,
    
    /**
     @abstract  Horizontal Ellipsis
     @discussion id: ellipsis-horizontal, unicode: f141, created: 3.1.
     */
    FAIconEllipsisHorizontal,
    
    /**
     @abstract  Vertical Ellipsis
     @discussion id: ellipsis-vertical, unicode: f142, created: 3.1.
     */
    FAIconEllipsisVertical,
    
    /**
     @abstract  RSS Sign
     @discussion id: rss-sign, unicode: f143, created: 3.1.
     */
    FAIconRssSign,
    
    /**
     @abstract  Play Sign
     @discussion id: play-sign, unicode: f144, created: 3.1.
     */
    FAIconPlaySign,
    
    /**
     @abstract  Ticket
     @discussion id: ticket, unicode: f145, created: 3.1.
     */
    FAIconTicket,
    
    /**
     @abstract  Minus Sign Alt
     @discussion id: minus-sign-alt, unicode: f146, created: 3.1.
     */
    FAIconMinusSignAlt,
    
    /**
     @abstract  Check Minus
     @discussion id: check-minus, unicode: f147, created: 3.1.
     */
    FAIconCheckMinus,
    
    /**
     @abstract  Level Up
     @discussion id: level-up, unicode: f148, created: 3.1.
     */
    FAIconLevelUp,
    
    /**
     @abstract  Level Down
     @discussion id: level-down, unicode: f149, created: 3.1.
     */
    FAIconLevelDown,
    
    /**
     @abstract  Check Sign
     @discussion id: check-sign, unicode: f14a, created: 3.1.
     */
    FAIconCheckSign,
    
    /**
     @abstract  Edit Sign
     @discussion id: edit-sign, unicode: f14b, created: 3.1.
     */
    FAIconEditSign,
    
    /**
     @abstract  Exteral Link Sign
     @discussion id: external-link-sign, unicode: f14c, created: 3.1.
     */
    FAIconExternalLinkSign,
    
    /**
     @abstract  Share Sign
     @discussion id: share-sign, unicode: f14d, created: 3.1.
     */
    FAIconShareSign,
    
    /**
     @abstract  Compass
     @discussion id: compass, unicode: f14e, created: 3.2.
     */
    FAIconCompass,
    
    /**
     @abstract  Collapse
     @discussion id: collapse, unicode: f150, created: 3.2.
     */
    FAIconCollapse,
    
    /**
     @abstract  Collapse Top
     @discussion id: collapse-top, unicode: f151, created: 3.2.
     */
    FAIconCollapseTop,
    
    /**
     @abstract  Expand
     @discussion id: expand, unicode: f152, created: 3.2.
     */
    FAIconExpand,
    
    /**
     @abstract  Euro (EUR)
     @discussion id: eur, unicode: f153, created: 3.2.
     */
    FAIconEur,
    
    /**
     @abstract  Euro (EUR)
     @discussion id: euro, unicode: f153, created: 3.2.
     */
    FAIconEuro,
    
    /**
     @abstract  GBP
     @discussion id: gbp, unicode: f154, created: 3.2.
     */
    FAIconGbp,
    
    /**
     @abstract  US Dollar
     @discussion id: usd, unicode: f155, created: 3.2.
     */
    FAIconUsd,
    
    /**
     @abstract  US Dollar
     @discussion id: dollar, unicode: f155, created: 3.2.
     */
    FAIconDollar,
    
    /**
     @abstract  Indian Rupee (INR)
     @discussion id: inr, unicode: f156, created: 3.2.
     */
    FAIconInr,
    
    /**
     @abstract  Indian Rupee (INR)
     @discussion id: rupee, unicode: f156, created: 3.2.
     */
    FAIconRupee,
    
    /**
     @abstract  Japanese Yen (JPY)
     @discussion id: jpy, unicode: f157, created: 3.2.
     */
    FAIconJpy,
    
    /**
     @abstract  Japanese Yen (JPY)
     @discussion id: yen, unicode: f157, created: 3.2.
     */
    FAIconYen,
    
    /**
     @abstract  Renminbi (CNY)
     @discussion id: cny, unicode: f158, created: 3.2.
     */
    FAIconCny,
    
    /**
     @abstract  Renminbi (CNY)
     @discussion id: renminbi, unicode: f158, created: 3.2.
     */
    FAIconRenminbi,
    
    /**
     @abstract  Korean Won (KRW)
     @discussion id: krw, unicode: f159, created: 3.2.
     */
    FAIconKrw,
    
    /**
     @abstract  Korean Won (KRW)
     @discussion id: won, unicode: f159, created: 3.2.
     */
    FAIconWon,
    
    /**
     @abstract  Bitcoin (BTC)
     @discussion id: btc, unicode: f15a, created: 3.2.
     */
    FAIconBtc,
    
    /**
     @abstract  Bitcoin (BTC)
     @discussion id: bitcoin, unicode: f15a, created: 3.2.
     */
    FAIconBitcoin,
    
    /**
     @abstract  Bitcoin (BTC)
     @discussion id: brand-icons, unicode: f15a, created: 3.2.
     */
    FAIconBrandIcons,
    
    /**
     @abstract  File
     @discussion id: file, unicode: f15b, created: 3.2.
     */
    FAIconFile,
    
    /**
     @abstract  File Text
     @discussion id: file-text, unicode: f15c, created: 3.2.
     */
    FAIconFileText,
    
    /**
     @abstract  Sort By Alphabet
     @discussion id: sort-by-alphabet, unicode: f15d, created: 3.2.
     */
    FAIconSortByAlphabet,
    
    /**
     @abstract  Sort By Alphabet Alt
     @discussion id: sort-by-alphabet-alt, unicode: f15e, created: 3.2.
     */
    FAIconSortByAlphabetAlt,
    
    /**
     @abstract  Sort By Attributes
     @discussion id: sort-by-attributes, unicode: f160, created: 3.2.
     */
    FAIconSortByAttributes,
    
    /**
     @abstract  Sort By Attributes Alt
     @discussion id: sort-by-attributes-alt, unicode: f161, created: 3.2.
     */
    FAIconSortByAttributesAlt,
    
    /**
     @abstract  Sort By Order
     @discussion id: sort-by-order, unicode: f162, created: 3.2.
     */
    FAIconSortByOrder,
    
    /**
     @abstract  Sort By Order Alt
     @discussion id: sort-by-order-alt, unicode: f163, created: 3.2.
     */
    FAIconSortByOrderAlt,
    
    /**
     @abstract  thumbs-up
     @discussion id: thumbs-up, unicode: f164, created: 3.2.
     */
    FAIconThumbsUp,
    
    /**
     @abstract  thumbs-down
     @discussion id: thumbs-down, unicode: f165, created: 3.2.
     */
    FAIconThumbsDown,
    
    /**
     @abstract  YouTube Sign
     @discussion id: youtube-sign, unicode: f166, created: 3.2.
     */
    FAIconYoutubeSign,
    
    /**
     @abstract  YouTube
     @discussion id: youtube, unicode: f167, created: 3.2.
     */
    FAIconYoutube,
    
    /**
     @abstract  Xing
     @discussion id: xing, unicode: f168, created: 3.2.
     */
    FAIconXing,
    
    /**
     @abstract  Xing Sign
     @discussion id: xing-sign, unicode: f169, created: 3.2.
     */
    FAIconXingSign,
    
    /**
     @abstract  YouTube Play
     @discussion id: youtube-play, unicode: f16a, created: 3.2.
     */
    FAIconYoutubePlay,
    
    /**
     @abstract  Dropbox
     @discussion id: dropbox, unicode: f16b, created: 3.2.
     */
    FAIconDropbox,
    
    /**
     @abstract  Stack Exchange
     @discussion id: stackexchange, unicode: f16c, created: 3.2.
     */
    FAIconStackexchange,
    
    /**
     @abstract  Instagram
     @discussion id: instagram, unicode: f16d, created: 3.2.
     */
    FAIconInstagram,
    
    /**
     @abstract  Flickr
     @discussion id: flickr, unicode: f16e, created: 3.2.
     */
    FAIconFlickr,
    
    /**
     @abstract  App.net
     @discussion id: adn, unicode: f170, created: 3.2.
     */
    FAIconAdn,
    
    /**
     @abstract  Bitbucket
     @discussion id: bitbucket, unicode: f171, created: 3.2.
     */
    FAIconBitbucket,
    
    /**
     @abstract  Bitbucket Sign
     @discussion id: bitbucket-sign, unicode: f172, created: 3.2.
     */
    FAIconBitbucketSign,
    
    /**
     @abstract  Tumblr
     @discussion id: tumblr, unicode: f173, created: 3.2.
     */
    FAIconTumblr,
    
    /**
     @abstract  Tumblr Sign
     @discussion id: tumblr-sign, unicode: f174, created: 3.2.
     */
    FAIconTumblrSign,
    
    /**
     @abstract  Long Arrow Down
     @discussion id: long-arrow-down, unicode: f175, created: 3.2.
     */
    FAIconLongArrowDown,
    
    /**
     @abstract  Long Arrow Up
     @discussion id: long-arrow-up, unicode: f176, created: 3.2.
     */
    FAIconLongArrowUp,
    
    /**
     @abstract  Long Arrow Left
     @discussion id: long-arrow-left, unicode: f177, created: 3.2.
     */
    FAIconLongArrowLeft,
    
    /**
     @abstract  Long Arrow Right
     @discussion id: long-arrow-right, unicode: f178, created: 3.2.
     */
    FAIconLongArrowRight,
    
    /**
     @abstract  Apple
     @discussion id: apple, unicode: f179, created: 3.2.
     */
    FAIconApple,
    
    /**
     @abstract  Windows
     @discussion id: windows, unicode: f17a, created: 3.2.
     */
    FAIconWindows,
    
    /**
     @abstract  Android
     @discussion id: android, unicode: f17b, created: 3.2.
     */
    FAIconAndroid,
    
    /**
     @abstract  Linux
     @discussion id: linux, unicode: f17c, created: 3.2.
     */
    FAIconLinux,
    
    /**
     @abstract  Dribbble
     @discussion id: dribbble, unicode: f17d, created: 3.2.
     */
    FAIconDribbble,
    
    /**
     @abstract  Skype
     @discussion id: skype, unicode: f17e, created: 3.2.
     */
    FAIconSkype,
    
    /**
     @abstract  Foursquare
     @discussion id: foursquare, unicode: f180, created: 3.2.
     */
    FAIconFoursquare,
    
    /**
     @abstract  Trello
     @discussion id: trello, unicode: f181, created: 3.2.
     */
    FAIconTrello,
    
    /**
     @abstract  Female
     @discussion id: female, unicode: f182, created: 3.2.
     */
    FAIconFemale,
    
    /**
     @abstract  Male
     @discussion id: male, unicode: f183, created: 3.2.
     */
    FAIconMale,
    
    /**
     @abstract  Gittip
     @discussion id: gittip, unicode: f184, created: 3.2.
     */
    FAIconGittip,
    
    /**
     @abstract  Sun
     @discussion id: sun, unicode: f185, created: 3.2.
     */
    FAIconSun,
    
    /**
     @abstract  Moon
     @discussion id: moon, unicode: f186, created: 3.2.
     */
    FAIconMoon,
    
    /**
     @abstract  Archive
     @discussion id: archive, unicode: f187, created: 3.2.
     */
    FAIconArchive,
    
    /**
     @abstract  Bug
     @discussion id: bug, unicode: f188, created: 3.2.
     */
    FAIconBug,
    
    /**
     @abstract  VK
     @discussion id: vk, unicode: f189, created: 3.2.
     */
    FAIconVk,
    
    /**
     @abstract  Weibo
     @discussion id: weibo, unicode: f18a, created: 3.2.
     */
    FAIconWeibo,
    
    /**
     @abstract  Renren
     @discussion id: renren, unicode: f18b, created: 3.2.
     */
    FAIconRenren,

    /**
     @abstract  AngelList
     @discussion id: angellist, unicode: f209, created: 4.2.
     */
    FAIconAngelList,

    /**
     @abstract  Bus
     @discussion id: bus, unicode: f207, created: 4.2.
     */
    FAIconBus,

    /**
     @abstract  CCDiscover
     @discussion id: ccdiscover, unicode: f1f2, created: 4.2.
     */
    FACCDiscover,

    /**
     @abstract  GoogleWallet
     @discussion id: googlewallet, unicode: f1ee, created: 4.2.
     */
    FAGoogleWallet,

    /**
     @abstract  LastFMSquare
     @discussion id: lastfmsquare, unicode: f203, created: 4.2.
     */
    FALastFMSquare,

    /**
     @abstract  PaintBrush
     @discussion id: paintbrush, unicode: f1fc, created: 4.2.
     */
    FAPaintBrush,

    /**
     @abstract  Ils
     @discussion id: ils, unicode: f20b, created: 4.2.
     */
    FAIls,

    /**
     @abstract  ToggleOff
     @discussion id: toggleoff, unicode: f204, created: 4.2.
     */
    FAToggleOff,

    /**
     @abstract  Twitch
     @discussion id: twitch, unicode: f1e8, created: 4.2.
     */
    FATwitch,

    /**
     @abstract  AreaChart
     @discussion id: areachart, unicode: f1fe, created: 4.2.
     */
    FAAreaChart,

    /**
     @abstract  Bicycle
     @discussion id: bicycle, unicode: f206, created: 4.2.
     */
    FABicycle,

    /**
     @abstract  Calculator
     @discussion id: calculator, unicode: f1ec, created: 4.2.
     */
    FACalculator,

    /**
     @abstract  CCMastercard
     @discussion id: ccmastercard, unicode: f1f1, created: 4.2.
     */
    FACCMastercard,

    /**
     @abstract  Copyright
     @discussion id: copyright, unicode: f1f9, created: 4.2.
     */
    FACopyright,

    /**
     @abstract  LineChart
     @discussion id: linechart, unicode: f201, created: 4.2.
     */
    FALineChart,

    /**
     @abstract  Paypal
     @discussion id: paypal, unicode: f1ed, created: 4.2.
     */
    FAPaypal,

    /**
     @abstract  ToggleOn
     @discussion id: toggleon, unicode: f205, created: 4.2.
     */
    FAToggleOn,

    /**
     @abstract  Wifi
     @discussion id: wifi, unicode: f1eb, created: 4.2.
     */
    FAWifi,

    /**
     @abstract  At
     @discussion id: at, unicode: f1fa, created: 4.2.
     */
    FAAt,

    /**
     @abstract  Binoculars
     @discussion id: binoculars, unicode: f1e5, created: 4.2.
     */
    FABinoculars,

    /**
     @abstract  CC
     @discussion id: cc, unicode: f20a, created: 4.2.
     */
    FACc,

    /**
     @abstract  CCPaypal
     @discussion id: ccpaypal, unicode: f1f4, created: 4.2.
     */
    FACcpaypal,

    /**
     @abstract  EyeDropper
     @discussion id: eyedropper, unicode: f1fb, created: 4.2.
     */
    FAEyeDropper,

    /**
     @abstract  IoxHost
     @discussion id: ioxhost, unicode: f208, created: 4.2.
     */
    FAIoxHost,

    /**
     @abstract  MeanPath
     @discussion id: meanpath, unicode: f20c, created: 4.2.
     */
    FAMeanPath,

    /**
     @abstract  PieChart
     @discussion id: piechart, unicode: f200, created: 4.2.
     */
    FAPieChart,

    /**
     @abstract  Slideshare
     @discussion id: slideshare, unicode: f1e7, created: 4.2.
     */
    FASlideShare,

    /**
     @abstract  Trash
     @discussion id: trash, unicode: f1f8, created: 4.2.
     */
    FATrash,

    /**
     @abstract  Yelp
     @discussion id: yelp, unicode: f1e9, created: 4.2.
     */
    FAYelp,

    /**
     @abstract  BellSlash
     @discussion id: bellslash, unicode: f1f6, created: 4.2.
     */
    FABellSlash,

    /**
     @abstract  BirthdayCake
     @discussion id: birthdaycake, unicode: f1fd, created: 4.2.
     */
    FABirthdayCake,

    /**
     @abstract  CCAmex
     @discussion id: ccamex, unicode: f1f3, created: 4.2.
     */
    FACCAmex,

    /**
     @abstract  CCStripe
     @discussion id: ccstripe, unicode: f1f5, created: 4.2.
     */
    FACCStripe,

    /**
     @abstract  FutbolO
     @discussion id: futbolo, unicode: f1e3, created: 4.2.
     */
    FAFutbolO,

    /**
     @abstract  LastFM
     @discussion id: lastfm, unicode: f202, created: 4.2.
     */
    FALastFM,

    /**
     @abstract  NewspaperO
     @discussion id: newspapero, unicode: f1ea, created: 4.2.
     */
    FANewspaperO,

    /**
     @abstract  Plug
     @discussion id: plug, unicode: f1e6, created: 4.2.
     */
    FAPlug,

    /**
     @abstract  TTY
     @discussion id: tty, unicode: f1e4, created: 4.2.
     */
    FATty,
};



@interface NSString (FontAwesome)

/**
 @abstract Returns the correct enum for a font-awesome icon.
 @discussion The list of identifiers can be found here: http://fortawesome.github.com/Font-Awesome/#all-icons 
 */
+ (FAIcon)fontAwesomeEnumForIconIdentifier:(NSString*)string;

/**
 @abstract Returns the font-awesome character associated to the icon enum passed as argument 
 */
+ (NSString*)fontAwesomeIconStringForEnum:(FAIcon)value;

/* 
 @abstract Returns the font-awesome character associated to the font-awesome identifier.
 @discussion The list of identifiers can be found here: http://fortawesome.github.com/Font-Awesome/#all-icons
 */
+ (NSString*)fontAwesomeIconStringForIconIdentifier:(NSString*)identifier;

@end
