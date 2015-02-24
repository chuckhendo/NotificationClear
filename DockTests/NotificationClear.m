//
//  MySamplePlugin.m
//  DockTests
//
//  Created by Carl Henderson on 2/23/15.
//  Copyright (c) 2015 Carl Henderson. All rights reserved.
//

#import "NotificationClear.h"

@implementation NotificationClear

@synthesize selfptr;

/**
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void) load
{
    [[NotificationClear sharedInstance] loadPlugin];
    // ... do whatever
    NSLog(@"NotificationClear installed");
}

/**
 * @return the single static instance of the plugin object
 */
+ (NotificationClear*) sharedInstance
{
    static NotificationClear* plugin = nil;
    
    if (plugin == nil)
        plugin = [[NotificationClear alloc] init];
    
    
    
    return plugin;
}

- (IBAction)clearNotifications:(id)sender {

    NSObject *data = [self.selfptr valueForKey:@"_dataSource"];

    for (NSString *app in [data valueForKey:@"applicationOrder"]) {
        NSObject *appInfo = objc_msgSend(data, @selector(applicationForIdentifier:), app);
        objc_msgSend(data, @selector(clearNotificationsForApplication:), appInfo);
    }
}



- (void) loadPlugin {
    
    
    NotificationClear *me = self;
    RSSwizzleInstanceMethod(NSClassFromString(@"NCNotificationTableController"),
                            @selector(tableWillBeShown),
                            RSSWReturnType(void),
                            RSSWArguments(),
                            RSSWReplacement(
    {
        me.selfptr = self;

        me.wrapperView = ((NSView *)[[[[self valueForKey:@"_tableScrollView"] valueForKey:@"superview"] valueForKey:@"superview"] valueForKey:@"superview"]);
        if(me.clearAllBtn == nil ) {
            
            for(NSView *subview in me.wrapperView.subviews) {
                if(subview.frame.size.height == 44.0) {
                    int buttonWidth = 80;
                    int buttonHeight = 32;
                    
                    int wrapperHeight = subview.frame.size.height;
                    int buttonTop = (wrapperHeight / 2) - (buttonHeight / 2) - 1;

                    int ncWidth = ((NSView *)[self valueForKey:@"_tableScrollView"]).frame.size.width;
                    
                    int buttonLeft = (ncWidth / 2) - (buttonWidth / 2);
                    
                    NSRect frame = NSMakeRect(buttonLeft, buttonTop, buttonWidth, buttonHeight);
                    me.clearAllBtn = [[NSButton alloc] initWithFrame:frame];

                    [me.clearAllBtn.cell setBezelStyle:NSRoundedBezelStyle];
                    [me.clearAllBtn.cell setBackgroundColor:[NSColor redColor]];
                    
                    [me.clearAllBtn setTarget:me];
                    [me.clearAllBtn setTitle:@"Clear"];
                    [me.clearAllBtn setAction:@selector(clearNotifications:)];
                    

                    [subview addSubview:me.clearAllBtn];
                }
            }
            
        } else {
            [me.clearAllBtn setHidden:NO];
        }
        

        RSSWCallOriginal();
    }), 0, NULL);
    
    RSSwizzleInstanceMethod(NSClassFromString(@"NCTodayViewController"),
                            @selector(willBeShown),
                            RSSWReturnType(void),
                            RSSWArguments(),
                            RSSWReplacement(
    {
        
        if(me.clearAllBtn != nil ) {
            [me.clearAllBtn setHidden:YES];
        }
        
        RSSWCallOriginal();
    }), 0, NULL);
    
    
}

@end
