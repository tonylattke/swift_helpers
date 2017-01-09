//
//  TestCppClassWrapper.m
//  CppWrapper
//
//  Created by Student on 08.01.17.
//  Copyright © 2017 Tony Lattke. All rights reserved.
//

#import "TestCppClassWrapper.h"
#include "TestCppClass.hpp"
#include "Assert.hpp"
@interface TestCppClassWrapper()
@property TestCppClass *cppItem;
@end
@implementation TestCppClassWrapper
- (instancetype)initWithTitle:(NSString*)title
{
    if (self = [super init]) {
        self.cppItem = new TestCppClass(std::string([title cStringUsingEncoding:NSUTF8StringEncoding]));
    }
    return self;
}
- (NSString*)getTitle
{
    return [NSString stringWithUTF8String:self.cppItem->getTtile().c_str()];
}
- (void)setTitle:(NSString*)title
{
    self.cppItem->setTitle(std::string([title cStringUsingEncoding:NSUTF8StringEncoding]));
}
@end
