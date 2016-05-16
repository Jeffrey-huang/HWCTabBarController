//
//  HWCTabBarController.m
//  HWCTabBarController
//
//  Created by 黄文昌 on 16/5/16.
//  Copyright © 2016年 黄文昌. All rights reserved.
//

#import "HWCTabBarController.h"
#import "HWCTabBar.h"
#import "HWCPlusButton.h"
#import <objc/runtime.h>

NSString *const HWCTabBarItemTitle = @"HWCTabBarItemTitle";
NSString *const HWCTabBarItemImage = @"HWCTabBarItemImage";
NSString *const HWCTabBarItemSelectedImage = @"HWCTabBarItemSelectedImage";

NSUInteger HWCTabbarItemsCount = 0;
NSUInteger HWCPlusButtonIndex = 0;
CGFloat HWCTabBarItemWidth = 0.0f;
NSString *const HWCTabBarItemWidthDidChangeNotification = @"HWCTabBarItemWidthDidChangeNotification";

@interface NSObject (HWCTabBarControllerItemInternal)

- (void)hwc_setTabBarController:(HWCTabBarController *)tabBarController;

@end

@interface HWCTabBarController () <UITabBarControllerDelegate>

@end

@implementation HWCTabBarController

@synthesize viewControllers = _viewControllers;

- (void)viewDidLoad {
    [super viewDidLoad];
    // 处理tabBar，使用自定义 tabBar 添加 发布按钮
    [self setUpTabBar];
    self.delegate = self;
}

#pragma mark -
#pragma mark - public Methods

+ (BOOL)havePlusButton {
    if (HWCExternPlusButton) {
        return YES;
    }
    return NO;
}
+ (NSUInteger)allItemsInTabBarCount {
    NSUInteger allItemsInTabBar = HWCTabbarItemsCount;
    if ([HWCTabBarController havePlusButton]) {
        allItemsInTabBar += 1;
    }
    return allItemsInTabBar;
}

- (id<UIApplicationDelegate>)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (UIWindow *)rootWindow {
    UIWindow *result = nil;
    
    do {
        if ([self.appDelegate respondsToSelector:@selector(window)]) {
            result = [self.appDelegate window];
        }
        
        if (result) {
            break;
        }
    } while (NO);
    
    return result;
}
/**
 *  利用 KVC 把系统的 tabBar 类型改为自定义类型。
 */
- (void)setUpTabBar {
    [self setValue:[[HWCTabBar alloc] init] forKey:@"tabBar"];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers && _viewControllers.count) {
        for (UIViewController *viewController in _viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        if ((!_tabBarItemsAttributes) || (_tabBarItemsAttributes.count != viewControllers.count)) {
            [NSException raise:@"HWCTabBarController" format:@"The count of HWCTabBarControllers is not equal to the count of tabBarItemsAttributes.【Chinese】设置_tabBarItemsAttributes属性时，请确保元素个数与控制器的个数相同，并在方法`-setViewControllers:`之前设置"];
        }
        
        if (HWCPlusChildViewController) {
            NSMutableArray *viewControllersWithPlusButton = [NSMutableArray arrayWithArray:viewControllers];
            [viewControllersWithPlusButton insertObject:HWCPlusChildViewController atIndex:HWCPlusButtonIndex];
            _viewControllers = [viewControllersWithPlusButton copy];
        } else {
            _viewControllers = [viewControllers copy];
        }
        HWCTabbarItemsCount = [viewControllers count];
        HWCTabBarItemWidth = ([UIScreen mainScreen].bounds.size.width - HWCPlusButtonWidth) / (HWCTabbarItemsCount);
        NSUInteger idx = 0;
        for (UIViewController *viewController in _viewControllers) {
            NSString *title = nil;
            NSString *normalImageName = nil;
            NSString *selectedImageName = nil;
            if (viewController != HWCPlusChildViewController) {
                title = _tabBarItemsAttributes[idx][HWCTabBarItemTitle];
                normalImageName = _tabBarItemsAttributes[idx][HWCTabBarItemImage];
                selectedImageName = _tabBarItemsAttributes[idx][HWCTabBarItemSelectedImage];
            } else {
                idx--;
            }
            
            [self addOneChildViewController:viewController
                                  WithTitle:title
                            normalImageName:normalImageName
                          selectedImageName:selectedImageName];
            [viewController hwc_setTabBarController:self];
            idx++;
        }
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [viewController hwc_setTabBarController:nil];
        }
        _viewControllers = nil;
    }
}
/**
 *  添加一个子控制器
 *
 *  @param viewController    控制器
 *  @param title             标题
 *  @param normalImageName   图片
 *  @param selectedImageName 选中图片
 */
- (void)addOneChildViewController:(UIViewController *)viewController
                        WithTitle:(NSString *)title
                  normalImageName:(NSString *)normalImageName
                selectedImageName:(NSString *)selectedImageName {
    
    viewController.tabBarItem.title = title;
    if (normalImageName) {
        UIImage *normalImage = [UIImage imageNamed:normalImageName];
        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        viewController.tabBarItem.image = normalImage;
    }
    if (selectedImageName) {
        UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        viewController.tabBarItem.selectedImage = selectedImage;
    }
    [self addChildViewController:viewController];
}
#pragma mark - delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController*)viewController {
    NSUInteger selectedIndex = tabBarController.selectedIndex;
    UIButton *plusButton = HWCExternPlusButton;
    if (HWCPlusChildViewController) {
        if ((selectedIndex == HWCPlusButtonIndex) && (viewController != HWCPlusChildViewController)) {
            plusButton.selected = NO;
        }
    }
    return YES;
}

@end
#pragma mark - NSObject+HWCTabBarControllerItem

@implementation NSObject (HWCTabBarControllerItemInternal)

- (void)hwc_setTabBarController:(HWCTabBarController *)tabBarController {
    objc_setAssociatedObject(self, @selector(hwc_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}
@end
@implementation NSObject (HWCTabBarController)

- (HWCTabBarController *)hwc_tabBarController {
    HWCTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(hwc_tabBarController));
    if (tabBarController) {
        return tabBarController;
    }
    if ([self isKindOfClass:[UIViewController class]] && [(UIViewController *)self parentViewController]) {
        tabBarController = [[(UIViewController *)self parentViewController] hwc_tabBarController];
        return tabBarController;
    }
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    if ([window.rootViewController isKindOfClass:[HWCTabBarController class]]) {
        tabBarController = (HWCTabBarController *)window.rootViewController;
    }
    return tabBarController;
}
@end