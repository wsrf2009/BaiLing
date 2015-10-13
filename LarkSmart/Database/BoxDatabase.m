//
//  BoxDatabase.m
//  CloudBox
//
//  Created by TTS on 15-4-14.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "BoxDatabase.h"
#import "FMDB.h"
#import "SystemToolClass.h"

#define DATABASE_PATH       @"database"
#define DATABASE_NAME       @"box.sqlite"

#define DATATABLE_OPENAPP_TRACE     @"openAppTrace"
#define DATATABLE_ITEM_DATE         @"date"

#define DATATABLE_SSIDPASSWORDS         @"dt_ssidPasswordRecords"
#define SSIDPASSWORDS_ITEM_SSID         @"ssid"
#define SSIDPASSWORDS_ITEM_PASSWORD     @"password"

#define DATATABLE_HTTPREQUESTURL            @"dt_httpRequestUrl"
#define HTTPREQUESTURL_ITEM_URLNAME         @"name"
#define HTTPREQUESTURL_ITEM_URL             @"url"


#define DATATABLE_QUESTIONANSWER            @"dt_questionAnswer"

#define DATATABLE_PRODUCTINFO               @"dt_productInfo"

#define DATATABLE_OPENID                    @"dt_openid"
#define OPENID_ITEM_OPENID                  @"openid"

#define DATATABLE_UDPSCANRESULT             @"dt_udpScanResult"
#define UDPSCANRESULT_TIME      @"time"

#define DATATABLE_TCPSCANRESULT             @"dt_tcpScanResult"
#define TCPSCANRESULT_TIME      @"time"

#define DATATABLE_HIMALAYA_POPHELPER        @"dt_himalayaPopHelper"
#define HIMALAYA_AUTOPOPHELPER  @"autoPopHelper"


@implementation BoxDatabase

+ (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)getDatabasePath {
    NSString *documentDictionary = [self getDocumentPath];

    return [documentDictionary stringByAppendingPathComponent:DATABASE_PATH];
}

+ (NSString *)getDatabase {
    NSString *databasePath = [self getDatabasePath];
    
    return [databasePath stringByAppendingPathComponent:DATABASE_NAME];
}

+ (FMDatabase *)openDatabase {
    NSString *dataBasePath = [self getDatabasePath];
    BOOL databaseIsExist = [[NSFileManager defaultManager] fileExistsAtPath:dataBasePath isDirectory:nil];
    if (!databaseIsExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataBasePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
 
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabase]];
    if ([db open]) {
        return db;
    } else {
        NSLog(@"open database failed!");
        return nil;
    }
}

+ (void)closeDatabase:(FMDatabase *)db {
    [db close];
}

#pragma APP第一次打开的时间表

+ (BOOL)createTheAppOpenedRecordsDatatable:(FMDatabase *)db {
    // 创建数据表 APP打开记录表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", DATATABLE_OPENAPP_TRACE, DATATABLE_ITEM_DATE];
        return [db executeUpdate:sqlCreateTable];
    } else {
        return NO;
    }
}

+ (NSString *)getOpenAppRecord {
    NSString *date = nil;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createTheAppOpenedRecordsDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %@", DATATABLE_OPENAPP_TRACE];
            FMResultSet *set = [db executeQuery:sqlQuery];
            
            //遍历表
            while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
                date = [set stringForColumn:DATATABLE_ITEM_DATE];
                break;
            }
        }
    }

    [self closeDatabase:db];
    
    return date;
}

+ (BOOL)isFirstOpenTheApp {
    NSString *openDate = [self getOpenAppRecord];
    if (nil != openDate) {
        NSLog(@"%s The app is not the first time to be opened, the first open is in %@", __func__, openDate);
        
        return NO;
    }
    
    return YES;
}

+ (BOOL)insertOpenAppRecord:(NSString *)date {
    BOOL retCode = NO;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createTheAppOpenedRecordsDatatable:db];
        if (retCode) {
            NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?)", DATATABLE_OPENAPP_TRACE];
            retCode = [db executeUpdate:sqlInsert, date];
        }
    }

    [self closeDatabase:db];
    
    return retCode;
}

#pragma 网络名和密码保存表

