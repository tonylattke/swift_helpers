//
//  MatrixEngineWrapper.h
//  TestMatrix
//
//  Created by Tony Lattke on 04.02.17.
//  Copyright © 2017 HSB. All rights reserved.
//

#ifndef MatrixEngineWrapper_h
#define MatrixEngineWrapper_h

#import <Foundation/Foundation.h>

@interface MatrixEngineWrapper : NSObject



- (instancetype)init;
- (instancetype)init:(int)m :(int)n;
- (instancetype)init:(int)m :(int)n :(NSArray*)numbers;


- (MatrixEngineWrapper*)add: (MatrixEngineWrapper*)b;
- (void) print :(NSString*)name;

@end

#endif /* MatrixEngineWrapper_h */
