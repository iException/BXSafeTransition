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

@property (nonatomic, strong) NSArray *bx_pushQueue;

@property (nonatomic, strong) NSArray *bx_popQueue;

@property (nonatomic, weak) UIViewController *bx_popingViewController;

@end

@interface UIViewController (BXSafeTransitionPrivate)

@property (nonatomic, assign) BOOL bx_pushing;

@property (nonatomic, weak) UINavigationController *bx_navigationController;

@end

@implementation UINavigationController (BXSafeTransition)

+ (void)load
{
    // Method Swizzling `pushViewController:animated:`
    Method pushOriginalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    Method pushSwizzledMethod = class_getInstanceMethod(self, @selector(bx_pushViewController:animated:));
    method_exchangeImplementations(pushOriginalMethod, pushSwizzledMethod);
    
    // Method Swizzling `popViewControllerAnimated:`
    Method popOriginalMethod = class_getInstanceMethod(self, @selector(popViewControllerAnimated:));
    Method popSwizzledMethod = class_getInstanceMethod(self, @selector(bx_popViewControllerAnimated:));
    method_exchangeImplementations(popOriginalMethod, popSwizzledMethod);
}

- (void)bx_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ( self.topViewController.bx_pushing ) {
        NSMutableArray *array = [self.bx_pushQueue mutableCopy];
        [array addObject:viewController];
        self.bx_pushQueue = [NSArray arrayWithArray:array];
        return;
    }
    
    if ( [self.bx_pushQueue containsObject:viewController] ) {
        NSMutableArray *array = [self.bx_pushQueue mutableCopy];
        [array removeObject:viewController];
        self.bx_pushQueue = [NSArray arrayWithArray:array];
    }
    
    viewController.bx_pushing = YES;
    
    [self bx_pushViewController:viewController animated:animated];
}

- (UIViewController *)bx_popViewControllerAnimated:(BOOL)animated
{
    if ( self.bx_popingViewController ) {
        NSMutableArray *array = [self.bx_popQueue mutableCopy];
        [array addObject:[NSNull null]];
        self.bx_popQueue = [NSArray arrayWithArray:array];
        return nil;
    }
    
    if ( self.bx_popQueue.count > 0 ) {
        NSMutableArray *array = [self.bx_popQueue mutableCopy];
        [array removeObjectAtIndex:0];
        self.bx_popQueue = [NSArray arrayWithArray:array];
    }
    
    UIViewController *viewController = [self bx_popViewControllerAnimated:animated];
    viewController.bx_navigationController = self;
    self.bx_popingViewController = viewController;
    return viewController;
}

- (void)bx_viewDidAppear
{
    if ( self.bx_pushQueue.firstObject ) {
        [self pushViewController:self.bx_pushQueue.firstObject animated:YES];
    }
}

- (void)bx_viewDidDisappear
{
    if ( self.bx_popQueue.firstObject ) {
        [self popViewControllerAnimated:YES];
    }
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

- (void)setBx_popingViewController:(UIViewController *)bx_popingViewController
{
    objc_setAssociatedObject(self, @selector(bx_popingViewController), bx_popingViewController, OBJC_ASSOCIATION_RETAIN);
}

- (UIViewController *)bx_popingViewController
{
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation UIViewController (BXSafeTransition)

+ (void)load
{
    Method applear_originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
    Method applear_swizzledMethod = class_getInstanceMethod(self, @selector(bx_viewDidAppear:));
    method_exchangeImplementations(applear_originalMethod, applear_swizzledMethod);
    
    Method disApplear_originalMethod = class_getInstanceMethod(self, @selector(viewDidDisappear:));
    Method disApplear_swizzledMethod = class_getInstanceMethod(self, @selector(bx_viewDidDisappear:));
    method_exchangeImplementations(disApplear_originalMethod, disApplear_swizzledMethod);
}

- (void)bx_viewDidAppear:(BOOL)animated
{
    self.bx_pushing = NO;
    
    [self.navigationController bx_viewDidAppear];
    
    [self bx_viewDidAppear:animated];
}

- (void)bx_viewDidDisappear:(BOOL)animated
{
    // if pop canceled, return.
    if ( self.bx_navigationController == nil ) { return; }

    self.bx_navigationController.bx_popingViewController = nil;
    
    [self.bx_navigationController bx_viewDidDisappear];
    
    [self bx_viewDidDisappear:animated];
}

- (void)setBx_pushing:(BOOL)bx_pushing
{
    objc_setAssociatedObject(self, @selector(bx_pushing), @(bx_pushing), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)bx_pushing
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBx_navigationController:(UINavigationController *)bx_navigationController
{
    objc_setAssociatedObject(self, @selector(bx_navigationController), bx_navigationController, OBJC_ASSOCIATION_RETAIN);
}

- (UINavigationController *)bx_navigationController
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
