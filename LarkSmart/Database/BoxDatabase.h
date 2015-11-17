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

/** 是否是第一次打开APP */
+ (BOOL)isFirstOpenTheApp;

/** 
 插入当前打开APP时的时间
 @param date 打开APP时的时间：yyyy-MM-dd HH:mm:ss zzz
 */
+ (BOOL)insertOpenAppRecord:(NSString *)date;

/** 保存SSID和密码 */
+ (BOOL)addSSID:(NSString *)ssid withPassword:(NSString *) password;

/** 
 获取保存的SSID的密码
 @return 如果没有该SSID的记录，则返回nil
 */
+ (NSString *)getPasswordWithSSID:(NSString *)ssid;

/** 
 更新url，如buy url，喜马拉雅帮助的url等 
 @param url 新的url
 @name url的名字，buy_url、help_url、product_url、xmly_help_url、weixin_url
 */
+ (BOOL)updateUrl:(NSString *)url withName:(NSString *)name;

/** 
 获取对应的url
 @param name url的名字，buy_url、help_url、product_url、xmly_help_url、weixin_url
 @return 返回对应name的url
 */
+ (NSString *)getUrlWithName:(NSString *)name;

/** 将从服务器获取的设备信息添加到数据库，当前没有用到 */
+ (BOOL)addProductId:(NSString *)pId title:(NSString *)title description:(NSString *)description icon:(NSString *)icon url:(NSString *)url guideImage:(NSString *)guideImage lastUpdateTime:(NSString *)lastUpdateTime guideType:(NSInteger)guideType;

/** 从数据库获取保存的产品信息 */
+ (NSMutableArray *)getItemsFromProducsInfo;

/** 获取APP的openId */
+ (NSString *)openId;

/** 更新APP的openId */
+ (BOOL)updateOpenId:(NSString *)openId;

#if TEST
/** 
 保存udp的扫描结果，当初做udp扫描测试时用到
 @param time 当前的时间
 @param result udp扫描的结果，哪些设备扫描到了1，哪些没扫描到0
 */
+ (BOOL)insertUdpScanResultWithScanTime:(NSString *)time scanResult:(NSMutableArray *)result;

/**
 保存tcp的扫描结果，当初做tcp扫描测试时用到
 @param time 当前的时间
 @param result udp扫描的结果，哪些设备扫描到了1，哪些没扫描到0
 */
+ (BOOL)insertTcpScanResultWithScanTime:(NSString *)time scanResult:(NSMutableArray *)result;
#endif

/** 
 在进入喜马拉雅界面时是否要自动弹出喜马拉雅帮助框 
 @return YES 要弹出
 @return NO 不弹出
 */
+ (BOOL)autoPopHimalayaHelper;

/** 
 修改进入喜马拉雅界面时，是否还要自动弹出帮助界面
 @param autoPop YES，还要自动弹出；NO，不再自动弹出
 */
+ (BOOL)changeHimalayaPopHelperState:(BOOL)autoPop;
@end
