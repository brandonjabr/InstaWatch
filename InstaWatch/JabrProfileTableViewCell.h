//
//  RekoCollectionViewCell.h
//  RekoCamDemo
//
//  Created by Brandon Jabr on 7/27/15.
//
//

#import <UIKit/UIKit.h>

@interface JabrProfileTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tap;
@property (retain, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *rankLabel;
@property (retain, nonatomic) IBOutlet UILabel *viewsLabel;
@property bool locked;
@property bool viewsLocked;




@end
