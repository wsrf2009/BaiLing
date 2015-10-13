//
//  BoxDatabase.h
//  CloudBox
//
//  Created by TTS on 15-4-14.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEST        0

#define DT_ITEM_BUYURL          @"buy_url"
#define DT_ITEM_HELPURL         @"help_url"
#define DT_ITEM_PRODUCTURL      @"product_url"
#define DT_ITEM_XMLYHELPURL     @"xmly_help_url"
#define DT_ITEM_WEIXINURL       @"weixin_url"

#define QUESTIONANSWER_ITEM_NAME            "name"
#define QUESTIONANSWER_ITEM_TIME            "time"
#define QUESTIONANSWER_ITEM_QUESTION        "question"
#define QUESTIONANSWER_ITEM_ANSWER          "answer"
#define QUESTIONANSWER_ITEM_HELPER          "helper"

#define PRODUCTINFO_PRODUCTID               @"productId"
#define PRODUCTINFO_TITLE                   @"title"
#define PRODUCTINFO_DESCRIPTION             @"description"
#define PRODUCTINFO_ICON                    @"icon"
#define PRODUCTINFO_URL                     @"url"
#define PRODUCTINFO_GUIDEIMAGE              @"guideImage"
#define PRODUCTINFO_LASTUPDATETIME          @"lastUpdateTime"
#define PRODUCTINFO_GUIDETYPE               @"guideType"

#if TEST
#define UDPSCANRESULT_ITEM_1    @"00E04CC972D0"/*黑*/
#define UDPSCANRESULT_ITEM_2    @"00E04CDD2EBD"/*光版常凯申*/
#define UDPSCANRESULT_ITEM_3    @"00E04CAC698D"/*乐乐小播语音智能台灯*/
#define UDPSCANRESULT_ITEM_4    @"00E04CB14AB7"/*白*/

#define TCPSCANRESULT_ITEM_1    @"00E04CC972D0"/*黑*/
#define TCPSCANRESULT_ITEM_2    @"00E04CDD2EBD"/*光版常凯申*/
#define TCPSCANRESULT_ITEM_3    @"00E04CAC698D"/*乐乐小播语音智能台灯*/
#define TCPSCANRESULT_ITEM_4    @"00E04CB14AB7"/*白*/
#endif
@interface BoxDatabase : NSObject

+ (BOOL)isFirstOpenTheApp;
+ (BOOL)insertOpenAppRecord:(NSString *)date;
+ (BOOL)addSSID:(NSString *)ssid withPassword:(NSString *) password;
+ (NSString *)getPasswordWithSSID:(NSString *)ssid;
+ (BOOL)updateUrl:(NSString *)url withName:(NSString *)name;
+ (NSString *)getUrlWithName:(NSString *)name;
#if 0
+ (BOOL)addName:(NSString *)name time:(NSString *)time question:(NSString *)question answer:(NSString *)answer help:(NSString *)helper;
+ (NSMutableArray *)getItemFromQuestionAnswer;
#endif
+ (BOOL)addProductId:(NSString *)pId title:(NSString *)title description:(NSString *)description icon:(NSString *)icon url:(NSString *)url guideImage:(NSString *)guideImage lastUpdateTime:(NSString *)lastUpdateTime guideType:(NSInteger)guideType;
+ (NSMutableArray *)getItemsFromProducsInfo;

+ (NSString *)openId;
+ (BOOL)updateOpenId:(NSString *)openId;
#if TEST
+ (BOOL)insertUdpScanResultWithScanTime:(NSString *)time scanResult:(NSMutableArray *)result;
+ (BOOL)insertTcpScanResultWithScanTime:(NSString *)time scanResult:(NSMutableArray *)result;
#endif
+ (BOOL)autoPopHimalayaHelper;
+ (BOOL)changeHimalayaPopHelperState:(BOOL)autoPop;
@end
