#import <UIKit/UIKit.h>

@class AVPlayer;

@interface PlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

- (void)setVideoGravity:(id)gravity;

@end
