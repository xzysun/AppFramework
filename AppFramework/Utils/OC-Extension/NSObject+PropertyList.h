//
//  NSObject+PropertyList.h
//  GameVideoShare
//
//  Created by xzysun on 14/10/20.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyList)

/**
 *  获取一个类的属性名称列表，递归父类到NSObject，不包含NSObject里面的属性
 *
 *  @return 属性名称列表
 */
-(NSArray *)getPropertyList;
@end
