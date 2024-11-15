//
//  SAView.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/19/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SAMacView.h"
#import "SALayer.h"

@implementation SAMacView

/* -(void)drawRect:(NSRect)dirtyRect
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    [viewHelper drawRect: dirtyRect Context: context Frame: frame];
    
    frame++;
    
    if (frame>=[viewHelper frames])
        frame = 0;
} */

-(void) setFrameSize: (NSSize)newSize
{
    [super setFrameSize:newSize];
    // NSLog(@"intercepted setFrameSize. new width = %f, new height = %f", newSize.width, newSize.height);
    self.layer.bounds = [self bounds];
	int result = CGRectGetMidX([self bounds]);
    if (@available(macOS 11, *))
    {
        self.layer.position = NSMakePoint(0, 0);
    }
    else
    {
        self.layer.position = NSMakePoint(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
    }
    SALayer* saLayer = (SALayer*) self.layer;
    
    // TODO bounds has changed by more than one tile footprint…
    [[saLayer viewHelper] clearCachedSpiritedArray];
    [[saLayer viewHelper] regenerateStatusText];
}

@end
