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

/** 获取APP的Document目录 */
+ (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/** 取得数据库所在的目录 */
+ (NSString *)getDatabasePath {
    NSString *documentDictionary = [self getDocumentPath];

    return [documentDictionary stringByAppendingPathComponent:DATABASE_PATH];
}

/** 取得数据库所在的完整路径 */
+ (NSString *)getDatabase {
    NSString *databasePath = [self getDatabasePath];
    
    return [databasePath stringByAppendingPathComponent:DATABASE_NAME];
}

/**  
 打开数据库
 @return 非nil 打开成功
 @return nil 打开数据库失败
 */
+ (FMDatabase *)openDatabase {
    NSString *dataBasePath = [self getDatabasePath]; // 数据库所在的完整目录
    BOOL databaseIsExist = [[NSFileManager defaultManager] fileExistsAtPath:dataBasePath isDirectory:nil]; // 判断数据库是否已存在
    if (!databaseIsExist) {
        /* 数据库还不存在则先创建数据库 */
        [[NSFileManager defaultManager] createDirectoryAtPath:dataBasePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
 
    /** 打开数据库 */
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabase]];
    if ([db open]) {
        return db;
    } else {
        NSLog(@"open database failed!");
        return nil;
    }
}

/** 关闭数据库 db */
+ (void)closeDatabase:(FMDatabase *)db {
    [db close];
}

#pragma APP第一次打开的时间表

/** 创建打开APP纪录的数据表 */
+ (BOOL)createTheAppOpenedRecordsDatatable:(FMDatabase *)db {
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", DATATABLE_OPENAPP_TRACE, DATATABLE_ITEM_DATE];
        return [db executeUpdate:sqlCreateTable];
    } else {
        return NO;
    }
}

/** 
 获取打开APP的纪录
 @return 如果之前已经打开过，则返回 日期、时间、时区：yyyy-MM-dd HH:mm:ss zzz
 @return 如果没有打开过，则返回nil
 */
+ (NSString *)getOpenAppRecord {
    NSString *date = nil;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createTheAppOpenedRecordsDatatable:db];
        if (retCode) {
            /* 查询 */
            NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %@", DATATABLE_OPENAPP_TRACE];
            FMResultSet *set = [db executeQuery:sqlQuery];
            
            /* 遍历 */
            while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
                date = [set stringForColumn:DATATABLE_ITEM_DATE];
                break;
            }
        }
    }

    [self closeDatabase:db];
    
    return date;
}

/** 是否是第一次打开APP */
+ (BOOL)isFirstOpenTheApp {
    NSString *openDate = [self getOpenAppRecord];
    if (nil != openDate) {
        
        /* 不为空，则表示APP已被打开过 */
        NSLog(@"%s The app is not the first time to be opened, the first open is in %@", __func__, openDate);
        
        return NO;
    }
    
    return YES;
}


/**
 插入当前打开APP时的时间
 @param date 打开APP时的时间：yyyy-MM-dd HH:mm:ss zzz
 */
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

/** 创建保存SSID和密码的数据表 */
+ (BOOL)createSSIDAndPasswordDatatable:(FMDatabase *)db {
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, %@)", DATATABLE_SSIDPASSWORDS, SSIDPASSWORDS_ITEM_SSID, SSIDPASSWORDS_ITEM_PASSWORD];
        return [db executeUpdate:sqlCreateTable];
    } else {
        return NO;
    }
}

/** 向数据表插入SSID和password */
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

/** 
 更改对应SSID的密码
 @param password 对应SSID的新密码
 @param ssid 特定的已经保存过的SSID
 */
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

/**
 获取保存的SSID的密码
 @return 如果没有该SSID的记录，则返回nil
 */
+ (NSString *)getPasswordWithSSID:(NSString *)ssid {
    NSString *password = nil;
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        BOOL retCode = [self createSSIDAndPasswordDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM %@ where %@ == '%@'", DATATABLE_SSIDPASSWORDS, SSIDPASSWORDS_ITEM_SSID, ssid];
            FMResultSet *set = [db executeQuery:sqlQuery];
        
            /* 遍历 */
            while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
                password = [set stringForColumn:SSIDPASSWORDS_ITEM_PASSWORD];
                break;
            }
        }
    }
    
    [self closeDatabase:db];
    
    return password;
}

/** 保存SSID和密码 */
+ (BOOL)addSSID:(NSString *)ssid withPassword:(NSString *) password {
    BOOL retCode;
    
    if ([ssid isEqualToString:@""]) {
        return YES; // SSID 为空
    }
    
    NSString *pw = [self getPasswordWithSSID:ssid]; // 该SSID是否已存在于数据库中
    if (nil == pw) {
        // 没有保存过该SSID则插入ssid和密码
        retCode = [self insertSSID:ssid withPassword:password];
    } else {
        // 已保存过该SSID则修改密码
        retCode = [self updatePassword:password withSSID:ssid];
    }
    
//    [self getPasswordWithSSID:ssid];
    
    return retCode;
}

#pragma 保存从后台获取的url

