## | Quality of life |
■ Removed the noise posteffect.

■ Changed camera angle from 15 degrees to 9 degrees. Reduced the camera rigidness.

■ Reduced tornado radius from 100 to 65 meters, increased the cooldown from 3 to 6 seconds.

■ Added more checkpoints on each level.

■ Changed Bat nest parameters:

— Increased maximum monster respawn period from 8 to 25 seconds.

■ Increased weapon pickup duration from 30 to 45 seconds. Some pickups are selectively set to have an increased duration.

■ Increased item rewards:

— Maximum reward for a virus probe (red one) is now 2,000 points instead of 500;

— Reward for a unique item (disk) is now $3,000 instead of $1,000;

— Minimum reward factor for probes has been increased from 0.5 to 0.75.

■ Reduced the price of the second level of the Machinegun upgrade from 25000 to 12500.

■ Increased reward for destroying enemies:

— Difficult enemies now have a $200 reward instead of $150;

— Minibosses now have a $500 reward instead of $250;

■ Changed the way Turbo works:

— Removed cooldown, now Turbo can be used at any time.

— Changed the posteffect during the use of Turbo.

— Fixed the bug that forced the player to waste Turbo/Jumper charges when driving into a cutscene with Turbo/Jumper activated.

■ Changed the color of the Turbo and Jumper charge amount indicator from dark blue to orange for better readability.

■ Increased the Flamethrower projectile speed and radius.

■ Reassigned the standard keybind of the "Get out of a difficult place" function to the O key.

■ Changed the texture fonts with Windows ones, so now text of any size looks good on all resolutions. Fixed font display on wide screen resolutions (big thanks to Joomer for providing the fix).

■ Fixed game crash upon loading the next level if player finished the mission with a bonus weapon still present on their vehicle.

■ Fixed the damage dealt by biotoxic hot-spots increasing upon loading a checkpoint.

■ Globally fixed timers. Timers now restore upon loading a checkpoint. Timer are now restored to the proper value after player unpauses the game.

■ Fixed an issue with player being able to get a secret entry without picking up a disk.

■ Added an option for a different quest completion sound.

■ Fixed timers that should start upon loading a checkpoint.

■ Added new weapon pickup on boss fight arenas.

■ Expanded the analytics that are given during boss battles, now they give actually useful information for defeating bosses.

■ Expanded the briefings with various information about missions.

■ Added tutorial in Mission 1 "Under siege" that explains new the pickups and gameplay features.

■ Added new tips on the loading screen (several gameplay ones and some about the standard keybinds).

■ Rewritten the bigger portion of the original English localization.

■ Fixed the issue with score indicator being cropped when playing on widescreen resolution.

■ Reduced bloom in Mission 3 "Secret files" and Mission 5 "Swamp roads". Reduced the frequency of the lightning strike effect.

■ Fixed performance issues in Mission 4 "Strange jungle".

■ Cleaned up the servers and unused queststates in all missions.

■ Commented out the unused Truck wheels and chassis.

■ Cleaned up the .xml files, the game should load a whole lot less of useless junk now.


## | Gameplay |
■ Added fully-functional Shotgun:

— Shotgun now features its own stylized weapon model (3D-model and animation by ICAS-14);

— Increased the spread of the pellets;

— Replaced the purchasable Flamethrower with a more all-round weapon - the Shotgun. Level one is a regular shotgun, level two is an automatic shotgun and level three is a shotgun with exploding ammunition. All Shotgun variations feature their own 3D-model. Flamethrower is still available as a temporary auxiliary weapon;

— Concrete pillboxes are now armed with Shotgun instead of Rocket launchers (pillboxes cannot aim the rockets, so they are pretty useless on them);

— Added new Shotgun weapon pickups starting from Mission 3.

— Added new hit effect for Shotgun level three.

■ Reworked the Rocket launcher:

— Replaced Storm model with three different appropriate models for each level of upgrade.

— Level one: primitive ATGM, cost is 20000;

— Level two: automatic rocket launcher, cost is 60000.

— Level three: tandem-charge ATGM (3D-model by Gnome627), cost is 80000.

■ Reworked the Flak cannon:

— Each level of upgrade now features its own 3D-model.

— Level one: twin machine gun with incendiary ammunition (3D-model authors: ICAS-14, lyokhatankist).

— Level two: quad heavy machine gun.

— Level three: rapid-firing chain gun with area of effect damage.

— Fixed and updated hit effects for all Flak cannon variations.

