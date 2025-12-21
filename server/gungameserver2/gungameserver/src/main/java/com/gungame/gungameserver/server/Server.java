package com.gungame.gungameserver.server;
import java.nio.channels.DatagramChannel;

public class Server {
    
    boolean running = true;
    
    public void run(){
        while (running) {
            long start = now();
        
            receivePackets();   // UDP read
            updateSimulation(); // fixed tick
            sendPackets();      // UDP write
        
            sleepUntilNextTick(start);
        }
    }
}