+ (BOOL)createSSIDAndPasswordDatatable:(FMDatabase *)db {
    // 创建数据表 ssid和密码记录表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, %@)", DATATABLE_SSIDPASSWORDS, SSIDPASSWORDS_ITEM_SSID, SSIDPASSWORDS_ITEM_PASSWORD];
        return [db executeUpdate:sqlCreateTable];
    } else {
        return NO;
    }
}

+ (BOOL)insertSSID:(NSString *)ssid withPassword:(NSString *) password {
    BOOL retCode = NO;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createSSIDAndPasswordDatatable:db];
        if (retCode) {
            NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?, ?)", DATATABLE_SSIDPASSWORDS];
            retCode = [db executeUpdate:sqlInsert, ssid, password];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

+ (BOOL)updatePassword:(NSString *)password withSSID:(NSString *)ssid {
    BOOL retCode = NO;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createSSIDAndPasswordDatatable:db];
        if (retCode) {
            NSString *sqlUpdate = [NSString stringWithFormat: @"update %@ set %@ = ? where %@ = ?", DATATABLE_SSIDPASSWORDS , SSIDPASSWORDS_ITEM_PASSWORD, SSIDPASSWORDS_ITEM_SSID];
            retCode = [db executeUpdate:sqlUpdate, password, ssid];
        }
    }
    
    [self closeDatabase:db];
 
    return retCode;

}

+ (NSString *)getPasswordWithSSID:(NSString *)ssid {
    NSString *password = nil;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createSSIDAndPasswordDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %@ where %@ == '%@'", DATATABLE_SSIDPASSWORDS, SSIDPASSWORDS_ITEM_SSID, ssid];
            FMResultSet *set = [db executeQuery:sqlQuery];
        
            //遍历Students表
            while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
                password = [set stringForColumn:SSIDPASSWORDS_ITEM_PASSWORD];
                break;
            }
        }
    }
    
    [self closeDatabase:db];
    
    return password;
}

+ (BOOL)addSSID:(NSString *)ssid withPassword:(NSString *) password {
    BOOL retCode;
    
    if ([ssid isEqualToString:@""]) {
        return YES; // SSID 为空
    }
    
    NSString *pw = [self getPasswordWithSSID:ssid];
    if (nil == pw) {
        // 插入ssid和密码
        retCode = [self insertSSID:ssid withPassword:password];
    } else {
        // 修改密码
        retCode = [self updatePassword:password withSSID:ssid];
    }
    
//    [self getPasswordWithSSID:ssid];
    
    return retCode;
}

#pragma 保存从后台获取的url

+ (BOOL)createNameUrlDatatable:(FMDatabase *)db {
    // 创建数据表 http请求地址表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, %@)", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, HTTPREQUESTURL_ITEM_URL];
        BOOL retCode = [db executeUpdate:sqlCreateTable];
        if (retCode) {
            NSString *inserUrl = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?)", DATATABLE_HTTPREQUESTURL];
            NSString *sqlQuery1 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_BUYURL];
            FMResultSet *set1 = [db executeQuery:sqlQuery1];
            if (![set1 next]) {
                NSLog(@"%s set1:%d", __func__, set1.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_BUYURL, @"http://www.larkiv.com/ilarkhelper/product/larkshop.html"];
            }
            
            NSString *sqlQuery2 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_HELPURL];
            FMResultSet *set2 = [db executeQuery:sqlQuery2];
            if (![set2 next]) {
                NSLog(@"%s set2:%d", __func__, set2.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_HELPURL, @"http://www.larkiv.com/ilarkhelper/help/"];
            }
            
            NSString *sqlQuery3 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_PRODUCTURL];
            FMResultSet *set3 = [db executeQuery:sqlQuery3];
            if (![set3 next]) {
                NSLog(@"%s set3:%d", __func__, set3.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_PRODUCTURL, @"http://www.larkiv.com/ilarkhelper/product/"];
            }
            
            NSString *sqlQuery4 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_XMLYHELPURL];
            FMResultSet *set4 = [db executeQuery:sqlQuery4];
            if (![set4 next]) {
                NSLog(@"%s set4:%d", __func__, set4.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_XMLYHELPURL, @"http://www.larkiv.com/ilarkhelper/help/xmly.html"];
            }
            
            NSString *sqlQuery5 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_WEIXINURL];
            FMResultSet *set5 = [db executeQuery:sqlQuery5];
            if (![set5 next]) {
                NSLog(@"%s set5:%d", __func__, set5.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_WEIXINURL, @"http://www.larkiv.com/alarkhelper/weixin/gongzhonghao.html"];
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)insertName:(NSString *)name url:(NSString *)url {
    BOOL retCode = NO;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createNameUrlDatatable:db];
        if (retCode) {
            NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?, ?)", DATATABLE_HTTPREQUESTURL];
            retCode = [db executeUpdate:sqlInsert, name, url];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

