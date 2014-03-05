//
//  UIBubbleTableView.h
//
//  Created by Alex Barinov

//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableViewCell.h"
#import "EGORefreshTableHeaderView.h"
typedef enum _NSBubbleTypingType
{
    NSBubbleTypingTypeNobody = 0,
    NSBubbleTypingTypeMe = 1,
    NSBubbleTypingTypeSomebody = 2
} NSBubbleTypingType;

@interface UIBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

}
@property (nonatomic, assign) id<UIBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic) NSBubbleTypingType typingBubble;
@property (nonatomic) BOOL showAvatars;
@property (nonatomic) BOOL isEdit;
- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated;

@end
