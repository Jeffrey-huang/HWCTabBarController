//
//  HWCTabBarController.h
//  HWCTabBarController
//
//  Created by 黄文昌 on 16/5/16.
//  Copyright © 2016年 黄文昌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+HWCTabBarControllerExtention.h"

FOUNDATION_EXTERN NSString *const HWCTabBarItemTitle;
FOUNDATION_EXTERN NSString *const HWCTabBarItemImage;
FOUNDATION_EXTERN NSString *const HWCTabBarItemSelectedImage;
FOUNDATION_EXTERN NSUInteger HWCTabbarItemsCount;
FOUNDATION_EXTERN NSUInteger HWCPlusButtonIndex;
FOUNDATION_EXTERN CGFloat HWCPlusButtonWidth;
FOUNDATION_EXTERN CGFloat HWCTabBarItemWidth;

@interface HWCTabBarController : UITabBarController

@property (nonatomic, readwrite, copy) NSArray<UIViewController *> *viewControllers;

@property (nonatomic, readwrite, copy) NSArray<NSDictionary *> *tabBarItemsAttributes;

+ (BOOL)havePlusButton;
+ (NSUInteger)allItemsInTabBarCount;

- (id<UIApplicationDelegate>)appDelegate;
- (UIWindow *)rootWindow;

@end
@interface NSObject (HWCTabBarController)

/*!
 * If `self` is kind of `UIViewController`, this method will return the nearest ancestor in the view controller hierarchy that is a tab bar controller. If `self` is not kind of `UIViewController`, it will return the `rootViewController` of the `rootWindow` as long as you have set the `HWCTabBarController` as the  `rootViewController`. Otherwise return nil. (read-only)
 */
@property (nonatomic, readonly) HWCTabBarController *hwc_tabBarController;

@end

FOUNDATION_EXTERN NSString *const HWCTabBarItemWidthDidChangeNotification;