+ (BOOL)updateUrl:(NSString *)url withName:(NSString *)name {
    BOOL retCode = NO;
    
    NSLog(@"%s name:%@ url:%@", __func__, name, url);
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createNameUrlDatatable:db];
        if (retCode) {
            NSString *sqlUpdate = [NSString stringWithFormat: @"update %@ set %@ = ? where %@ = ?", DATATABLE_HTTPREQUESTURL , HTTPREQUESTURL_ITEM_URL, HTTPREQUESTURL_ITEM_URLNAME];
            retCode = [db executeUpdate:sqlUpdate, url, name];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

+ (NSString *)getUrlWithName:(NSString *)name {
    NSString *url = nil;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createNameUrlDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, name];
            FMResultSet *set = [db executeQuery:sqlQuery];
        
            //遍历Students表
            while ([set next]) {
                
                url = [set stringForColumn:HTTPREQUESTURL_ITEM_URL];
                break;
            }
        }
    }
    
    [self closeDatabase:db];
    
    return url;
}
#if 0
#pragma 问答记录表操作

// 创建问答记录表
NSString *sqlCreateTable5 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %s (%s, %s, %s, %s, %s)", DATATABLE_QUESTIONANSWER, QUESTIONANSWER_ITEM_NAME, QUESTIONANSWER_ITEM_TIME, QUESTIONANSWER_ITEM_QUESTION, QUESTIONANSWER_ITEM_ANSWER, QUESTIONANSWER_ITEM_HELPER];
[db executeUpdate:sqlCreateTable5];

+ (BOOL)insertName:(NSString *)name time:(NSString *)time question:(NSString *)question answer:(NSString *)answer help:(NSString *)helper {
    BOOL retCode;
    NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?, ?, ?, ?, ?)", @DATATABLE_QUESTIONANSWER];
    
    NSLog(@"%s", __func__);
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [db executeUpdate:sqlInsert, name, time, question, answer, helper];
        [self closeDatabase:db];
    } else {
        retCode = NO;
    }
    
    return retCode;
}

+ (NSMutableArray *)getItemFromQuestionAnswer {
    NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %s", DATATABLE_QUESTIONANSWER];
    
    NSLog(@"%s", __func__);
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        FMResultSet* set = [db executeQuery:sqlQuery];
        
        //遍历数据表
        while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库

            [arr addObject:[set resultDictionary]];
        }
        
        [self closeDatabase:db];
    }
    
    return arr;
}

+ (NSUInteger)getNumberOfQuestionAnswer {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %s", DATATABLE_QUESTIONANSWER];
    NSUInteger rowNumber = 0;
    
    NSLog(@"%s", __func__);
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        FMResultSet* set = [db executeQuery:sqlQuery];
        while ([set next]) {
            rowNumber++;
        }
        [self closeDatabase:db];
    }
    
    return rowNumber;
}

+ (BOOL)deleteItemFromQuestionAnswerWithTime:(NSString *)time {
    NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", @DATATABLE_QUESTIONANSWER, @QUESTIONANSWER_ITEM_TIME];
    BOOL retCode;
    
    NSLog(@"%s %@", __func__, time);
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [db executeUpdate:sqlDelete, time];
        [self closeDatabase:db];
    } else {
        retCode = NO;
    }
    
    return retCode;
}

