Peer4commit
==========

[![peercoin tip for next commit](http://peer4commit.com/projects/1.svg)](http://peer4commit.com/projects/1)
[![bitcoin tip for next commit](http://tip4commit.com/projects/560.svg)](http://tip4commit.com/projects/560)

Donate peercoins to open source projects or make commits and get tips for it.

Official site: http://peer4commit.com/

Tip modifiers
-------------

Project owners can change the amount given to a commit during the merge. To do that they must include one of these hashtags in the merge commit message:
* `#huge`: the author will get 5 times the normal tip amount
* `#big`: 2 times the normal amount
* `#small`: half the normal amount
* `#tiny`: 1/5th the normal amount
* `#free`: no tip at all

Note that each merged commit will receive its own modified tip.

Also note that the modifier only works when all these conditions are met:

1. The merge has exactly 2 parents and there are new commits in only one of the 2 branches. More complex merges are harder to interpret. This is what happens when you merge a pull request on GitHub.
2. The merge author is a collaborator of the project. This was implemented to prevent abusive hidden modifiers in commit messages.

We suggest project owners add a public statement on how they will modify tips. See below for our own example.

Tipping policy for the peer4commit project
------------------------------------------

Minor internal code changes with no effect on the user experience will be flagged as #tiny. This includes code beautification, minor optimizations, etc.

Other changes will mainly be evaluated on how they impact the end user experience. The more they solve a real problem the bigger the tip. The more they add a wanted feature, the bigger the tip.

Internal changes that significantly helps future developments (like paying a large technical debt) will also receive larger tips.

The time required to make the change may also be taken into account.

License
=======

[MIT License](https://github.com/sigmike/peer4commit/blob/master/LICENSE)

Based on [Tip4commit](http://tip4commit.com/), [MIT License](https://github.com/tip4commit/tip4commit/blob/master/LICENSE), copyright (c) 2013-2014 tip4commit
