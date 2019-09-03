


# puff model

![](https://user-images.githubusercontent.com/6005346/64186083-3b507900-ce3c-11e9-865a-f0c0a3d2694f.gif)

This repository contains code that implements a simple (4-ODE, 4-parameter) model that describes the kinetics of the gas phase concentration of an odorant delivered using commmon laboratory techniques. 

This code accompanies this paper:

"Controlling and measuring dynamic odorant stimuli in the laboratory" by Srinivas Gorur-Shandilya, Carlotta Martelli, Mahmut Demir and Thierry Emonet. (currently under review at JEB)

## Installation 

Assuming you have git installed, you can install this code and all dependencies using:

```bash
git clone https://github.com/sg-s/puff-model
git clone https://github.com/sg-s/srinivas.gs_mtools
git clone https://github.com/sg-s/puppeteer
```

Don't forget to link these folders in your MATLAB prompt 

## Usage

Run this script to launch an interactive model where you can play with the parameters of the model to see how the shape of the pulse changes: 

```matlab
% type this in your matlab prompt
puff_explorer
```

