//
//  Channel.m
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import "Channel.h"

@implementation Channel

- (id)initWithData:(NSData *)data
{
    if (self = [super init])
    {
        _rawData = [data mutableCopy];
    }

    return self;
}

- (NSString *)name
{
    unsigned const char *bytes = _rawData.bytes;
    return [[NSString alloc] initWithBytes:&bytes[45] length:100 encoding:NSUTF16LittleEndianStringEncoding];
}

- (void)setName:(NSString *)name
{
    [name getBytes:&(_rawData.mutableBytes[45]) maxLength:100 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, [name length]) remainingRange:NULL];

    // Fill the remaining bytes with 0x00
    for (NSUInteger i = [name length] * 2; i < 100; i++)
    {                              // ^ UTF-16!
        char *bytes = _rawData.mutableBytes;
        bytes[45 + i] = 0;
    }

    [self updateChecksum];
}

- (int)number
{
    unsigned const char *bytes = _rawData.bytes;
    return bytes[0]   + (bytes[1]<<8);
}

- (void)setNumber:(int)number
{
    unsigned char *bytes = _rawData.mutableBytes;

    bytes[0] = number        & 0xFF;
    bytes[1] = (number >> 8) & 0xFF;

    [self updateChecksum];
}

- (BOOL)favorite
{
    unsigned const char *bytes = _rawData.bytes;
    return (bytes[6] & 1) == 1;
}

- (void)setFavorite:(BOOL)favorite
{
    unsigned char *bytes = _rawData.mutableBytes;

    if (favorite)
    {
        bytes[6] |= 1;
    }
    else
    {
        bytes[6] &= ~1;
    }

    [self updateChecksum];
}

- (NSString *)servicetype
{
    unsigned const char *bytes = _rawData.bytes;
    switch (bytes[9])
    {
        case 1:
            return @"SD";
        case 2:
            return @"Radio";
        case 25:
            return @"HD";
        default:
            return [NSString stringWithFormat:@"%d", bytes[9]];
    }
}

- (int)encryption
{
    unsigned const char *bytes = _rawData.bytes;
    return bytes[23];
}

- (int)parentallock
{
    unsigned const char *bytes = _rawData.bytes;
    return bytes[244] + (bytes[245]<<8);
}

- (int)checksum
{
    unsigned const char *bytes = _rawData.bytes;
    return bytes[_rawData.length-1];
}

- (void)updateChecksum
{
    uint8_t sum = 0;
    unsigned char *bytes = _rawData.mutableBytes;
    
    for (int i = 0; i < _rawData.length - 1; i++)
    {
        sum += bytes[i];
    }

    bytes[_rawData.length-1] = sum;
}

@end
