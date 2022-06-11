# Hit Detection

Hit detection is currently pending rework as I am not entirely satisfied with it. However what is there should work though it is barebones. Basically the idea is you use the hitbox class to detect hits and then real the hit attributes to define hit responses. The hit attributes would be entirely user defined as I currently do not plan to include any default implementation due to vast number of possible attributes (damage, knockback, etc.)

The other classes exist to manage which hitboxes are currently activated. Basically a combatant could have multiple hit states but one 1 active at a time, and within that hitstate they could have multiple hitboxes, some to define their 'hurtbox' others to define their 'attackbox', the hitboxes within a state could then be switched and manipulated to match a combat animation. You could think of each HitState as representing what the current configuration of hitboxes would be during an attack, standing still, etc.

I'll likely stick with these concepts but I think the implementation could be better...
