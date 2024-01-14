<!-- Improved compatibility of back to top link: See: https://github.com/lolakkalol/6502-computer-project/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
<!--[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]-->



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/lolakkalol/6502-computer-project">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">6502 Computer Project</h3>

  <p align="center">
    A 6502-based computer project!
    <br />
    <a href="https://github.com/lolakkalol/6502-computer-project"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/lolakkalol/6502-computer-project/tree/main/programs">View Demo Programs</a>
    ·
    <a href="https://github.com/lolakkalol/6502-computer-project/issues">Report Bug</a>
    ·
    <a href="https://github.com/lolakkalol/6502-computer-project/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

This project started thanks to [Ben Eater's](https://www.youtube.com/@BenEater) video series on his 6502-based computer, which is the basis for my project and learning experience.
The project has a very simple goal of me learning low-level embedded system development on hardware and software. To achieve this learning goal, a few project goals/milestones have been set up to steer the project in a satisfactory direction.
The computer should also not be a carbon copy of Ben Eater's computer to promote self-learning and delving into documentation and learning by doing. I believe you remember things better when you fail at something and, in the end, solve the problems that made you fail.

### Goals
These goals aim to create a 6502-based computer on a single PCB that can be expanded with modules later on.
- Learn "low-level" embedded computer architecture basics
  - Both hardware and software
- Build a 6502-based computer on a PCB which shall:
  - Be expandable, meaning you can add modules to it later (Some kind of expansion bus)
  - Output text console to a computer screen
  - Handle mouse and keyboard (USB/PS2 either or both)
  - Have serial communication capability
  - Load programs over serial into RAM (Maybe some kind of bootloader?)
  - Flash the program flash over some protocol
  - Some kind of operating system
- Try and avoid scope creep
- HAVE FUN!

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With
These are the currently used programs and frameworks used for building the project, for both software and hardware.

- [CA65, LD65](https://cc65.github.io/) for assembling, linking and relocating the code.
- [KiCad](https://www.kicad.org/) for designing the computer and its physical layout.
- [GNU Make](https://www.gnu.org/software/make/) for automating the build tasks of CC65 and LD65.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple example steps.

### Prerequisites

* CC65 (Windows/Linux)
Download and install the cross-development package [CC65](https://github.com/cc65/cc65) (available for both Windows and Linux).

* GNU Utils (Windows)
Download `GNU make` and `CoreUtils` from https://gnuwin32.sourceforge.net/packages.html and add them to your path.

### Installation (Software)

1. Clone the repository
2. In `6502-computer-project/programs/<program name>/` simple run make
3. Flash the EEPROM using your choice of programmer

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

This project currently has three different areas: Schematics and KiCad symbols, hardware debugger, and programs, each will be explained below.

### Schematics and KiCad symbols
Found in the folder `6502-and-friends` and `6502-schematic`, here the schematic over the computer, the custom symbols and PCB design can be found.

### Hardware debugger
Found, at the moment, in the folder `bus-sniffer`; this is simply a program for an Arduino Mega2560 sniffing and printing to the console the: Address bus, data buss and control bus.
It can also supply its own clock, which can be halted at the press of a button and send single clock pulses to support hardware debugging.

### Programs
Found in the folder `Programs`, contain all the currently constructed programs and a template for creating a new program.
Each program comes with its own make file specifying how it is to be built together with throughout commenting. 
All programs are written in 6502 assembly and most is created according to the specified template.

The template contain the following:
- `main.asm` Here is the main code.
- `lib.asm` Here, the supporting code should be put, such as sub-routines, following the example sub-routines structure.
- `start.asm` holds the start-up code and is already written in the template; it is responsible for initializing memory segments at startup.
- `makefile` Specifies how to build and link `main.asm`, `lib.asm` and `start.asm`.
- `target.cfg` Specifies the address space, segments, and their location in memory for the linker to us.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap
There are currently two main roadmaps, one for a Pi estimation program used to get familiar with the 6502 and another for the actual computer project.
For the Pi estimation program the computer seen in the current KiCad schematic is used.

### Pi estimation
- [ ] IEEE 754 Floating point arithmetic
  - [X] Addition/Subtraction
  - [ ] Multiplication
  - [ ] Division
  - [ ] (To be expanded upon if necessary)
- [ ] LCD printing
- [ ] Convert Floating point numbers to decimal
- [ ] Pi estimation algorithm
  - [ ] (To be expanded upon)

### 6502-based computer
- [ ] Decide desirable features
- [ ] Design schematic
  - [ ] Research chips needed
  - [ ] Plan address space
  - [ ] Create KiCad symbols for chips
  - [ ] Route connections between chips
  - [ ] (To be expanded upon)
- [ ] Operating system?

See the [open issues](https://github.com/lolakkalol/6502-computer-project/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Micro documentation
Here a very small condenced documentation can be found only used as a quick reference.
The code is often commented so do not forget to look there.

### Memory map
![image](https://github.com/lolakkalol/6502-computer-project/assets/23548892/c80aab7e-f1ac-4e97-982a-5b658e6c99c1)

### Floating point routines
The floating point routines are all commented on and explained in the code but have also been planned before implementation using a high-level flowchart in draw.io found below.

[Flowchart](https://drive.google.com/file/d/1zk0GJeMiMwG2__90PIV5DE1KcaoCTDiV/view?usp=sharing)

<!-- CONTRIBUTING -->
<!--## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>-->



<!-- LICENSE -->
<!--## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>-->



<!-- CONTACT -->
## Contact

Alexander Stenlund -  alexander.stenlund@telia.com

Project Link: [https://github.com/lolakkalol/6502-computer-project](https://github.com/lolakkalol/6502-computer-project)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [6502 Primer](https://wilsonminesco.com/6502primer/)
* [6502 forum](http://forum.6502.org/viewtopic.php?t=1064&start=105)
* [65SIB](http://forum.6502.org/viewtopic.php?t=1064&start=105)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/lolakkalol/6502-computer-project.svg?style=for-the-badge
[contributors-url]: https://github.com/lolakkalol/6502-computer-project/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/lolakkalol/6502-computer-project.svg?style=for-the-badge
[forks-url]: https://github.com/lolakkalol/6502-computer-project/network/members
[stars-shield]: https://img.shields.io/github/stars/lolakkalol/6502-computer-project.svg?style=for-the-badge
[stars-url]: https://github.com/lolakkalol/6502-computer-project/stargazers
[issues-shield]: https://img.shields.io/github/issues/lolakkalol/6502-computer-project.svg?style=for-the-badge
[issues-url]: https://github.com/lolakkalol/6502-computer-project/issues
[license-shield]: https://img.shields.io/github/license/lolakkalol/6502-computer-project.svg?style=for-the-badge
[license-url]: https://github.com/lolakkalol/6502-computer-project/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
