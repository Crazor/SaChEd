//
//  Channel.h
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property NSMutableData *rawData;
@property NSString *name;
@property int number;
@property BOOL favorite;
@property (readonly) NSString *servicetype;
@property (readonly) int encryption;
@property (readonly) int parentallock;
@property (readonly) int checksum;

- (id)initWithData:(NSData *)data;
- (void)updateChecksum;

@end
