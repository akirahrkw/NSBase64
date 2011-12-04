//
//  NSBase64.m
//
//  Created by Hirakawa Akira on 11/07/26.
//  Copyright 2011 freelancer. All rights reserved.
//

#import "NSBase64.h"

static char base64Alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (NSBase64)


-(NSString*) encodeBase64
{
    unsigned char * bytes = (unsigned char *)[self bytes];   
    
    int bitSize = [self length] * 8;
    int lessThan24bits = bitSize % 24;
    int count = bitSize / 24;
    NSMutableString* str = [[[NSMutableString alloc] initWithString:@""] autorelease];
    
    char k = 0;
    char l = 0;
    char b1 = 0;
    char b2 = 0;
    char b3 = 0;
    
    int dataIndex = 0;
    int i=0;
    
    for(; i < count; i++)
    {
        dataIndex = i * 3;
        b1 = bytes[dataIndex];
        b2 = bytes[dataIndex + 1];
        b3 = bytes[dataIndex + 2];
        
        l = (char)(b2 & 15);
        k = (char)(b1 & 3);
        
        char val1 = (b1 & -128) != 0 ? (char) (b1 >> 2 ^ 192) : (char) (b1 >> 2);
        char val2 = (b2 & -128) != 0 ? (char) (b2 >> 4 ^ 240) : (char) (b2 >> 4);
        char val3 = (b3 & -128) != 0 ? (char) (b3 >> 6 ^ 252) : (char) (b3 >> 6);
        
        [str appendFormat:@"%c",base64Alphabet[val1]];
        [str appendFormat:@"%c",base64Alphabet[val2 | k << 4]];
        [str appendFormat:@"%c",base64Alphabet[l << 2 | val3]];
        [str appendFormat:@"%c",base64Alphabet[b3 & 63]];
        
    }
    
    dataIndex = i * 3;
    
    if(lessThan24bits == 8 )
    {
        b1 = bytes[dataIndex];
        k = (char) (b1 & 3);
        char val1 = (b1 & -128) != 0 ? (char)(b1 >> 2 ^ 192) : (char)(b1 >> 2);
        [str appendFormat:@"%c",base64Alphabet[val1]];
        [str appendFormat:@"%c",base64Alphabet[k << 4]];
        [str appendFormat:@"%c",61];
        [str appendFormat:@"%c",61];
    }
    else if(lessThan24bits == 16 )
    {
        b1 = bytes[dataIndex];
        b2 = bytes[dataIndex + 1];
        l = (char) (b2 & 15);
        k = (char) (b1 & 3);
        char val1 = (b1 & -128) != 0 ? (char)(b1 >> 2 ^ 192) : (char) (b1 >> 2);
        char val2 = (b2 & -128) != 0 ? (char)(b2 >> 4 ^ 240) : (char) (b2 >> 4);
        
        [str appendFormat:@"%c",base64Alphabet[val1]];
        [str appendFormat:@"%c",base64Alphabet[val2 | k << 4]];
        [str appendFormat:@"%c",base64Alphabet[l << 2]];
        [str appendFormat:@"%c",61];        
    }
    
    return str;
}

@end

@implementation NSString (NSBase64)

-(NSData*) decodeBase64
{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char * base64Data = (unsigned char *)[data bytes];   
    
    int count = [data length] / 4;
    
    int last = 0;
    for(last = [data length] ; base64Data[last - 1] == 61 ;){
        if(--last == 0){ return nil; }
    }
    
    char decodedData[last - count]; 
	bzero(decodedData, sizeof(decodedData));
    
    int encodedIndex = 0;
    int dataIndex = 0;
    char marker0 = 0;
    char marker1 = 0;
    char b1 = 0;
    char b2 = 0;
    char b3 = 0;
    char b4 = 0;
    
    for(int i=0; i < count; i++)
    {
        dataIndex = i * 4;
        marker0 = base64Data[dataIndex + 2];
        marker1 = base64Data[dataIndex + 3];
        b1 = base64Alphabet[base64Data[dataIndex]];
        b2 = base64Alphabet[base64Data[dataIndex + 1]];
     
        if(marker0 != 61 && marker1 != 61)
        {
            b3 = base64Alphabet[marker0];
            b4 = base64Alphabet[marker1];
            decodedData[encodedIndex] = (char)(b1 << 2 | b2 >> 4);
            decodedData[encodedIndex + 1] = (char)((b2 & 15) << 4 | (b3 >> 2 & 15));//b3 >> 2 & 15
            decodedData[encodedIndex + 2] = (char)(b3 << 6 | b4);
        }
        else if(marker0 == 61)
        {
            decodedData[encodedIndex] = (char)(b1 << 2 | b2 >> 4);
        }
        else if(marker1 == 61)
        {
            b3 = base64Alphabet[marker0];
            decodedData[encodedIndex] = (char)(b1 << 2 | b2 >> 4);
            decodedData[encodedIndex + 1] = (char)((b2 & 15) << 4 | (b3 >> 2 & 15));//b3 >> 2 & 15)
        }
        
        encodedIndex += 3;
        
    }
    
    return [NSData dataWithBytes:decodedData length:sizeof(decodedData)];
}


@end
