//
//  Channel.m
//  SaChEd
//
//  Created by Crazor on 17.11.12.
//  Copyright (c) 2012 Crazor. All rights reserved.
//

#import "Channel.h"

@implementation Channel

NSDictionary *formats;

+(void)initialize
{
    formats = @{
        @"old": @{
            @"name": @45,
            @"service": @9,
            @"favorite": @6
        },
        @"new": @{
            @"name": @65,
            @"service": @15,
            @"favorite": @292
        }
    };
}

- (id)initWithData:(NSData *)data format:(NSString *)format
{
    if (self = [super init])
    {
        _format = format;
        _offsets = formats[format];
        _rawData = [data mutableCopy];
    }

    return self;
}

- (NSString *)name
{
    unsigned const char *bytes = _rawData.bytes;
    return [[NSString alloc] initWithBytes:&bytes[[_offsets[@"name"] intValue]] length:100 encoding:NSUTF16LittleEndianStringEncoding];
}

- (void)setName:(NSString *)name
{
    [name getBytes:&(_rawData.mutableBytes[[_offsets[@"name"] intValue]]) maxLength:100 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, [name length]) remainingRange:NULL];

    // Fill the remaining bytes with 0x00
    for (NSUInteger i = [name length] * 2; i < 100; i++)
    {                              // ^ UTF-16!
        char *bytes = _rawData.mutableBytes;
        bytes[[_offsets[@"name"] intValue] + i] = 0;
    }
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
}

- (BOOL)favorite1
{
    unsigned const char *bytes = _rawData.bytes;
    return (bytes[[_offsets[@"favorite"] intValue]] & 1) == 1;
}

- (BOOL)favorite2
{
    unsigned const char *bytes = _rawData.bytes;
    return (bytes[[_offsets[@"favorite"] intValue]] & 2) == 2;
}

- (BOOL)favorite3
{
    unsigned const char *bytes = _rawData.bytes;
    return (bytes[[_offsets[@"favorite"] intValue]] & 4) == 4;
}

- (BOOL)favorite4
{
    unsigned const char *bytes = _rawData.bytes;
    return (bytes[[_offsets[@"favorite"] intValue]] & 8) == 8;
}

- (void)setFavorite1:(BOOL)favorite
{
    unsigned char *bytes = _rawData.mutableBytes;

    if (favorite)
    {
        bytes[[_offsets[@"favorite"] intValue]] |= 1;
    }
    else
    {
        bytes[[_offsets[@"favorite"] intValue]] &= ~1;
    }
}

- (void)setFavorite2:(BOOL)favorite
{
    if ([_format isEqualToString:@"new"])
    {
        unsigned char *bytes = _rawData.mutableBytes;
        
        if (favorite)
        {
            bytes[[_offsets[@"favorite"] intValue]] |= 2;
        }
        else
        {
            bytes[[_offsets[@"favorite"] intValue]] &= ~2;
        }
    }
}

- (void)setFavorite3:(BOOL)favorite
{
    if ([_format isEqualToString:@"new"])
    {
        unsigned char *bytes = _rawData.mutableBytes;
        
        if (favorite)
        {
            bytes[[_offsets[@"favorite"] intValue]] |= 4;
        }
        else
        {
            bytes[[_offsets[@"favorite"] intValue]] &= ~4;
        }
    }
}

- (void)setFavorite4:(BOOL)favorite
{
    if ([_format isEqualToString:@"new"])
    {
        unsigned char *bytes = _rawData.mutableBytes;
        
        if (favorite)
        {
            bytes[[_offsets[@"favorite"] intValue]] |= 8;
        }
        else
        {
            bytes[[_offsets[@"favorite"] intValue]] &= ~8;
        }
    }
}

- (NSString *)servicetype
{
    unsigned const char *bytes = _rawData.bytes;
    switch (bytes[[_offsets[@"service"] intValue]])
    {
        case 1:
            return @"SD";
        case 2:
            return @"Radio";
        case 25:
            return @"HD";
        default:
            return [NSString stringWithFormat:@"%d", bytes[[_offsets[@"service"] intValue]]];
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