+ (BOOL)addName:(NSString *)name time:(NSString *)time question:(NSString *)question answer:(NSString *)answer help:(NSString *)helper {
    NSUInteger number = [self getNumberOfQuestionAnswer];
    
    NSLog(@"%s", __func__);
    
    if (number >= 5) {
        NSUInteger overplus = number-4;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:overplus];
        FMDatabase *db = [self openDatabase];
        if (nil != db) {
            NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %s", DATATABLE_QUESTIONANSWER];
            FMResultSet *set = [db executeQuery:sqlQuery];
            while ([set next]) {
                NSString *time = [set stringForColumn:@QUESTIONANSWER_ITEM_TIME];
                
                [arr addObject:time];
                if (--overplus <= 0) {
                    break;
                }
            }
        }
        [self closeDatabase:db];
        
        for (NSString *t in arr) {
            [self deleteItemFromQuestionAnswerWithTime:t];
        }
    }
    
    return [self insertName:name time:time question:question answer:answer help:helper];
}

#endif

#pragma 保存从后台服务器获取的产品信息表

+ (BOOL)createProductsInfoDatatable:(FMDatabase *)db {
    // 创建产品信息表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, %@, %@, %@, %@, %@, %@, %@)", DATATABLE_PRODUCTINFO, PRODUCTINFO_PRODUCTID, PRODUCTINFO_TITLE, PRODUCTINFO_DESCRIPTION, PRODUCTINFO_ICON, PRODUCTINFO_URL, PRODUCTINFO_GUIDEIMAGE, PRODUCTINFO_LASTUPDATETIME, PRODUCTINFO_GUIDETYPE];
        [db executeUpdate:sqlCreateTable];
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)updateProductId:(NSString *)pId title:(NSString *)title description:(NSString *)description icon:(NSString *)icon url:(NSString *)url guideImage:(NSString *)guideImage lastUpdateTime:(NSString *)lastUpdateTime guideType:(NSInteger)guideType {
    
    FMDatabase *db = [self openDatabase];
    BOOL retCode = NO;
    
    if (nil != db) {
        retCode = [self createProductsInfoDatatable:db];
        if (retCode) {
            NSString *sqlUpdate = [NSString stringWithFormat: @"update %@ set %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@=%ld where %@='%@'", DATATABLE_PRODUCTINFO, PRODUCTINFO_TITLE, title, PRODUCTINFO_DESCRIPTION, description, PRODUCTINFO_ICON, icon, PRODUCTINFO_URL, url, PRODUCTINFO_GUIDEIMAGE, guideImage, PRODUCTINFO_LASTUPDATETIME, lastUpdateTime,  PRODUCTINFO_GUIDETYPE, (long)guideType, PRODUCTINFO_PRODUCTID, pId];
            retCode = [db executeUpdate:sqlUpdate];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

+ (BOOL)insertProductId:(NSString *)pId title:(NSString *)title description:(NSString *)description icon:(NSString *)icon url:(NSString *)url guideImage:(NSString *)guideImage lastUpdateTime:(NSString *)lastUpdateTime guideType:(NSInteger)guideType {
    
    BOOL retCode = NO;
    FMDatabase *db = [self openDatabase];
    
    if (nil != db) {
        retCode = [self createProductsInfoDatatable:db];
        if (retCode) {
            NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES ('%@', '%@', '%@',  '%@', '%@', '%@', '%@', %ld)", DATATABLE_PRODUCTINFO, PRODUCTINFO_PRODUCTID, PRODUCTINFO_TITLE, PRODUCTINFO_DESCRIPTION, PRODUCTINFO_ICON, PRODUCTINFO_URL, PRODUCTINFO_GUIDEIMAGE, PRODUCTINFO_LASTUPDATETIME, PRODUCTINFO_GUIDETYPE, pId, title, description, icon, url, guideImage, lastUpdateTime, (long)guideType];
            retCode = [db executeUpdate:sqlInsert];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

+ (BOOL)addProductId:(NSString *)pId title:(NSString *)title description:(NSString *)description icon:(NSString *)icon url:(NSString *)url guideImage:(NSString *)guideImage lastUpdateTime:(NSString *)lastUpdateTime guideType:(NSInteger)guideType {
    BOOL isExists = NO;
    BOOL retCode;
    
    NSLog(@"%s", __func__);
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createProductsInfoDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ == '%@'", DATATABLE_PRODUCTINFO, PRODUCTINFO_PRODUCTID, pId];
            FMResultSet *set = [db executeQuery:sqlQuery];
            if ([set next]) {

                isExists = YES;
            }
        }
    } else {
        return NO;
    }
    
    [self closeDatabase:db];
    
    if (isExists) {
        retCode = [self updateProductId:pId title:title description:description icon:icon url:url guideImage:guideImage lastUpdateTime:lastUpdateTime guideType:guideType];
    } else {
        retCode = [self insertProductId:pId title:title description:description icon:icon url:url guideImage:guideImage lastUpdateTime:lastUpdateTime guideType:guideType];
    }
    
    return retCode;
}

+ (NSMutableArray *)getItemsFromProducsInfo {

    NSMutableArray *arr = [[NSMutableArray alloc] init];
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createProductsInfoDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %@", DATATABLE_PRODUCTINFO];
            FMResultSet *set = [db executeQuery:sqlQuery];
        
            //遍历数据表
            while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
            
                [arr addObject:[set resultDictionary]];
            }
        }
    }
    
    [self closeDatabase:db];
    
    return arr;
}


#pragma 记录App的openid

+ (BOOL)createOpenIdDatatable:(FMDatabase *)db {
    // 创建openid表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", DATATABLE_OPENID, OPENID_ITEM_OPENID];
        BOOL retCode = [db executeUpdate:sqlCreateTable];
        if (retCode) {
            NSString *inserOpenid = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?)", DATATABLE_OPENID];
            NSString *sqlQuery = [NSString stringWithFormat: @"select * from %@", DATATABLE_OPENID];

            FMResultSet *set = [db executeQuery:sqlQuery];
            if (![set next]) {
                NSLog(@"%s set:%@", __func__, set.resultDictionary);
                [db executeUpdate:inserOpenid, @"999999999"];
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)openId {
    NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %@", DATATABLE_OPENID];
    NSString *openId = nil;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createOpenIdDatatable:db];
        if (retCode) {
            FMResultSet* set = [db executeQuery:sqlQuery];
            
            //遍历表
            while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
                openId = [set stringForColumn:OPENID_ITEM_OPENID];
                break;
            }
        }
    }
    
    [self closeDatabase:db];
    
    return openId;
}

