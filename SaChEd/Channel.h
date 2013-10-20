//
//  Channel.h
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property NSDictionary *offsets;
@property NSString *format;
@property NSMutableData *rawData;
@property NSString *name;
@property int number;
@property BOOL favorite1;
@property BOOL favorite2;
@property BOOL favorite3;
@property BOOL favorite4;
@property (readonly) NSString *servicetype;
@property (readonly) int encryption;
@property (readonly) int parentallock;
@property (readonly) int checksum;

- (id)initWithData:(NSData *)data format:(NSString *)format;
- (void)updateChecksum;

@end
