# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].


## [1.0.2] - 2024-10-23

### Added

- You can now search for the title of your current reputation standing/reaction, e.g. "Renown 10", "Collaborator", "Stranger", "Level 36", "True Friend", etc.

### Fixed

- Small performance improvements.



## [1.0.1] - 2024-10-04

### Fixed

- The rep bar will now only be tried to be added to the ReputationFrame once it's actually loaded and then only once (instead of every time you see a loading screen lol).



## [1.0.0] - 2024-10-03

### Changed

- Recoded the entire addon, now I just manipulate the update function of Blizzards ReputationFrame with an algorithm of my own.

- Searching for something now colors the part of the name of the faction you were searching for (e.g. searching for "War" colors the "War" part in "The War Within" green).



## [0.6.2] - 2023-10-14

### Changed

- Rewrote the option settings, since it was unreliable at best

### Fixed

- After your first install of the addon it would try to load some settings which obviously aren't there yet



## [0.6.0] - 2023-10-04

### Added

- Logo for Curseforge / ingame

### Fixed

- Minor UI fixes



## [0.5.8] - 2023-10-03

### Added

- Initial release

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/NintendoLink07/RepSearch/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/NintendoLink07/RepSearch/releases/tag/1.0.2
[1.0.1]: https://github.com/NintendoLink07/RepSearch/releases/tag/1.0.1
[1.0.0]: https://github.com/NintendoLink07/RepSearch/releases/tag/1.0.0
[0.6.2]: https://github.com/NintendoLink07/RepSearch/releases/tag/0.6.2
[0.6.0]: https://github.com/NintendoLink07/RepSearch/releases/tag/0.6.0
[0.5.8]: https://github.com/NintendoLink07/RepSearch/releases/tag/0.5.8