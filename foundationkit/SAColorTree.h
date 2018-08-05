//
//  SAColorTree.h
//  spiritedarray
//
//  Created by Dave Horlick on 5/7/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SpiritedArray.h"
#import "SAReductionContext.h"
#import "MemorizedSpiritedArray.h"

@interface SAColorTree : NSObject
{
    NSMutableArray* branches;
    uint depth;
    uint minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue;
    
    /**
     number of pixels whose color is contained in the RGB cube which this node represents
     */
    uint n1;
    
    /**
     number of pixels whose color is not represented in a node at lower depth in the tree; initially, n2=0 for all nodes except leaves of the tree.
     */
    uint n2;
    
    /**
     sums of the red component values for all pixels not classified at a lower depth. The combination of these sums and n2 will ultimately characterize the mean color of a set of pixels represented by this node.
     */
    uint Sr;
    
    /**
     sums of the green component values for all pixels not classified at a lower depth. The combination of these sums and n2 will ultimately characterize the mean color of a set of pixels represented by this node.
     */
    uint Sg;
    
    /**
     sums of the blue component values for all pixels not classified at a lower depth. The combination of these sums and n2 will ultimately characterize the mean color of a set of pixels represented by this node.
     */
    uint Sb;
    
    /**
     the distance squared in RGB space between each pixel contained within a node and the nodes' center. This represents the quantization error for a node.
     */
    uint E;
    
    MemorizedSpiritedArray* reassigned;
}

-(id) initWithSpiritedArray:(SpiritedArray *)designatedSpiritedArray Colors: (uint) colors;

-(uint) colors;

-(SAReductionContext*) reduceToColors: (uint) colors;

-(BOOL) leaf;

-(SAColorType) centerColor;

-(SAColorType) assignColor: (SAColorType) originalColor;

-(SpiritedArray*) reassignSpiritedArray:(SpiritedArray*) designatedSpiritedArray;

-(SAColorTree*) lowRedLowGreenLowBlue;
-(SAColorTree*) setLowRedLowGreenLowBlue: (SAColorTree*) branch;
-(SAColorTree*) highRedLowGreenLowBlue;
-(SAColorTree*) setHighRedLowGreenLowBlue: (SAColorTree*) branch;
-(SAColorTree*) lowRedHighGreenLowBlue;
-(SAColorTree*) setLowRedHighGreenLowBlue: (SAColorTree*) branch;
-(SAColorTree*) highRedHighGreenHighBlue;
-(SAColorTree*) setHighRedHighGreenHighBlue:(SAColorTree*) branch;
-(SAColorTree*) lowRedLowGreenHighBlue;
-(SAColorTree*) setLowRedLowGreenHighBlue: (SAColorTree*) branch;
-(SAColorTree*) lowRedHighGreenHighBlue;
-(SAColorTree*) setLowRedHighGreenHighBlue: (SAColorTree*) branch;
-(SAColorTree*) highRedLowGreenHighBlue;
-(SAColorTree*) setHighRedLowGreenHighBlue: (SAColorTree*) branch;
-(SAColorTree*) highRedHighGreenLowBlue;
-(SAColorTree*) setHighRedHighGreenLowBlue: (SAColorTree*) branch;

@end
