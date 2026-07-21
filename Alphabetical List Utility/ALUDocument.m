//
//  ALUDocument.m
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 8/4/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUDocument.h"

@implementation ALUDocument

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError {
    if ([contents length] > 0) {
        self.noteContent = [[NSString alloc] initWithBytes:[contents bytes]
                                                    length:[contents length]
                                                  encoding:NSUTF8StringEncoding];
    } else {
        self.noteContent = @" ";
    }
    
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    if ([self.noteContent length] == 0) {
        self.noteContent = @" ";
    }
    
    // -length is a UTF-16 unit count, not a UTF-8 byte count. Using it as the byte length
    // silently truncated any note containing emoji, accents or curly quotes.
    return [self.noteContent dataUsingEncoding:NSUTF8StringEncoding];
}



@end
