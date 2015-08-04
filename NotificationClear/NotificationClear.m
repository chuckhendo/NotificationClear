//
//  MySamplePlugin.m
//  DockTests
//
//  Re-written for learning and El Capitan by Wolfgang Baird on 8/3/15.
//
//  Confirmed compatible on builds 15A244d, x, and x
//
//  Copyright (c) 2015 Carl Henderson. All rights reserved.
//  Copyright (c) 2015 Wolfgang Baird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKSwizzle.h"
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface MyManager : NSObject {
    NSButton *someProperty;
}

@property (nonatomic, retain) NSButton *someProperty;

+ (id)sharedManager;

@end

static MyManager *sharedMyManager = nil;

@implementation MyManager

@synthesize someProperty;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedManager] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
- (id)init {
    if (self = [super init]) {
        someProperty = [[NSButton alloc] init];
        [ someProperty setHidden:true ];
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [someProperty release];
    [super dealloc];
}

@end

@interface _NotificationClear : NSObject
@end

@implementation _NotificationClear

+(void)load {
    ZKSwizzle(_WB_NCNotificationTableController, NCNotificationTableController);
    ZKSwizzle(_WB_NCTodayViewController, NCTodayViewController);
}

@end

@interface _WB_NCTodayViewController : NSViewController
@end

@implementation _WB_NCTodayViewController

- (void)notificationCenterTabWillBeShown
{
    ZKOrig(void);
    
    MyManager *sharedManager = [MyManager sharedManager];
    NSButton *clearAllBtn = sharedManager.someProperty;
    
    if(! clearAllBtn.hidden)
    {
        [clearAllBtn setHidden:YES];
    }
}
@end

@interface _WB_NCNotificationTableController : NSViewController
@end

@implementation _WB_NCNotificationTableController

- (IBAction)clearNotifications:(id)sender
{
    NSObject *data = [self valueForKey:@"_dataSource"];
    
    for (NSString *app in [data valueForKey:@"applicationOrder"])
    {
        NSObject *appInfo = objc_msgSend(data, @selector(applicationForIdentifier:), app);
        objc_msgSend(data, @selector(clearNotificationsForApplication:), appInfo);
    }
}

- (void) notificationCenterTabWillBeShown
{
    ZKOrig(void);
    
    NSScrollView *ttt = ZKHookIvar(self, NSScrollView *, "_tableScrollView");
    NSView *test = (NSView *)ttt.superview.superview.superview;
    
    MyManager *sharedManager = [MyManager sharedManager];
    NSButton *clearAllBtn = sharedManager.someProperty;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        for(NSView *subview in test.subviews)
        {
            if(subview.frame.size.height == 44.0)
            {
                int buttonWidth = 80;
                int buttonHeight = 32;
                
                int wrapperHeight = subview.frame.size.height;
                int buttonTop = (wrapperHeight / 2) - (buttonHeight / 2) - 1;
                
                int ncWidth = ((NSView *)[self valueForKey:@"_tableScrollView"]).frame.size.width;
                
                int buttonLeft = (ncWidth / 2) - (buttonWidth / 2);
                
                NSRect frame = NSMakeRect(buttonLeft, buttonTop, buttonWidth, buttonHeight);
                [clearAllBtn setFrame:frame];
                
                [clearAllBtn.cell setBezelStyle:NSRoundedBezelStyle];
                [clearAllBtn.cell setBackgroundColor:[NSColor redColor]];
                
                [clearAllBtn setTarget:self];
                [clearAllBtn setTitle:@"Clear"];
                [clearAllBtn setAction:@selector(clearNotifications:)];
                
                [subview addSubview:clearAllBtn];
                
                [clearAllBtn setHidden:NO];
            }
        }
    });
    
    if (clearAllBtn.hidden)
    {
        [clearAllBtn setHidden:NO];
    }
}

@end
