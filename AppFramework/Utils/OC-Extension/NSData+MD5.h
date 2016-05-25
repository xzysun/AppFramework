//
//  NSData+MD5.h
//  GameVideoShare
//
//  Created by xzysun on 14/12/5.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MD5)

-(NSString *)md5String;

/**
 *  根据传入的路径计算一个文件的MD5值
 *
 *  @param path 本地文件路径
 *
 *  @return 文件的MD5值
 */
+(NSString*)getFileMD5WithPath:(NSString*)path;
@end
