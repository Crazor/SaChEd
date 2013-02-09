//
//  AppDelegate.h
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChannelListController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ChannelListController *channelListController;

@end
