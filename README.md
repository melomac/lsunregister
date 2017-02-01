## lsunregister

`lsunregister` is a command line interface to __batch deregister__ applications in macOS LaunchServices database, using a _prefix_, a _pattern_ or a _regular expression_.

`lsunregister` can also provide a clean list of all registered applications in LaunchServices database.

`lsunregister` uses LaunchServices framework private functions for maximum efficiency.


### Usage

	lsunregister --prefix / -p <prefix>
	lsunregister --like   / -l <pattern>
	lsunregister --regex  / -r <regular expression>
	lsunregister --debug  / -d : print all registered applications and exit.


### Examples

	lsunregister --prefix ~/.Trash/
	lsunregister --like   "/Volumes/*/.Trashes/*"
	lsunregister --regex  "/Users/.*?/(\.Trash|Desktop|Downloads|Library/Mail)/.*"
	lsunregister --debug  | sort

