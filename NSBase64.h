//
//  NSBase64.h
//
//  Created by Hirakawa Akira on 11/07/26.
//  Copyright 2011 freelancer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (NSBase64)

- (NSString*) encodeBase64;

@end

@interface NSString (NSBase64) 

- (NSData*)   decodeBase64;
    
@end