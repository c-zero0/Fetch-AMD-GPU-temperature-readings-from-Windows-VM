Description:

    You might wonder why am I bothering with adlx when Open Hardware Monitor worked just fine in my previous project. Well, after precisely 1 minute and 50 seconds, the vm would crash when Open Hardware Monitor was set to run at boot. Idk why, but that's how it is. This is another way of accomplising the same thing, but with adlx instead of Open Hardware Monitor. Enjoy
    
    This guide helps fetch the hotspot temperature of an amd gpu passed-through to a Windows VM using the adlx library into 1 .txt file compatible with CoolerControl, so this sensor could be added as a custom one and seen by the host while the VM is on.

    The adlx based c++ program cannot be run directly via qemu guest agent, so it will be run with task scheduler.
    
    The thing works like this: 
    -get-temps.sh executes task scheduler in windows and prints the output of the generated output.txt located on the vm containing the hotspot temperature (and additionally some other stats: voltage and power draw of the gpu);
    -task scheduler runs the "Run Fetch" schedule, which, when run, it executes 'run.bat' with nircmd (so that a command line wouldn't pop up every few seconds on the vm monitor)
    -'run.bat' executes 'temps.py', and outputs to 'output.txt'
    -'temps.py' executes 'fetch.exe', the program written in adl-x. in the repo is attached the slightly modified 'mainPerfGPUMetrics.cpp' to suit my needs (source: https://github.com/GPUOpen-LibrariesAndSDKs/ADLX)
    
    To automate everything, you can run 'loop_write_temp.sh', which executes 'write-temp.py' continuously (which writes 'get-temps.sh' output formatted to CoolerControl standards to /tmp/gpu_hotspot_temperature)
    

Requirements:

    Python3 - host & guest
    jq - host

Guide:

    1. Add this to your guest libvirt xml:

        <channel type="unix">
        <target type="virtio" name="org.qemu.guest_agent.0"/>
        <address type="virtio-serial" controller="0" bus="0" port="1"/>
        </channel>

    2. Copy 'get-temps' folder to guest in C:\
    3. Install Qemu Guest Agent (virtio-win iso with drivers at "https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md" - guest agent is in the guest-agent folder)
    4. Edit the scripts as needed to have the correct paths in windows / linux, as well as correct vm names.
    5. Add a new schedule in task scheduler (Create Basic Task->Name: "Run Fetch"->daily->next->Start a program next->Program/script field: "C:\get-temps\nircmd.exe C:\get-temps\nircmd.exe exec hide C:\get-temps\run.bat"->next->hit yes->Finish)
    7. Now create the custom sensors in CoolerControl for the Hotspot located at /tmp/gpu_hotspot_temperature.txt

Many thanks to the guy who wrote https://gist.github.com/jpsutton/8734ce209f7874d5e386d2865c1adc8a , chatgpt and the example programs from the adlx library
