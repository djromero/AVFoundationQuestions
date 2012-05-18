#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlayerView

- (id)init {
    self = [super init];
    if (self) {
        AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.layer.masksToBounds = YES; 
#if PlayerViewDebugGeometry
        self.layer.backgroundColor = [[UIColor cyanColor] CGColor];
        self.layer.borderColor = [[UIColor magentaColor] CGColor];
        self.layer.borderWidth = 4;        
        self.alpha = 0.40f;
        self.layer.masksToBounds = NO;         
#else
        self.alpha = 0.0f;
        self.backgroundColor = [UIColor clearColor];        
#endif
    }
    return self;
}

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayer *)player {
	return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
	[(AVPlayerLayer *)[self layer] setPlayer:player];    
}

- (void)setVideoGravity:(id)gravity {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;    
    layer.videoGravity = gravity;    
}

@end
