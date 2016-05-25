//
//  HttpClient.m
//  TengShare
//
//  Created by xzysun on 15/10/18.
//  Copyright © 2015年 anyApp. All rights reserved.
//

#import "HttpClient.h"
#import "AFNetWorking.h"
#import "Config.h"
#import "HttpClient+Cache.h"
#import "AppService.h"
#import "KeyChainHelper.h"
#import "UIDevice+info.h"
#import "NSString+Encode.h"

@interface HttpClient ()

@property (strong, nonatomic) AFHTTPSessionManager *httpManager;
@end

@implementation HttpClient

+(instancetype)getClient
{
    static HttpClient *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HttpClient alloc] init];
    });
    return _instance;
}

-(instancetype)init
{
    if (self=[super init]) {
        //init here
        NSURL *baseUrl = [NSURL URLWithString:kServerBaseURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        configuration.URLCache = nil;
        configuration.HTTPMaximumConnectionsPerHost = 1;
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        configuration.HTTPShouldSetCookies = YES;
        self.httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl sessionConfiguration:configuration];
//        self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain", nil];
        WeakSelf
        //设置加密
#ifdef DevSetting
        self.httpManager.securityPolicy.allowInvalidCertificates = YES;
        self.httpManager.securityPolicy.validatesDomainName = NO;
#endif
//        self.httpManager.securityPolicy.SSLPinningMode = AFSSLPinningModeCertificate;
//        httpManager.securityPolicy.validatesCertificateChain = NO;
////        httpManager.securityPolicy.validatesDomainName = NO;
//        NSData *cer = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"a2" ofType:@"cer"]];
//        self.httpManager.securityPolicy.pinnedCertificates = @[cer];
        //设置网络状态观察器
        NSString *domain = getDomainFromURLString(kServerBaseURL);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9]{1,2})(\\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[0-9]{1,2})){3}$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSInteger matches = [regex numberOfMatchesInString:domain options:(NSMatchingOptions)0 range:NSMakeRange(0, domain.length)];
        if (matches > 0) {
            //服务器地址是IP
        } else {
            //服务器地址是域名
            //#warning 目前这个版本的ReachabilityManager对域名的处理有问题，暂时使用默认的
            self.httpManager.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:domain];
        }
        [self.httpManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            //网络状态发生了变化
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    DDLogInfo(@"检测到网络连接");
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    DDLogInfo(@"检测到网络断开");
                    break;
                default:
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkStatusChangedNotification object:weakSelf];
        }];
        [self.httpManager.reachabilityManager startMonitoring];
        //检测缓存文件夹
        [self checkCacheFileFolder];
    }
    return self;
}

-(BOOL)netowrkReachable
{
    //返回当前是否联网
    return self.httpManager.reachabilityManager.reachable;
}

#pragma mark - Send Request
-(void)sendRequestForPath:(NSString *)path WithMethod:(RequestMethod)method WithParameters:(NSDictionary *)params Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure CacheTime:(NSTimeInterval)cacheTime TimeoutInterval:(NSTimeInterval)timeout
{
    NSString *methodStr = [self getRequestMethodForType:method];
    //检查缓存
    NSString *cacheFileName  = [self getCacheFileNameForPath:path Method:methodStr Params:params];
    id cachedResult = [self checkCacheWithFileName:cacheFileName ForTimeoutInterval:cacheTime];
    if (cachedResult) {
        DDLogDebug(@"请求%@命中缓存，直接返回", path);
        success(cachedResult);
        return;
    }
    DDLogDebug(@"准备执行请求%@", path);
    //发起请求
    NSString *url = [kServerBaseURL stringByAppendingString:path];
    NSMutableURLRequest *request = nil;
    if (method == POST_JSON) {
        //请求头使用JSON进行序列化
        AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
        jsonSerializer.timeoutInterval = timeout;
        NSDictionary *headers = self.httpManager.requestSerializer.HTTPRequestHeaders;
        [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [jsonSerializer setValue:obj forHTTPHeaderField:key];
        }];
        request = [jsonSerializer requestWithMethod:methodStr URLString:[[NSURL URLWithString:url relativeToURL:self.httpManager.baseURL] absoluteString] parameters:params error:nil];
    } else {
        self.httpManager.requestSerializer.timeoutInterval = timeout;
        request = [self.httpManager.requestSerializer requestWithMethod:methodStr URLString:[[NSURL URLWithString:url relativeToURL:self.httpManager.baseURL] absoluteString] parameters:params error:nil];
    }
    request.timeoutInterval = timeout;
    WeakSelf
    NSURLSessionDataTask *dataTask = [self.httpManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //获取到响应
        DDLogDebug(@"执行请求%@获取到响应:%@", path, responseObject);
        [weakSelf handleResponse:response ResponseObject:responseObject Error:error Success:^(id result) {
            //写入缓存
            if (cacheTime >= 0) {
                [weakSelf storeCacheForFileName:cacheFileName AndResponseObject:result];
            }
            success(result);
        } Failure:^(NSString *errorMsg, NSInteger errorCode) {
            //失败处理
            if (errorCode == kServerErrorNotLogin) {
                [weakSelf reloginAndResendRequest:request CacheTime:cacheTime CacheFileName:cacheFileName Success:success Failure:^(NSString *errorMsg, NSInteger errorCode) {
                    DDLogWarn(@"重新登录失败:%@", errorMsg);
                    failure(@"当前账号状态异常，请退出应用并重新登录", kDefaultErrorCode);
                }];
            } else {
                failure(errorMsg, errorCode);
            }
        }];
    }];
    [dataTask resume];
}

