//
//  SAHyperPlane.h
//  spiritedarray
//
//  Created by Dave Horlick on 11/5/12.
//  Copyleft 2012 River Porpoise Software
//

@interface SAHyperPlane : NSObject
{
	uint width;
	uint height;
	uint frames;
}

- (uint) frames;
- (uint) width;
- (uint) height;
- (uint) pixels;

@end
