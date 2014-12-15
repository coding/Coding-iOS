//
//  NSString+FontAwesome.m
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

#import "NSString+FontAwesome.h"

@implementation NSString (FontAwesome)

#pragma mark - Public API
+ (FAIcon)fontAwesomeEnumForIconIdentifier:(NSString*)string {
    NSDictionary *enums = [self enumDictionary];
    return [enums[string] integerValue];
}

+ (NSString*)fontAwesomeIconStringForEnum:(FAIcon)value {
    return [NSString fontAwesomeUnicodeStrings][value];
}

+ (NSString*)fontAwesomeIconStringForIconIdentifier:(NSString*)identifier {
    return [self fontAwesomeIconStringForEnum:[self fontAwesomeEnumForIconIdentifier:identifier]];
}

#pragma mark - Data Initialization
+ (NSArray *)fontAwesomeUnicodeStrings {
    
    static NSArray *fontAwesomeUnicodeStrings;
    
    static dispatch_once_t unicodeStringsOnceToken;
    dispatch_once(&unicodeStringsOnceToken, ^{
        
        fontAwesomeUnicodeStrings = @[@"\uf000", @"\uf001", @"\uf002", @"\uf003", @"\uf004", @"\uf005", @"\uf006", @"\uf007", @"\uf008", @"\uf009",
                                      @"\uf00a", @"\uf00b", @"\uf00c", @"\uf00d", @"\uf00e", @"\uf010", @"\uf011", @"\uf011", @"\uf012", @"\uf013",
                                      @"\uf013", @"\uf014", @"\uf015", @"\uf016", @"\uf017", @"\uf018", @"\uf019", @"\uf01a", @"\uf01b", @"\uf01c",
                                      @"\uf01d", @"\uf01e", @"\uf01e", @"\uf021", @"\uf022", @"\uf023", @"\uf024", @"\uf025", @"\uf026", @"\uf027",
                                      @"\uf028", @"\uf029", @"\uf02a", @"\uf02b", @"\uf02c", @"\uf02d", @"\uf02e", @"\uf02f", @"\uf030", @"\uf031",
                                      @"\uf032", @"\uf033", @"\uf034", @"\uf035", @"\uf036", @"\uf037", @"\uf038", @"\uf039", @"\uf03a", @"\uf03b",
                                      @"\uf03c", @"\uf03d", @"\uf03e", @"\uf040", @"\uf041", @"\uf042", @"\uf043", @"\uf044", @"\uf045", @"\uf046",
                                      @"\uf047", @"\uf048", @"\uf049", @"\uf04a", @"\uf04b", @"\uf04c", @"\uf04d", @"\uf04e", @"\uf050", @"\uf051",
                                      @"\uf052", @"\uf053", @"\uf054", @"\uf055", @"\uf056", @"\uf057", @"\uf058", @"\uf059", @"\uf05a", @"\uf05b",
                                      @"\uf05c", @"\uf05d", @"\uf05e", @"\uf060", @"\uf061", @"\uf062", @"\uf063", @"\uf064", @"\uf064", @"\uf065",
                                      @"\uf066", @"\uf067", @"\uf068", @"\uf069", @"\uf06a", @"\uf06b", @"\uf06c", @"\uf06d", @"\uf06e", @"\uf070",
                                      @"\uf071", @"\uf072", @"\uf073", @"\uf074", @"\uf075", @"\uf076", @"\uf077", @"\uf078", @"\uf079", @"\uf07a",
                                      @"\uf07b", @"\uf07c", @"\uf07d", @"\uf07e", @"\uf080", @"\uf081", @"\uf082", @"\uf083", @"\uf084", @"\uf085",
                                      @"\uf085", @"\uf086", @"\uf087", @"\uf088", @"\uf089", @"\uf08a", @"\uf08b", @"\uf08c", @"\uf08d", @"\uf08e",
                                      @"\uf090", @"\uf091", @"\uf092", @"\uf093", @"\uf094", @"\uf095", @"\uf096", @"\uf096", @"\uf097", @"\uf098",
                                      @"\uf099", @"\uf09a", @"\uf09b", @"\uf09c", @"\uf09d", @"\uf09e", @"\uf0a0", @"\uf0a1", @"\uf0a2", @"\uf0a3",
                                      @"\uf0a4", @"\uf0a5", @"\uf0a6", @"\uf0a7", @"\uf0a8", @"\uf0a9", @"\uf0aa", @"\uf0ab", @"\uf0ac", @"\uf0ad",
                                      @"\uf0ae", @"\uf0b0", @"\uf0b1", @"\uf0b2", @"\uf0c0", @"\uf0c1", @"\uf0c2", @"\uf0c3", @"\uf0c4", @"\uf0c5",
                                      @"\uf0c6", @"\uf0c7", @"\uf0c8", @"\uf0c9", @"\uf0ca", @"\uf0cb", @"\uf0cc", @"\uf0cd", @"\uf0ce", @"\uf0d0",
                                      @"\uf0d1", @"\uf0d2", @"\uf0d3", @"\uf0d4", @"\uf0d5", @"\uf0d6", @"\uf0d7", @"\uf0d8", @"\uf0d9", @"\uf0da",
                                      @"\uf0db", @"\uf0dc", @"\uf0dd", @"\uf0de", @"\uf0e0", @"\uf0e1", @"\uf0e2", @"\uf0e2", @"\uf0e3", @"\uf0e4",
                                      @"\uf0e5", @"\uf0e6", @"\uf0e7", @"\uf0e8", @"\uf0e9", @"\uf0ea", @"\uf0eb", @"\uf0ec", @"\uf0ed", @"\uf0ee",
                                      @"\uf0f0", @"\uf0f1", @"\uf0f2", @"\uf0f3", @"\uf0f4", @"\uf0f5", @"\uf0f6", @"\uf0f7", @"\uf0f8", @"\uf0f9",
                                      @"\uf0fa", @"\uf0fb", @"\uf0fc", @"\uf0fd", @"\uf0fe", @"\uf100", @"\uf101", @"\uf102", @"\uf103", @"\uf104",
                                      @"\uf105", @"\uf106", @"\uf107", @"\uf108", @"\uf109", @"\uf10a", @"\uf10b", @"\uf10c", @"\uf10d", @"\uf10e",
                                      @"\uf110", @"\uf111", @"\uf112", @"\uf112", @"\uf113", @"\uf114", @"\uf115", @"\uf116", @"\uf117", @"\uf118",
                                      @"\uf119", @"\uf11a", @"\uf11b", @"\uf11c", @"\uf11d", @"\uf11e", @"\uf120", @"\uf121", @"\uf122", @"\uf122",
                                      @"\uf123", @"\uf123", @"\uf124", @"\uf125", @"\uf126", @"\uf127", @"\uf128", @"\uf129", @"\uf12a", @"\uf12b",
                                      @"\uf12c", @"\uf12d", @"\uf12e", @"\uf130", @"\uf131", @"\uf132", @"\uf133", @"\uf134", @"\uf135", @"\uf136",
                                      @"\uf137", @"\uf138", @"\uf139", @"\uf13a", @"\uf13b", @"\uf13c", @"\uf13d", @"\uf13e", @"\uf140", @"\uf141",
                                      @"\uf142", @"\uf143", @"\uf144", @"\uf145", @"\uf146", @"\uf147", @"\uf148", @"\uf149", @"\uf14a", @"\uf14b",
                                      @"\uf14c", @"\uf14d", @"\uf14e", @"\uf150", @"\uf151", @"\uf152", @"\uf153", @"\uf153", @"\uf154", @"\uf155",
                                      @"\uf155", @"\uf156", @"\uf156", @"\uf157", @"\uf157", @"\uf158", @"\uf158", @"\uf159", @"\uf159", @"\uf15a",
                                      @"\uf15a", @"\uf15a", @"\uf15b", @"\uf15c", @"\uf15d", @"\uf15e", @"\uf160", @"\uf161", @"\uf162", @"\uf163",
                                      @"\uf164", @"\uf165", @"\uf166", @"\uf167", @"\uf168", @"\uf169", @"\uf16a", @"\uf16b", @"\uf16c", @"\uf16d",
                                      @"\uf16e", @"\uf170", @"\uf171", @"\uf172", @"\uf173", @"\uf174", @"\uf175", @"\uf176", @"\uf177", @"\uf178",
                                      @"\uf179", @"\uf17a", @"\uf17b", @"\uf17c", @"\uf17d", @"\uf17e", @"\uf180", @"\uf181", @"\uf182", @"\uf183",
                                      @"\uf184", @"\uf185", @"\uf186", @"\uf187", @"\uf188", @"\uf189", @"\uf18a", @"\uf18b", @"\uf209", @"\uf207",
                                      @"\uf1f2", @"\uf1ee", @"\uf203", @"\uf1fc", @"\uf20b", @"\uf204", @"\uf1e8", @"\uf1fe", @"\uf206", @"\uf1ec",
                                      @"\uf1f1", @"\uf1f9", @"\uf201", @"\uf1ed", @"\uf205", @"\uf1eb", @"\uf1fa", @"\uf1e5", @"\uf20a", @"\uf1f4",
                                      @"\uf1fb", @"\uf208", @"\uf20c", @"\uf200", @"\uf1e7", @"\uf1f8", @"\uf1e9", @"\uf1f6", @"\uf1fd", @"\uf1f3",
                                      @"\uf1f5", @"\uf1e3", @"\uf202", @"\uf1ea", @"\uf1e6", @"\uf1e4"];

    });
    
    return fontAwesomeUnicodeStrings;
}

