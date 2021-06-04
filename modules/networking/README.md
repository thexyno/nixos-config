# Networking

## Structure

| Vlan Name | Vlan ID | IP Range | Uses |
|--|--|--|--|
|lan  |3|10.0.0.1/16|Everything|
|iot  |1|10.1.0.1/16|Only Connected to WiFi and ds9. Used for those creepy chinese iot devices that never should see the internet|
|guest|2|192.168.178.1/24|Used for guests and creepy iot shit that should see the internet, but nothing else (Thermomix Clone, ...)|
