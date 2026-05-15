# bode_extended

An advanced MATLAB script designed to generate and plot both asymptotic and real Bode diagrams for continuous-time transfer functions. 

While standard asymptotic approximations often oversimplify system behavior near break frequencies, this tool bridges the gap by implementing precise magnitude corrections, specifically focusing on second-order underdamped systems.

---

## Technical Description

### Key Features & Improvements
*   **Asymptotic & Real Curve Overlay:** Plots the ideal asymptotic paths alongside the true magnitude and phase responses, allowing for immediate visual comparison.
*   **Second-Order Peak Correction:** Unlike basic asymptotic tools, this script accurately calculates the resonance peak for complex conjugate poles and zeros. It evaluates the damping ratio ($\zeta$) and applies the exact analytical correction ($20\log_{10}(2\zeta)$ dB) at the natural frequency ($\omega_n$).
*   **Dynamic Magnitude Scaling:** Incorporates precise decibel adjustments (such as the standard $\approx -3$ dB correction for first-order roots and the mathematically rigorous resonance scaling for second-order factors) to ensure the plotted real curves reflect true physical behavior.
*   **Comprehensive Transfer Function Parsing:** Automatically identifies system gain ($K$), integrators/differentiators at the origin, first-order poles/zeros, and underdamped second-order quadratic factors.

### How It Works
The script analyzes the numerator and denominator coefficients of a given transfer function to break it down into its fundamental dynamic components:
1.  **Gain ($K$) and Integrators/Differentiators ($s^{\pm n}$):** Establishes the initial magnitude slope ($\pm 20n$ dB/decade) and initial phase shift.
2.  **First-Order Real Roots ($s/\omega_c + 1$):** Introduces a $\pm 20$ dB/dec slope change at the corner frequency $\omega_c$, applying a $-3$ dB correction for poles ($+3$ dB for zeros) to trace the real response.
3.  **Second-Order Quadratic Factors ($s^2/\omega_n^2 + 2\zeta s/\omega_n + 1$):** Introduces a $\pm 40$ dB/dec slope change at the natural frequency $\omega_n$. The script computes the precise peak deviation based on the damping factor $\zeta$, correcting the asymptotic peak directly on the graph.

---

## Usage

To run the extended Bode plotter, pass the numerator and denominator coefficients of your transfer function to the `bode_extended` function.

### Example
For a second-order underdamped system with complex conjugate poles:

$$G(s) = \frac{4}{s^2 + 0.4s + 4}$$

```matlab
% Define your transfer function coefficients (using Control System Toolbox)
num = [4]; 
den = [1 0.4 4];
G = tf(num,den);

% Run the extended Bode plotter
bode_extended(G,both,both,'4.81'); % bode_extended(<tf>,<mag|phase|both>,<asymp|real|both>,<1dec|4.81>)
```


## Installation
1. Clone this repository to your local machine
```bash
git clone https://github.com/emulationman8810/bode_extended.git
```
2. Open MATLAB and add the repository folder to your MATLAB path, or copy the `bode_extended.m` file directly into your working directory.

---

## License & Credits
This project is an extended version based on asymptotic Bode plotting concepts. Expanded and optimized by [Your Name/Username] to incorporate real curve generation, first-order corner corrections, and second-order resonance peak scaling.


