//
//  ChannelViewController.m
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import "ChannelListController.h"
#import "Channel.h"
#import <Objective-Zip/Objective-Zip.h>

@implementation ChannelListController

NSString *MovedRowsType = @"MOVED_ROWS_TYPE";

- (id)init
{
    if (self = [super init])
    {
        channels = [NSMutableArray array];
    }

    return self;
}

- (void)awakeFromNib
{
	[channelsTableView registerForDraggedTypes:[NSArray arrayWithObject:MovedRowsType]];

	[super awakeFromNib];
}

- (void)updateFavoriteCheckbox
{
    if (_favoriteCount == channels.count)
    {
        _allFavoriteCheckbox.state = NSOnState;
    }
    else if (_favoriteCount == 0)
    {
        _allFavoriteCheckbox.state = NSOffState;
    }
    else
    {
        _allFavoriteCheckbox.state = NSMixedState;
    }
}

#pragma mark IBActions

- (IBAction)openFile:(id)sender {
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];

    openDlg.canChooseFiles = YES;

    if ([openDlg runModal] == NSOKButton)
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];

        for (NSURL *fileName in files)
        {
            if ([[fileName lastPathComponent] isEqualToString:@"map-CableD"])
            {
                [self readMapCableD:fileName];
            }
            else if ([[fileName pathExtension] isEqualToString:@"scm"])
            {
                [self readSCM:fileName];
            }
            else
            {
                [self openFile:self];
            }
        }
    }
}

- (IBAction)saveFile:(id)sender
{
    NSSavePanel *saveDlg = [NSSavePanel savePanel];

    if ( [saveDlg runModal] == NSOKButton)
    {
        NSURL *fileName = [saveDlg URL];

        [self writeMapCableD:fileName];
        [window setDocumentEdited:NO];
    }
}

/*
- (IBAction)checkAll:(id)sender
{
    if ([sender intValue] == NSOffState)
    {
        for (Channel *c in channels)
        {
            c.favorite = NO;
        }
        _favoriteCount = 0;
    }
    else if ([sender intValue] == NSOnState || [sender intValue] == NSMixedState)
    {
        for (Channel *c in channels)
        {
            c.favorite = YES;
        }
        _favoriteCount = (int)channels.count;
        [sender setIntValue:NSOnState];
    }
    
    [channelsTableView reloadData];
    [window setDocumentEdited:YES];
}
*/

- (IBAction)renumber:(id)sender
{
    int i = 1;
    for (Channel *c in channels)
    {
        if (![c.servicetype isEqualToString:@"Radio"])
        {
            c.number = i++;
        }
    }
    i = 1000;
    for (Channel *c in channels)
    {
        if ([c.servicetype isEqualToString:@"Radio"])
        {
            c.number = i++;
        }
    }
    [channelsTableView reloadData];
    [window setDocumentEdited:YES];
}

#pragma mark - SCM handling
- (void)readSCM:(NSURL *)file
{
    ZipFile *scmZip = [ZipFile zipFileWithURL:file mode:ZipFileModeUnzip error:nil];
    if ([scmZip locateFileInZip:@"map-CableD" error:nil])
    {
        ZipReadStream *mapCableDStream = [scmZip readCurrentFileInZip:nil];
        NSData *mapCableDData = [mapCableDStream readDataOfLength:[scmZip getCurrentFileInZipInfo:nil].length error:nil];
        [self readMapCableDData:mapCableDData];
    }
    else
    {
        [self openFile:self];
    }
}

#pragma mark mapCableD r/w

- (void)readMapCableD:(NSURL *)file
{
    NSData *mapData = [NSData dataWithContentsOfURL:file];
    [self readMapCableDData:mapData];
}
    
- (void)readMapCableDData:(NSData *)mapData
{
    const unsigned char *bytes = [mapData bytes];

    NSString *format;
    int skip;
    if (mapData.length == 1000*248)
    {
        format = @"old";
        skip = 248;
    }
    else if (mapData.length == 1000*320)
    {
        format = @"new";
        skip = 320;
    }
    
    for (int i = 0; i < [mapData length]; i+=skip)
    {
        if (bytes[i] == 0 && bytes[i+1] == 0)
        {
            continue;
        }
        
        Channel *c = [[Channel alloc] initWithData:[NSData dataWithBytes:&bytes[i] length:skip] format:format];
        [channels addObject:c];
        
        if (c.favorite1)
        {
            _favoriteCount++;
        }
    }
    
    [channelsTableView reloadData];
    //[channelsTableView setSortDescriptors:[NSArray arrayWithObjects:
    //                                  [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES selector:@selector(compare:)],
    //                                  nil]];
    
    [self updateFavoriteCheckbox];
    //[channelsTableView sizeToFit];
}


- (void)writeMapCableD:(NSURL *)file
{
    unsigned char *zeroes[248000];

    NSMutableData *mapData = [NSMutableData data];

    for (Channel *c in channels)
    {
        [mapData appendData:[c rawData]];
    }

    [mapData appendBytes:zeroes length:248000 - mapData.length];

    [mapData writeToURL:file atomically:NO];
}

