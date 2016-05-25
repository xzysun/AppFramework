//
//  JailBreakDetection.m
//  DataEase
//
//  Created by xzysun on 16/1/8.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import "JailBreakDetection.h"

@implementation JailBreakDetection

+(BOOL)isJailBroken {
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]) {
        return YES;
    }
    
    NSError *error;
    NSString *testWriteText = @"Jailbreak test";
    NSString *testWritePath = @"/private/jailbreaktest.txt";
    
    [testWriteText writeToFile:testWritePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error == nil) {
        [[NSFileManager defaultManager] removeItemAtPath:testWritePath error:nil];
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:testWritePath error:nil];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]) {
        return YES;
    }
    
#endif
    
    return NO;
}

@end
