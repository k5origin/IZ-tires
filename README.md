# IZ-tires

This is a resource script for the FiveM FXServer. This script adds realistic tire wear and brake fade for an authentic racing experience.

Usage:
Type /usecar in the chat box to enable tire wear for the car you are driving. Only cars selected with this command will be affected
Type /pit in the car to reset the tires and brakes to perfect condition

Features:
- Tracks the condition of all 4 tires of a car
- Tracks the condition of the brakes
- Tire strength and brake durability can be adjusted in the code
- Cars lose their cornering capabilities when tires are worn
- Different aspects of a car's handling are affected depending the layout of the car (An FF car for example will mostly be affected by front tire wear)
- Brake temperature increases more when braking at high speeds
- Brakes can be cooled over time and by wind at high speeds
- Overheated brakes have reduced effectiveness and eventually fail to stop a car

Possible Future updates
- Vehicle condition will synchronize across all clients
- Functionality for bikes (or vehicles with more or less than 4 wheels)

Installation:
Place __resource.lua and client.lua into the resources/IZ-tires folder. 
add "start IZ-tires" to the server.cfg

