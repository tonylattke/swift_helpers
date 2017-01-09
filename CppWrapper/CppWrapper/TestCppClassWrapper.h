//
//  TestCppClassWrapper.h
//  CppWrapper
//
//  Created by Student on 08.01.17.
//  Copyright © 2017 Tony Lattke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCppClassWrapper : NSObject
- (instancetype)initWithTitle:(NSString*)title;
- (NSString*)getTitle;
- (void)setTitle:(NSString*)title;
@end
