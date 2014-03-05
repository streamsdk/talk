//
//  UIBubbleTableViewCell.h
//
//  Created by Alex Barinov

//

#import <UIKit/UIKit.h>
#import "NSBubbleData.h"
#import "AppDelegate.h"
@interface UIBubbleTableViewCell : UITableViewCell

@property (nonatomic, strong) NSBubbleData *data;
@property (nonatomic) BOOL showAvatar;
@property (nonatomic) BOOL isEdit;
@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic) BOOL isClicked;
@property (nonatomic, retain) NSMutableArray *deleteArray;
@end
