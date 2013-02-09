//
//  AppDelegate.m
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_channelListController openFile:self];
}

- (BOOL)windowShouldClose:(id)sender
{
    if ([_window isDocumentEdited])
    {
        return NO;
    }

    return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp terminate:self];
}

@end
