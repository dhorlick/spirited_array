//
//  SAColorTree.m
//  spiritedarray
//
//  Created by Dave Horlick on 5/7/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAColorTree.h"
#import "math.h"
#import "SAReductionContext.h"

@implementation SAColorTree

-(id) init
{
    if (self = [super init])
    {
        [self doSetup];
    }
    
    return self;
}

-(id) initWithSpiritedArray:(SpiritedArray *)designatedSpiritedArray Colors: (uint) colors
{
    if (self = [super init])
    {
        [self doSetup];
        [self classifySpiritedArray:designatedSpiritedArray];
    }
    
    return self;
}

-(void) doSetup
{
    minRed = 0U; maxRed = 255U;
    minGreen = 0U; maxGreen = 255U;
    minBlue = 0U; maxBlue = 255U;
    
    branches = [[NSMutableArray alloc] initWithCapacity:8U];

    for (uint i=0U; i<8; i++)
        [branches addObject:[NSNull null]];
    
    depth = 0U;
    n1 = 0U;
    n2 = 0U;
}

-(void) setDepth: (uint) designatedDepth
{
    depth = designatedDepth;
}

-(void) classifySpiritedArray: (SpiritedArray*) designatedSpiritedArray
{
    depth = 0U;
    
    // iterate over spirited array & classify pixel colors
    
    for (uint frame=0U; frame < [designatedSpiritedArray frames]; frame++)
    {
        for (uint y=0U; y < [designatedSpiritedArray height]; y++)
        {
            for (uint x = 0U; x < [designatedSpiritedArray width]; x++)
            {
                SAColorType color = [designatedSpiritedArray pixelColorAtFrame:frame X:x Y:y];
                [self classifyColor:color CurrentDepth:1U TargetDepth:5U];
            }
        }
    }
}

-(SAColorType) centerColor
{
    SAColorType result = {(maxRed-minRed)/2, (maxGreen-minGreen)/2, (maxBlue-minBlue)/2};
    return result;
}

-(void) classifyColor: (SAColorType) color CurrentDepth: (uint) designatedCurrentDepth TargetDepth: (uint) designatedTargetDepth
{
    depth = designatedCurrentDepth;
    
    n1++;
    SAColorType centerColor = [self centerColor];
    E += (pow(color.Red-centerColor.Red, 2.0) + pow(color.Green-centerColor.Green, 2.0) + pow(color.Blue-centerColor.Blue, 2.0));
    
    if (designatedCurrentDepth < designatedTargetDepth)
    {
        SAColorTree* subNode = [self associatedBranch: color];        
        [subNode classifyColor:color CurrentDepth:designatedCurrentDepth+1U TargetDepth:designatedTargetDepth];
    }
    else
    {
        n2++;
        
        Sr+=color.Red;
        Sg+=color.Green;
        Sb+=color.Blue;
    }
}

-(SAReductionContext*) reduceToColors: (uint) colors
{
    SAReductionContext* reductionContext = [SAReductionContext new];
    
    BOOL firstTime = YES;
    double Ep = 0.0;
    
    uint previousColorCount = 0U;
    uint currentColorCount = 0U;
    
    while ((currentColorCount=[self colors]) > colors)
    {
        if (!firstTime)
        {
            if (previousColorCount==currentColorCount)
            {
                @throw [NSException exceptionWithName:@"Bug" reason:[NSString stringWithFormat:@"Color count isn't declining: %u", currentColorCount] userInfo:nil]; // bug
            }
            
            Ep = [self minE];
        }
        
        [self reduceTo: Ep];
        
        firstTime = NO;
        previousColorCount = currentColorCount;
    }
    
    return reductionContext;
}

-(SAColorTree*) branchAtIndex:(uint) index
{
    id result = [branches objectAtIndex:0U];
    if ([[NSNull null] isEqual: result])
         return nil;
     else
         return result;
}

-(SAColorTree*) setBranch: (SAColorTree*)branch AtIndex:(uint) index
{
    SAColorTree* oldValue = [self branchAtIndex:index];
    
    if (branch!=nil)
        [branches replaceObjectAtIndex:index withObject:branch];
    else
        [branches replaceObjectAtIndex:index withObject:[NSNull null]];
    
    return oldValue;
}

-(SAColorTree*) lowRedLowGreenLowBlue
{
    return [self branchAtIndex:0U];
}

-(SAColorTree*) setLowRedLowGreenLowBlue: (SAColorTree*) branch;
{
    return [self setBranch: branch AtIndex: 0U];
}

-(SAColorTree*) highRedLowGreenLowBlue
{
    return [self branchAtIndex:1U];
}

-(SAColorTree*) setHighRedLowGreenLowBlue: (SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 1U];
}

-(SAColorTree*) lowRedHighGreenLowBlue
{
    return [self branchAtIndex: 2U];
}

-(SAColorTree*) setLowRedHighGreenLowBlue: (SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 2U];
}