+ (BOOL)updateOpenId:(NSString *)openId {
    
    if (nil == openId) {
        return NO;
    }
    
    NSLog(@"%s openId:%@", __func__, openId);
    
    BOOL retCode = NO;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createOpenIdDatatable:db];
        if (retCode) {
            NSString *sqlUpdate = [NSString stringWithFormat: @"update %@ set %@ = ?", DATATABLE_OPENID , OPENID_ITEM_OPENID];
            retCode = [db executeUpdate:sqlUpdate, openId];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

#pragma 记录udp 和tcp扫描结果的表

#if TEST
NSString *sqlCreateTable8 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, '%@', '%@', '%@', '%@')", DATATABLE_UDPSCANRESULT, UDPSCANRESULT_TIME, UDPSCANRESULT_ITEM_1, UDPSCANRESULT_ITEM_2, UDPSCANRESULT_ITEM_3, UDPSCANRESULT_ITEM_4];
[db executeUpdate:sqlCreateTable8];

NSString *sqlCreateTable9 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, '%@', '%@', '%@', '%@')", DATATABLE_TCPSCANRESULT, TCPSCANRESULT_TIME, TCPSCANRESULT_ITEM_1, TCPSCANRESULT_ITEM_2, TCPSCANRESULT_ITEM_3, TCPSCANRESULT_ITEM_4];
[db executeUpdate:sqlCreateTable9];

NSLog(@"%s 为什么没创建成功－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－", __func__);
#endif

#if TEST
+ (BOOL)insertUdpScanResultWithScanTime:(NSString *)time scanResult:(NSMutableArray *)result {
    BOOL item1Result = NO;
    BOOL item2Result = NO;
    BOOL item3Result = NO;
    BOOL item4Result = NO;
    
    for (NSString *item in result) {
        NSLog(@"%s %@ %@", __func__, time, item);
        if ([item isEqualToString:UDPSCANRESULT_ITEM_1]) {
            item1Result = YES;
        } else if ([item isEqualToString:UDPSCANRESULT_ITEM_2]) {
            item2Result = YES;
        } else if ([item isEqualToString:UDPSCANRESULT_ITEM_3]) {
            item3Result = YES;
        } else if ([item isEqualToString:UDPSCANRESULT_ITEM_4]) {
            item4Result = YES;
        }
    }
    
    NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ (%@, '%@', '%@', '%@', '%@') VALUES ('%@', %d, %d, %d, %d)", DATATABLE_UDPSCANRESULT, UDPSCANRESULT_TIME, UDPSCANRESULT_ITEM_1, UDPSCANRESULT_ITEM_2, UDPSCANRESULT_ITEM_3, UDPSCANRESULT_ITEM_4, time, item1Result, item2Result, item3Result, item4Result];
    BOOL retCode;
    FMDatabase *db = [self openDatabase];
    
    if (nil != db) {
        retCode = [db executeUpdate:sqlInsert];
        [self closeDatabase:db];
    } else {
        return NO;
    }
    
    return retCode;
}

