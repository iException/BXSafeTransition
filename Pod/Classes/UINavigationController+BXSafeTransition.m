//
//  UINavigationController+BXSafeTransition.m
//  Baixing
//
//  Created by phoebus on 6/23/15.
//  Copyright (c) 2015 baixing. All rights reserved.
//

#import "UINavigationController+BXSafeTransition.h"
#import <objc/runtime.h>

@interface UINavigationController (BXSafeTransitionPrivate)

@property (nonatomic, assign) BOOL bx_pushing;
@property (nonatomic, assign) BOOL bx_poping;

@property (nonatomic, strong) NSArray *bx_pushQueue;
@property (nonatomic, strong) NSArray *bx_popQueue;

@end

@interface UIViewController (BXSafeTransitionPrivate)

@property (nonatomic, weak) UINavigationController *bx_navigationController;

@end

@implementation UINavigationController (BXSafeTransition)

+ (void)load
{
    // this solution is below system version 8.0.
    if ( [UIDevice currentDevice].systemVersion.doubleValue < 8.0 ) {
        // Method Swizzling `pushViewController:animated:`
        Method pushOriMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
        Method pushSwlMethod = class_getInstanceMethod(self, @selector(bx_pushViewController:animated:));
        method_exchangeImplementations(pushOriMethod, pushSwlMethod);
        
        // Method Swizzling `popViewControllerAnimated:`
        Method popOriMethod = class_getInstanceMethod(self, @selector(popViewControllerAnimated:));
        Method popSwlMethod = class_getInstanceMethod(self, @selector(bx_popViewControllerAnimated:));
        method_exchangeImplementations(popOriMethod, popSwlMethod);
    }
}

- (void)bx_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // if pushing, add push operation into queue.
    if ( self.bx_pushing || self.bx_poping ) {
        NSMutableArray *array = [self.bx_pushQueue mutableCopy];
        [array addObject:viewController];
        self.bx_pushQueue = [NSArray arrayWithArray:array];
        return;
    }
    
    // remove current push operation when viewController in queue.
    if ( [self.bx_pushQueue containsObject:viewController] ) {
        NSMutableArray *array = [self.bx_pushQueue mutableCopy];
        [array removeObject:viewController];
        self.bx_pushQueue = [NSArray arrayWithArray:array];
    }
    
    // set pushing flag
    self.bx_pushing = YES;
    
    // do push operation
    [self bx_pushViewController:viewController animated:animated];
}

- (UIViewController *)bx_popViewControllerAnimated:(BOOL)animated
{
    // if poping, add pop operation into queue.
    if ( self.bx_poping || self.bx_pushing ) {
        NSMutableArray *array = [self.bx_popQueue mutableCopy];
        [array addObject:[NSNull null]];
        self.bx_popQueue = [NSArray arrayWithArray:array];
        return nil;
    }
    
    // remove current pop operation when viewController in queue.
    if ( self.bx_popQueue.count > 0 ) {
        NSMutableArray *array = [self.bx_popQueue mutableCopy];
        [array removeObjectAtIndex:0];
        self.bx_popQueue = [NSArray arrayWithArray:array];
    }
    
    // set poping flag
    self.bx_poping = YES;
    
    // do pop operation
    UIViewController *viewController = [self bx_popViewControllerAnimated:animated];
    
    // retain navigation controller when viewDidDisapplear, view.navigationController is nil.
    viewController.bx_navigationController = self;
    
    return viewController;
}

- (void)bx_viewDidAppear
{
    // get first object in queue to do push operation.
    if ( self.bx_pushQueue.firstObject ) {
        [self pushViewController:self.bx_pushQueue.firstObject animated:YES];
    }
}

- (void)bx_viewDidDisappear
{
    // get first object in queue to do pop operation.
    if ( self.bx_popQueue.firstObject ) {
        [self popViewControllerAnimated:YES];
    }
}

#pragma mark - setter & getter
- (void)setBx_pushing:(BOOL)bx_pushing
{
    objc_setAssociatedObject(self, @selector(bx_pushing), @(bx_pushing), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)bx_pushing
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBx_poping:(BOOL)bx_poping
{
    objc_setAssociatedObject(self, @selector(bx_poping), @(bx_poping), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)bx_poping
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBx_pushQueue:(NSArray *)bx_pushQueue
{
    objc_setAssociatedObject(self, @selector(bx_pushQueue), bx_pushQueue, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray *)bx_pushQueue
{
    NSArray *queue = objc_getAssociatedObject(self, _cmd);
    if ( nil == queue ) {
        queue = [NSArray array];
        self.bx_pushQueue = queue;
    }
    return queue;
}

- (void)setBx_popQueue:(NSArray *)bx_popQueue
{
    objc_setAssociatedObject(self, @selector(bx_popQueue), bx_popQueue, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray *)bx_popQueue
{
    NSArray *queue = objc_getAssociatedObject(self, _cmd);
    if ( nil == queue ) {
        queue = [NSArray array];
        self.bx_popQueue = queue;
    }
    return queue;
}

@end

@implementation UIViewController (BXSafeTransition)

+ (void)load
{
    // this solution is below system version 8.0.
    if ( [UIDevice currentDevice].systemVersion.doubleValue < 8.0 ) {
        Method applear_originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
        Method applear_swizzledMethod = class_getInstanceMethod(self, @selector(bx_viewDidAppear:));
        method_exchangeImplementations(applear_originalMethod, applear_swizzledMethod);
        
        Method disApplear_originalMethod = class_getInstanceMethod(self, @selector(viewDidDisappear:));
        Method disApplear_swizzledMethod = class_getInstanceMethod(self, @selector(bx_viewDidDisappear:));
        method_exchangeImplementations(disApplear_originalMethod, disApplear_swizzledMethod);
    }
}

- (void)bx_viewDidAppear:(BOOL)animated
{
    // reset bx_pushing flag when push finished.
    self.navigationController.bx_pushing = NO;
    
    // reset bx_poping flag when pop canceled.
    self.navigationController.bx_poping = NO;
    
    // goto next push operation
    [self.navigationController bx_viewDidAppear];
    
    [self bx_viewDidAppear:animated];
}

- (void)bx_viewDidDisappear:(BOOL)animated
{
    // reset bx_poping flag when pop finished.
    self.bx_navigationController.bx_poping = NO;
    
    // goto next pop operation
    [self.bx_navigationController bx_viewDidDisappear];
    
    [self bx_viewDidDisappear:animated];
}

#pragma mark - setter & getter
- (void)setBx_navigationController:(UINavigationController *)bx_navigationController
{
    objc_setAssociatedObject(self, @selector(bx_navigationController), bx_navigationController, OBJC_ASSOCIATION_RETAIN);
}

- (UINavigationController *)bx_navigationController
{
    return objc_getAssociatedObject(self, _cmd);
}

@end