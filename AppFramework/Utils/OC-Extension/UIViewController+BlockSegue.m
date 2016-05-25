//
//  UIViewController+BlockSegue.m
//  GameVideoShare
//
//  Created by xzysun on 15/8/6.
//  Copyright (c) 2015年 AnyApps. All rights reserved.
//

#import "UIViewController+BlockSegue.h"
#import <objc/runtime.h>

@interface UIViewController (BlockSegueInternal)

@property (nonatomic, strong) NSMutableDictionary *seguePreparationDic;
@end

@implementation UIViewController (BlockSegueInternal)
static char seguePreparationDicKey;
-(void)setSeguePreparationDic:(NSMutableDictionary *)seguePreparationDic
{
    [self willChangeValueForKey:@"seguePreparationDic"];
    objc_setAssociatedObject(self, &seguePreparationDicKey, seguePreparationDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"seguePreparationDic"];
}

-(NSMutableDictionary *)seguePreparationDic
{
    return objc_getAssociatedObject(self, &seguePreparationDicKey);
}
@end

@implementation UIViewController (BlockSegue)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(prepareForSegue:sender:);
        SEL swizzledSelector = @selector(custom_prepareForSegue:sender:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

-(void)custom_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self custom_prepareForSegue:segue sender:sender];
    NSLog(@"prepareForSegue:%@ sender:%@", segue, sender);
    SeguePreparationBlock preparation = [self.seguePreparationDic valueForKey:[segue identifier]];
    if (preparation) {
        preparation([segue destinationViewController]);
        [self.seguePreparationDic removeObjectForKey:[segue identifier]];
    }
}

-(void)presentViewControllerWithSegueIdentifier:(NSString *)segueIndetifier AndPreparation:(SeguePreparationBlock)preparation
{
    if (self.seguePreparationDic == nil) {
        self.seguePreparationDic = [NSMutableDictionary dictionary];
    }
    [self.seguePreparationDic setValue:preparation forKey:segueIndetifier];
    [self performSegueWithIdentifier:segueIndetifier sender:self];
}
@end
