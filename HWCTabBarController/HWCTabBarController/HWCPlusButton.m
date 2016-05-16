//
//  HWCPlusButton.m
//  HWCTabBarController
//
//  Created by 黄文昌 on 16/5/16.
//  Copyright © 2016年 黄文昌. All rights reserved.
//

#import "HWCPlusButton.h"
#import "HWCTabBarController.h"

CGFloat HWCPlusButtonWidth = 0.0f;
UIButton<HWCPlusButtonSubclassing> *HWCExternPlusButton = nil;
UIViewController *HWCPlusChildViewController = nil;

@implementation HWCPlusButton
#pragma mark -
#pragma mark - public Methods

+ (void)registerSubclass {
    if (![self conformsToProtocol:@protocol(HWCPlusButtonSubclassing)]) {
        return;
    }
    Class<HWCPlusButtonSubclassing> class = self;
    UIButton<HWCPlusButtonSubclassing> *plusButton = [class plusButton];
    HWCExternPlusButton = plusButton;
    HWCPlusButtonWidth = plusButton.frame.size.width;
    if ([[self class] respondsToSelector:@selector(plusChildViewController)]) {
        HWCPlusChildViewController = [class plusChildViewController];
        [[self class] addSelectViewControllerTarget:plusButton];
        if ([[self class] respondsToSelector:@selector(indexOfPlusButtonInTabBar)]) {
            HWCPlusButtonIndex = [[self class] indexOfPlusButtonInTabBar];
        } else {
            [NSException raise:@"HWCTabBarController" format:@"If you want to add PlusChildViewController, you must realizse `+indexOfPlusButtonInTabBar` in your custom plusButton class.【Chinese】如果你想使用PlusChildViewController样式，你必须同时在你自定义的plusButton中实现 `+indexOfPlusButtonInTabBar`，来指定plusButton的位置"];
        }
    }
}

- (void)plusChildViewControllerButtonClicked:(UIButton<HWCPlusButtonSubclassing> *)sender {
    sender.selected = YES;
    [self hwc_tabBarController].selectedIndex = HWCPlusButtonIndex;
}

#pragma mark -
#pragma mark - Private Methods

+ (void)addSelectViewControllerTarget:(UIButton<HWCPlusButtonSubclassing> *)plusButton {
    id target = self;
    NSArray<NSString *> *selectorNamesArray = [plusButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    if (selectorNamesArray.count == 0) {
        target = plusButton;
        selectorNamesArray = [plusButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    }
    [selectorNamesArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector =  NSSelectorFromString(obj);
        [plusButton removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }];
    [plusButton addTarget:plusButton action:@selector(plusChildViewControllerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}
@end