+ (NSDictionary *)enumDictionary {
    
	static NSDictionary *enumDictionary;
    
    static dispatch_once_t enumDictionaryOnceToken;
    dispatch_once(&enumDictionaryOnceToken, ^{
        
		NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];        
        tmp[@"icon-glass"]          = @(FAIconGlass);
        tmp[@"icon-music"]          = @(FAIconMusic);
        tmp[@"icon-search"]         = @(FAIconSearch);
        tmp[@"icon-envelope-alt"]   = @(FAIconEnvelopeAlt);
        tmp[@"icon-heart"]          = @(FAIconHeart);
        tmp[@"icon-star"]           = @(FAIconStar);
        tmp[@"icon-star-empty"]     = @(FAIconStarEmpty);
        tmp[@"icon-user"]           = @(FAIconUser);
        tmp[@"icon-film"]           = @(FAIconFilm);
        tmp[@"icon-th-large"]       = @(FAIconThLarge);
        tmp[@"icon-th"]             = @(FAIconTh);
        tmp[@"icon-th-list"]        = @(FAIconThList);
        tmp[@"icon-ok"]             = @(FAIconOk);
        tmp[@"icon-remove"]         = @(FAIconRemove);
        tmp[@"icon-zoom-in"]        = @(FAIconZoomIn);
        tmp[@"icon-zoom-out"]       = @(FAIconZoomOut);
        tmp[@"icon-off"]            = @(FAIconOff);
        tmp[@"icon-power-off"]      = @(FAIconPowerOff);
        tmp[@"icon-signal"]         = @(FAIconSignal);
        tmp[@"icon-cog"]            = @(FAIconCog);
        tmp[@"icon-Gear"]           = @(FAIconGear);
        tmp[@"icon-trash"]          = @(FAIconTrash);
        tmp[@"icon-home"]           = @(FAIconHome);
        tmp[@"icon-file-alt"]       = @(FAIconFileAlt);
        tmp[@"icon-time"]           = @(FAIconTime);
        tmp[@"icon-road"]           = @(FAIconRoad);
        tmp[@"icon-download-alt"]   = @(FAIconDownloadAlt);
        tmp[@"icon-download"]       = @(FAIconDownload);
        tmp[@"icon-upload"]         = @(FAIconUpload);
        tmp[@"icon-inbox"]          = @(FAIconInbox);
        tmp[@"icon-play-circle"]    = @(FAIconPlayCircle);
        tmp[@"icon-repeat"]         = @(FAIconRepeat);
        tmp[@"icon-rotate-right"]   = @(FAIconRotateRight);
        tmp[@"icon-refresh"]        = @(FAIconRefresh);
        tmp[@"icon-list-alt"]       = @(FAIconListAlt);
        tmp[@"icon-lock"]           = @(FAIconLock);
        tmp[@"icon-flag"]           = @(FAIconFlag);
        tmp[@"icon-headphones"]     = @(FAIconHeadphones);
        tmp[@"icon-volume-off"]     = @(FAIconVolumeOff);
        tmp[@"icon-volume-down"]    = @(FAIconVolumeDown);
        tmp[@"icon-volume-up"]      = @(FAIconVolumeUp);
        tmp[@"icon-qrcode"]         = @(FAIconQrcode);
        tmp[@"icon-barcode"]        = @(FAIconBarcode);
        tmp[@"icon-tag"]            = @(FAIconTag);
        tmp[@"icon-tags"]           = @(FAIconTags);
        tmp[@"icon-book"]           = @(FAIconBook);
        tmp[@"icon-bookmark"]       = @(FAIconBookmark);
        tmp[@"icon-print"]          = @(FAIconPrint);
        tmp[@"icon-camera"]         = @(FAIconCamera);
        tmp[@"icon-font"]           = @(FAIconFont);
        tmp[@"icon-bold"]           = @(FAIconBold);
        tmp[@"icon-italic"]         = @(FAIconItalic);
        tmp[@"icon-text-height"]    = @(FAIconTextHeight);
        tmp[@"icon-text-width"]     = @(FAIconTextWidth);
        tmp[@"icon-align-left"]     = @(FAIconAlignLeft);
        tmp[@"icon-align-center"]   = @(FAIconAlignCenter);
        tmp[@"icon-align-right"]    = @(FAIconAlignRight);
        tmp[@"icon-align-justify"]  = @(FAIconAlignJustify);
        tmp[@"icon-list"]           = @(FAIconList);
        tmp[@"icon-indent-left"]    = @(FAIconIndentLeft);
        tmp[@"icon-indent-right"]   = @(FAIconIndentRight);
        tmp[@"icon-facetime-video"] = @(FAIconFacetimeVideo);
        tmp[@"icon-picture"]        = @(FAIconPicture);
        tmp[@"icon-pencil"]         = @(FAIconPencil);
        tmp[@"icon-map-marker"]     = @(FAIconMapMarker);
        tmp[@"icon-adjust"]         = @(FAIconAdjust);
        tmp[@"icon-tint"]           = @(FAIconTint);
        tmp[@"icon-edit"]           = @(FAIconEdit);
        tmp[@"icon-share"]          = @(FAIconShare);
        tmp[@"icon-check"]          = @(FAIconCheck);
        tmp[@"icon-move"]           = @(FAIconMove);
        tmp[@"icon-step-backward"]  = @(FAIconStepBackward);
        tmp[@"icon-fast-backward"]  = @(FAIconFastBackward);
        tmp[@"icon-backward"]       = @(FAIconBackward);
        tmp[@"icon-play"]           = @(FAIconPlay);
        tmp[@"icon-pause"]          = @(FAIconPause);
        tmp[@"icon-stop"]           = @(FAIconStop);
        tmp[@"icon-forward"]        = @(FAIconForward);
        tmp[@"icon-fast-forward"]   = @(FAIconFastForward);
        tmp[@"icon-step-forward"]   = @(FAIconStepForward);
        tmp[@"icon-eject"]          = @(FAIconEject);
        tmp[@"icon-chevron-left"]   = @(FAIconChevronLeft);
        tmp[@"icon-chevron-right"]  = @(FAIconChevronRight);
        tmp[@"icon-plus-sign"]      = @(FAIconPlusSign);
        tmp[@"icon-minus-sign"]     = @(FAIconMinusSign);
        tmp[@"icon-remove-sign"]    = @(FAIconRemoveSign);
        tmp[@"icon-ok-sign"]        = @(FAIconOkSign);
        tmp[@"icon-question-sign"]  = @(FAIconQuestionSign);
        tmp[@"icon-info-sign"]      = @(FAIconInfoSign);
        tmp[@"icon-screenshot"]     = @(FAIconScreenshot);
        tmp[@"icon-remove-circle"]  = @(FAIconRemoveCircle);
        tmp[@"icon-ok-circle"]      = @(FAIconOkCircle);
        tmp[@"icon-ban-circle"]     = @(FAIconBanCircle);
        tmp[@"icon-arrow-left"]     = @(FAIconArrowLeft);
        tmp[@"icon-arrow-right"]    = @(FAIconArrowRight);
        tmp[@"icon-arrow-up"]       = @(FAIconArrowUp);
        tmp[@"icon-arrow-down"]     = @(FAIconArrowDown);
        tmp[@"icon-share-alt"]      = @(FAIconShareAlt);
        tmp[@"icon-mail-forward"]   = @(FAIconMailForward);
        tmp[@"icon-resize-full"]    = @(FAIconResizeFull);
        tmp[@"icon-resize-small"]   = @(FAIconResizeSmall);
        tmp[@"icon-plus"]           = @(FAIconPlus);
        tmp[@"icon-minus"]          = @(FAIconMinus);
        tmp[@"icon-asterisk"]       = @(FAIconAsterisk);
        tmp[@"icon-exclamation-sign"]       = @(FAIconExclamationSign);
        tmp[@"icon-gift"]           = @(FAIconGift);
        tmp[@"icon-leaf"]           = @(FAIconLeaf);
        tmp[@"icon-fire"]           = @(FAIconFire);
        tmp[@"icon-eye-open"]       = @(FAIconEyeOpen);
        tmp[@"icon-eye-close"]      = @(FAIconEyeClose);
        tmp[@"icon-warning-sign"]   = @(FAIconWarningSign);
        tmp[@"icon-plane"]          = @(FAIconPlane);
        tmp[@"icon-calendar"]       = @(FAIconCalendar);
        tmp[@"icon-random"]         = @(FAIconRandom);
        tmp[@"icon-comment"]        = @(FAIconComment);
        tmp[@"icon-magnet"]         = @(FAIconMagnet);
        tmp[@"icon-chevron-up"]     = @(FAIconChevronUp);
        tmp[@"icon-chevron-down"]   = @(FAIconChevronDown);
        tmp[@"icon-retweet"]        = @(FAIconRetweet);
        tmp[@"icon-shopping-cart"]  = @(FAIconShoppingCart);
        tmp[@"icon-folder-close"]   = @(FAIconFolderClose);
        tmp[@"icon-folder-open"]    = @(FAIconFolderOpen);
        tmp[@"icon-resize-vertical"]        = @(FAIconResizeVertical);
        tmp[@"icon-resize-horizontal"]      = @(FAIconResizeHorizontal);
        tmp[@"icon-bar-chart"]              = @(FAIconBarChart);
        tmp[@"icon-twitter-sign"]   = @(FAIconTwitterSign);
        tmp[@"icon-facebook-sign"]  = @(FAIconFacebookSign);
        tmp[@"icon-camera-retro"]   = @(FAIconCameraRetro);
        tmp[@"icon-key"]            = @(FAIconKey);
        tmp[@"icon-cogs"]           = @(FAIconCogs);
        tmp[@"icon-gears"]          = @(FAIconGears);
        tmp[@"icon-comments"]       = @(FAIconComments);
        tmp[@"icon-thumbs-up-alt"]  = @(FAIconThumbsUpAlt);
        tmp[@"icon-thumbs-down-alt"]        = @(FAIconThumbsDownAlt);
        tmp[@"icon-star-half"]      = @(FAIconStarHalf);
        tmp[@"icon-heart-empty"]    = @(FAIconHeartEmpty);
        tmp[@"icon-signout"]        = @(FAIconSignout);
        tmp[@"icon-linkedin-sign"]  = @(FAIconLinkedinSign);
        tmp[@"icon-pushpin"]        = @(FAIconPushpin);
        tmp[@"icon-external-link"]  = @(FAIconExternalLink);
        tmp[@"icon-signin"]         = @(FAIconSignin);
        tmp[@"icon-trophy"]         = @(FAIconTrophy);
        tmp[@"icon-github-sign"]    = @(FAIconGithubSign);
        tmp[@"icon-upload-alt"]     = @(FAIconUploadAlt);
        tmp[@"icon-lemon"]          = @(FAIconLemon);
        tmp[@"icon-phone"]          = @(FAIconPhone);
        tmp[@"icon-check-empty"]    = @(FAIconCheckEmpty);
        tmp[@"icon-unchecked"]      = @(FAIconUnchecked);
        tmp[@"icon-bookmark-empty"] = @(FAIconBookmarkEmpty);
        tmp[@"icon-phone-sign"]     = @(FAIconPhoneSign);
        tmp[@"icon-twitter"]        = @(FAIconTwitter);
        tmp[@"icon-facebook"]       = @(FAIconFacebook);
        tmp[@"icon-github"]         = @(FAIconGithub);
        tmp[@"icon-unlock"]         = @(FAIconUnlock);
        tmp[@"icon-credit-card"]    = @(FAIconCreditCard);
        tmp[@"icon-rss"]            = @(FAIconRss);
        tmp[@"icon-hdd"]            = @(FAIconHdd);
        tmp[@"icon-bullhorn"]       = @(FAIconBullhorn);
        tmp[@"icon-bell"]           = @(FAIconBell);
        tmp[@"icon-certificate"]    = @(FAIconCertificate);
        tmp[@"icon-hand-right"]     = @(FAIconHandRight);
        tmp[@"icon-hand-left"]      = @(FAIconHandLeft);
        tmp[@"icon-hand-up"]        = @(FAIconHandUp);
        tmp[@"icon-hand-down"]      = @(FAIconHandDown);
        tmp[@"icon-circle-arrow-left"]      = @(FAIconCircleArrowLeft);
        tmp[@"icon-circle-arrow-right"]     = @(FAIconCircleArrowRight);
        tmp[@"icon-circle-arrow-up"]        = @(FAIconCircleArrowUp);
        tmp[@"icon-circle-arrow-down"]      = @(FAIconCircleArrowDown);
        tmp[@"icon-globe"]          = @(FAIconGlobe);
        tmp[@"icon-wrench"]         = @(FAIconWrench);
        tmp[@"icon-tasks"]          = @(FAIconTasks);
        tmp[@"icon-filter"]         = @(FAIconFilter);
        tmp[@"icon-briefcase"]      = @(FAIconBriefcase);
        tmp[@"icon-fullscreen"]     = @(FAIconFullscreen);
        tmp[@"icon-group"]          = @(FAIconGroup);
        tmp[@"icon-link"]           = @(FAIconLink);
        tmp[@"icon-cloud"]          = @(FAIconCloud);
        tmp[@"icon-beaker"]         = @(FAIconBeaker);
        tmp[@"icon-cut"]            = @(FAIconCut);
        tmp[@"icon-copy"]           = @(FAIconCopy);
        tmp[@"icon-paper-clip"]     = @(FAIconPaperClip);
        tmp[@"icon-save"]           = @(FAIconSave);
        tmp[@"icon-sign-blank"]     = @(FAIconSignBlank);
        tmp[@"icon-reorder"]        = @(FAIconReorder);
        tmp[@"icon-list-ul"]        = @(FAIconListUl);
        tmp[@"icon-list-ol"]        = @(FAIconListOl);
        tmp[@"icon-strikethrough"]  = @(FAIconStrikethrough);
        tmp[@"icon-underline"]      = @(FAIconUnderline);
        tmp[@"icon-table"]          = @(FAIconTable);
        tmp[@"icon-magic"]          = @(FAIconMagic);
        tmp[@"icon-truck"]          = @(FAIconTruck);
        tmp[@"icon-pinterest"]      = @(FAIconPinterest);
        tmp[@"icon-pinterest-sign"] = @(FAIconPinterestSign);
        tmp[@"icon-google-plus-sign"]       = @(FAIconGooglePlusSign);
        tmp[@"icon-google-plus"]    = @(FAIconGooglePlus);
        tmp[@"icon-money"]          = @(FAIconMoney);
        tmp[@"icon-caret-down"]     = @(FAIconCaretDown);
        tmp[@"icon-caret-up"]       = @(FAIconCaretUp);
        tmp[@"icon-caret-left"]     = @(FAIconCaretLeft);
        tmp[@"icon-caret-right"]    = @(FAIconCaretRight);
        tmp[@"icon-columns"]        = @(FAIconColumns);
        tmp[@"icon-sort"]           = @(FAIconSort);
        tmp[@"icon-sort-down"]      = @(FAIconSortDown);
        tmp[@"icon-sort-up"]        = @(FAIconSortUp);
        tmp[@"icon-envelope"]       = @(FAIconEnvelope);
        tmp[@"icon-linkedin"]       = @(FAIconLinkedin);
        tmp[@"icon-undo"]           = @(FAIconUndo);
        tmp[@"icon-rotate-left"]    = @(FAIconRotateLeft);
        tmp[@"icon-legal"]          = @(FAIconLegal);
        tmp[@"icon-dashboard"]      = @(FAIconDashboard);
        tmp[@"icon-comment-alt"]    = @(FAIconCommentAlt);
        tmp[@"icon-comments-alt"]   = @(FAIconCommentsAlt);
        tmp[@"icon-bolt"]           = @(FAIconBolt);
        tmp[@"icon-sitemap"]        = @(FAIconSitemap);
        tmp[@"icon-umbrella"]       = @(FAIconUmbrella);
        tmp[@"icon-paste"]          = @(FAIconPaste);
        tmp[@"icon-lightbulb"]      = @(FAIconLightbulb);
        tmp[@"icon-exchange"]       = @(FAIconExchange);
        tmp[@"icon-cloud-download"] = @(FAIconCloudDownload);
        tmp[@"icon-cloud-upload"]   = @(FAIconCloudUpload);
        tmp[@"icon-user-md"]        = @(FAIconUserMd);
        tmp[@"icon-stethoscope"]    = @(FAIconStethoscope);
        tmp[@"icon-suitcase"]       = @(FAIconSuitcase);
        tmp[@"icon-bell-alt"]       = @(FAIconBellAlt);
        tmp[@"icon-coffee"]         = @(FAIconCoffee);
        tmp[@"icon-food"]           = @(FAIconFood);
        tmp[@"icon-file-text-alt"]  = @(FAIconFileTextAlt);
        tmp[@"icon-building"]       = @(FAIconBuilding);
        tmp[@"icon-hospital"]       = @(FAIconHospital);
        tmp[@"icon-ambulance"]      = @(FAIconAmbulance);
        tmp[@"icon-medkit"]         = @(FAIconMedkit);
        tmp[@"icon-fighter-jet"]    = @(FAIconFighterJet);
        tmp[@"icon-beer"]           = @(FAIconBeer);
        tmp[@"icon-h-sign"]         = @(FAIconHSign);
        tmp[@"icon-plus-sign-alt"]  = @(FAIconPlusSignAlt);
        tmp[@"icon-double-angle-left"]      = @(FAIconDoubleAngleLeft);
        tmp[@"icon-double-angle-right"]     = @(FAIconDoubleAngleRight);
        tmp[@"icon-double-angle-up"]        = @(FAIconDoubleAngleUp);
        tmp[@"icon-double-angle-down"]      = @(FAIconDoubleAngleDown);
        tmp[@"icon-angle-left"]     = @(FAIconAngleLeft);
        tmp[@"icon-angle-right"]    = @(FAIconAngleRight);
        tmp[@"icon-angle-up"]       = @(FAIconAngleUp);
        tmp[@"icon-angle-down"]     = @(FAIconAngleDown);
        tmp[@"icon-desktop"]        = @(FAIconDesktop);
        tmp[@"icon-laptop"]         = @(FAIconLaptop);
        tmp[@"icon-tablet"]         = @(FAIconTablet);
        tmp[@"icon-mobile-phone"]   = @(FAIconMobilePhone);
        tmp[@"icon-circle-blank"]   = @(FAIconCircleBlank);
        tmp[@"icon-quote-left"]     = @(FAIconQuoteLeft);
        tmp[@"icon-quote-right"]    = @(FAIconQuoteRight);
        tmp[@"icon-spinner"]        = @(FAIconSpinner);
        tmp[@"icon-circle"]         = @(FAIconCircle);
        tmp[@"icon-reply"]          = @(FAIconReply);
        tmp[@"icon-mail-reply"]     = @(FAIconMailReply);
        tmp[@"icon-github-alt"]     = @(FAIconGithubAlt);
        tmp[@"icon-folder-close-alt"]       = @(FAIconFolderCloseAlt);
        tmp[@"icon-folder-open-alt"]        = @(FAIconFolderOpenAlt);
        tmp[@"icon-expand-alt"]     = @(FAIconExpandAlt);
        tmp[@"icon-collapse-alt"]   = @(FAIconCollapseAlt);
        tmp[@"icon-smile"]          = @(FAIconSmile);
        tmp[@"icon-frown"]          = @(FAIconFrown);
        tmp[@"icon-meh"]            = @(FAIconMeh);
        tmp[@"icon-gamepad"]        = @(FAIconGamepad);
        tmp[@"icon-keyboard"]       = @(FAIconKeyboard);
        tmp[@"icon-flag-alt"]       = @(FAIconFlagAlt);
        tmp[@"icon-flag-checkered"] = @(FAIconFlagCheckered);
        tmp[@"icon-terminal"]       = @(FAIconTerminal);
        tmp[@"icon-code"]           = @(FAIconCode);
        tmp[@"icon-reply-all"]      = @(FAIconReplyAll);
        tmp[@"icon-mail-reply-all"] = @(FAIconMailReplyAll);
        tmp[@"icon-star-half-empty"]        = @(FAIconStarHalfEmpty);
        tmp[@"icon-star-half-full"] = @(FAIconStarHalfFull);
        tmp[@"icon-location-arrow"] = @(FAIconLocationArrow);
        tmp[@"icon-crop"]           = @(FAIconCrop);
        tmp[@"icon-code-fork"]      = @(FAIconCodeFork);
        tmp[@"icon-unlink"]         = @(FAIconUnlink);
        tmp[@"icon-question"]       = @(FAIconQuestion);
        tmp[@"icon-info"]           = @(FAIconInfo);
        tmp[@"icon-exclamation"]    = @(FAIconExclamation);
        tmp[@"icon-superscript"]    = @(FAIconSuperscript);
        tmp[@"icon-subscript"]      = @(FAIconSubscript);
        tmp[@"icon-eraser"]         = @(FAIconEraser);
        tmp[@"icon-puzzle-piece"]   = @(FAIconPuzzlePiece);
        tmp[@"icon-microphone"]     = @(FAIconMicrophone);
        tmp[@"icon-microphone-off"] = @(FAIconMicrophoneOff);
        tmp[@"icon-shield"]         = @(FAIconShield);
        tmp[@"icon-calendar-empty"] = @(FAIconCalendarEmpty);
        tmp[@"icon-fire-extinguisher"]      = @(FAIconFireExtinguisher);
        tmp[@"icon-rocket"]         = @(FAIconRocket);
        tmp[@"icon-maxcdn"]         = @(FAIconMaxcdn);
        tmp[@"icon-chevron-sign-left"]      = @(FAIconChevronSignLeft);
        tmp[@"icon-chevron-sign-right"]     = @(FAIconChevronSignRight);
        tmp[@"icon-chevron-sign-up"]        = @(FAIconChevronSignUp);
        tmp[@"icon-chevron-sign-down"]      = @(FAIconChevronSignDown);
        tmp[@"icon-html5"]          = @(FAIconHtml5);
        tmp[@"icon-css3"]           = @(FAIconCss3);
        tmp[@"icon-anchor"]         = @(FAIconAnchor);
        tmp[@"icon-unlock-alt"]     = @(FAIconUnlockAlt);
        tmp[@"icon-bullseye"]       = @(FAIconBullseye);
        tmp[@"icon-ellipsis-horizontal"]    = @(FAIconEllipsisHorizontal);
        tmp[@"icon-ellipsis-vertical"]      = @(FAIconEllipsisVertical);
        tmp[@"icon-rss-sign"]       = @(FAIconRssSign);
        tmp[@"icon-play-sign"]      = @(FAIconPlaySign);
        tmp[@"icon-ticket"]         = @(FAIconTicket);
        tmp[@"icon-minus-sign-alt"] = @(FAIconMinusSignAlt);
        tmp[@"icon-check-minus"]    = @(FAIconCheckMinus);
        tmp[@"icon-level-up"]       = @(FAIconLevelUp);
        tmp[@"icon-level-down"]     = @(FAIconLevelDown);
        tmp[@"icon-check-sign"]     = @(FAIconCheckSign);
        tmp[@"icon-edit-sign"]      = @(FAIconEditSign);
        tmp[@"icon-external-link-sign"]     = @(FAIconExternalLinkSign);
        tmp[@"icon-share-sign"]     = @(FAIconShareSign);
        tmp[@"icon-compass"]        = @(FAIconCompass);
        tmp[@"icon-collapse"]       = @(FAIconCollapse);
        tmp[@"icon-collapse-top"]   = @(FAIconCollapseTop);
        tmp[@"icon-expand"]         = @(FAIconExpand);
        tmp[@"icon-eur"]            = @(FAIconEur);
        tmp[@"icon-euro"]           = @(FAIconEuro);
        tmp[@"icon-gbp"]            = @(FAIconGbp);
        tmp[@"icon-usd"]            = @(FAIconUsd);
        tmp[@"icon-dollar"]         = @(FAIconDollar);
        tmp[@"icon-inr"]            = @(FAIconInr);
        tmp[@"icon-rupee"]          = @(FAIconRupee);
        tmp[@"icon-jpy"]            = @(FAIconJpy);
        tmp[@"icon-yen"]            = @(FAIconYen);
        tmp[@"icon-cny"]            = @(FAIconCny);
        tmp[@"icon-renminbi"]       = @(FAIconRenminbi);
        tmp[@"icon-krw"]            = @(FAIconKrw);
        tmp[@"icon-won"]            = @(FAIconWon);
        tmp[@"icon-btc"]            = @(FAIconBtc);
        tmp[@"icon-bitcoin"]        = @(FAIconBitcoin);
        tmp[@"icon-brand-icons"]    = @(FAIconBrandIcons);
        tmp[@"icon-file"]           = @(FAIconFile);
        tmp[@"icon-file-text"]      = @(FAIconFileText);
        tmp[@"icon-sort-by-alphabet"]       = @(FAIconSortByAlphabet);
        tmp[@"icon-sort-by-alphabet-alt"]   = @(FAIconSortByAlphabetAlt);
        tmp[@"icon-sort-by-attributes"]     = @(FAIconSortByAttributes);
        tmp[@"icon-sort-by-attributes-alt"] = @(FAIconSortByAttributesAlt);
        tmp[@"icon-sort-by-order"]          = @(FAIconSortByOrder);
        tmp[@"icon-sort-by-order-alt"]      = @(FAIconSortByOrderAlt);
        tmp[@"icon-thumbs-up"]      = @(FAIconThumbsUp);
        tmp[@"icon-thumbs-down"]    = @(FAIconThumbsDown);
        tmp[@"icon-youtube-sign"]   = @(FAIconYoutubeSign);
        tmp[@"icon-youtube"]        = @(FAIconYoutube);
        tmp[@"icon-xing"]           = @(FAIconXing);
        tmp[@"icon-xing-sign"]      = @(FAIconXingSign);
        tmp[@"icon-youtube-play"]   = @(FAIconYoutubePlay);
        tmp[@"icon-dropbox"]        = @(FAIconDropbox);
        tmp[@"icon-stackexchange"]  = @(FAIconStackexchange);
        tmp[@"icon-instagram"]      = @(FAIconInstagram);
        tmp[@"icon-flickr"]         = @(FAIconFlickr);
        tmp[@"icon-adn"]            = @(FAIconAdn);
        tmp[@"icon-bitbucket"]      = @(FAIconBitbucket);
        tmp[@"icon-bitbucket-sign"] = @(FAIconBitbucketSign);
        tmp[@"icon-tumblr"]         = @(FAIconTumblr);
        tmp[@"icon-tumblr-sign"]    = @(FAIconTumblrSign);
        tmp[@"icon-long-arrow-down"]        = @(FAIconLongArrowDown);
        tmp[@"icon-long-arrow-up"]          = @(FAIconLongArrowUp);
        tmp[@"icon-long-arrow-left"]        = @(FAIconLongArrowLeft);
        tmp[@"icon-long-arrow-right"]       = @(FAIconLongArrowRight);
        tmp[@"icon-apple"]          = @(FAIconApple);
        tmp[@"icon-windows"]        = @(FAIconWindows);
        tmp[@"icon-android"]        = @(FAIconAndroid);
        tmp[@"icon-linux"]          = @(FAIconLinux);
        tmp[@"icon-dribbble"]       = @(FAIconDribbble);
        tmp[@"icon-skype"]          = @(FAIconSkype);
        tmp[@"icon-foursquare"]     = @(FAIconFoursquare);
        tmp[@"icon-trello"]         = @(FAIconTrello);
        tmp[@"icon-female"]         = @(FAIconFemale);
        tmp[@"icon-male"]           = @(FAIconMale);
        tmp[@"icon-gittip"]         = @(FAIconGittip);
        tmp[@"icon-sun"]            = @(FAIconSun);
        tmp[@"icon-moon"]           = @(FAIconMoon);
        tmp[@"icon-archive"]        = @(FAIconArchive);
        tmp[@"icon-bug"]            = @(FAIconBug);
        tmp[@"icon-vk"]             = @(FAIconVk);
        tmp[@"icon-weibo"]          = @(FAIconWeibo);
        tmp[@"icon-renren"]         = @(FAIconRenren);
        tmp[@"icon-angel-list"]     = @(FAIconAngelList);
        tmp[@"icon-bus"]     = @(FAIconBus);
        tmp[@"icon-cc-discover"]     = @(FACCDiscover);
        tmp[@"icon-google-wallet"]     = @(FAGoogleWallet);
        tmp[@"icon-last-fm-square"]     = @(FALastFMSquare);
        tmp[@"icon-paint-brush"]     = @(FAPaintBrush);
        tmp[@"icon-ils"]     = @(FAIls);
        tmp[@"icon-toggle-off"]     = @(FAToggleOff);
        tmp[@"icon-switch"]     = @(FATwitch);
        tmp[@"icon-area-chart"]     = @(FAAreaChart);
        tmp[@"icon-bicycle"]     = @(FABicycle);
        tmp[@"icon-calculator"]     = @(FACalculator);
        tmp[@"icon-cc-mastercard"]     = @(FACCMastercard);
        tmp[@"icon-copyright"]     = @(FACopyright);
        tmp[@"icon-line-chart"]     = @(FALineChart);
        tmp[@"icon-paypal"]     = @(FAPaypal);
        tmp[@"icon-toggle-on"]     = @(FAToggleOn);
        tmp[@"icon-wifi"]     = @(FAWifi);
        tmp[@"icon-at"]     = @(FAAt);
        tmp[@"icon-binoculars"]     = @(FABinoculars);
        tmp[@"icon-cc"]     = @(FACc);
        tmp[@"icon-cc-paypal"]     = @(FACcpaypal);
        tmp[@"icon-eye-dropper"]     = @(FAEyeDropper);
        tmp[@"icon-iox-host"]     = @(FAIoxHost);
        tmp[@"icon-mean-path"]     = @(FAMeanPath);
        tmp[@"icon-pie-chart"]     = @(FAPieChart);
        tmp[@"icon-slide-share"]     = @(FASlideShare);
        tmp[@"icon-trash"]     = @(FATrash);
        tmp[@"icon-yelp"]     = @(FAYelp);
        tmp[@"icon-bell-slash"]     = @(FABellSlash);
        tmp[@"icon-birthday-cake"]     = @(FABirthdayCake);
        tmp[@"icon-cc-amex"]     = @(FACCAmex);
        tmp[@"icon-cc-stripe"]     = @(FACCStripe);
        tmp[@"icon-futbol-o"]     = @(FAFutbolO);
        tmp[@"icon-last-fm"]     = @(FALastFM);
        tmp[@"icon-newspaper-o"]     = @(FANewspaperO);
        tmp[@"icon-plug"]     = @(FAPlug);
        tmp[@"icon-tty"]     = @(FATty);
		enumDictionary = tmp;
	});
    
    return enumDictionary;
}

@end