#pragma mark - tableView datasource/delegate methods

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [channels sortUsingDescriptors: [tableView sortDescriptors]];
    [tableView reloadData];
    [window setDocumentEdited:YES];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [channels count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Channel *channel = channels[row];
    if ([[tableColumn identifier] isEqualToString:@"favorite1"])
    {
        if (channel.favorite1)
        {
            //return [NSImage imageNamed:@"green-heart-icon-hi.png"];
            return [NSNumber numberWithInt:NSOnState];
        }
        else
        {
            return [NSNumber numberWithInt:NSOffState];
            //return [[NSImage alloc] init];
        }
    }
    else if ([[tableColumn identifier] isEqualToString:@"favorite2"])
    {
        if (channel.favorite2)
        {
            //return [NSImage imageNamed:@"green-heart-icon-hi.png"];
            return [NSNumber numberWithInt:NSOnState];
        }
        else
        {
            return [NSNumber numberWithInt:NSOffState];
            //return [[NSImage alloc] init];
        }
    }
    else if ([[tableColumn identifier] isEqualToString:@"favorite3"])
    {
        if (channel.favorite3)
        {
            //return [NSImage imageNamed:@"green-heart-icon-hi.png"];
            return [NSNumber numberWithInt:NSOnState];
        }
        else
        {
            return [NSNumber numberWithInt:NSOffState];
            //return [[NSImage alloc] init];
        }
    }
    else if ([[tableColumn identifier] isEqualToString:@"favorite4"])
    {
        if (channel.favorite4)
        {
            //return [NSImage imageNamed:@"green-heart-icon-hi.png"];
            return [NSNumber numberWithInt:NSOnState];
        }
        else
        {
            return [NSNumber numberWithInt:NSOffState];
            //return [[NSImage alloc] init];
        }
    }
    else if ([[tableColumn identifier] isEqualToString:@"parentallock"])
    {
        if (channel.parentallock & 1)
        {
            return [NSImage imageNamed:@"locked.png"];
        }
        else
        {
            //return [NSImage imageNamed:@"unlocked.png"];
            return [[NSImage alloc] init];
        }
    }
    else if ([[tableColumn identifier] isEqualToString:@"encryption"])
    {
        if (channel.encryption & 0x20)
        {
            return [NSImage imageNamed:@"locked.png"];
        }
        else
        {
            //return [NSImage imageNamed:@"unlocked.png"];
            return [[NSImage alloc] init];
        }
    }
    return [channel valueForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    Channel *channel = channels[rowIndex];

    if ([[aTableColumn identifier] isEqualToString:@"name"])
    {
        channel.name = anObject;
    }
    else if ([[aTableColumn identifier] isEqualToString:@"number"])
    {
        channel.number = [anObject intValue];
        [channels removeObject:channel];
        [channels insertObject:channel atIndex:[channel number]-1];
        [self renumber:self];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"favorite1"])
    {
        channel.favorite1 = [anObject boolValue];
        if ([anObject boolValue])
        {
            _favoriteCount++;
        }
        else
        {
            _favoriteCount--;
        }
        [self updateFavoriteCheckbox];
        [window setDocumentEdited:YES];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"favorite2"])
    {
        channel.favorite2 = [anObject boolValue];
        if ([anObject boolValue])
        {
            _favoriteCount++;
        }
        else
        {
            _favoriteCount--;
        }
        [self updateFavoriteCheckbox];
        [window setDocumentEdited:YES];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"favorite3"])
    {
        channel.favorite3 = [anObject boolValue];
        if ([anObject boolValue])
        {
            _favoriteCount++;
        }
        else
        {
            _favoriteCount--;
        }
        [self updateFavoriteCheckbox];
        [window setDocumentEdited:YES];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"favorite4"])
    {
        channel.favorite4 = [anObject boolValue];
        if ([anObject boolValue])
        {
            _favoriteCount++;
        }
        else
        {
            _favoriteCount--;
        }
        [self updateFavoriteCheckbox];
        [window setDocumentEdited:YES];
    }
}

#pragma mark TableView Drag'n'drop

-(BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	//[pboard declareTypes:[NSArray arrayWithObject:MovedRowsType] owner:nil];
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard setData:theData forType:MovedRowsType];

	return YES;
}

-(NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSDragOperation theDragOperation = NSDragOperationMove;

	[tv setDropRow:row dropOperation:theDragOperation];

	return theDragOperation;
}

-(BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)to dropOperation:(NSTableViewDropOperation)operation {
	NSIndexSet* rowIndexeSet = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:MovedRowsType]];

	NSMutableIndexSet *theRowIndexSetTmp = [[NSMutableIndexSet alloc] initWithIndexSet:rowIndexeSet];

	NSInteger theIndexNo = 0;

	while ([theRowIndexSetTmp count] > 0) {
		theIndexNo = [theRowIndexSetTmp firstIndex];
		[theRowIndexSetTmp removeIndex:theIndexNo];

		Channel *theRow;

        theRow = [channels objectAtIndex:theIndexNo];
        [channels insertObject:theRow atIndex:to];
        
		if(theIndexNo > to) {
            // Move row upwards
            [channels removeObjectAtIndex:theIndexNo+1];
		}
        else
        {
            // Move row downwards
            [channels removeObjectAtIndex:theIndexNo];
		}
	}

    [self renumber:self];

    //[channelsTableView reloadData];

	return YES;
}

@end
