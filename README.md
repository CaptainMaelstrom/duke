duke
====

duke is the digital version of Catalyst Game Labs' abstract strategy board game "The Duke".

http://www.catalystgamelabs.com/casual-games/the-duke/

You can follow the link above to read the rules .pdf. Currently, there is no hotseat or AI implemented. The possible ways to play the game are across the internet, and through the network loopback address.

Windows Executable
------------------

Just unrar and double-click duke.exe to run an instance of the game on Windows.

https://drive.google.com/file/d/0B7dSai__8CnaRjR2Y0xQRmRJRzQ/edit?usp=sharing

Starting an internet game
-------------------------

You and a friend should both open an instance of the game. One player types "host" and presses enter and the other person should type in the first person's IP address and press enter. If you successfully make a connection, you will see two player names in the lobby.
You may now type in a new name and press enter, press left and right to change the map, or up and down to change your player color.

Starting a local loopback game
------------------------------

Open two instances of duke. In one, press spacebar and type "host" and press enter. In the second, press spacebar and type "18667" and press enter. You should see two player names in the lobby.

Other instructions
------------------

* You may right-click on any troop to see a close-up of the troop tile.
* Press space bar over the Duchess and Oracle to use their abilities.
* Press D to draw more troop tiles on your turn.
* You can either click and drag or click to grab and click to release tiles to move them.
* The first person to kill all the dukes on the board is the winner

Bugs/Gotchas
------------

* The game breaks when players used the same color as other players. Don't start the game until all players have a unique color.

Credits
-------

Thanks to kikito for various libraries
https://github.com/kikito

Thanks to leafo for enet (now part of love2D)


