//
//  LocalMusicTask.m
//  CloudBox
//
//  Created by TTS on 15/9/25.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import "LocalMusicTask.h"
#import <MediaPlayer/MediaPlayer.h>
#import "pinyin.h"
#import "SystemToolClass.h"

#define WebRootDir  NSHomeDirectory()

NSString const *songsRelativeDir = @"tmp/songs";
NSString const *songFormat = @"mp3";
NSString const *convertFormat = @"mov";

@implementation YYTXMediaItem

@end

@interface LocalMusicTask ()
@property (nonatomic, retain) NSString *musicDirAbsolute;
@property (nonatomic, retain) dispatch_queue_t queueForSerialImport;
@property (nonatomic, retain) dispatch_semaphore_t semaphoreForLibraryImport;

@end

@implementation LocalMusicTask

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _queueForSerialImport = dispatch_queue_create("serial queue for exporting songs", DISPATCH_QUEUE_SERIAL);
        _semaphoreForLibraryImport = dispatch_semaphore_create(3);
        _musicDirAbsolute = [WebRootDir stringByAppendingPathComponent:(NSString *)songsRelativeDir]; // 手机音乐所在的绝对路径
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:_musicDirAbsolute isDirectory:&isDir]; // 手机音乐的路径是否已存在
        if ( !(isDir == YES && existed == YES) ) {
            // 没有songs目录则创建
            [fileManager createDirectoryAtPath:_musicDirAbsolute withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _musicItems = [NSMutableArray array];
        
        [self performSelectorInBackground:@selector(refreshMediaList) withObject:nil]; // 默认自动扫描手机上的音乐
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id)delegate {
    self = [self init];
    if (nil != self) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)addMediaItem:(MPMediaItem *)mediaItem ToSongList:(NSMutableArray *)mutableArray {
    
    NSString *songTitle = [mediaItem valueForProperty: MPMediaItemPropertyTitle]; // 歌曲名
    NSURL *urlA =[mediaItem valueForProperty:MPMediaItemPropertyAssetURL]; // 歌曲所在的位置
    
    NSString *ext = urlA.pathExtension;
    if ([ext isEqualToString:(NSString *)songFormat]) {
        /* 为MP3格式 */
        NSLog (@"%@/%@", urlA, songTitle);
        
        BOOL isExist = NO;
        
        for (YYTXMediaItem *item in mutableArray) {
            if ([item.audio.title isEqualToString:songTitle]) { // 歌曲列表中是否已存在同名的
                isExist = YES;
                break;
            }
        }
        
        if (!isExist) {
            /* 将在ipod－library中搜索到的音乐加入到歌曲列表中 */
            YYTXMediaItem *item = [[YYTXMediaItem alloc] init];
            item.audio = [[AudioClass alloc] init];
            item.audio.duration = [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] integerValue];
            item.audio.title = songTitle;
            item.audio.url = [self createUrlWithFileName:[songTitle stringByAppendingPathExtension:ext]];
            item.isSelected = NO;
            item.assetUrl = urlA;
            item.file = [_musicDirAbsolute stringByAppendingPathComponent:[songTitle stringByAppendingPathExtension:ext]]; // 歌曲文件的绝对路径
            item.state = YYTXMediaExportingStateUnknown; // 初始状态
            
            [mutableArray addObject:item];
            
            [self addItemToImportQueue:item];
        }
    }
}

- (void)searchSongsFromiPod {
    // 从ipod库中读出音乐文件
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
    // 读取条件
    MPMediaPropertyPredicate *albumNamePredicate =
    [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty: MPMediaItemPropertyMediaType];
    [mediaQuery addFilterPredicate:albumNamePredicate];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [mediaQuery items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"%@", songTitle);
        [self addMediaItem:song ToSongList:_musicItems];
    }
}

