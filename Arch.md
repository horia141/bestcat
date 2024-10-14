# Architecture

BestCat uses [Godot](https://godot.org) as the game engine and this determines the architecture of the system to a large degree. The game application consists of a number of scenes and scripts that work to make the game.

## Components

There are two main manager scenes - `Application` and `Game`.

`Application` is the top-most scene that fully manages the game, and that exists throughout the lifetime of the game. 

* It nominally shows the main menu and initiates a mission, but in fact it holds all global application-level constructs that everyone else needs to be aware of.
* When a new mission starts, `Application` is in charge of creating a new `Game`, and disposing of the old one. In the future, player-centric bookkeeping will happen here (scores, trophies, records of actions, etc)

`Game` is a child of `Application` that handles the current running game.

* This does most of the heavy-lifting for game logic.
* A `Game` has a current mission. This is specified by the application at start time, but the `Game` is in charge of linking everything together.
* The `Game` wires everything toegther, makes sures enemies are handled, projectiles are hit, the mission progresses, etc.

All other entities are rather local. They care about their own local behaviour, but never change anything with the global one (such as pausing the game, handling input, doing IO, etc.).

## Patterns

Try to go with the flow. We don't need _a lot of abstraction_ here. Rather we need to be close to the patterns and concepts of the game engine. For example, every mission is a separate scene, deriving from an abstract `Mission`. But it can contain a variety of enemies, story points, triggers, etc. that need not have much in common with other missions. As another example, every enemy type has a custom script that controls the attack patterns.

Any scene should be usable _as is_. Both in the editor, and when starting them as a "game". They shouldn't need teh `Application` or `Game` scenes to wire them up.

State should be kept as local as possible.

Communicating with child scenes should be done via direct method calls.

Communicating with parent scenes should be done via signals.

Using `await` on a single signal invocation should be preferred for most single event entities that operate raather "synchronously" (ie waiting for an OK from a dialog).

A scene should not control whether it is visible or not, or active or not. It's parent/manager should do that.

The manager scene is in charge of instantiating a new object in the scene. For example, when a player shoots it can create the projectile, but it needs to tell the `Game` that a new projectile is creted so it can create it.

The manager scene is also in charge of removing a child object from the scene. An object should not call `queue_free` on itself.

The `Game` should be the only one pausing and unpausing the game. Not always followed!