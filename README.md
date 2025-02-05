This is a lua library for making simple n-body simulations

It is intended for artistic purposes, such as visualizers, over accuracy for scientific simulations. It supports easily creating stable systems that stay centered and constrained, for ease of drawing to a screen for very long periods of time without bodies drifting or flying to infinity.

Parameters can be tweaked for different orbital qualities:
- `dt`: The time step
- `softening`: A sort of "minimum distance" used in force calculations, to prevent very high forces being applied as bodies fly very close to each other. Lowering this value will allow for stronger "slingshot" effects, raising it makes slingshots weaker.
- `gravExponent`: The exponent that is applied to the distance in the denominator of the gravity force calculations. Raising it will lead to more slingshots and 2-body tightly orbiting pairs, lowering it will make motions smoother, slower, and less dramatic.
    - For Newton's laws of motion, this should be 3

more documentation to come
