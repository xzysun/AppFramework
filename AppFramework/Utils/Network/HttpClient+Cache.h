//
//  HttpClient+Cache.h
//  TengShare
//
//  Created by xzysun on 15/10/18.
//  Copyright © 2015年 anyApp. All rights reserved.
//

#import "HttpClient.h"

@interface HttpClient (Cache)

/**
 *  检查并创建缓存文件夹
 */
-(void)checkCacheFileFolder;

/**
 *  根据参数获取缓存文件的名称
 *
 *  @param path   请求路径
 *  @param method 请求方法
 *  @param params 请求的参数
 *
 *  @return 文件名
 */
-(NSString *)getCacheFileNameForPath:(NSString *)path Method:(NSString *)method Params:(NSDictionary *)params;

/**
 *  检查缓存文件是否有效并返回
 *
 *  @param fileName 缓存的文件名
 *  @param timeout  超时时间
 *
 *  @return 如果缓存有效则返回缓存对象，否则返回nil
 */
-(id)checkCacheWithFileName:(NSString *)fileName ForTimeoutInterval:(NSTimeInterval)timeout;

/**
 *  保存到缓存
 *
 *  @param fileName 缓存的文件名
 *  @param data     要缓存的数据对象
 */
-(void)storeCacheForFileName:(NSString *)fileName AndResponseObject:(id)data;

/**
 *  计算缓存的大小
 *
 *  @return 请求缓存的大小，单位字节
 */
-(long long)doCalculateCacheFileSize;

/**
 *  执行清理缓存操作
 */
-(void)doCleanCache;
@end