/** 创建保存各种url的数据表 */
+ (BOOL)createNameUrlDatatable:(FMDatabase *)db {
    // 创建数据表 http请求地址表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@, %@)", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, HTTPREQUESTURL_ITEM_URL]; // 数据表有两列：该url的类别名称，url本身
        BOOL retCode = [db executeUpdate:sqlCreateTable]; // 创建数据表
        if (retCode) {
            NSString *inserUrl = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?)", DATATABLE_HTTPREQUESTURL];
            
            NSString *sqlQuery1 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_BUYURL];
            FMResultSet *set1 = [db executeQuery:sqlQuery1]; // 查询是否已有buyurl
            if (![set1 next]) {
                /* 没有则插入buyurl */
                NSLog(@"%s set1:%d", __func__, set1.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_BUYURL, @"http://www.larkiv.com/ilarkhelper/product/larkshop.html"];
            }
            
            NSString *sqlQuery2 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_HELPURL];
            FMResultSet *set2 = [db executeQuery:sqlQuery2]; // 查询是否已包含helpurl
            if (![set2 next]) {
                /* 没有则插入和helpurl */
                NSLog(@"%s set2:%d", __func__, set2.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_HELPURL, @"http://www.larkiv.com/ilarkhelper/help/"];
            }
            
            NSString *sqlQuery3 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_PRODUCTURL];
            FMResultSet *set3 = [db executeQuery:sqlQuery3]; // 查询是否已包含producturl
            if (![set3 next]) {
                /* 没有则插入producturl */
                NSLog(@"%s set3:%d", __func__, set3.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_PRODUCTURL, @"http://www.larkiv.com/ilarkhelper/product/"];
            }
            
            NSString *sqlQuery4 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_XMLYHELPURL];
            FMResultSet *set4 = [db executeQuery:sqlQuery4]; // 查询是否已包含xmlyhelpurl
            if (![set4 next]) {
                /* 没有则插入xmlyhelpurl */
                NSLog(@"%s set4:%d", __func__, set4.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_XMLYHELPURL, @"http://www.larkiv.com/ilarkhelper/help/xmly.html"];
            }
            
            NSString *sqlQuery5 = [NSString stringWithFormat: @"select * from %@ where %@ == '%@'", DATATABLE_HTTPREQUESTURL, HTTPREQUESTURL_ITEM_URLNAME, DT_ITEM_WEIXINURL]; // 查询是否已包含weixinurl
            FMResultSet *set5 = [db executeQuery:sqlQuery5];
            if (![set5 next]) {
                /* 没有则插入weixinurl */
                NSLog(@"%s set5:%d", __func__, set5.hasAnotherRow);
                [db executeUpdate:inserUrl, DT_ITEM_WEIXINURL, @"http://www.larkiv.com/alarkhelper/weixin/gongzhonghao.html"];
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}

/* 向数据表中插入url */
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

/**
 更新url，如buy url，喜马拉雅帮助的url等
 @param url 新的url
 @name url的名字，buy_url、help_url、product_url、xmly_help_url、weixin_url
 */
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

/**
 获取对应的url
 @param name url的名字，buy_url、help_url、product_url、xmly_help_url、weixin_url
 @return 返回对应name的url
 */
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

/* 创建产品信息数据表 */
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

/* 更新产品信息 */
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

/* 插入产品信息 */
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

/** 将从服务器获取的设备信息添加到数据库，当前没有用到 */
+ (BOOL)addProductId:(NSString *)pId title:(NSString *)title description:(NSString *)description icon:(NSString *)icon url:(NSString *)url guideImage:(NSString *)guideImage lastUpdateTime:(NSString *)lastUpdateTime guideType:(NSInteger)guideType {
    BOOL isExists = NO;
    BOOL retCode;
    
    NSLog(@"%s", __func__);
    
    FMDatabase *db = [self openDatabase];
    if (nil != db) {
        retCode = [self createProductsInfoDatatable:db];
        if (retCode) {
            NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ == '%@'", DATATABLE_PRODUCTINFO, PRODUCTINFO_PRODUCTID, pId]; // 查询数据表中是否已包含了该产品
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
        /* 如果已包含则直接更新即可 */
        retCode = [self updateProductId:pId title:title description:description icon:icon url:url guideImage:guideImage lastUpdateTime:lastUpdateTime guideType:guideType];
    } else {
        /* 若数据库中没有该产品，则直接插入该产品的信息即可 */
        retCode = [self insertProductId:pId title:title description:description icon:icon url:url guideImage:guideImage lastUpdateTime:lastUpdateTime guideType:guideType];
    }
    
    return retCode;
}

/** 从数据库获取保存的产品信息 */
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

/* 创建APP OpenID的数据表 */
+ (BOOL)createOpenIdDatatable:(FMDatabase *)db {
    // 创建openid表
    if (nil != db) {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", DATATABLE_OPENID, OPENID_ITEM_OPENID];
        BOOL retCode = [db executeUpdate:sqlCreateTable];
        if (retCode) {
            /* 创建数据表成功则向其中插入一个默认的openid */
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

/** 获取APP的openId */
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

/** 更新APP的openId */
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

/* 创建存放是否自动弹出喜马拉雅帮助的数据表 */
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

/**
 在进入喜马拉雅界面时是否要自动弹出喜马拉雅帮助框
 @return YES 要弹出
 @return NO 不弹出
 */
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

/**
 修改进入喜马拉雅界面时，是否还要自动弹出帮助界面
 @param autoPop YES，还要自动弹出；NO，不再自动弹出
 */
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
