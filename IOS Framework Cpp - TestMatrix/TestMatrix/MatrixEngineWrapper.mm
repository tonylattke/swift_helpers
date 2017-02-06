//
//  MatrixEngineWrapper.m
//  TestMatrix
//
//  Created by Tony Lattke on 04.02.17.
//  Copyright © 2017 HSB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MatrixEngine/Mat.hpp>
#import "MatrixEngineWrapper.h"


@interface MatrixEngineWrapper()
@property Mat *cppItem;
@end

@implementation MatrixEngineWrapper

- (instancetype) init
{
    if (self = [super init]) {
        self.cppItem = new Mat();
    }
    return self;
}

- (instancetype) init:(int)m :(int)n
{
    if (self = [super init]) {
        self.cppItem = new Mat(m,n);
    }
    return self;
}

- (instancetype) init:(int)m :(int)n :(NSArray*)numbers
{
    if (self = [super init]) {
        float cValues[m*n];
        for(int i = 0; i < numbers.count; i++){
            float temp = [[numbers objectAtIndex:i] floatValue];
            cValues[i] = temp;
        }
        self.cppItem = new Mat(m,n,cValues);
    }
    return self;
}

- (MatrixEngineWrapper*) add: (MatrixEngineWrapper*)b
{
    MatrixEngineWrapper *result = [[MatrixEngineWrapper alloc] init:self->_cppItem->m :self->_cppItem->n];
    *(result->_cppItem) = *(self->_cppItem) + *(b->_cppItem);
    return result;
}

- (void) print :(NSString*) name
{
    self.cppItem->Print([name UTF8String]);
}

@end