■ Replaced Machinegun level one 3D-model with a properly stylized visual. Reworked the firing rate and damage parameters while keeping the damage per minute the same as it was.

■ Replaced the OG Van truck vehicle with properly stylized visual:

— Added new miniboss type that uses the police variant of the vehicle;

— Vans will now be encountered as regular enemies from Mission 5 onwards.

■ Buffed the Truck-type minibosses:

— Vehicles now use all available weapon placements;

— Increased hitpoints from 300 to 450.

■ The reward for destroying mutant mushrooms is now issued at the end of the mission. The bonus reward increases exponentially depending on the total number of mushrooms on the level.

■ Fixed voiceover of random enemies. Now enemies are divided into different factions with their own sets of voicelines (instead of everything being mashed together in one single set of voicelines, as it was in the original game). Adjusted faction relationships. Added new police car prototypes with more aggressive behavior in combat.

■ Fixed an issue with incorrect weapon placement on some variations of the Sedan.

■ Two pillboxes located near the place of the skirmish with the police have been added to the list of targets that need to be destroyed to activate the quest "Ray in the Darkness" in Mission 1 "Under siege".

■ Fixed player vehicle positioning after the "top-down camera" sections in Mission 2 "Base No. 31".

■ Fixed the second checkpoint in Mission 2 "Base No. 31". In the original, it was unusable due to too low fps/crash when loading it. Unfortunately, this required sacrificing the zombie spawner at the destroyed power plant. Instead, the player will now be met by several police cars there.

■ Added 4x-damage, repair and armor pickups near the power plant in Mission 2 "Base No. 31".

■ The pillboxes at the entrance to the chemical lab in Mission 2 "Base No. 31" will now be automatically destroyed at the start of the cutscene before the skirmish with the zombies. No more pillboxes attacking the player upon loading the checkpoint.

■ Added two Repair pickups after the chemical laboratory in Mission 2 "Base No. 31".

■ The Truck-miniboss in Mission 2 "Base No. 31" will now only appear when the player approaches the skirmish with the miniboss. Thus, the skirmish will always take place on the road, as intended.

■ Fixed the GPS-navigator in Mission 5 "Swamp roads".

■ Fixed the final cutscene playing twice in Mission 5 "Swamp roads".

■ The toxic wave in Mission 6 "Last man standing" now starts after the second cutscene, in which the General informs the player about its approach.

■ Fixed mutant mushrooms that were difficult to see due to the wrong angle of placement in missions 4 "Strange jungle" and 6 "Last man standing"; a collision with them could lead to the instant death.

■ Fixed early spawning of the boss in Mission 6 "Last man standing" at the end of the toxic wave, which led to the instant death of the player if they did not reach the boss fight arena (which frankly looked like a bug). Instead of instant death, the player's health will slowly deteriorate. Duplication of the boss was also fixed.

■ Fixed thermite charges in Mission 5 "Swamp roads" having a collision. Previously, hitting them could launch the player high into the sky.

■ Fixed the bug that prevented players from completing the quest of destroying zombies at Road River in Mission 7 "Desert Heat" when loading the checkpoint in a new game session. Also, this quest now actually fails when the timer expires.

■ Fixed enemy spawns in Mission 8 "The Big Hunt":

— Fixed prototypes in ambushes, adjusted the enemy pool in ambushes;