-(void)sendFormDataForPath:(NSString *)path WithMethod:(RequestMethod)method WithParameters:(NSDictionary *)params MimeTypes:(NSArray *)mimeTypes Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure TimeoutInterval:(NSTimeInterval)timeout
{
    NSString *methodStr = [self getRequestMethodForType:method];
    DDLogDebug(@"准备执行请求%@", path);
    //发起请求
    NSString *url = [kServerBaseURL stringByAppendingString:path];
    self.httpManager.requestSerializer.timeoutInterval = timeout;
    NSMutableURLRequest *request = [self.httpManager.requestSerializer multipartFormRequestWithMethod:methodStr URLString:[[NSURL URLWithString:url relativeToURL:self.httpManager.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSInteger mineTypeIndex = 0;
        for (NSString *key in params.allKeys) {
            id value = [params objectForKey:key];
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                NSString *valueString = [NSString stringWithFormat:@"%@", value];
                [formData appendPartWithFormData:[valueString dataUsingEncoding:NSUTF8StringEncoding] name:key];
            } else if ([value isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:value name:key fileName:key mimeType:[mimeTypes objectAtIndex:mineTypeIndex]];
                mineTypeIndex++;
            } else {
                DDLogWarn(@"表单中%@对于的内如类型未知:%@", key, value);
            }
        }
    } error:nil];
    request.timeoutInterval = timeout;
    WeakSelf
    NSURLSessionUploadTask *uploadTask = [self.httpManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //获取到响应
        DDLogDebug(@"执行请求%@获取到响应:%@", path, responseObject);
        [weakSelf handleResponse:responseObject ResponseObject:responseObject Error:error Success:^(id result) {
            success(result);
        } Failure:^(NSString *errorMsg, NSInteger errorCode) {
            if (errorCode == kServerErrorNotLogin) {
                [weakSelf reloginAndResendRequest:request CacheTime:kNoCache CacheFileName:nil Success:success Failure:^(NSString *errorMsg, NSInteger errorCode) {
                    DDLogWarn(@"重新登录失败:%@", errorMsg);
                    failure(@"当前账号状态异常，请退出应用并重新登录", kDefaultErrorCode);
                }];
            } else {
                failure(errorMsg, errorCode);
            }
        }];
    }];
    [uploadTask resume];
}

-(void)loginToServerWithUserName:(NSString *)userName Password:(NSString *)password Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure
{
#warning Login API Path
    NSString *path = @"/user/login.do";
    NSString *url = [kServerBaseURL stringByAppendingString:path];
    NSString *currentVersion = [[UIDevice currentDevice] appVersion];
    NSString *osVersion = [UIDevice currentDevice].systemVersion;
    NSString *model = [[UIDevice currentDevice] deviceModel];
    NSString *encryptedPassword = [password md5String];
    NSDictionary *params = @{@"username":userName, @"password":encryptedPassword, @"model":model, @"platform":@"iOS", @"uuid":[AppService getService].udid, @"version":osVersion, @"version_id":currentVersion};
    NSString *methodStr = [self getRequestMethodForType:POST];
    NSMutableURLRequest *request = [self.httpManager.requestSerializer requestWithMethod:methodStr URLString:[[NSURL URLWithString:url relativeToURL:self.httpManager.baseURL] absoluteString] parameters:params error:nil];
    WeakSelf
    NSURLSessionDataTask *dataTask = [self.httpManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        DDLogDebug(@"执行登陆请求%@获取到响应:%@", path, responseObject);
        [weakSelf handleResponse:response ResponseObject:responseObject Error:error Success:^(id result) {
            NSError *error = nil;
            User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:[result objectForKey:@"user"] error:&error];
            if (error) {
                failure(@"登录接口异常", kDefaultErrorCode);
            } else {
                [AppService getService].currentUser = user;
                success(result);
            }
        } Failure:failure];
    }];
    [dataTask resume];
}

