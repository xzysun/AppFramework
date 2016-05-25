//
//  HttpClient+Cache.m
//  TengShare
//
//  Created by xzysun on 15/10/18.
//  Copyright © 2015年 anyApp. All rights reserved.
//

#import "HttpClient+Cache.h"
#import "Config.h"
#import "NSString+Encode.h"
#import <sys/stat.h>
#import "AppService.h"

@implementation HttpClient (Cache)

#pragma mark - Cache
/**
 *  获取缓存文件夹的路径
 *
 *  @return 路径
 */
-(NSURL *)getCacheFileFolder
{
    NSURL *folder = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"RequestCache" isDirectory:YES];
    return folder;
}

/**
 *  检查并创建缓存文件夹
 */
-(void)checkCacheFileFolder
{
    NSURL *cacheFolder = [self getCacheFileFolder];
    DDLogInfo(@"缓存目录:%@", cacheFolder);
    if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheFolder path]]) {
        DDLogWarn(@"缓存目录%@不存在，准备创建", cacheFolder);
        [[NSFileManager defaultManager] createDirectoryAtURL:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

/**
 *  根据参数获取缓存文件的名称
 *
 *  @param path   请求路径
 *  @param method 请求方法
 *  @param params 请求的参数
 *
 *  @return 文件名
 */
-(NSString *)getCacheFileNameForPath:(NSString *)path Method:(NSString *)method Params:(NSDictionary *)params
{
    if ([method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"]) {
        return nil;
    }
    NSString *paramsString = nil;
    if (params) {
        NSError *error = nil;
        NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:(NSJSONWritingOptions)0 error:&error];
        if (error || paramsData == nil) {
            DDLogWarn(@"生成缓存文件名的时候发生异常:%@", error);
            return nil;
        }
        paramsString = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
    }
    NSNumber *userID = ([AppService getService].currentUser.userId)?[AppService getService].currentUser.userId:@(-1);
//    NSNumber *userID = @(0);
    NSString *fileName = [NSString stringWithFormat:@"RequestCache_%@_%@_%@_%@", path, method, paramsString, userID];
    //    DDLogDebug(@"cache file name:%@", fileName);
    return [fileName md5String];
}

/**
 *  检查缓存文件是否有效并返回
 *
 *  @param fileName 缓存的文件名
 *  @param timeout  超时时间
 *
 *  @return 如果缓存有效则返回缓存对象，否则返回nil
 */
-(id)checkCacheWithFileName:(NSString *)fileName ForTimeoutInterval:(NSTimeInterval)timeout
{
    if (fileName == nil) {
        return nil;//不需要缓存
    }
    if (timeout <= 0) {
        return nil;//不需要缓存
    }
    NSURL *filePath = [[self getCacheFileFolder] URLByAppendingPathComponent:fileName];
    NSString *filePathString = [filePath path];
    BOOL existedFlag = [[NSFileManager defaultManager] fileExistsAtPath:filePathString];
    if (!existedFlag) {
        //缓存项目不存在
        return nil;
    }
    //读取文件的修改日期
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathString error:nil];
    if (fileAttributes == nil) {
        //文件信息异常，认为缓存失效
        return nil;
    }
    NSDate *modifyDate = [fileAttributes fileModificationDate];
    if (modifyDate == nil) {
        //文件修改日期异常，认为缓存失效
        return nil;
    }
    //判断过期
    if ([[NSDate date] timeIntervalSinceDate:modifyDate] > timeout) {
        DDLogDebug(@"缓存过期");
        return nil;
    }
    //读取文件
    NSData *cacheData = [NSData dataWithContentsOfURL:filePath];
    NSError *error;
    id cache = [NSJSONSerialization JSONObjectWithData:cacheData options:(NSJSONReadingOptions)0 error:&error];
    if (error) {
        DDLogWarn(@"读取缓存的JSON转换出错:%@", error);
    }
    return cache;
}

/**
 *  保存到缓存
 *
 *  @param fileName 缓存的文件名
 *  @param data     要缓存的数据对象
 */
-(void)storeCacheForFileName:(NSString *)fileName AndResponseObject:(id)data
{
    if (fileName == nil || data == nil || data == (id)[NSNull null]) {
        return;
    }
    NSURL *filePath = [[self getCacheFileFolder] URLByAppendingPathComponent:fileName];
    NSError *error;
//    [self removeMeForObject:data];//对数据执行一些清理工作
    NSData *cacheData = [NSJSONSerialization dataWithJSONObject:data options:(NSJSONWritingOptions)0 error:&error];
    if (error || !cacheData) {
        DDLogWarn(@"写入缓存的JSON转换出错:%@", error);
        return;
    }
    BOOL writeFlag = [cacheData writeToURL:filePath atomically:YES];
    if (!writeFlag) {
        DDLogWarn(@"缓存文件写入失败");
        [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
    }
}

//清理对象中当前用户的相关数据，键值为"me"的对象
-(void)removeMeForObject:(id)object
{
    if ([object isKindOfClass:[NSMutableArray class]]) {
        for (id subObject in object) {
            [self removeMeForObject:subObject];
        }
    } else if ([object isKindOfClass:[NSMutableDictionary class]]) {
        if ([object objectForKey:@"me"]) {
            [object removeObjectForKey:@"me"];
        }
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self removeMeForObject:obj];
        }];
    }
    return;
}

-(long long)doCalculateCacheFileSize
{
    NSURL *cacheFolder = [self getCacheFileFolder];
    NSEnumerator *childFilesEnumerator = [[[NSFileManager defaultManager] subpathsAtPath:[cacheFolder path]] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString* fileAbsolutePath = [[cacheFolder URLByAppendingPathComponent:fileName] path];
        //使用unix c函数计算文件大小
        struct stat st;
        if(lstat([fileAbsolutePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
            folderSize += st.st_size;
        }
    }
    return folderSize;
    //    NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:[cacheFolder path] error:nil];
    //    return [attribute fileSize];
}

-(void)doCleanCache
{
    NSURL *cacheFolder = [self getCacheFileFolder];
    NSEnumerator *childFilesEnumerator = [[[NSFileManager defaultManager] subpathsAtPath:[cacheFolder path]] objectEnumerator];
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString* fileAbsolutePath = [[cacheFolder URLByAppendingPathComponent:fileName] path];
        //使用unix c函数计算文件大小
        [[NSFileManager defaultManager] removeItemAtPath:fileAbsolutePath error:nil];
    }
}
@end