— In the final bossfight, the enemy spawn has been fixed so that it always happens after the cutscene (so that enemies don't have time to get closer while player is watching the cutscene).

— Added another wave of enemies to the second phase of the boss.

■ Enlarged the boss fight area in Mission 8 "The Big Hunt" to prevent the player from dying through no fault of their own by driving too close to one of the rocks.

■ Fixed a crash when colliding with the final boss vehicle when they perform a ram.

■ Reworked the final boss:

— Fixed the affiliation of boss' vehicle.

— Removed the 10x player damage reduction period.

— Reworked boss resistance values to compensate for the change above.

■ Reworked the final cutscene.

■ Replaced the visuals of the cars thrown by the boss in Mission 8 "The Big Hunt". They are also now immune to damage (thus fixing the crash that occurs when a thrown car is destroyed with a Rocket launcher).

■ Fixed the weapon placement on the boss car in Mission 8 "The Big Hunt".

■ Added "New game+":

— If the player confirms to start a New game+ after defeating the final boss, the campaign will start over again with the progress from the previous playthrough preserved and new rules that make the gameplay more challenging.

■ Added a secret boss towards the end of the game.

## | Visuals |

■ Fixed the playback of the Machinegun animation when firing long bursts.

■ Replaced the model of enemy-specific type of the Machinegun (3D-model by ICAS-14). The new Machinegun's sound uses a previously unused set of sounds from the game files.

■ Replaced the OG Hunter model with a Thunder Turtle (player's vehicle) with a previously unused unique paint job from the game files.

■ Replaced the military patrol vehicle model in Mission 7 "Desert heat":

— Patrols now use stylized Humvees;

— Added a variation of the Humvee in Delta colors;

— Hunter suspension added to the servers.

■ Improved vehicle destruction effects. Now vehicles explode with corresponding visual and sound effects, in particular when a vehicle is destroyed with the Flak cannon.

■ Fixed an issue with the posteffect when exiting to the main menu from any mission.

■ Added burnt skins to all weapons.

■ Fixed significantly offset collision on the new gas station model.

■ Fixed hit decals of the Machinegun and Flamethrower.

■ Fixed material of region 5 wooden bridge section.

■ Fixed suspension stiffness parameters for all non-playable vehicles.

■ Fixed Sedan chassis materials.

■ Fixed effects for all Magenta variations.

■ Fixed suspension models of the Truck and red Magenta.

■ Fixed materials of Truck wheels and chassis, fixed material of destroyed second variation of the Truck.

■ Restored the cut Truck's third axle.

■ Fixed Truck suspension.

■ Fixed the presence of a visual effect in the quest completion sound effect.

■ Improved GRENADE type hit effects.

■ Fixed floating fences in Mission 1 "Under siege" and Mission 8 "The Big Hunt".

■ Removed unused and duplicate objects in Mission 1 "Under siege".

■ Fixed a pipe near the factory complex in Mission 3 "Secret files" that was assigned an unspecified model.

■ Swapped the previews and loading screen images for Mission 4 "Strange jungle" and Mission 6 "Last man standing".

■ Fixed weapon pickup visuals in Mission 6 "Last man standing" and Mission 8 "The Big Hunt".

■ Changed the weather in Mission 7 "Desert heat" (previously this mission reused the same weather from Mission 2 "Base No. 31").

■ Returned the hangar structure at the beginning of Mission 7 "Desert heat".

■ Changed the weather on Mission 8 "The Big Hunt". The weather on this level is no longer randomized.

## | Cutscenes |
■ Changed General's model to a previously unused model from the game files, made specifically for this character by the original devs.

■ Fixed the timing of all voicelines, thus no more "theatrical pauses" in the cutscenes.

■ Restored the cut dialogue. In particular, the General's monologue in Mission 7 "Desert heat" that reveals some important elements of the plot.

■ Fixed the camera in the opening cutscene of Mission 1 "Under siege".

■ Restored the radio transmission cutscene in Mission 3 "Secret files".

■ Fixed the final quest in Mission 3 "Secret files". Also, the mission now ends with a cutscene with restored voicelines, rather than suddenly loading the next mission.

■ Remade the opening cutscene in Mission 6 "Last man standing". Firstly, the structure of the cutscene itself has been fixed, secondly, the staging of the scene has been slightly changed, and thirdly (3), the player's car will no longer drive into the water and take damage before the game even starts.

■ Fixed the analytical report being issued during the final cutscene in Mission 6 "Last man standing" (meaning that quest completion sound will no longer play during the characters' speech).

■ Fixed the duration of the cutscene upon arrival at the Fly-Hill airfield in Mission 7 "Desert heat". Godmode is assigned to the player for the duration of the cutscene. After the cutscene, the player health is fully restored before the upcoming turret section.

■ Changed the cutscene of the first encounter with the infected military patrol in Mission 7 "Desert heat" in such a way as to clearly show the player the objective of the mission.

■ Fixed the analytical report being issued during the final cutscene in Mission 8 "The Big Hunt".

■ Added credits after the final boss battle.

## | Audio |
■ Fixed missing ambient sounds. All sounds have had their volume adjusted.

■ Added alternative versions of music tracks. That should reduce the problem of music repetitiveness.

■ Changed the sounds of the suspension and car collisions with an unused set of sounds from the game files.

■ Changed the sound of the basic version of the Machinegun with an unused set of sounds from the game files.

■ Changed the sound of the idling engine.

■ Fixed the volume of the Flak cannon gunfire sound.

■ Fixed the quest completion sound, it is no longer spatial.

■ Fixed missing explosion sound for some car destruction effects.