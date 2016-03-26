*If you are the legal team of a preexisting company called Napalm, you can f@%& off*

![Napalm](https://raw.githubusercontent.com/cheeselover/napalm/master/logo.jpeg)
#### Everyone's favourite way to create useless Node dependencies - right from your text editor!

Napalm is an Atom plugin that provides a way to seamlessly and quickly create new NPM packages for your locally defined functions. This makes it EXTREMELY easy to keep your code 100% reusable with low coupling and high isolation. Additionally, the entire WORLD can use your functions, so you will make a significant contribution to the Node ecosystem!!11!1!!!1!one!!1!

![Our amazing logo](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)

## What it does

This plugin automatically creates Github repositories and NPM packages (under your own accounts) for individual functions you've defined in your own project, which are then actually published to the NPM registry so other people can see your fantastic work. It also installs the newly created NPM packages to your local project and adds them to your dependencies for clean, concise, and beautiful code! Now everyone can use your artistically crafted code as hard dependencies in their own projects!

## Usage

![Napalm](https://raw.githubusercontent.com/cheeselover/napalm/master/usage.gif)

Before installing/using this plugin, make sure you have Github and NPM accounts. Then, login to NPM from the terminal by typing the following command: `$ npm login`. Also, MAKE SURE YOU OPEN ATOM FROM THE TERMINAL. There are a lot of issues with the Atom editor on Mac OSX, so instead of opening it via the Applications folder, just run the following command in your terminal:  `$ atom`

1. Make a selection of ONE function definition and press Ctrl+Alt+n or right click and go to "Napalm -> Package".

2. With nothing selected, press Ctrl+Alt+n or right click and go to "Napalm -> Package". This will parse all function definitions in the current file.
