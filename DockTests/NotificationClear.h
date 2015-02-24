//
//  MySamplePlugin.h
//  DockTests
//
//  Created by Carl Henderson on 2/23/15.
//  Copyright (c) 2015 Carl Henderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RSSwizzle.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface NotificationClear : NSObject

@property (retain) NSObject *selfptr;
@property (retain) NSButton *clearAllBtn;
@property (retain) NSView *wrapperView;

- (IBAction) test : (id) sender;
- (void) loadPlugin;
@end