-(SAColorTree*) highRedHighGreenHighBlue
{
    return [self branchAtIndex: 3U];
}

-(SAColorTree*) setHighRedHighGreenHighBlue:(SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 3U];
}

-(SAColorTree*) lowRedLowGreenHighBlue
{
    return [self branchAtIndex: 4U];
}

-(SAColorTree*) setLowRedLowGreenHighBlue: (SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 4U];
}

-(SAColorTree*) lowRedHighGreenHighBlue
{
    return [self branchAtIndex:5U];
}

-(SAColorTree*) setLowRedHighGreenHighBlue: (SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 5U];
}

-(SAColorTree*) highRedLowGreenHighBlue
{
    return [self branchAtIndex:6U];
}

-(SAColorTree*) setHighRedLowGreenHighBlue: (SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 6U];
}

-(SAColorTree*) highRedHighGreenLowBlue
{
    return [self branchAtIndex:7U];
}

-(SAColorTree*) setHighRedHighGreenLowBlue: (SAColorTree*) branch
{
    return [self setBranch: branch AtIndex: 7U];
}

-(void) reduceTo: (double) Ep
{
    if ([self lowRedLowGreenLowBlue] != nil)
    {
        if ([[self lowRedLowGreenLowBlue] leaf])
        {
            [self assimilate: [self lowRedLowGreenLowBlue]];
            [self setLowRedLowGreenLowBlue: nil];
        }
        else
            [[self lowRedLowGreenLowBlue] reduceTo:Ep];
    }
    
    if ([self highRedLowGreenLowBlue]!=nil)
    {
        if ([[self highRedLowGreenLowBlue] leaf])
        {
            [self assimilate:[self highRedLowGreenLowBlue]];
            [self setHighRedLowGreenLowBlue: nil];
        }
        else
            [[self highRedLowGreenLowBlue] reduceTo:Ep];
    }
    
    if ([self lowRedHighGreenLowBlue]!=nil)
    {
        if ([[self lowRedHighGreenLowBlue] leaf])
        {
            [self assimilate:[self lowRedHighGreenLowBlue]];
            [self setLowRedHighGreenLowBlue: nil];
        }
        else
            [[self lowRedHighGreenLowBlue] reduceTo:Ep];
    }
    
    if ([self highRedHighGreenHighBlue]!=nil)
    {
        if ([[self highRedHighGreenHighBlue] leaf])
        {
            [self assimilate:[self highRedHighGreenHighBlue]];
            [self setHighRedHighGreenHighBlue: nil];
        }
        else
            [[self highRedHighGreenHighBlue] reduceTo:Ep];
    }
    
    if ([self lowRedLowGreenHighBlue]!=nil)
    {
        if ([[self lowRedLowGreenHighBlue] leaf])
        {
            [self assimilate:[self lowRedLowGreenHighBlue]];
            [self setLowRedLowGreenHighBlue: nil];
        }
        else
            [[self lowRedLowGreenHighBlue] reduceTo:Ep];
    }
    
    if ([self lowRedHighGreenHighBlue]!=nil)
    {
        if ([[self lowRedHighGreenHighBlue] leaf])
        {
            [self assimilate:[self lowRedHighGreenHighBlue]];
            [self setLowRedHighGreenHighBlue: nil];
        }
        else
            [[self lowRedHighGreenHighBlue] reduceTo:Ep];
    }
    
    if ([self highRedLowGreenHighBlue]!=nil)
    {
        if ([[self highRedLowGreenHighBlue] leaf])
        {
            [self assimilate:[self highRedLowGreenHighBlue]];
            [self setHighRedLowGreenHighBlue: nil];
        }
        [[self highRedLowGreenHighBlue] reduceTo:Ep];
    }
    
    if ([self highRedHighGreenLowBlue]!=nil)
    {
        if ([[self highRedHighGreenLowBlue] leaf])
        {
            [self assimilate:[self highRedHighGreenLowBlue]];
            [self setHighRedHighGreenLowBlue: nil];
        }
        else
            [[self highRedHighGreenLowBlue] reduceTo:Ep];
    }
}

-(void) assimilate: (SAColorTree*) doomed
{
    // The values of n2, Sr, Sg, and Sb in a node being pruned are always added to the corresponding data in that node's parent.
    
    n2 += [doomed n2];
    Sr += [doomed Sr];
    Sg += [doomed Sg];
    Sb += [doomed Sb];
}

-(uint) colors
{
    uint colors = 1U;
    
    if ([self lowRedLowGreenLowBlue]!=nil)
        colors += [[self lowRedLowGreenLowBlue] colors];
    if ([self highRedLowGreenLowBlue]!=nil)
        colors += [[self highRedLowGreenLowBlue] colors];
    if ([self lowRedHighGreenLowBlue]!=nil)
        colors += [[self lowRedHighGreenLowBlue] colors];
    if ([self highRedHighGreenHighBlue]!=nil)
        colors += [[self highRedHighGreenHighBlue] colors];
    if ([self lowRedLowGreenHighBlue]!=nil)
        colors += [[self lowRedLowGreenHighBlue] colors];
    if ([self lowRedHighGreenHighBlue]!=nil)
        colors += [[self lowRedHighGreenHighBlue] colors];
    if ([self highRedLowGreenHighBlue]!=nil)
        colors += [[self highRedLowGreenHighBlue] colors];
    if ([self highRedHighGreenLowBlue]!=nil)
        colors += [[self highRedHighGreenLowBlue] colors];
    
    return colors;
}

