//
//  IconView.m
//  talk
//
//  Created by wangsh on 13-12-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "IconView.h"

@implementation IconView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        icon = [[NSArray alloc]initWithObjects:@"face.png", @"photog150.png",@"camera_icon150.png",@"video150.png",nil];
    }
    return self;
}

-(void)loadIconView:(int)page size:(CGSize)size
{
	//row number
	for (int i=0; i<1; i++) {
		//column numer
		for (int y=0; y<4; y++) {
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(y*(size.width+40), i*size.height, size.width, size.height)];
            NSString * str = [icon objectAtIndex:i*3+y];
            UIImage *image = [UIImage imageNamed:str];
            [button setImage:image forState:UIControlStateNormal];
            button.tag=i*4+y;
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
        }
    }
}


-(void)selected:(UIButton*)bt
{
    
        NSString *str=[icon objectAtIndex:bt.tag];
        NSLog(@"点击其他%@",str);

        [delegate selectedIconView:bt.tag];
}


@end
