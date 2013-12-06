//
//  UIBubbleTableViewCell.h
//
//  Created by Alex Barinov

//

#import <UIKit/UIKit.h>
#import "NSBubbleData.h"

@interface UIBubbleTableViewCell : UITableViewCell

@property (nonatomic, strong) NSBubbleData *data;
@property (nonatomic) BOOL showAvatar;

@end
