//
//  AIMutableStringAdditions.h
//  Adium
//
//  Created by Nelson Elhage on Sun Mar 14 2004.
//  Copyright (c) 2004-2005 The Adium Team. All rights reserved.
//

@interface NSMutableString (AIMutableStringAdditions)
+ (NSMutableString *)stringWithContentsOfASCIIFile:(NSString *)path;

//This is so that code that may be dealing with a mutable string
//or mutable attributed string can call [str mutableString] and get 
//a mutable string out of it, that it can work with that without
//worrying about what kind of string it's dealing with
- (NSMutableString*)mutableString;

- (void)convertNewlinesToSlashes;
@end
