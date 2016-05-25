//
//  User.h
//  AppFramework
//
//  Created by xzysun on 16/5/25.
//  Copyright © 2016年 AnyApps. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface User : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *userId;
@end
