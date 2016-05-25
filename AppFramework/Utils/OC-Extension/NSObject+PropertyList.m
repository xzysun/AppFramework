//
//  NSObject+PropertyList.m
//  GameVideoShare
//
//  Created by xzysun on 14/10/20.
//  Copyright (c) 2014年 AnyApps. All rights reserved.
//

#import "NSObject+PropertyList.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyList)

-(NSArray *)getPropertyList{
    if ([self class] == [NSObject class]) {
        //递归到NSObject类了
        return nil;
    }
    
    NSMutableArray *propertyList = [[NSMutableArray alloc] init];
    
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for(i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        
        NSString *eachPropertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        [propertyList addObject:eachPropertyName];
        
    }
    
    free(properties);
    
    return [propertyList arrayByAddingObjectsFromArray:[[self superclass] getPropertyList]];
}
@end
