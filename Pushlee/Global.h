//
//  Global.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#ifndef Pushlee_Global_h
#define Pushlee_Global_h

//*****************Parse Keys**************
#define PARSE_APPLICATION_ID                        @"LpbkxLf---------------------YKvQMFw17Iy0"
#define PARSE_CLIENT_KEY                            @"IuSt0t3---------------------EHeIub3OL9Lj"

//*****************NSUserDefaults Keys**************
#define DEFAULT_FIRST_RUN                           @"UserDefaultFirstRun"
#define DEFAULT_USER_LOGGED                         @"UserDefaultAlreadyLogged"
#define DEFAULT_DEAL_SURVEY                         @"UserDefaultDealSurvey"
#define DEFAULT_INIT_STATION                        @"UserDefaultInitStation"
#define DEFAULT_REWARD_LIST                         @"UserDefaultRewardList"
#define DEFAULT_REWARD_AVAILABLE                    @"UserDefaultRewardAvailable"

#define DEFAULT_DEAL_ID                             @"UserDefaultDealID"
#define DEFAULT_STATION_ID                          @"UserDefaultStationID"
#define DEFAULT_LAST_DEAL                           @"UserDefaultLastDeal"
#define DEFAULT_LAST_VISITED_DEAL                   @"UserDefaultLastVisitedDeal"
#define DEFAULT_LAST_VISITED_STATION                @"UserDefaultLastVisitedStation"

#define DEFAULT_GOT_PASSBOOK                        @"UserDefaultGotPassBook"
#define DEFAULT_FAVORITE_STORES                     @"UserDefaultFavoriteStores"

#define DEFAULT_FIRST_RECEIPT                       @"UserDefaultFirstReceipt"
#define DEFAULT_RECEIPT_TIME                        @"UserDefaultReceiptTime"
#define DEFAULT_RECEIPT_COUNT                       @"UserDefaultReceiptCount"

//*****************ViewControllers IDs**************
#define UITABBAR_CONTROLLER                         @"UITabBarController"
#define WALKTHROUGH_NAVIGATION_CONTROLLER           @"WalkThroughNavigationController"
#define LOGIN_NAVIGATION_CONTROLLER                 @"LoginNavigationController"
#define DEAL_SURVEY_NAVIGATION_CONTROLLER           @"DealSurveyNavigationController"

#define HELP_FRIENDS_VIEW_CONTROLLER                @"HelpFriendsViewController"
#define WALKTHROUGH_VIEW_CONTROLLER                 @"WalkThroughViewController"
#define INVITE_FRIENDS_VIEW_CONTROLLER              @"InviteFriendsViewController"
#define STATUS_VIEW_CONTROLLER                      @"StatusViewController"
#define PROFILE_VIEW_CONTROLLER                     @"ProfileViewController"
#define DEAL_SURVEY_VIEW_CONTROLLER                 @"DealSurveyViewController"
#define REDEEM_VIEW_CONTROLLER                      @"RedeemViewController"
#define SUGGESTION_VIEW_CONTROLLER                  @"SuggestStationViewController"
#define LEFT_MENU_VIEW_CONTROLLER                   @"LeftMenuTableViewController"
#define RIGHT_MENU_VIEW_CONTROLLER                  @"RightMenuTableViewController"
#define BARCORD_VIEW_CONTROLLER                     @"BarcodeViewController"
#define GET_MORE_REWARD_VIEW_CONTROLLER             @"GetMoreRewardViewController"
#define SCRATCH_VIEW_CONTROLLER                     @"ScratchViewController"
#define STATION_SELECT_VIEW_CONTROLLER              @"StationSelectViewController"
#define ADD_STORE_VIEW_CONTROLLER                   @"AddStoreViewController"

#define RECEIPT_VIEW_CONTROLLER                     @"ReceiptViewController"
#define RECEIPT_INTRO_VIEW_CONTROLLER               @"ReceiptIntroViewController"
#define RECEIPT_WINNER_VIEW_CONTROLLER              @"ReceiptWinnerViewController"
#define RECEIPT_LOSER_VIEW_CONTROLLER               @"ReceiptLoserViewController"

//***************** User Notification **************
#define NOTIFICATION_GOT_LOCATION                   @"NotificationGotLocation"
#define NOTIFICATION_GOT_REWARD                     @"NotificationGotReward"

//*****************App Constants**************
#define LOCATION_UPDATE_INTERVAL                    3600
#define FAVORITE_STORE_MAXIMUM                      10

#define PASS_BOOK_SERVER                            @"http://www.push---------------------------upon.php"
#define PASS_BOOK_IDENTIFIER                        @"pa-----------------upon"
#define PASS_BOOK_SERIALNUMBER                      @"100-------56"

//*****************Beacon Constants**************
#define KEY_LAST_UPDATE_ID                          @"KeyLastUpdateID"
#define KEY_BEACON_LIST                             @"KeyBeaconList"

#define WORK_STORE_LATITUDE                         42.4738609f
#define WORK_STORE_LONGITUDE                        -96.4007479f

#endif
