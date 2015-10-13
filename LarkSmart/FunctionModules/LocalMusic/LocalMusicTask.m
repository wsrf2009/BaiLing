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
        _musicDirAbsolute = [WebRootDir stringByAppendingPathComponent:(NSString *)songsRelativeDir];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:_musicDirAbsolute isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) ) {
            // 没有songs目录则创建
            [fileManager createDirectoryAtPath:_musicDirAbsolute withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _musicItems = [NSMutableArray array];
        
        [self performSelectorInBackground:@selector(refreshMediaList) withObject:nil];
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
    
    NSString *songTitle = [mediaItem valueForProperty: MPMediaItemPropertyTitle];
    NSURL *urlA =[mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    NSString *ext = urlA.pathExtension;
    if ([ext isEqualToString:(NSString *)songFormat]) {
        
        NSLog (@"%@/%@", urlA, songTitle);
        
        BOOL isExist = NO;
        
        for (YYTXMediaItem *item in mutableArray) {
            if ([item.audio.title isEqualToString:songTitle]) {
                isExist = YES;
                break;
            }
        }
        
        if (!isExist) {
            YYTXMediaItem *item = [[YYTXMediaItem alloc] init];
            item.audio = [[AudioClass alloc] init];
            item.audio.duration = [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] integerValue];
            item.audio.title = songTitle;
            item.audio.url = [self createUrlWithFileName:[songTitle stringByAppendingPathExtension:ext]];
            item.isSelected = NO;
            item.assetUrl = urlA;
            item.file = [_musicDirAbsolute stringByAppendingPathComponent:[songTitle stringByAppendingPathExtension:ext]];
            item.state = YYTXMediaExportingStateUnknown;
            
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

- (void)searchSongsInLocalDir {
    
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:_musicDirAbsolute];
    
    NSString *fileName;
    
    while(fileName = [directoryEnumerator nextObject]) {
        
        if([[fileName pathExtension] isEqualToString:(NSString *)songFormat]) {
            
            YYTXMediaItem *item = [[YYTXMediaItem alloc] init];
            item.audio = [[AudioClass alloc] init];
            item.audio.title = [fileName stringByDeletingPathExtension];
            item.audio.url = [self createUrlWithFileName:fileName];
            item.isSelected = NO;
            item.file = [_musicDirAbsolute stringByAppendingPathComponent:fileName];
            item.assetUrl = nil;
            item.audio.duration = (NSInteger)[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:item.file] error:nil].duration;
            item.state = YYTXMediaExportingStateCompleted;
            
            [_musicItems addObject:item];
            
        } else {
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
            item1.pinYin = [[HTFirstLetter pinYin:item1.audio.title] uppercaseString];
        }
        
        if (nil == item2.pinYin) {
            item2.pinYin = [[HTFirstLetter pinYin:item2.audio.title] uppercaseString];
        }
        
        return  [item1.pinYin localizedCompare:item2.pinYin];
        
    }];
    NSLog(@"%s _ord:%@", __func__, [orderedSongs componentsJoinedByString:@","]);
    
    [_musicItems removeAllObjects];
    
    NSString *groupTitle;
    NSMutableArray *arr;
    for (YYTXMediaItem *item in orderedSongs) {
        unichar letter;
        NSString *firstLetter;
        [item.pinYin getCharacters:&letter range:NSMakeRange(0, 1)];
        
        if(isalpha(letter)) {
            firstLetter = [item.pinYin substringToIndex:1];
        } else {
            firstLetter = @"#";
        }
        
        NSLog(@"%s g:%@, f:%@", __func__, groupTitle, firstLetter);
        
        if (nil == groupTitle) {
            groupTitle = firstLetter;
            arr = [NSMutableArray array];
            [_musicItems addObject:arr];
            [arr addObject:groupTitle];
            [arr addObject:item];
        } else {
            if ([groupTitle isEqualToString:firstLetter]) {
                [arr addObject:item];
            } else {
                groupTitle = firstLetter;
                arr = [NSMutableArray array];
                [_musicItems addObject:arr];
                [arr addObject:groupTitle];
                [arr addObject:item];
            }
        }
    }
    
    for (NSMutableArray *arr in _musicItems) {
        NSLog(@"%s %@", __func__, [arr componentsJoinedByString:@","]);
    }
}

- (NSString *)createUrlWithFileName:(NSString *)file {
    
    NSString *domain = [NSString stringWithFormat:@"%@:%@", [SystemToolClass IPAddress], [SystemToolClass httpServerPort]];
    NSString *urlMusicDir = [domain stringByAppendingPathComponent:(NSString *)songsRelativeDir];
    NSString *urlMusic = [urlMusicDir stringByAppendingPathComponent:file];
    NSString *urlHttp = [@"http://" stringByAppendingString:urlMusic];
    
    return [urlHttp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
