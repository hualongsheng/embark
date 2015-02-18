// testdevice.click

// Tests whether Click can read packets from the network.
// You may need to modify the device name in FromDevice.
// You'll probably need to be root to run this.

// Run with
//    click testdevice.click
// (runs as a user-level program; uses Linux packet sockets or a similar
// mechanism), or
//    click-install testdevice.click
// (runs inside a Linux kernel).

// If you run this inside the kernel, your kernel's ordinary IP stack
// will stop getting packets from eth0. This might not be convenient.
// The Print messages are printed to the system log, which is accessible
// with 'dmesg' and /var/log/messages. The most recent 2-4K of messages are
// stored in /click/messages.

//PollDevice(eth4) -> Print(ok) -> Discard;
//PollDevice(eth4) -> c0:: AverageCounter() -> Discard;

//PollDevice(eth4) -> Queue(100) -> c0:: AverageCounter() -> SendDevice(eth4, BURST 32);
pd1::PollDevice(eth4, QUEUE 0, BURST 32) -> q1::SimpleQueue(100) -> sd1::SendDevice(eth5, BURST 32, QUEUE 0);

//pd11::PollDevice(eth1, PORTID 0, QUEUE 1, BURST 32) -> q11::Queue(100) -> sd11::SendDevice(eth2, BURST 32, PORTID 3, QUEUE 1);

//pd2::PollDevice(eth5, QUEUE 0, BURST 32) -> q2::SimpleQueue(100) ->sd2::SendDevice(eth6, BURST 32, QUEUE 0);

//pd22::PollDevice(eth3, PORTID 1, QUEUE 1, BURST 32) -> q22::Queue(100) ->sd22::SendDevice(eth4, BURST 32,  PORTID 2, QUEUE 1);

StaticThreadSched(pd1 0, sd1 0);
//StaticThreadSched(pd11 1, sd11 1);

//StaticThreadSched(pd2 2, sd2 2);
//StaticThreadSched(pd2 1, sd2 1);
//StaticThreadSched(pd22 3, sd22 3);

//DFromToDevice(0, PORTID_R 0, PORTID_T 3);
//DFromToDevice(0, PORTID_R 1, PORTID_T 2);

//pd3::PollDevice(eth7, QUEUE 0, BURST 32) -> q3::SimpleQueue(100) -> sd3::SendDevice(eth4, BURST 32, QUEUE 0);

pd4::PollDevice(eth5, QUEUE 0, BURST 32) -> q4::SimpleQueue(100) -> sd4::SendDevice(eth4, BURST 32, QUEUE 0);

//StaticThreadSched(pd3 2, sd3 2);
StaticThreadSched(pd4 1, sd4 1);

//rt :: StaticIPLookup(
//   192.168.210.0/24 0,
//   192.168.111.0/24 1);

//pd1::PollDevice(eth4, PORTID 0, QUEUE 0, BURST 32) -> Strip(14) -> CheckIPHeader2() -> rt; 

//rt[0] -> q1::Queue(100) -> DecIPTTL -> EtherEncap(0x0800, 1:1:1:1:1:1, 2:2:2:2:2:2)
//      -> sd1::SendDevice(eth4, BURST 32, PORTID 1, QUEUE 0);

//rt[1] -> q2::Queue(100) -> DecIPTTL -> EtherEncap(0x0800, 1:11:11:11:11:11, 2:22:22:22:22:22)
//      -> sd3::SendDevice(eth5, BURST 32, PORTID 2, QUEUE 0);
