tbl :: MBarkTable

elementclass MBarkGateway {
    $rule | input 
    -> ProtocolTranslator46
    -> MBArkFirewall(FILENAME $rule, TABLE tbl)
    -> proxy::MBArkProxy;
    proxy[0] -> [0]output;
    proxy[1] -> [1]output;
}

//FromDump(FILENAME /project/cs/netsys/data/pcaps/m57/m57.pcap, STOP true) -> c;

pd0::PollDevice(p513p1, QUEUE 0, BURST 32) -> Strip(14)
    -> gw0::MBarkGateway(conf/test_fw.rules)

q0::SimpleQueue(20000)
    -> sd0::SendDevice(p513p2, QUEUE 0, BURST 32);

gw0[0]    
    -> EtherEncap(0x86DD, 1:1:1:1:1:1, 2:2:2:2:2:2)
    -> q0

gw0[1]
    -> EtherEncap(0x86DD, 1:1:1:1:1:1, 2:2:2:2:2:2)
    -> q0