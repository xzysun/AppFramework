//
//  HttpClient.h
//  TengShare
//
//  Created by xzysun on 15/10/18.
//  Copyright © 2015年 anyApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HttpSuccessBlock)(id result);
typedef void(^HttpFailureBlock)(NSString *errorMsg, NSInteger errorCode);

typedef enum : NSUInteger {
    GET,
    POST,
    POST_JSON,
    PUT,
    DELETE,
} RequestMethod;

@interface HttpClient : NSObject

+(instancetype)getClient;

/**
 *  网络是否可以访问，这里返回的是最近一次检测的结果
 */
@property (nonatomic, assign, readonly) BOOL netowrkReachable;

/**
 *  发送请求
 *
 *  @param path      请求路径，使用相对服务器域名的路径
 *  @param method    请求的类型
 *  @param params    请求参数列表
 *  @param success   成功回调
 *  @param failure   失败回调
 *  @param cacheTime 缓存时间，负数为不缓存，0为请求服务器并刷新缓存，正数为缓存的有效时间
 *  @param timeout   超时时间
 */
-(void)sendRequestForPath:(NSString *)path WithMethod:(RequestMethod)method WithParameters:(NSDictionary *)params Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure CacheTime:(NSTimeInterval)cacheTime TimeoutInterval:(NSTimeInterval)timeout;

/**
 *  发送表单请求，如果有文件的话转换成NSData传入params参数，这个请求不会进行缓存
 *
 *  @param path    请求路径，使用相对服务器域名的路径
 *  @param method  请求的类型
 *  @param params  请求参数列表，目前支持NSString，NSNumber，NSData
 *  @param mimeTypes    请求中Data类型的mineType列表
 *  @param success 成功回调
 *  @param failure 失败回调
 *  @param timeout 超时时间
 */
-(void)sendFormDataForPath:(NSString *)path WithMethod:(RequestMethod)method WithParameters:(NSDictionary *)params MimeTypes:(NSArray *)mimeTypes Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure TimeoutInterval:(NSTimeInterval)timeout;

/**
 *  向服务器登录
 *
 *  @param userName 用户名
 *  @param password 密码
 *  @param success  成功回调
 *  @param failure  失败回调
 */
-(void)loginToServerWithUserName:(NSString *)userName Password:(NSString *)password Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure;

#pragma mark - Cache
-(long long)calculateCacheFileSize;
-(void)cleanCache;
@end
