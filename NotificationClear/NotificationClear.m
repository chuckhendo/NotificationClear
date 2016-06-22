//
//  NotificationClear.m
//  NotificationClear
//
//  Re-written for learning and El Capitan by Wolfgang Baird on 8/3/15.
//  Now supports 10.9 to 10.12
//
//  Copyright (c) 2015 Carl Henderson. All rights reserved.
//  Copyright (c) 2015 - 2016 Wolfgang Baird. All rights reserved.
//

@import AppKit;
#import "ZKSwizzle.h"

NSButton *clearAllBtn = nil;
Class ncTableController;
SEL getApp;
SEL clearApp;

@interface NCNotificationCenter : NSObject
- (id)applicationFor:(id)arg1;
- (id)applicationForIdentifier:(id)arg1;
- (void)clearNotificationsForApplication:(id)arg1;
- (void)clearNotificationsFor:(id)arg1;
@end

@interface _WB_NotificationClear : NSObject
@end

@interface _WB_NCTodayViewController : NSViewController
@end

@interface _WB_NCNotificationTableController : NSViewController
- (IBAction)clearNotifications:(id)sender;
@end

@interface _WB_NCNotificationCenterWindowController : NSWindowController
@end

void _WB_NCNShow(NSViewController * nsv)
{
    NSScrollView *_scrollView = ZKHookIvar(nsv, NSScrollView *, "_tableScrollView");
    NSView *_superView = (NSView *)_scrollView.superview.superview.superview;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        int buttonWidth = 80;
        int buttonHeight = 32;
        int buttonTop = 5;
        int ncWidth = ((NSView *)[nsv valueForKey:@"_tableScrollView"]).frame.size.width;
        int buttonLeft = (ncWidth / 2) - (buttonWidth / 2);
        NSRect frame;
        if ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion > 9)
        {
            buttonHeight = 32;
            buttonLeft = (ncWidth / 2) - (buttonWidth / 2);
        } else {
            buttonHeight = 30;
            buttonLeft = (ncWidth / 2) + (buttonWidth / 4);
        }
        frame = NSMakeRect(buttonLeft, buttonTop, buttonWidth, buttonHeight);
        [clearAllBtn setFrame:frame];
        [clearAllBtn setTarget:nsv];
        [clearAllBtn setTitle:@"Clear"];
        [clearAllBtn setAction:@selector(clearNotifications:)];
        [clearAllBtn setBezelStyle:NSRoundedBezelStyle];        // NSRecessedBezelStyle
        [clearAllBtn setHidden:NO];
        [_superView addSubview:clearAllBtn];
    });
    
    if (clearAllBtn.hidden)
        [clearAllBtn setHidden:NO];
}

void _WB_NCTShow()
{
    if(! clearAllBtn.hidden)
        [clearAllBtn setHidden:YES];
}

@implementation _WB_NotificationClear

+(void)load
{
    clearAllBtn = [[NSButton alloc] init];
    NSUInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    if (osx_ver >= 12) {
        ncTableController = NSClassFromString(@"NotificationCenterApp.NotificationsTableController");
        getApp = @selector(applicationFor:);
        clearApp = @selector(clearNotificationsFor:);
        ZKSwizzle(_WB_NCNotificationCenterWindowController, NCNotificationCenterWindowController);
    } else {
        ZKSwizzle(_WB_NCNotificationTableController, NCNotificationTableController);
        ZKSwizzle(_WB_NCTodayViewController, NCTodayViewController);
    }
    NSLog(@"Notification Clear Loaded");
}

@end

@implementation _WB_NCTodayViewController

// 10.9 + 10.10 support
- (void)willBeShown
{
    ZKOrig(void);
    _WB_NCTShow();
}

// 10.11 support
- (void)notificationCenterTabWillBeShown
{
    ZKOrig(void);
    _WB_NCTShow();
}

@end

@implementation _WB_NCNotificationTableController

- (IBAction)clearNotifications:(id)sender
{
    NSObject *data = [self valueForKey:@"_dataSource"];
    for (NSString *app in [data valueForKey:@"applicationOrder"])
    {
        NSObject *appInfo = [data performSelector:@selector(applicationForIdentifier:) withObject:app];
        [data performSelector:@selector(clearNotificationsForApplication:) withObject:appInfo];
    }
}

// 10.9 + 10.10 support
- (void) tableWillBeShown
{
    ZKOrig(void);
    _WB_NCNShow(self);
}

// 10.11 support
- (void) notificationCenterTabWillBeShown
{
    ZKOrig(void);
    _WB_NCNShow(self);
}

@end

@implementation _WB_NCNotificationCenterWindowController

// 10.12 support

- (IBAction)clearNotifications:(id)sender
{
    NSViewController *viewController = ZKHookIvar(self, NSViewController*, "_visibleViewController");
    NSObject *data = ZKHookIvar(viewController, NSObject*, "dataSource");
    NSMutableDictionary *appDict = ZKHookIvar(data, NSMutableDictionary*, "_applicationForBundleIdentifier");
    for (NSObject *item in appDict)
    {
        NSObject *appInfo = [data performSelector:getApp withObject:item];
        [data performSelector:clearApp withObject:appInfo];
    }
}

- (void)wb_toggleHidden
{
    NSViewController *viewController = ZKHookIvar(self, NSViewController*, "_visibleViewController");
    if ([viewController class] == ncTableController)
    {
        [clearAllBtn setHidden:NO];
    }
    else
    {
        [clearAllBtn setHidden:YES];
    }
}

- (void)tabChanged:(id)arg1 {
    ZKOrig(void, arg1);
    [self wb_toggleHidden];
}

- (void)willBeShown {
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        NSLog(@"Setting up button");
        NSButton *sanPedro = ZKHookIvar(self, NSButton*, "_prefsButton");
        NSView *_superView = [sanPedro superview];
        NSButton *editButton = ZKHookIvar(self, NSButton*, "_editButton");
        [clearAllBtn setFrame:[editButton frame]];
        [clearAllBtn setTarget:self];
        [clearAllBtn setTitle:@"Clear"];
        [clearAllBtn setAction:@selector(clearNotifications:)];
        [clearAllBtn setBezelStyle:NSRoundedBezelStyle];        // NSRecessedBezelStyle
        [clearAllBtn setHidden:NO];
        [_superView addSubview:clearAllBtn];
    });
    [self wb_toggleHidden];
    ZKOrig(void);
}

@end