+ (BOOL)insertTcpScanResultWithScanTime:(NSString *)time scanResult:(NSMutableArray *)result {
    BOOL item1Result = NO;
    BOOL item2Result = NO;
    BOOL item3Result = NO;
    BOOL item4Result = NO;
    
    for (NSString *item in result) {
        NSLog(@"%s %@ %@", __func__, time, item);
        if ([item isEqualToString:TCPSCANRESULT_ITEM_1]) {
            item1Result = YES;
        } else if ([item isEqualToString:TCPSCANRESULT_ITEM_2]) {
            item2Result = YES;
        } else if ([item isEqualToString:TCPSCANRESULT_ITEM_3]) {
            item3Result = YES;
        } else if ([item isEqualToString:TCPSCANRESULT_ITEM_4]) {
            item4Result = YES;
        }
    }
    
    NSString *sqlInsert = [NSString stringWithFormat: @"INSERT INTO %@ (%@, '%@', '%@', '%@', '%@') VALUES ('%@', %d, %d,  %d, %d)", DATATABLE_TCPSCANRESULT, TCPSCANRESULT_TIME, TCPSCANRESULT_ITEM_1, TCPSCANRESULT_ITEM_2, TCPSCANRESULT_ITEM_3, TCPSCANRESULT_ITEM_4, time, item1Result, item2Result, item3Result, item4Result];
    BOOL retCode;
    FMDatabase *db = [self openDatabase];
    
    if (nil != db) {
        retCode = [db executeUpdate:sqlInsert];
        [self closeDatabase:db];
    } else {
        return NO;
    }
    
    return retCode;
}
#endif

#pragma 自动弹出喜马拉雅界面纪录表

+ (BOOL)createAutoPopHimalayaHelper:(FMDatabase *)db {
    
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", DATATABLE_HIMALAYA_POPHELPER, HIMALAYA_AUTOPOPHELPER];
        BOOL retCode = [db executeUpdate:sqlCreateTable];
        if (retCode) {
            NSString *inserUrl2 = [NSString stringWithFormat: @"INSERT INTO %@ VALUES (?)", DATATABLE_HIMALAYA_POPHELPER];
            NSString *sqlQuery = [NSString stringWithFormat: @"select * from %@", DATATABLE_HIMALAYA_POPHELPER];
            FMResultSet *set = [db executeQuery:sqlQuery];
            if (![set next]) {
                [db executeUpdate:inserUrl2, @1];
            }
        }
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)autoPopHimalayaHelper {
    BOOL autoPop;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createAutoPopHimalayaHelper:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %@", DATATABLE_HIMALAYA_POPHELPER];
            FMResultSet* set = [db executeQuery:sqlQuery];
            
            //遍历表
            while ([set next]) {
                autoPop = [set intForColumn:HIMALAYA_AUTOPOPHELPER];
                break;
            }
        }
    }
    
    [self closeDatabase:db];
    
    return autoPop;
}

+ (BOOL)changeHimalayaPopHelperState:(BOOL)autoPop {
    BOOL retCode = NO;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createAutoPopHimalayaHelper:db];
        if (retCode) {
            NSString *sqlUpdate = [NSString stringWithFormat: @"update %@ set %@ = ?", DATATABLE_HIMALAYA_POPHELPER, HIMALAYA_AUTOPOPHELPER];
            retCode = [db executeUpdate:sqlUpdate, [NSNumber numberWithBool:autoPop]];
        }
    }
    
    [self closeDatabase:db];
    
    return retCode;
}

@end
