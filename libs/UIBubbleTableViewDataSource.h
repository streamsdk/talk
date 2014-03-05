//
//  UIBubbleTableViewDataSource.h
//
//  Created by Alex Barinov

//

#import <Foundation/Foundation.h>

@class NSBubbleData;
@class UIBubbleTableView;
@protocol UIBubbleTableViewDataSource <NSObject>

@optional
-(void)reloadBubbleView:(NSMutableArray * )array;
@required

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView;
- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row;

@end
