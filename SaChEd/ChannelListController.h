//
//  ChannelViewController.h
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelListController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *channelsTableView;
    __weak NSButton *_allFavoriteCheckbox;
    NSMutableArray *channels;
    IBOutlet NSWindow *window;
}

@property NSString *format;
@property int favoriteCount;

- (IBAction)openFile:(id)sender;
- (IBAction)renumber:(id)sender;

@property (weak) IBOutlet NSButton *allFavoriteCheckbox;
@end
