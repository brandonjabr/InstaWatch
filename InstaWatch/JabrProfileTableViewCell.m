//
//  RekoCollectionViewCell.m
//  RekoCamDemo
//
//  Created by Brandon Jabr on 7/27/15.
//
//

#import "JabrProfileTableViewCell.h"

@implementation JabrProfileTableViewCell


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"JabrProfileTableViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
    
}

@end
