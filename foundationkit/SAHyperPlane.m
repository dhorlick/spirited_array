//
//  SAHyperCube.m
//  spiritedarray
//
//  Created by Dave Horlick on 11/5/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SAHyperPlane.h"

@implementation SAHyperPlane

- (uint) frames
{
	return frames;
}

- (uint) width
{
	return width;
}

- (uint) height
{
	return height;
}

-(uint) pixels
{
    return frames * width * height;
}

@end
