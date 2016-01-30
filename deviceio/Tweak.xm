%hook musicCapabilitiesResponse

-(void)setCapabilities:(NSArray *)array{
	array = [NSArray arrayWithObjects:@1,@2,@3,@4,@0,nil];
	%orig;
}

%end

%ctor {
    %init(musicCapabilitiesResponse = objc_getClass("GarminDeviceIO.MusicControlCapabilitiesResponse"));
}