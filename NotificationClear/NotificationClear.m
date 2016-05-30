//
//  MySamplePlugin.m
//  DockTests
//
//  Re-written for learning and El Capitan by Wolfgang Baird on 8/3/15.
//  Now supports 10.9 to 10.11
//
//  Copyright (c) 2015 Carl Henderson. All rights reserved.
//  Copyright (c) 2015 - 2016 Wolfgang Baird. All rights reserved.
//

@import AppKit;
#import "ZKSwizzle.h"
NSButton *clearAllBtn = nil;

@interface NCNotificationCenter : NSObject
- (id)applicationForIdentifier:(id)arg1;
- (void)clearNotificationsForApplication:(id)arg1;
@end

@interface _NotificationClear : NSObject
@end

@interface _WB_NCNotificationTableController : NSViewController
- (IBAction)clearNotifications:(id)sender;
@end

@interface _WB_NCTodayViewController : NSViewController
@end

void _WB_NCNShow(NSViewController * nsv) {
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

void _WB_NCTShow() {
    if(! clearAllBtn.hidden)
        [clearAllBtn setHidden:YES];
}

@implementation _NotificationClear

+(void)load {
    clearAllBtn = [[NSButton alloc] init];
    ZKSwizzle(_WB_NCNotificationTableController, NCNotificationTableController);
    ZKSwizzle(_WB_NCTodayViewController, NCTodayViewController);
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
- (void) tableWillBeShown {
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