#pragma mark - Cache
-(long long)calculateCacheFileSize
{
    return [self doCalculateCacheFileSize];
}

-(void)cleanCache
{
    return [self doCleanCache];
}


#pragma mark - Private
-(BOOL)handleResponse:(NSURLResponse *)response ResponseObject:(id)responseObject Error:(NSError *)error Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure
{
    BOOL succeedFlag = NO;
    if (error) {
        NSString *msg = [error localizedDescription];
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
            //用户取消
            msg = nil;
        } else  if ([error.domain isEqualToString:NSURLErrorDomain]&&(error.code == NSURLErrorTimedOut||error.code == NSURLErrorCannotFindHost || error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorDNSLookupFailed || error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorUserCancelledAuthentication || error.code == NSURLErrorUserAuthenticationRequired || error.code == NSURLErrorDataNotAllowed)) {
            msg = @"网络状态异常，请检查您的网络设置并重试";
        } else {
            msg = @"系统处理异常，请稍后重试";
        }
        failure(msg, error.code);
    } else if (responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *error = [responseObject objectForKey:@"error"];
            if (error && error != (id)[NSNull null]) {
                //系统定义的错误
                NSInteger errorCode = [[error objectForKey:@"errno"] integerValue];
                NSString *errorMsg = [error objectForKey:@"message"];
                failure(errorMsg, errorCode);
            } else {
                succeedFlag = YES;
                if (success) {
                    success(responseObject);
                }
            }
        } else {
            failure(@"服务器返回的数据异常", kDefaultErrorCode);
        }
    } else {
        failure(@"系统处理异常，请稍后重试", kDefaultErrorCode);
    }
    return succeedFlag;
}

-(void)reloginAndResendRequest:(NSURLRequest *)request CacheTime:(NSTimeInterval)cacheTime CacheFileName:(NSString *)cacheFileName Success:(HttpSuccessBlock)success Failure:(HttpFailureBlock)failure
{
    
    DDLogWarn(@"检测登录状态异常，准备重新登录");
    //重新登录的情况
    NSString *userName = [KeyChainHelper searchKeyChainValue:kStorageKeyUserName];
    NSString *password = [KeyChainHelper searchKeyChainValue:kStorageKeyPassword];
    WeakSelf
    [self loginToServerWithUserName:userName Password:password Success:^(id result) {
        DDLogInfo(@"重新登录成功，准备重发请求");
        //重连成功，尝试重新发送
        if (request.HTTPBodyStream) {
            //上传模式
            NSURLSessionUploadTask *task = [weakSelf.httpManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
                //
            } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                DDLogDebug(@"重发上传请求%@收到响应:%@", request.URL.path, responseObject);
                [weakSelf handleResponse:response ResponseObject:responseObject Error:error Success:success Failure:failure];
            }];
            [task resume];
            return;
        }
        NSURLSessionDataTask *task = [weakSelf.httpManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            DDLogDebug(@"重发请求%@收到响应:%@", request.URL.path, responseObject);
            [weakSelf handleResponse:response ResponseObject:responseObject Error:error Success:^(id resultData) {
                //写入缓存
                if (cacheTime >= 0) {
                    [weakSelf storeCacheForFileName:cacheFileName AndResponseObject:resultData];
                }
                success(resultData);
            } Failure:failure];
        }];
        [task resume];
    } Failure:^(NSString *errorMsg, NSInteger errorCode) {
        DDLogWarn(@"重新登录失败:%@", errorMsg);
        failure(@"当前账号状态异常，请退出应用并重新登录", kDefaultErrorCode);
    }];
    return;
}


/**
 *  转换请求类型
 *
 *  @param type 枚举RequestMethod的请求类型
 *
 *  @return 请求类型的字符串
 */
-(NSString *)getRequestMethodForType:(RequestMethod)type
{
    NSString *methodStr = nil;
    switch (type) {
        case GET:
            methodStr = @"GET";
            break;
        case POST:
        case POST_JSON:
            methodStr = @"POST";
            break;
        case PUT:
            methodStr = @"PUT";
            break;
        case DELETE:
            methodStr = @"DELETE";
            break;
        default:
            methodStr = @"GET";
            break;
    }
    return methodStr;
}
@end
