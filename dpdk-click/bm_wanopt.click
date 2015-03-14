elementclass PacketSource {
  //FromDump contains complete packets up to EtherHeader
  
  s::FromDump("/home/justine/mfiveseven.2.pcap", BIGMEM 2000000) ->
  
  //Random Source and InfiniteSource just generate Payloads, need to
  //Encapsulate in UDP/IP header and EtherEncap.

  //s::RandomSource(LENGTH 1200, BURST 64) ->
  //s::InfiniteSource(LENGTH 1000, BURST 64) ->
  //DynamicUDPIPEncap(1.0.0.1, 1234, 2.0.0.2, 1234, 1, 10) ->
  //SetIPChecksum ->
  //EtherEncap(0x800, 11:22:33:44:55:66, 66:55:44:33:22:11) ->
  output;
}

//Each thread has own Discard elt and one packet source.
egress0::Discard
egress1::Discard
egress2::Discard
egress3::Discard
egress::ThreadFanner
egress[0]  -> egress0;
egress[1] -> egress1;
egress[2] -> egress2;
egress[3] -> egress3;

egressPlusEther::EtherEncap(0x800, 11:22:33:44:55:66, 66:55:44:33:22:11) -> egress;

i0::PacketSource 
  -> ARPClassifier::Classifier(12/0806 20/0001, 12/0806 20/0002, 12/0800, -);
i1::PacketSource -> ARPClassifier;
i2::PacketSource -> ARPClassifier;
i3::PacketSource -> ARPClassifier;

  //ARP Machinery
  ARPClassifier[0] -> ARPResponder(1.2.3.4/32 11:22:33:44:55:66) -> egress;
  ARPClassifier[1] -> Discard; //ToHost
  ARPClassifier[3] -> Discard; //Not IP
  
  //Stuff that is IP traffic!
  ARPClassifier[2] -> 
  Strip(14) ->
  CheckIPHeader2(VERBOSE 0, CHECKSUM true) ->
  ipc::IPClassifier(icmp, tcp or udp);
 
  //Ping packets get handled here.
  ipc[0] -> icmpreply::ICMPPingResponder;
  icmpreply[0] -> egressPlusEther;
  icmpreply[1] -> Discard; // should be nothing

  //Stuff that's not ping gets prepped for cache
  ipc[1]
    //-> Print("tcp or udp")
    -> CheckIPHeader2(0, CHECKSUM true, VERBOSE true)
    -> dt::DecIPTTL[0]
    -> df::IPFragmenter(1500);

  //Stuff that didn't survive TTL, Fragmentation generates an error
  dt[1] -> ICMPError(1.2.3.4, timeexceeded) -> egressPlusEther;
  df[1] -> ICMPError(1.2.3.4, unreachable, needfrag) -> egressPlusEther;

  //Great! Now we encode.
  df[0]
  -> ThreadSafeEncoderElement()
  -> CheckIPHeader2(0, CHECKSUM true, VERBOSE true)
  -> egressPlusEther;
  //And done!

dm::DriverManager(
  set a 0,
  label x,
  //print "WAITING",
  wait 1s,
  //set e1 $(egress1.count),
  //set e0 $(egress0.count), 
  //set e2 $(egress2.count), 
  //set e3 $(egress3.count), 
  //set b $(add $e0 $e1),
  set b $(egress0.count),
  print "done $(sub $b $a) packets in 1s",
  set a $b,
  goto x 1
); 

//StaticThreadSched(i0/s 0, dm 1)
StaticThreadSched(i0/s 0, i1/s 1, i2/s 2, i3/s 3, dm 4)
//StaticThreadSched(i0/s 0, i1/s 1, dm 2)