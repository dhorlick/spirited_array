//
//  spiritedarrayTests.h
//  spiritedarrayTests
//
//  Created by Dave Horlick on 10/19/12.
//  Copyleft 2012 River Porpoise Software
//

#import <XCTest/XCTest.h>
#import "SpiritedArray.h"
#import "SpiritedArrayIterator.h"

@interface spiritedarrayTests : XCTestCase
{
}

-(void) makeSureArrayLooksRight: (SpiritedArray*)spiritedArray Red:(SAColorType)red Green:(SAColorType)green Blue:(SAColorType) blue;

-(void) assertNextPixelColor:(NSString*)message SpiritedArrayIterator:(SpiritedArrayIterator*)sai Color:(SAColorType) color;

@end

