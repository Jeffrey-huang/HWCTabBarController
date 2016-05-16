//
//  HWCPlusButton.h
//  HWCTabBarController
//
//  Created by 黄文昌 on 16/5/16.
//  Copyright © 2016年 黄文昌. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HWCPlusButtonSubclassing

@required
+ (id)plusButton;
@optional

/*!
 用来自定义加号按钮的位置，如果不实现默认居中。
 @attention 以下两种情况下，必须实现该协议方法，否则 HWCTabBarController 会抛出 exception 来进行提示：
 1. 添加了 PlusButton 且 TabBarItem 的个数是奇数。
 2. 实现了 `+plusChildViewController`。
 @return 用来自定义加号按钮在 TabBar 中的位置。
 *
 */
+ (NSUInteger)indexOfPlusButtonInTabBar;

/*!
 该方法是为了调整自定义按钮中心点Y轴方向的位置，建议在按钮超出了 tabbar 的边界时实现该方法。
 
 @return 返回值是自定义按钮中心点Y轴方向的坐标除以 tabbar 的高度，如果不实现，会自动进行比对，预设一个较为合适的位置，如果实现了该方法，预设的逻辑将失效。
 *
 */
+ (CGFloat)multiplerInCenterY;

/*!
 实现该方法后，能让 PlusButton 的点击效果与跟点击其他 UITabBarButton 效果一样，跳转到该方法指定的 UIViewController 。
 @attention 必须同时实现 `+indexOfPlusButtonInTabBar` 来指定 PlusButton 的位置。
 @return 指定 PlusButton 点击后跳转的 UIViewController。
 *
 */
+ (UIViewController *)plusChildViewController;

@end

@class HWCTabBar;

FOUNDATION_EXTERN UIButton<HWCPlusButtonSubclassing> *HWCExternPlusButton;
FOUNDATION_EXTERN UIViewController *HWCPlusChildViewController;

@interface HWCPlusButton : UIButton
+ (void)registerSubclass;

- (void)plusChildViewControllerButtonClicked:(UIButton<HWCPlusButtonSubclassing> *)sender;
@end
