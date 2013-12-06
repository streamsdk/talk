//
//  PlayerView.h
//  talk
//
//  Created by wangshuai on 13-11-13.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerView : UIViewController

{
    UIView *background;
}
@property (nonatomic,strong) MPMoviePlayerViewController *pvc ;

-(void)playVideo:(NSURL *)url;

//-(void) bigImage :(CGSize) bigImageSize;

@end