/** 在歌曲存放路径下搜索 */
- (void)searchSongsInLocalDir {
    
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:_musicDirAbsolute];
    
    NSString *fileName;
    
    while(fileName = [directoryEnumerator nextObject]) { // 枚举目录中的歌曲文件
        
        if([[fileName pathExtension] isEqualToString:(NSString *)songFormat]) {
            /* 为MP3格式，添加到歌曲列表 */
            YYTXMediaItem *item = [[YYTXMediaItem alloc] init];
            item.audio = [[AudioClass alloc] init];
            item.audio.title = [fileName stringByDeletingPathExtension];
            item.audio.url = [self createUrlWithFileName:fileName];
            item.isSelected = NO;
            item.file = [_musicDirAbsolute stringByAppendingPathComponent:fileName];
            item.assetUrl = nil;
            item.audio.duration = (NSInteger)[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:item.file] error:nil].duration;
            item.state = YYTXMediaExportingStateCompleted; // 初始状态
            
            [_musicItems addObject:item];
            
        } else {
            /* MP3格式以外的，直接删除 */
            [[NSFileManager defaultManager] removeItemAtPath:[_musicDirAbsolute stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (void)sortedAndGroupedSongs {
    
    /* 按照音乐的标题进行排序 */
    NSArray *orderedSongs = [_musicItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        YYTXMediaItem *item1 = obj1;
        YYTXMediaItem *item2 = obj2;
        if (nil == item1.pinYin) {
            item1.pinYin = [[HTFirstLetter pinYin:item1.audio.title] uppercaseString]; // 为每一首歌加上拼音
        }
        
        if (nil == item2.pinYin) {
            item2.pinYin = [[HTFirstLetter pinYin:item2.audio.title] uppercaseString]; // 全部大写
        }
        
        return  [item1.pinYin localizedCompare:item2.pinYin]; // 排序
        
    }];
    NSLog(@"%s _ord:%@", __func__, [orderedSongs componentsJoinedByString:@","]);
    
    [_musicItems removeAllObjects];
    /* 对排序后的歌曲按首字母分组 */
    NSString *groupTitle;
    NSMutableArray *arr;
    for (YYTXMediaItem *item in orderedSongs) {
        unichar letter;
        NSString *firstLetter;
        [item.pinYin getCharacters:&letter range:NSMakeRange(0, 1)];
        
        if(isalpha(letter)) { // 字母？
            firstLetter = [item.pinYin substringToIndex:1];
        } else {
            firstLetter = @"#";
        }
        
        NSLog(@"%s g:%@, f:%@", __func__, groupTitle, firstLetter);
        
        if (nil == groupTitle) {
            groupTitle = firstLetter;
            arr = [NSMutableArray array];
            [_musicItems addObject:arr];
            [arr addObject:groupTitle]; // 首字母
            [arr addObject:item];
        } else {
            if ([groupTitle isEqualToString:firstLetter]) {
                [arr addObject:item];
            } else {
                groupTitle = firstLetter;
                arr = [NSMutableArray array];
                [_musicItems addObject:arr];
                [arr addObject:groupTitle]; // 首字母
                [arr addObject:item];
            }
        }
    }
    
    for (NSMutableArray *arr in _musicItems) {
        NSLog(@"%s %@", __func__, [arr componentsJoinedByString:@","]);
    }
}

/** 将文件file创建为url，以方便http访问 */
- (NSString *)createUrlWithFileName:(NSString *)file {
    
    NSString *domain = [NSString stringWithFormat:@"%@:%@", [SystemToolClass IPAddress], [SystemToolClass httpServerPort]]; // IP地址：端口号
    NSString *urlMusicDir = [domain stringByAppendingPathComponent:(NSString *)songsRelativeDir]; // 后跟歌曲所在的绝对路径
    NSString *urlMusic = [urlMusicDir stringByAppendingPathComponent:file]; // 再跟上歌曲文件名
    NSString *urlHttp = [@"http://" stringByAppendingString:urlMusic];
    
    return [urlHttp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // 返回完整的url
}

- (void)addItemToImportQueue:(YYTXMediaItem *)item {
    
    /* 从ipod库中添加的音乐 */
    if (YYTXMediaExportingStateUnknown == item.state) {
        
        item.state = YYTXMediaExportingStateWaiting;
        
        dispatch_async(_queueForSerialImport, ^{
            
            dispatch_semaphore_wait(_semaphoreForLibraryImport, DISPATCH_TIME_FOREVER);
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:item.file]) { // 最终文件已存在 .mp3，转换完成
                
                item.state = YYTXMediaExportingStateCompleted;
                dispatch_semaphore_signal(_semaphoreForLibraryImport);
                
                if ([_delegate respondsToSelector:@selector(mediaExportStateChange)]) {
                    [_delegate mediaExportStateChange];
                }
            } else {
                
                /* 移除可能存在中间文件 .mov */
                NSString *middleFile = [[item.file stringByDeletingPathExtension] stringByAppendingPathExtension:(NSString *)convertFormat];
                [[NSFileManager defaultManager] removeItemAtPath:middleFile error:nil];
                
                item.libraryImport = [[TSLibraryImport alloc] init];
                if (nil == item.libraryImport) { // 初始化不成功，失败
                    item.state = YYTXMediaExportingStateFailed;
                    dispatch_semaphore_signal(_semaphoreForLibraryImport);
                    if ([_delegate respondsToSelector:@selector(mediaExportStateChange)]) {
                        [_delegate mediaExportStateChange];
                    }
                } else {
                    
                    /* 开始转换 */
                    item.state = YYTXMediaExportingStateExporting;
                    
                    [item.libraryImport importAsset:item.assetUrl toURL:[NSURL fileURLWithPath:item.file] completionBlock:^(TSLibraryImport *import) {
                        
                        item.assetUrl = nil;
                        
                        if (AVAssetExportSessionStatusCompleted == import.status) { // 转换完成
                            
                            item.state = YYTXMediaExportingStateCompleted;
                            dispatch_semaphore_signal(_semaphoreForLibraryImport);
                            
                            if ([_delegate respondsToSelector:@selector(mediaExportStateChange)]) {
                                [_delegate mediaExportStateChange];
                            }
                        } else {
                            if (AVAssetExportSessionStatusFailed == import.status) { // 转换失败
                                
                                item.state = YYTXMediaExportingStateFailed;
                                
                                // 删除中间文件和最重文件
                                [[NSFileManager defaultManager] removeItemAtPath:middleFile error:nil];
                                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:item.file] error:nil];
                                dispatch_semaphore_signal(_semaphoreForLibraryImport);
                                
                                if ([_delegate respondsToSelector:@selector(mediaExportStateChange)]) {
                                    [_delegate mediaExportStateChange];
                                }
                            } else if (AVAssetExportSessionStatusCancelled == import.status) { // 转换取消
                                
                                item.state = YYTXMediaExportingStateCancelled;
                                // 删除中间文件和最重文件
                                [[NSFileManager defaultManager] removeItemAtPath:middleFile error:nil];
                                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:item.file] error:nil];
                                dispatch_semaphore_signal(_semaphoreForLibraryImport);
                                
                                if ([_delegate respondsToSelector:@selector(mediaExportStateChange)]) {
                                    [_delegate mediaExportStateChange];
                                }
                            }
                        }
                    }];
                }
            }
        });
    }
}

- (void)refreshMediaList {

    [self clearMediaList];
    [self regainMedias];
}

- (void)clearMediaList {

    for (NSInteger i=0; i<_musicItems.count; i++) {
        NSArray *arr = [_musicItems objectAtIndex:i];
        for (NSInteger j=0; j<arr.count; j++) {
            id obj = arr[j];
            if ([obj isKindOfClass:[YYTXMediaItem class]]) {
                YYTXMediaItem *item = obj;
                if (nil != item.libraryImport) {
                    [item.libraryImport cancelExport];
                }
            }
        }
    }
    
    [_musicItems removeAllObjects];
}

- (void)regainMedias{

    [self searchSongsInLocalDir];
    [self searchSongsFromiPod];
    [self sortedAndGroupedSongs];
}

@end
