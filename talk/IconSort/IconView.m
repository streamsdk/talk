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
        icon = [[NSArray alloc]initWithObjects: @"photog150.png",@"camera_icon150.png",@"video150.png",@"map.png",@"searchphotog150.png",nil];
    }
    return self;
}

-(void)loadIconView:(int)page size:(CGSize)size
{
	//row number
    NSArray * array = [[NSArray alloc]initWithObjects:@"Choose a Photo",@"Camera",@"Choose a Video",@"send location",@"search photo", nil];
	for (int i=0; i<2; i++) {
		//column numer
		for (int y=0; y<3; y++) {
            if (i*3+y>[icon count]-1)break;
                
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(y*(size.width+30)+35*(y+1), i*(size.height+20), size.width, size.height)];
            NSString * str = [icon objectAtIndex:i*3+y];
            UIImage *image = [UIImage imageNamed:str];
            [button setImage:image forState:UIControlStateNormal];
            button.tag=i*3+y;
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(y*(size.width+40)+20*(y+1), size.height*(i+1)+20*i, 80, 20)];
            label.text= [array objectAtIndex:y+i*3];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10.0f];
            [self addSubview:label];
            [label setBackgroundColor:[UIColor clearColor]];
            if (y!=2) {
                UIButton * separatorButton  = [UIButton buttonWithType:UIButtonTypeCustom];
                [separatorButton setFrame:CGRectMake(y*100+105, 10+60*i, 5, size.height-20)];
                [separatorButton setImage:[UIImage imageNamed:@"separator.png"] forState:UIControlStateNormal];
                [self addSubview:separatorButton];
            }
            
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
