//
//  KeyChainHelper.h
//  TengShare
//
//  Created by xzysun on 14-10-16.
//  Copyright (c) 2014年 anyApp. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  用于在钥匙串保存数据的工具类
 */
@interface KeyChainHelper : NSObject

/**
 *  在keychain里面保存一个数据
 *
 *  @param identifier 保存数据的键值
 *  @param value      要保存的数据
 */
+ (void)createKeyChainValue:(NSString *)identifier value:(NSString *)value;

/**
 *  在keychain里面查找一个数据
 *
 *  @param identifier 保存数据的键值
 *
 *  @return 保存的数据，或者nil
 */
+ (id)searchKeyChainValue:(NSString *)identifier;

/**
 *  从keychain里面删除一个数据
 *
 *  @param identifier 保存数据的键值
 */
+ (void)deleteKeyChainValue:(NSString *)identifier;

@end
