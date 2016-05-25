//
//  KeyChainHelper.m
//  TengShare
//
//  Created by xzysun on 14-10-16.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import "KeyChainHelper.h"

@implementation KeyChainHelper

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)identifier {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
            identifier, (__bridge id)kSecAttrService,
            identifier, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)createKeyChainValue:(NSString *)identifier value:(NSString *)value{
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)searchKeyChainValue:(NSString *)identifier
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    OSStatus secStatus = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData);
    if ( secStatus == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", identifier, e);
        } @finally {
        }
    }else{
        NSLog(@"SecItemCopyMatching Error. Error code is: %ld", (long)secStatus);
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)deleteKeyChainValue:(NSString *)identifier
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end
