#import <AVFoundation/AVFoundation.h>
#import "AVFViewController.h"
#import "PlayerView.h"

void *kCurrentItemDidChangeKVO  = &kCurrentItemDidChangeKVO;
void *kRateDidChangeKVO         = &kRateDidChangeKVO;
void *kStatusDidChangeKVO       = &kStatusDidChangeKVO;
void *kDurationDidChangeKVO     = &kDurationDidChangeKVO;
void *kTimeRangesKVO            = &kTimeRangesKVO;
void *kBufferFullKVO            = &kBufferFullKVO;
void *kBufferEmptyKVO           = &kBufferEmptyKVO;
void *kDidFailKVO               = &kDidFailKVO;

@interface AVFViewController ()
{
    AVPlayer *player;
    PlayerView *playerView;
    id timeObserver;
    NSInteger _playing;
}
@end

@implementation AVFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self playURL:[NSURL URLWithString:@"http://nba.cdn.turner.com/nba/big/channels/top_plays/2012/02/03/20120203_top10.nba_nba_ipad.mp4"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma -

- (void)dealloc
{
    [player removeTimeObserver:timeObserver];
}

#pragma -

- (void)playURL:(NSURL *)videoURL
{
    if (!player) {
        player = [[AVPlayer alloc] init];
        playerView = [[PlayerView alloc] init];
        [playerView setPlayer:player];
        playerView.frame = CGRectInset(self.view.bounds, 20, 20);
        playerView.backgroundColor = [UIColor greenColor];
        playerView.alpha = 1;
        [self.view addSubview:playerView];
        
        [player addObserver:self forKeyPath:@"rate"                            options:NSKeyValueObservingOptionNew context:kRateDidChangeKVO];
        [player addObserver:self forKeyPath:@"currentItem.status"              options:NSKeyValueObservingOptionNew context:kStatusDidChangeKVO];
        [player addObserver:self forKeyPath:@"currentItem.duration"            options:NSKeyValueObservingOptionNew context:kDurationDidChangeKVO];
        [player addObserver:self forKeyPath:@"currentItem.loadedTimeRanges"    options:NSKeyValueObservingOptionNew context:kTimeRangesKVO];    
        [player addObserver:self forKeyPath:@"currentItem.playbackBufferFull"  options:NSKeyValueObservingOptionNew context:kBufferFullKVO];    
        [player addObserver:self forKeyPath:@"currentItem.playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:kBufferEmptyKVO];    
        [player addObserver:self forKeyPath:@"currentItem.error"               options:NSKeyValueObservingOptionNew context:kDidFailKVO];    
        
    }
    [player replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc] initWithURL:videoURL]];
    
    timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, 600) queue:nil usingBlock:^(CMTime time) {
        NSLog(@"Playback time %.5f", CMTimeGetSeconds(time));
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if (kRateDidChangeKVO == context) {
        NSLog(@"Player playback rate changed: %.5f", player.rate);
        if (player.rate == 0.0) {
            NSLog(@" . . . PAUSE");
        }
    } else if (kStatusDidChangeKVO == context) {
        NSLog(@"Player status changed: %i", player.status);
        if (player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@" . . . ready to play");
        }
    } else if (kTimeRangesKVO == context) {
        NSLog(@"Loaded time ranges changed");
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            NSLog(@" . . . %.5f -> %.5f", CMTimeGetSeconds(timerange.start), CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration)));
            if (CMTIME_COMPARE_INLINE(timerange.duration, >, CMTimeMakeWithSeconds(3, timerange.duration.timescale))) {
                if (!_playing) {
                    [player play];
                    _playing = 1;
                }
            } 
            if (CMTIME_COMPARE_INLINE(timerange.duration, >, CMTimeMakeWithSeconds(4, timerange.duration.timescale))) {
                if (_playing == 1) {
                    [player pause];
                    _playing = 2;
                }
            } 
            if (CMTIME_COMPARE_INLINE(timerange.duration, >=, CMTimeMakeWithSeconds(5, timerange.duration.timescale))) {
                if (_playing == 2) {
                    [player play];
                    _playing = 3;
                }
            }
        }
    }
    //NSLog(@"%@", keyPath);
    //NSLog(@"%@", object);
    //NSLog(@"%@", change);
}

@end