-(BOOL) leaf
{
    return (n2 > 0); // is this right?
}

-(double) minE
{
    BOOL foundAny = NO;
    
    double min = 0.0;
    
    if ([self leaf])
    {
        min = E;
        foundAny = YES;
    }
    else
    {
        if ([self lowRedLowGreenLowBlue]!=nil)
        {
            min = [SAColorTree max:[[self lowRedLowGreenLowBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self highRedLowGreenLowBlue]!=nil)
        {
            min = [SAColorTree max:[[self highRedLowGreenLowBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self lowRedHighGreenLowBlue]!=nil)
        {
            min = [SAColorTree max:[[self lowRedHighGreenLowBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self highRedHighGreenHighBlue]!=nil)
        {
            min = [SAColorTree max:[[self highRedHighGreenHighBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self lowRedLowGreenHighBlue]!=nil)
        {
            min = [SAColorTree max:[[self lowRedLowGreenHighBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self lowRedHighGreenHighBlue]!=nil)
        {
            min = [SAColorTree max:[[self lowRedHighGreenHighBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self highRedLowGreenHighBlue]!=nil)
        {
            min = [SAColorTree max:[[self highRedLowGreenHighBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
        if ([self highRedHighGreenLowBlue]!=nil)
        {
            min = [SAColorTree max:[[self highRedHighGreenLowBlue] minE] B:min AlwaysTakeA:!foundAny];
            foundAny = YES;
        }
    }
    
    return min;
}

+(double) max: (double) a B: (double) b AlwaysTakeA: (BOOL) alwaysTakeA;
{
    if (alwaysTakeA)
        return a;
    else if (a>b)
        return a;
    else
        return b;
}

-(uint) n1
{
    return n1;
}

-(uint) n2
{
    return n2;
}

-(uint) Sr
{
    return Sr;
}

-(uint) Sg
{
    return Sg;
}

-(uint) Sb
{
    return Sb;
}

-(uint) E
{
    return E;
}

-(NSArray*) branches
{
    NSMutableArray* result = [NSMutableArray new];
    for (uint i=0U; i<[branches count]; i++)
    {
        SAColorTree* thing = [self branchAtIndex:i];
        if (thing!=nil)
            [result addObject: thing];
        // else
            // ???
    }

    return result;
}

-(SAColorTree*) associatedBranch: (SAColorType) color
{
    SAColorType centerColor = [self centerColor];
    
    // TODO create a branch if necessary
    
    if (color.Red < centerColor.Red)
    {
        if (color.Green < centerColor.Green)
        {
            if (color.Blue < centerColor.Blue)
                return [self lowRedLowGreenLowBlue];
            else
                return [self lowRedLowGreenHighBlue];
        }
        else
        {
            if (color.Blue < centerColor.Blue)
                return [self lowRedHighGreenLowBlue];
            else
                return [self lowRedHighGreenHighBlue];
        }
    }
    else
    {
        if (color.Green < centerColor.Green)
        {
            if (color.Blue < centerColor.Blue)
                return [self highRedLowGreenLowBlue];
            else
                return [self highRedLowGreenHighBlue];
        }
        else
        {
            if (color.Blue < centerColor.Blue)
                return [self highRedHighGreenLowBlue];
            else
                return [self highRedHighGreenHighBlue];
        }
    }
    
    return nil;
}

-(SAColorType) assignColor: (SAColorType) originalColor
{
    SAColorTree* associated = [self associatedBranch: originalColor];
    
    if (associated != nil)
    {
        return [associated assignColor:originalColor];
    }
    else
    {
        return [self centerColor];
    }
}

-(SpiritedArray*) reassignSpiritedArray:(SpiritedArray*) designatedSpiritedArray
{
    return designatedSpiritedArray;
    
    MemorizedSpiritedArray* result = [[MemorizedSpiritedArray alloc] initWith: [designatedSpiritedArray frames] Width: [designatedSpiritedArray width] Height: [designatedSpiritedArray height]];
    
    for (uint frame=0U; frame<[designatedSpiritedArray frames]; frame++)
    {
        for (uint y=0U; y<[designatedSpiritedArray height]; y++)
        {
            for (uint x=0U; x<[designatedSpiritedArray width]; x++)
            {
                [result writePixelColorAtFrame:frame X:x Y:y Color:[self assignColor:[designatedSpiritedArray pixelColorAtFrame:frame X:x Y:y]]];
            }
        }
    }
    
    return result;
}

@end
