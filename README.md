# Solar Car Race Strategy Model

Welcome to the Solar Car Race Strategy model repository for the University of Nottingham's solar race team. This project aims to provide a comprehensive strategy model for predicting the performance and outcomes of a solar car participating in the [Bridgestone World Solar Challenge](https://www.worldsolarchallenge.org/).

## Purpose

This repository contains the MATLAB code for simulating and optimising the race strategy of a solar-powered vehicle. The model aims to predict the entire race, taking into account various factors such as solar energy input, vehicle parameters, and route specifics. The goal is to optimise the vehicle's speed, charging stops, and overall energy management to achieve the best possible race outcome.

## Description

### Key Features

- **Comprehensive Calculations**: Includes calculations for all relevant forces and uses time as the dependent variable.
- **Optimised Charging Strategy**: Focuses on charging primarily at the first checkpoint to provide flexibility in subsequent legs.
- **Variable Parameters**: Allows adjustments for real-world changes, such as varying energy usage and additional energy available.
- **Scoring Algorithm**: Evaluates every possible outcome to determine the optimal race strategy.

### Limitations and Improvements

- **Wind Speed and Direction**: Assumed to have no effect; real-time data can improve accuracy.
- **Slope Data**: Simplified; more detailed slope data from resources like Google Maps can enhance predictions.
- **Solar Model**: Does not account for cloud cover; using average cloud cover data can improve results.
- **Battery Model**: Simplified; accounting for degradation and heat effects could enhance accuracy.

### Pseudo Code Overview

The model operates in two main modes: prediction and real-time. The prediction mode uses detailed calculations to simulate the race, while the real-time mode focuses on simplified calculations for onboard implementation.

#### Predicted Model

1. Initialise with fixed and chosen input parameters.
2. Calculate solar energy input for each day.
3. Determine required average velocity, power, and energy usage for each leg.
4. Calculate total energy needed and optimize charging at checkpoints.
5. Compare outcomes to determine the best strategy.
6. Output relevant measurements.

#### Real Model

1. Initialize with fixed and chosen input parameters.
2. Calculate solar energy input for each day.
3. Calculate average velocity and energy required for each leg.
4. Display relevant information.

## Code Overview

The code consists of several main sections:

1. **Initialization**: Define fixed and variable parameters, import solar data.
2. **Solar Calculations**: Compute energy input from solar panels for each day.
3. **Velocity, Power, and Energy Calculations**: Determine speeds, power usage, and energy requirements for each leg of the race.
4. **Charging Calculations**: Calculate necessary charging times and energy based on race predictions.
5. **Score Algorithm**: Evaluate race outcomes and determine the optimal strategy based on scoring metrics.
6. **Output**: Print the best strategy based on the model's calculations.

## How to Run the Code

To run this code, you need MATLAB installed on your system. The code requires two external data files (`SolarData.txt` and `FinalDaySolar.txt`) which should be included in the `SolarData` folder.

1. **Clone the Repository**: 
   ```bash
   git clone https://github.com/yourusername/solar-car-race-strategy-model.git
   cd solar-car-race-strategy-model

2. **Run the script**:
   Open MATLAB, navigate to the repository folder, and run the main script:

   ```bash
   run(OptimalStrategy.m)

## Additional scripts

Within the `Additional Models` folder, some additional scripts have been included, which are used to determine the optimal penalty/charging rate, the battery SoC over the race and the generic solar model. The code from these scripts has been combined in the `OptimalStrategy.m` script.

## Final things...

Feel free to contribute to this project by opening issues or submitting pull requests. For any questions, contact the repository maintainer.

Happy racing!
